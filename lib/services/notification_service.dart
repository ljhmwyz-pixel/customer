import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import 'notification_payload.dart';
import 'reminder_scheduler.dart';

/// 基于 flutter_local_notifications 的提醒调度实现。
///
/// 调度模式选 [AndroidScheduleMode.alarmClock]：底层走 setAlarmClock()，
/// 系统把它当用户设置的闹铃对待，Doze 与省电策略对它的压制最弱。
/// 这是对抗 ColorOS 后台管控最有力的一档，详见 docs/phase2/PLAN.md 第 2.3 节。
class NotificationService implements ReminderScheduler {
  NotificationService({
    required this._db,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  /// 提醒渠道 id。改动会导致用户此前的渠道设置（声音、震动）失效。
  static const String channelId = 'follow_reminders';
  static const String channelName = '跟进提醒';
  static const String channelDescription = '客户跟进计划到期提醒';

  /// 记账闹钟 id 的偏移量。
  ///
  /// 记账闹钟与通知走两套完全独立的 id 空间（AlarmManager 与 NotificationManager），
  /// 本来不会冲突。但加个偏移量能让 adb dumpsys alarm 的输出一眼看出哪条是记账闹钟，
  /// 排查「提醒响了但没记录」时省事。
  static const int notifiedMarkIdOffset = 1000000;

  /// 点击通知时对外通报的 payload。由 app 层监听后执行跳转。
  ///
  /// 用 ValueNotifier 而不是回调：应用冷启动时通知可能比路由更早就绪，
  /// 存成状态可以让 app 层在自己准备好之后再读。
  static final ValueNotifier<NotificationPayload?> tappedPayload =
      ValueNotifier<NotificationPayload?>(null);

  @override
  Future<void> init() async {
    if (_initialized) return;

    await _initTimeZone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onForegroundResponse,
      // 应用未启动时点通知按钮，回调在独立 isolate 执行。
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );

    await _createChannel();

    // 记账闹钟依赖它，且必须在任何 oneShotAt 之前调一次。
    await AndroidAlarmManager.initialize();

    _initialized = true;
  }

  /// 初始化时区库并设为设备当前时区。
  ///
  /// zonedSchedule 要 TZDateTime，拿不到正确的本地时区就会把提醒排到错误的时刻。
  /// 不能依赖 DateTime.now() 的隐式本地时区：库里存的是 UTC 毫秒，
  /// 跨时区或夏令时切换时隐式转换会偏。
  ///
  /// 用当前 UTC 偏移量去 timezone 库里反查位置，而不是用
  /// `DateTime.now().timeZoneName`：后者在 Android 上返回 `CST` 这类缩写，
  /// `tz.getLocation()` 认不了这种写法。这样也免掉了引入 flutter_timezone 插件。
  Future<void> _initTimeZone() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(resolveLocalLocation());
  }

  /// 建通知渠道。
  ///
  /// importance 必须是 max：低于此值锁屏不弹横幅，
  /// 验收第 2 项「锁屏状态下准时弹出通知」会过不了。
  /// 渠道一旦创建，importance 无法通过代码再改，只能由用户在系统设置里调,
  /// 所以初次就要设对。
  Future<void> _createChannel() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async {
    await init();

    final planAt = DateTime.fromMillisecondsSinceEpoch(
      plan.planAt,
      isUtc: true,
    );
    final scheduled = tz.TZDateTime.from(planAt, tz.local);

    // 已经过去的时间点不排。系统对过去时刻的行为不一致：
    // 有的立即触发，有的静默丢弃，都不是我们想要的。
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('计划 ${plan.id} 的时间已过，跳过排期：$scheduled');
      return;
    }

    final payload = NotificationPayload(
      planId: plan.id,
      customerId: plan.customerId,
    );

