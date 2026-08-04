import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/helpers.dart';

/// 通知按钮的数据库副作用。
///
/// handleNotificationAction 自己 new AppDatabase() 连真实文件，测试里没法注入，
/// 所以这里直接验它调用的那两个 DAO 方法。真正的端到端行为
/// （应用未启动时点按钮）只能在设备上验，属于 2A 验收第 13 项。
void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() => db.close());

  Future<int> seedPlan({DateTime? planAt}) async {
    final customerId = await seedCustomer(db);
    return db.planDao.insertPlan(
      customerId: customerId,
      title: '回电',
      planAt: planAt ?? DateTime.now().add(const Duration(hours: 1)),
    );
  }

  group('已完成', () {
    test('状态变为 completed 且 completedAt 落库', () async {
      final planId = await seedPlan();
      await db.planDao.markCompleted(planId);

      final plan = await db.planDao.findById(planId);
      expect(PlanStatus.fromDb(plan!.status), PlanStatus.completed);
      expect(plan.completedAt, isNotNull);
    });
  });

  group('推迟一天', () {
    test('planAt 顺延 24 小时，状态回 pending，notifiedAt 清空', () async {
      final planAt = DateTime.now().add(const Duration(minutes: 5));
      final planId = await seedPlan(planAt: planAt);

      // 先模拟提醒已触发，这样才能验证 notifiedAt 真的被清掉。
      await db.planDao.markNotified(planId);
      expect((await db.planDao.findById(planId))!.notifiedAt, isNotNull);

      final before = (await db.planDao.findById(planId))!.planAt;
      await db.planDao.postpone(planId);
      final after = (await db.planDao.findById(planId))!;

      expect(after.planAt - before, const Duration(days: 1).inMilliseconds);
      expect(PlanStatus.fromDb(after.status), PlanStatus.pending);
      // 状态回 pending 而 notifiedAt 还留着的话，提醒记录里会出现
      // 一条触发时间早于计划时间的记录，看起来像提前触发了。
      expect(after.notifiedAt, isNull);
    });

    test('计划不存在时返回 0，不抛异常', () async {
      // 用户可能在通知还挂着的时候把计划删了，此时点按钮不该崩。
      expect(await db.planDao.postpone(999999), 0);
    });
  });

  group('触发记账', () {
    test('markNotified 记下的是真实触发时刻，不是计划时刻', () async {
      final planAt = DateTime.now().add(const Duration(minutes: 5));
      final planId = await seedPlan(planAt: planAt);

      // 故意用一个与 planAt 明显不同的时刻，验证存的是传入值。
      final firedAt = planAt.add(const Duration(seconds: 37));
      await db.planDao.markNotified(planId, at: firedAt);

      final plan = await db.planDao.findById(planId);
      expect(
        plan!.notifiedAt,
        firedAt.toUtc().millisecondsSinceEpoch,
        reason: '两者的差值就是系统延迟，是判断闹钟有没有被压制的依据',
      );
      expect(PlanStatus.fromDb(plan.status), PlanStatus.notified);
    });
  });

  group('提醒记录查询', () {
    test('只列出 notifiedAt 非空的计划', () async {
      final notifiedId = await seedPlan();
      await seedPlan(); // 未触发过的，不该出现
      await db.planDao.markNotified(notifiedId);

      final logs = await db.planDao.listNotified();
      expect(logs.length, 1);
      expect(logs.single.plan.id, notifiedId);
      expect(logs.single.customerName, isNotEmpty);
    });

    test('触发后立刻点完成的记录仍在列表里', () async {
      // 用 status 过滤会漏掉这类记录，让日志显得比实际触发得少。
      final planId = await seedPlan();
      await db.planDao.markNotified(planId);
      await db.planDao.markCompleted(planId);

      final logs = await db.planDao.listNotified();
      expect(logs.map((e) => e.plan.id), contains(planId));
    });

    test('按触发时间倒序', () async {
      final older = await seedPlan();
      final newer = await seedPlan();
      final base = DateTime.now();
      await db.planDao.markNotified(older, at: base);
      await db.planDao.markNotified(
        newer,
        at: base.add(const Duration(minutes: 1)),
      );

      final logs = await db.planDao.listNotified();
      expect(logs.map((e) => e.plan.id).toList(), [newer, older]);
    });
  });
}
