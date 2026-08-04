import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 厂商私有设置页跳转的结果。
enum OemJumpResult {
  /// 跳中了厂商的专用设置页
  oem,

  /// 厂商页打不开，已回退到系统「应用详情」页
  appDetails,

  /// 连应用详情页都没打开，只能展示纯文字步骤
  failed;

  static OemJumpResult fromNative(String? raw) => switch (raw) {
    'oem' => OemJumpResult.oem,
    'app_details' => OemJumpResult.appDetails,
    _ => OemJumpResult.failed,
  };
}

/// 厂商私有权限设置页的跳转通道。
///
/// 自启动与后台弹出界面这两项权限没有公开 API，只能靠未文档化的组件名跳转，
/// 原生侧实现见 android/.../OemSettingsBridge.kt。
///
/// 在 AOSP 模拟器上必然拿到 [OemJumpResult.appDetails]，这是预期结果，
/// 用来验证阶段 2A 验收第 4 项的回退路径。
class OemSettingsChannel {
  const OemSettingsChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  /// 与 MainActivity.kt 中的常量必须一致。
  static const String channelName = 'com.snyder.customer/oem_settings';

  final MethodChannel _channel;

  Future<OemJumpResult> openAutoStartSettings() =>
      _invoke('openAutoStartSettings');

  Future<OemJumpResult> openBackgroundPopupSettings() =>
      _invoke('openBackgroundPopupSettings');

  Future<OemJumpResult> openAppDetails() => _invoke('openAppDetails');

  Future<OemJumpResult> _invoke(String method) async {
    try {
      final raw = await _channel.invokeMethod<String>(method);
      return OemJumpResult.fromNative(raw);
    } on MissingPluginException {
      // 通道未注册。测试环境或非 Android 平台会走到这里，不该让引导页崩掉。
      debugPrint('厂商设置通道不可用：$method');
      return OemJumpResult.failed;
    } on PlatformException catch (e) {
      debugPrint('厂商设置跳转失败：$method / ${e.message}');
      return OemJumpResult.failed;
    }
  }
}