    await _plugin.zonedSchedule(
      id: plan.id,
      title: customerName,
      body: plan.title,
      scheduledDate: scheduled,
      payload: payload.encode(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          // 客户名称和跟进动作属于业务数据，锁屏默认隐藏详细内容。
          visibility: NotificationVisibility.private,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              NotificationActions.complete,
              '已完成',
              // 点完按钮就收起通知。
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              NotificationActions.postpone,
              '推迟一天',
              cancelNotification: true,
            ),
          ],
        ),
      ),
    );

    await _scheduleNotifiedMark(plan.id, scheduled);
  }

  /// 排一个与通知同时刻的记账闹钟。
  ///
  /// 为什么需要它：flutter_local_notifications 的 zonedSchedule 到点后，
  /// 通知完全由原生侧弹出，Dart 侧不会被唤醒，也没有任何「已投递」回调。
  /// 所以如果只用它，follow_plans.notified_at 永远是空的，
  /// 验收第 9 项要的「实际触发时间」就无从记录。
  ///
  /// alarmClock 与通知同档，两者被系统延迟的程度接近，记下的时刻才有参考价值。
  /// 即便有偏差也不影响提醒本身：这条闹钟只写数据库，不负责弹通知，
  /// 它失败最多是日志缺一条，用户该看到的提醒照旧。
  Future<void> _scheduleNotifiedMark(int planId, tz.TZDateTime at) async {
    final ok = await AndroidAlarmManager.oneShotAt(
      at,
      notifiedMarkIdOffset + planId,
      markPlanNotified,
      exact: true,
      wakeup: true,
      alarmClock: true,
      // 开机后由 rescheduleAll() 统一重排，不交给插件自己持久化：
      // 插件的重排走它自己的存储，与我们的数据库可能不一致。
      rescheduleOnReboot: false,
      params: <String, dynamic>{'planId': planId},
    );
    if (!ok) {
      debugPrint('计划 $planId 的记账闹钟排期失败，触发时间将无法记录');
    }
  }

  @override
  Future<void> cancelForPlan(int planId) async {
    await init();
    await _plugin.cancel(id: planId);
    await AndroidAlarmManager.cancel(notifiedMarkIdOffset + planId);
  }

  @override
  Future<int> rescheduleAll() async {
    await init();

    // 先全清再重排。逐条比对现有排期与数据库的差异更省事件数，
    // 但状态机会复杂很多，而这个操作只在开机、覆盖安装、时区变更时执行，
    // 频率极低，不值得为省几次系统调用引入复杂度。
    //
    // 记账闹钟没有 cancelAll，只能按 id 逐个取消，所以要先拿到现有排期列表
    // 再清通知。顺序反了就拿不到 id 了。
    final stale = await pendingIds();
    await _plugin.cancelAll();
    for (final id in stale) {
      await AndroidAlarmManager.cancel(notifiedMarkIdOffset + id);
    }

    final now = DateTime.now();
    final plans = await _db.planDao.listUpcoming(now: now);

    var count = 0;
    for (final plan in plans) {
      final customer = await _db.customerDao.findById(plan.customerId);
      if (customer == null) continue;

      await scheduleForPlan(plan, customerName: customer.name);
      count++;
    }

    debugPrint('重建提醒完成，共 $count 条');
    return count;
  }

  @override
  Future<List<int>> pendingIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((e) => e.id).toList()..sort();
  }

  /// 应用在前台或后台但进程存活时的通知响应。
  static void _onForegroundResponse(NotificationResponse response) {
    final payload = NotificationPayload.decode(response.payload);
    if (payload == null) return;

    // 按钮动作交给统一处理器，与后台 isolate 走同一套逻辑，避免两份实现走偏。
    if (response.actionId != null) {
      handleNotificationAction(actionId: response.actionId!, payload: payload);
      return;
    }

    // 点通知体本身：通报给 app 层做跳转。
    tappedPayload.value = payload;
  }
}

