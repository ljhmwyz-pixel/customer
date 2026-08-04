import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database_provider.dart';
import 'app_prefs.dart';
import 'notification_service.dart';
import 'permission_service.dart';
import 'reminder_scheduler.dart';

final appPrefsProvider = Provider<AppPrefs>((ref) => AppPrefs());

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(prefs: ref.watch(appPrefsProvider)),
);

/// 提醒调度器。
///
/// 暴露成接口类型而不是 NotificationService：真机验证若发现 setAlarmClock
/// 被 ColorOS 压制，换实现只改这一处，页面代码不用动。
/// 降级顺序见 docs/phase2/PLAN.md 第 4.2 节。
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => NotificationService(db: ref.watch(databaseProvider)),
);

/// 全部权限的当前状态。
///
/// 从系统设置页返回后状态才会变，而跳转本身不产生任何回调，
/// 所以由页面在 resume 时手动 invalidate 这个 provider 来刷新。
final permissionStatesProvider = FutureProvider((ref) {
  return ref.watch(permissionServiceProvider).checkAll();
});
