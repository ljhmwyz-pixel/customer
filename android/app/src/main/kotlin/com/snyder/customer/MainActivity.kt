package com.snyder.customer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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

    companion object {
        /** 与 lib/services/oem_settings_channel.dart 中的常量必须一致。 */
        private const val CHANNEL = "com.snyder.customer/oem_settings"
    }
}
