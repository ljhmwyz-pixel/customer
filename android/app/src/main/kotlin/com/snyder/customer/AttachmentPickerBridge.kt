package com.snyder.customer

import android.app.Activity
import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.UUID
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

enum class AttachmentPickerOutcome {
    SELECTED,
    CANCELLED,
    INVALID,
}

fun attachmentPickerOutcome(resultCode: Int, hasUri: Boolean): AttachmentPickerOutcome =
    when {
        resultCode == Activity.RESULT_CANCELED -> AttachmentPickerOutcome.CANCELLED
        resultCode == Activity.RESULT_OK && hasUri -> AttachmentPickerOutcome.SELECTED
        else -> AttachmentPickerOutcome.INVALID
    }

class AttachmentPickerBridge(
    private val activity: Activity,
    private val launchPickerIntent: (Intent) -> Unit,
    private val executor: ExecutorService = Executors.newSingleThreadExecutor(),
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var channel: MethodChannel? = null
    private var pendingResult: MethodChannel.Result? = null

    fun attach(messenger: BinaryMessenger) {
        channel?.setMethodCallHandler(null)
        channel = MethodChannel(messenger, CHANNEL).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    PICK_FILE_METHOD -> launchPicker(result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun onPickerResult(resultCode: Int, uri: Uri?) {
        val result = pendingResult ?: return
        when (attachmentPickerOutcome(resultCode, uri != null)) {
            AttachmentPickerOutcome.CANCELLED -> completePending { it.success(null) }
            AttachmentPickerOutcome.INVALID -> completePending {
                it.error("picker_invalid_result", "系统文件选择器未返回有效文件", null)
            }

            AttachmentPickerOutcome.SELECTED -> copyUriToCache(uri!!, result)
        }
    }

    fun dispose() {
        channel?.setMethodCallHandler(null)
        channel = null
        completePending {
            it.error("picker_disposed", "附件选择器已关闭", null)
        }
        executor.shutdown()
    }

    private fun launchPicker(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("picker_busy", "已有附件选择请求正在进行", null)
            return
        }

        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            type = "*/*"
        }
        try {
            launchPickerIntent(intent)
        } catch (error: RuntimeException) {
            completePending {
                it.error("picker_unavailable", error.message ?: "无法打开系统文件选择器", null)
            }
        }
    }

    private fun copyUriToCache(uri: Uri, expectedResult: MethodChannel.Result) {
        executor.execute {
            try {
                val metadata = copyToPrivateCache(activity.contentResolver, uri)
                mainHandler.post {
                    completePending(expectedResult) { it.success(metadata) }
                }
            } catch (error: Exception) {
                mainHandler.post {
                    completePending(expectedResult) {
                        it.error("file_read_failed", error.message ?: "无法读取所选文件", null)
                    }
                }
            }
        }
    }

    private fun copyToPrivateCache(
        contentResolver: ContentResolver,
        uri: Uri,
    ): Map<String, Any> {
        val originalName = queryDisplayName(contentResolver, uri)
            ?: "attachment-${UUID.randomUUID()}"
        val cacheDirectory = File(activity.cacheDir, CACHE_DIRECTORY).apply {
            check(exists() || mkdirs()) { "无法创建附件临时目录" }
        }
        val destination = File(
            cacheDirectory,
            "${UUID.randomUUID()}${safeExtension(originalName)}",
        )

        try {
            val input = contentResolver.openInputStream(uri)
                ?: error("系统未提供所选文件的读取流")
            input.use { source ->
                FileOutputStream(destination).use { output -> source.copyTo(output) }
            }
            return mapOf(
                "sourcePath" to destination.absolutePath,
                "originalName" to originalName,
                "mimeType" to (contentResolver.getType(uri) ?: DEFAULT_MIME_TYPE),
                "sizeBytes" to destination.length(),
            )
        } catch (error: Exception) {
            destination.delete()
            throw error
        }
    }

    private fun queryDisplayName(contentResolver: ContentResolver, uri: Uri): String? =
        contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            val nameColumn = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (nameColumn >= 0 && cursor.moveToFirst()) cursor.getString(nameColumn) else null
        }?.takeIf { it.isNotBlank() }

    private fun safeExtension(originalName: String): String {
        val extension = originalName.substringAfterLast('.', missingDelimiterValue = "")
        return if (extension.matches(SAFE_EXTENSION)) ".${extension.lowercase()}" else ""
    }

    private fun completePending(callback: (MethodChannel.Result) -> Unit) {
        val result = pendingResult ?: return
        pendingResult = null
        callback(result)
    }

    private fun completePending(
        expectedResult: MethodChannel.Result,
        callback: (MethodChannel.Result) -> Unit,
    ) {
        if (pendingResult !== expectedResult) return
        pendingResult = null
        callback(expectedResult)
    }

    companion object {
        private const val CHANNEL = "com.snyder.customer/attachments"
        private const val PICK_FILE_METHOD = "pickFile"
        private const val CACHE_DIRECTORY = "attachment_sources"
        private const val DEFAULT_MIME_TYPE = "application/octet-stream"
        private val SAFE_EXTENSION = Regex("[A-Za-z0-9]{1,10}")
    }
}