/// 按当前 UTC 偏移量反查 timezone 库里的位置。
///
/// 做成顶层函数便于单测：时区解析错了会让所有提醒偏到错误时刻，
/// 是这条链路上最需要独立验证的一环。
///
/// 先试常用位置再全库遍历：同一个偏移量能匹配到几十个位置
/// （UTC+8 就有 Asia/Shanghai、Asia/Makassar、Australia/Perth 等），
/// 遍历顺序由 map 决定，不给优先级会随机命中一个冷门位置。
/// 虽然同偏移的位置在计算上等价，但日志里出现 `Asia/Makassar` 会误导排障。
@visibleForTesting
tz.Location resolveLocalLocation({DateTime? now}) {
  final at = now ?? DateTime.now();
  final offset = at.timeZoneOffset;
  final ms = at.millisecondsSinceEpoch;

  // 目标设备在中国大陆，Asia/Shanghai 应当稳定命中第一项。
  const preferred = <String>[
    'Asia/Shanghai',
    'Asia/Hong_Kong',
    'Asia/Taipei',
    'Asia/Tokyo',
    'Asia/Singapore',
    'UTC',
  ];
  for (final name in preferred) {
    final location = tz.timeZoneDatabase.locations[name];
    if (location != null && _offsetAt(location, ms) == offset) {
      return location;
    }
  }

  for (final location in tz.timeZoneDatabase.locations.values) {
    // 跳过 Etc/* 与不含 '/' 的历史别名（CST、PRC 之类），它们不代表真实地区，
    // 且部分别名的夏令时规则与现代规则不一致。
    if (!location.name.contains('/') || location.name.startsWith('Etc/')) {
      continue;
    }
    if (_offsetAt(location, ms) == offset) {
      debugPrint('时区按偏移量匹配到 ${location.name}（偏移 $offset）');
      return location;
    }
  }

  // 理论上不可达：tzdata 覆盖了所有现行偏移量。
  // 真发生了说明 tzdata 未初始化，退回 UTC 保证不崩，但提醒时间会偏。
  debugPrint('警告：未找到偏移量 $offset 对应的时区，退回 UTC，提醒时间可能偏移');
  return tz.UTC;
}

/// 某个位置在指定时刻的 UTC 偏移量。
///
/// timezone 0.11.1 的 `TimeZone.offset` 已经是 Duration 类型，
/// 尽管它的文档注释仍写着 "Milliseconds east of UTC"（遗留未更新）。
/// 照注释包一层 Duration(milliseconds: ...) 会编译不过。
Duration _offsetAt(tz.Location location, int millisecondsSinceEpoch) =>
    location.timeZone(millisecondsSinceEpoch).offset;

/// 后台 isolate 的通知响应入口。
///
/// 必须标 `@pragma('vm:entry-point')`：这个函数只被原生侧调用，
/// release 构建的 tree-shaking 会把它当死代码删掉，
/// 症状是 debug 下按钮正常、release 下点了没反应。
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  final payload = NotificationPayload.decode(response.payload);
  if (payload == null || response.actionId == null) return;

  handleNotificationAction(actionId: response.actionId!, payload: payload);
}

/// 记账闹钟的回调：把提醒的真实触发时刻写进数据库。
///
/// 由 AlarmManager 在独立 isolate 里调用，与主应用进程无关，
/// 所以同样必须标 `@pragma('vm:entry-point')`，且要自开数据库连接。
///
/// 只写库，不弹通知：通知由 flutter_local_notifications 负责。
/// 这里多弹一次会变成重复提醒。
@pragma('vm:entry-point')
Future<void> markPlanNotified(int alarmId, Map<String, dynamic> params) async {
  final planId = params['planId'];
  if (planId is! int) {
    debugPrint('记账闹钟 $alarmId 缺少 planId，跳过');
    return;
  }

  final db = AppDatabase();
  try {
    final plan = await db.planDao.findById(planId);
    // 计划可能已被删除，或用户在提醒响之前就手动点了完成。
    // 这两种情况都不该把状态改回 notified。
    if (plan == null) return;
    if (plan.completedAt != null) return;

    await db.planDao.markNotified(planId);
  } finally {
    await db.close();
  }
}

/// 处理通知按钮动作。前台与后台 isolate 共用。
///
/// 后台 isolate 拿不到主 isolate 的数据库实例，所以这里自己开一个连接。
/// drift 允许多个连接访问同一文件，SQLite 的锁机制会处理并发写。
Future<void> handleNotificationAction({
  required String actionId,
  required NotificationPayload payload,
}) async {
  final db = AppDatabase();
  try {
    switch (actionId) {
      case NotificationActions.complete:
        await db.planDao.markCompleted(payload.planId);

      case NotificationActions.postpone:
        await db.planDao.postpone(payload.planId);
        // 推迟后计划回到 pending，需要重新排闹钟，否则新时间不会触发。
        final plan = await db.planDao.findById(payload.planId);
        final customer = await db.customerDao.findById(payload.customerId);
        if (plan != null && customer != null) {
          await NotificationService(
            db: db,
          ).scheduleForPlan(plan, customerName: customer.name);
        }

      default:
        debugPrint('未知的通知动作：$actionId');
    }
  } finally {
    // 后台 isolate 里必须关掉，否则连接会随 isolate 一起泄漏。
    await db.close();
  }
}
