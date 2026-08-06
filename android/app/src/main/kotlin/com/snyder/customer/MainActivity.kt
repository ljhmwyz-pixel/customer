package com.snyder.customer

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var attachmentPickerBridge: AttachmentPickerBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        attachmentPickerBridge = AttachmentPickerBridge(
            activity = this,
            launchPickerIntent = { intent ->
                startActivityForResult(intent, ATTACHMENT_PICKER_REQUEST_CODE)
            },
        )
        attachmentPickerBridge.attach(flutterEngine.dartExecutor.binaryMessenger)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAutoStartSettings" ->
                    result.success(OemSettingsBridge.openAutoStartSettings(this))

                "openBackgroundPopupSettings" ->
                    result.success(OemSettingsBridge.openBackgroundPopupSettings(this))

                "openAppDetails" ->
                    result.success(OemSettingsBridge.openAppDetails(this))

                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Android Activity result callback")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == ATTACHMENT_PICKER_REQUEST_CODE &&
            ::attachmentPickerBridge.isInitialized
        ) {
            attachmentPickerBridge.onPickerResult(resultCode, data?.data)
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (::attachmentPickerBridge.isInitialized) {
            attachmentPickerBridge.dispose()
        }
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        /** 与 lib/services/oem_settings_channel.dart 中的常量必须一致。 */
        private const val CHANNEL = "com.snyder.customer/oem_settings"
        private const val ATTACHMENT_PICKER_REQUEST_CODE = 41031
    }
}
