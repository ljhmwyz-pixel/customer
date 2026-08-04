import '../data/database.dart';

/// 提醒调度的抽象接口。
///
/// 刻意留这层抽象：ColorOS 对后台闹钟的管控很激进，真机验证可能发现
/// 首选方案（setAlarmClock）被压制。届时只需换一个实现，
/// 而不必翻遍散落各处的调用点。
///
/// 降级顺序见 docs/phase2/PLAN.md 第 4.2 节：
/// 1. alarmClock（当前实现）
/// 2. exactAllowWhileIdle
/// 3. android_alarm_manager_plus 直接调 AlarmManager
/// 4. 前台服务常驻 + 自建轮询（明显影响体验，最后手段）
abstract interface class ReminderScheduler {
  /// 初始化通知渠道与时区。必须在任何排期前调用一次。
  Future<void> init();

  /// 为一条计划排闹钟。已存在同 id 的排期时覆盖。
  Future<void> scheduleForPlan(FollowPlanRow plan, {required String customerName});

  /// 取消一条计划的闹钟。
  Future<void> cancelForPlan(int planId);

  /// 全量重建：清掉现有排期，按数据库里的未来计划重新排。
  ///
  /// 开机、覆盖安装、时区变更后调用。返回重建的条数。
  Future<int> rescheduleAll();

  /// 当前已排期的通知 id 列表。用于验证与排障。
  Future<List<int>> pendingIds();
}
