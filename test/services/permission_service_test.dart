import 'package:customer/services/oem_settings_channel.dart';
import 'package:customer/services/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// 权限模型的约定。
///
/// 真实的权限申请要跳系统设置页，单测覆盖不到，那部分是 2A 验收第 2、3 项，
/// 只能在设备上验。这里锁住的是「哪些权限可查、顺序如何、状态怎么映射」
/// 这些不该被随手改掉的约定。
void main() {
  // MethodChannel 要拿 ServicesBinding.instance，不初始化会直接抛
  // 「Binding has not yet been initialized」，而不是我们想验的 MissingPluginException。
  TestWidgetsFlutterBinding.ensureInitialized();

  group('权限顺序', () {
    test('通知排第一', () {
      // 没有通知权限，闹钟再准也弹不出来，所以它必须最先引导。
      expect(ReminderPermission.values.first, ReminderPermission.notification);
    });

    test('厂商私有的两项排在最后', () {
      // 它们必然在 AOSP 上失败，放前面会让引导一开始就卡住。
      expect(
        ReminderPermission.values.last,
        ReminderPermission.backgroundPopup,
      );
      expect(
        ReminderPermission.values[ReminderPermission.values.length - 2],
        ReminderPermission.autoStart,
      );
    });

    test('精确闹钟排在电池优化之前', () {
      final values = ReminderPermission.values;
      expect(
        values.indexOf(ReminderPermission.exactAlarm),
        lessThan(values.indexOf(ReminderPermission.batteryOptimization)),
      );
    });
  });

  group('厂商权限标记', () {
    test('只有自启动与后台弹出界面是厂商私有', () {
      final vendor = ReminderPermission.values
          .where((e) => e.isVendorSpecific)
          .toSet();

      expect(vendor, {
        ReminderPermission.autoStart,
        ReminderPermission.backgroundPopup,
      });
    });

    test('每项都有标题与说明文案', () {
      for (final permission in ReminderPermission.values) {
        expect(permission.title, isNotEmpty);
        expect(permission.why, isNotEmpty);
      }
    });
  });

  group('厂商权限状态查询', () {
    test('厂商权限恒为 unknown', () async {
      // 这两项没有任何系统 API 可查，返回 granted 会让引导页显示成
      // 「已开启」，掩盖真实情况。
      final service = PermissionService();

      expect(
        await service.check(ReminderPermission.autoStart),
        ReminderPermissionState.unknown,
      );
      expect(
        await service.check(ReminderPermission.backgroundPopup),
        ReminderPermissionState.unknown,
      );
    });
  });

  group('跳转结果映射', () {
    test('原生返回值能正确映射', () {
      expect(OemJumpResult.fromNative('oem'), OemJumpResult.oem);
      expect(OemJumpResult.fromNative('app_details'), OemJumpResult.appDetails);
      expect(OemJumpResult.fromNative('failed'), OemJumpResult.failed);
    });

    test('未知值与 null 归为 failed', () {
      // 宁可当成失败去展示图文步骤，也不要当成成功让用户以为已经开好了。
      expect(OemJumpResult.fromNative(null), OemJumpResult.failed);
      expect(OemJumpResult.fromNative('whatever'), OemJumpResult.failed);
    });
  });

  group('通道不可用时的兜底', () {
    test('非 Android 环境跳转返回 failed 而不是抛异常', () async {
      // 测试环境没有注册原生通道，会抛 MissingPluginException。
      // 引导页不该因此崩掉。
      const channel = OemSettingsChannel();
      expect(await channel.openAutoStartSettings(), OemJumpResult.failed);
      expect(await channel.openAppDetails(), OemJumpResult.failed);
    });
  });
}
