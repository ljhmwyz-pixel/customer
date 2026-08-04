import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_prefs.dart';
import 'oem_settings_channel.dart';

/// 提醒链路需要的五项权限。
///
/// 顺序即引导顺序，按依赖关系排：没有通知权限，闹钟再准也弹不出来，
/// 所以通知放第一位。厂商私有的两项放最后，它们失败不影响前三项的效果。
enum ReminderPermission {
  /// 通知权限。Android 13+ 需运行时申请。
  notification,

  /// 精确闹钟。Android 14+ 默认拒绝，跳系统设置页而非弹对话框。
  exactAlarm,

  /// 电池优化白名单。不加白名单，Doze 会把提醒推迟到维护窗口。
  batteryOptimization,

  /// 自启动。ColorOS 私有，无 API 可查询状态。
  autoStart,

  /// 后台弹出界面。ColorOS 私有，无 API 可查询状态。
  backgroundPopup;

  String get title => switch (this) {
    ReminderPermission.notification => '通知权限',
    ReminderPermission.exactAlarm => '精确闹钟',
    ReminderPermission.batteryOptimization => '电池优化白名单',
    ReminderPermission.autoStart => '自启动',
    ReminderPermission.backgroundPopup => '后台弹出界面',
  };

  String get why => switch (this) {
    ReminderPermission.notification => '没有它，到点的提醒不会出现在通知栏。',
    ReminderPermission.exactAlarm => '没有它，系统会把提醒推迟到不确定的时间。',
    ReminderPermission.batteryOptimization => '没有它，息屏久了提醒会被省电策略压住。',
    ReminderPermission.autoStart => '没有它，重启手机后提醒不会自动恢复。',
    ReminderPermission.backgroundPopup => '没有它，应用未打开时提醒可能弹不出来。',
  };

  /// 是否为厂商私有权限。
  ///
  /// 私有权限拿不到状态，只能引导用户自己确认，UI 上要区别对待。
  bool get isVendorSpecific =>
      this == ReminderPermission.autoStart ||
      this == ReminderPermission.backgroundPopup;
}

/// 权限状态。
enum ReminderPermissionState {
  /// 已授予
  granted,

  /// 未授予，可继续申请
  denied,

  /// 系统层面已永久拒绝，只能去设置页手动开
  permanentlyDenied,

  /// 无法查询。厂商私有权限恒为此值。
  unknown;

  bool get isGranted => this == ReminderPermissionState.granted;
}

/// 权限查询与申请。
///
/// 只做权限本身，不含任何 UI。引导页在 features/reminders/ 下，
/// 这样后续要把引导入口挪到设置页时不需要动这里的逻辑。
class PermissionService {
  PermissionService({AppPrefs? prefs, OemSettingsChannel? oem})
    : _prefs = prefs ?? AppPrefs(),
      _oem = oem ?? const OemSettingsChannel();

  final AppPrefs _prefs;
  final OemSettingsChannel _oem;

  /// 「引导流程已走完一遍」标记的键。
  static const String _onboardedKey = 'reminder_permission_onboarded';

  /// 用户手动确认过厂商权限的键前缀。
  static const String _vendorConfirmedPrefix = 'vendor_permission_confirmed_';

  /// 查询状态。厂商私有的两项无法查询，直接返回 unknown。
  Future<ReminderPermissionState> check(ReminderPermission permission) async {
    final handle = _handleOf(permission);
    if (handle == null) return ReminderPermissionState.unknown;

    return _mapStatus(await handle.status);
  }

  /// 一次取全部状态，引导页与设置页都用它渲染列表。
  Future<Map<ReminderPermission, ReminderPermissionState>> checkAll() async {
    final result = <ReminderPermission, ReminderPermissionState>{};
    for (final permission in ReminderPermission.values) {
      result[permission] = await check(permission);
    }
    return result;
  }

  /// 申请一项权限。
  ///
  /// 三项 AOSP 权限走 permission_handler；精确闹钟与电池优化实际是跳系统设置页，
  /// 用户在页面上操作完返回，状态才会变，所以调用方需要在返回后重新 [check]。
  Future<ReminderPermissionState> request(ReminderPermission permission) async {
    final handle = _handleOf(permission);
    if (handle == null) return ReminderPermissionState.unknown;

    // 已经永久拒绝时再调 request() 不会弹窗，会直接返回拒绝，
    // 表现为「点了按钮没反应」。这种情况直接送去设置页。
    final current = await handle.status;
    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return ReminderPermissionState.permanentlyDenied;
    }

    return _mapStatus(await handle.request());
  }

  /// 跳厂商私有设置页。返回实际走到了哪一层，供 UI 决定提示文案。
  Future<OemJumpResult> openVendorSettings(ReminderPermission permission) {
    return switch (permission) {
      ReminderPermission.autoStart => _oem.openAutoStartSettings(),
      ReminderPermission.backgroundPopup => _oem.openBackgroundPopupSettings(),
      // 非厂商权限不该走到这里，兜底跳应用详情页而不是抛异常。
      _ => _oem.openAppDetails(),
    };
  }

  /// 记录用户自称已开启某项厂商权限。
  ///
  /// 这两项查不到真实状态，只能存用户的说法。它不代表权限真的开了，
  /// 唯一作用是不再反复引导。真实效果只能靠提醒是否触发来判断。
  Future<void> markVendorConfirmed(ReminderPermission permission) =>
      _prefs.setBool('$_vendorConfirmedPrefix${permission.name}', true);

  Future<bool> isVendorConfirmed(ReminderPermission permission) =>
      _prefs.getBool('$_vendorConfirmedPrefix${permission.name}');

  /// 引导流程是否已走完一遍。
  ///
  /// 走完就不再自动弹，避免每次启动都被拦一下。
  /// 用户后续想调整，从设置页的「提醒权限」进。
  Future<bool> isOnboarded() => _prefs.getBool(_onboardedKey);

  Future<void> markOnboarded() => _prefs.setBool(_onboardedKey, true);

  /// 三项 AOSP 权限是否都已授予。决定提醒能否可靠工作的底线。
  Future<bool> hasCorePermissions() async {
    for (final permission in const [
      ReminderPermission.notification,
      ReminderPermission.exactAlarm,
      ReminderPermission.batteryOptimization,
    ]) {
      if (!(await check(permission)).isGranted) return false;
    }
    return true;
  }

  Permission? _handleOf(ReminderPermission permission) => switch (permission) {
    ReminderPermission.notification => Permission.notification,
    ReminderPermission.exactAlarm => Permission.scheduleExactAlarm,
    ReminderPermission.batteryOptimization =>
      Permission.ignoreBatteryOptimizations,
    // 厂商私有权限没有对应的 Permission，只能跳设置页。
    ReminderPermission.autoStart => null,
    ReminderPermission.backgroundPopup => null,
  };

  static ReminderPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return ReminderPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return ReminderPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) {
      // 受设备策略限制，用户自己改不了。当永久拒绝处理，至少会引导去设置页看看。
      debugPrint('权限受限，无法通过申请获得');
      return ReminderPermissionState.permanentlyDenied;
    }
    return ReminderPermissionState.denied;
  }
}
