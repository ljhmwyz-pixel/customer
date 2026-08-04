package com.snyder.customer

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

/**
 * 跳转厂商私有权限设置页。
 *
 * 自启动与「后台弹出界面」这两项没有任何公开 API，只能靠厂商未文档化的
 * Activity 组件名去跳。这些组件名随 ROM 版本变化，且随时可能被改掉或加上
 * 签名校验，所以每一次跳转都必须假定它会失败。
 *
 * 三层策略：
 * 1. 按候选列表依次试厂商组件名
 * 2. 全部失败则退到系统「应用详情」页（AOSP 保证存在）
 * 3. 连应用详情页都打不开才返回 false，由 Flutter 侧展示纯图文步骤
 *
 * 这样在 AOSP 模拟器上会稳定走到第 2 层，正好用来验证阶段 2A 的回退路径。
 */
object OemSettingsBridge {

    /** 跳转结果。Flutter 侧据此决定提示文案。 */
    const val RESULT_OEM = "oem"
    const val RESULT_FALLBACK_APP_DETAILS = "app_details"
    const val RESULT_FAILED = "failed"

    /**
     * 自启动管理页候选。
     *
     * ColorOS / OPPO 放在 com.coloros.safecenter 与较新的 com.oplus.battery 下。
     * 一加 13 是 ColorOS 15，实际命中哪个要等真机验证（阶段 2B），
     * 所以这里把已知的几个都列上，逐个试。
     */
    private val autoStartCandidates = listOf(
        // ColorOS 较新版本（OPLUS 品牌合并后）
        ComponentName(
            "com.oplus.safecenter",
            "com.oplus.safecenter.permission.startup.StartupAppListActivity"
        ),
        ComponentName(
            "com.oplus.battery",
            "com.oplus.powermanager.fuelgaue.PowerUsageModelActivity"
        ),
        // ColorOS 早期版本
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.permission.startup.StartupAppListActivity"
        ),
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.startupapp.StartupAppListActivity"
        ),
        // 氢/氧 OS 时期的一加
        ComponentName(
            "com.oneplus.security",
            "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"
        )
    )

    /**
     * 「后台弹出界面」权限页候选。
     *
     * ColorOS 把它归在应用权限管理里，通常没有直达入口，
     * 多数情况只能落到应用详情页由用户自己点进「权限」。
     */
    private val backgroundPopupCandidates = listOf(
        ComponentName(
            "com.oplus.notificationmanager",
            "com.oplus.notificationmanager.MainActivity"
        ),
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.permission.PermissionManagerActivity"
        ),
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.permission.floatwindow.FloatWindowListActivity"
        )
    )

    fun openAutoStartSettings(context: Context): String =
        openFirstAvailable(context, autoStartCandidates)

    fun openBackgroundPopupSettings(context: Context): String =
        openFirstAvailable(context, backgroundPopupCandidates)

    fun openAppDetails(context: Context): String =
        if (startAppDetails(context)) RESULT_FALLBACK_APP_DETAILS else RESULT_FAILED

    private fun openFirstAvailable(
        context: Context,
        candidates: List<ComponentName>
    ): String {
        for (component in candidates) {
            val intent = Intent().apply {
                this.component = component
                // 从 Flutter Activity 启动，正常不需要 NEW_TASK，
                // 但部分厂商设置页声明了独立 taskAffinity，加上更稳。
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            // resolveActivity 先探一次：直接 startActivity 抛异常也能捕获，
            // 但部分 ROM 会先弹一个系统错误 toast 再抛，用户会看到闪一下的报错。
            if (context.packageManager.resolveActivity(intent, 0) == null) continue
            try {
                context.startActivity(intent)
                return RESULT_OEM
            } catch (_: ActivityNotFoundException) {
                // 组件存在但不可导出，继续试下一个
            } catch (_: SecurityException) {
                // ColorOS 对部分设置页加了调用方签名校验
            }
        }
        return openAppDetails(context)
    }

    private fun startAppDetails(context: Context): Boolean {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", context.packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return try {
            context.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }
}
