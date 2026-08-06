import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 业务查询与状态流转。这些方法是阶段 2、3 直接依赖的，
/// 单纯的增删改查测试覆盖不到它们的语义。
void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  group('lastFollowAt 冗余字段维护', () {
    test('写入跟进记录后同步更新', () async {
      final id = await seedCustomer(db);
      expect((await db.customerDao.findById(id))!.lastFollowAt, isNull);

      final at = DateTime(2026, 8, 1, 10);
      await db.followupDao.insertAndTouchCustomer(
        customerId: id,
        occurredAt: at,
        method: FollowMethod.phone,
        content: 'x',
      );

      expect(
        (await db.customerDao.findById(id))!.lastFollowAt,
        at.toUtc().millisecondsSinceEpoch,
      );
    });

    test('补录过去的跟进不把 lastFollowAt 往前拨', () async {
      final id = await seedCustomer(db);
      final recent = DateTime(2026, 8, 3);

      await db.followupDao.insertAndTouchCustomer(
        customerId: id,
        occurredAt: recent,
        method: FollowMethod.phone,
        content: '最近的',
      );
      // 补录一条上个月的记录。
      await db.followupDao.insertAndTouchCustomer(
        customerId: id,
        occurredAt: DateTime(2026, 7, 1),
        method: FollowMethod.wechat,
        content: '补录的',
      );

      expect(
        (await db.customerDao.findById(id))!.lastFollowAt,
        recent.toUtc().millisecondsSinceEpoch,
        reason: '补录旧记录不应覆盖更晚的最后跟进时间',
      );
      expect(await db.followupDao.countOf(id), 2);
    });

    test('写入更晚的跟进会推进 lastFollowAt', () async {
      final id = await seedCustomer(db);
      await db.followupDao.insertAndTouchCustomer(
        customerId: id,
        occurredAt: DateTime(2026, 8, 1),
        method: FollowMethod.phone,
        content: 'a',
      );

      final later = DateTime(2026, 8, 5);
      await db.followupDao.insertAndTouchCustomer(
        customerId: id,
        occurredAt: later,
        method: FollowMethod.phone,
        content: 'b',
      );

      expect(
        (await db.customerDao.findById(id))!.lastFollowAt,
        later.toUtc().millisecondsSinceEpoch,
      );
    });
  });

  group('listStale 久未联系', () {
    test('从未跟进过的客户按创建时间判断', () async {
      final now = DateTime(2026, 8, 4);
      // 一个刚创建的客户，一个 60 天前创建的客户，都没有跟进记录。
      await db.customerDao.insertCustomer(name: '新客户', now: now);
      await db.customerDao.insertCustomer(
        name: '老客户',
        now: now.subtract(const Duration(days: 60)),
      );

      final stale = await db.customerDao.listStale(now: now, days: 30);
      expect(stale.map((e) => e.name), ['老客户']);
    });

    test('已成交与已流失不计入', () async {
      final now = DateTime(2026, 8, 4);
      final old = now.subtract(const Duration(days: 60));

      await db.customerDao.insertCustomer(name: '在跟进', now: old);
      await db.customerDao.insertCustomer(
        name: '已成交',
        stage: CustomerStage.deal,
        now: old,
      );
      await db.customerDao.insertCustomer(
        name: '已流失',
        stage: CustomerStage.lost,
        now: old,
      );

      final stale = await db.customerDao.listStale(now: now, days: 30);
      expect(stale.map((e) => e.name), ['在跟进']);
    });

    test('近期有跟进的不计入', () async {
      final now = DateTime(2026, 8, 4);
      final id = await db.customerDao.insertCustomer(
        name: '有跟进',
        now: now.subtract(const Duration(days: 60)),
      );
      await db.followupDao.insertAndTouchCustomer(
        customerId: id,
        occurredAt: now.subtract(const Duration(days: 3)),
        method: FollowMethod.phone,
        content: '刚聊过',
      );

      expect(await db.customerDao.listStale(now: now, days: 30), isEmpty);
    });
  });

  group('订单金额统计', () {
    test('sumAmountByCustomer 仅统计已完成订单', () async {
      final id = await seedCustomer(db);
      await db.orderDao.insertOrder(
        customerId: id,
        orderNo: 'S-1',
        orderedAt: DateTime(2026, 8, 1),
        amountCents: 10000,
        status: OrderStatus.paid,
      );
      await db.orderDao.insertOrder(
        customerId: id,
        orderNo: 'S-2',
        orderedAt: DateTime(2026, 8, 2),
        amountCents: 5000,
        status: OrderStatus.completed,
      );
      await db.orderDao.insertOrder(
        customerId: id,
        orderNo: 'S-3',
        orderedAt: DateTime(2026, 8, 3),
        amountCents: 99900,
        status: OrderStatus.cancelled,
      );

      expect(await db.orderDao.sumAmountByCustomer(id), 5000);
    });

    test('无订单时返回 0 而不是抛错', () async {
      final id = await seedCustomer(db);
      expect(await db.orderDao.sumAmountByCustomer(id), 0);
    });

    test('sumAmountGroupedByCustomer 一次取全', () async {
      final a = await seedCustomer(db, name: 'A');
      final b = await seedCustomer(db, name: 'B');
      final c = await seedCustomer(db, name: 'C');

      await db.orderDao.insertOrder(
        customerId: a,
        orderNo: 'G-1',
        orderedAt: DateTime(2026, 8, 1),
        amountCents: 100,
        status: OrderStatus.completed,
      );
      await db.orderDao.insertOrder(
        customerId: a,
        orderNo: 'G-2',
        orderedAt: DateTime(2026, 8, 2),
        amountCents: 200,
        status: OrderStatus.completed,
      );
      await db.orderDao.insertOrder(
        customerId: b,
        orderNo: 'G-3',
        orderedAt: DateTime(2026, 8, 3),
        amountCents: 300,
        status: OrderStatus.cancelled,
      );

      final sums = await db.orderDao.sumAmountGroupedByCustomer();
      expect(sums[a], 300);
      // 只有取消订单的客户不出现在结果里，调用方按 0 处理。
      expect(sums[b], isNull);
      expect(sums[c], isNull);
    });

    test('nextOrderNo 同日递增，换日重置', () async {
      final id = await seedCustomer(db);
      final day = DateTime(2026, 8, 4);

      final first = await db.orderDao.nextOrderNo(at: day);
      expect(first, '20260804-001');
      await db.orderDao.insertOrder(
        customerId: id,
        orderNo: first,
        orderedAt: day,
        amountCents: 100,
      );

      final second = await db.orderDao.nextOrderNo(at: day);
      expect(second, '20260804-002');
      await db.orderDao.insertOrder(
        customerId: id,
        orderNo: second,
        orderedAt: day,
        amountCents: 100,
      );

      expect(await db.orderDao.nextOrderNo(at: day), '20260804-003');

      // 换一天从 001 重新开始。
      expect(
        await db.orderDao.nextOrderNo(at: DateTime(2026, 8, 5)),
        '20260805-001',
      );
    });

    test('中间订单被删也不会撞上仍存在的号', () async {
      final id = await seedCustomer(db);
      final day = DateTime(2026, 8, 4);

      for (var i = 1; i <= 3; i++) {
        await db.orderDao.insertOrder(
          customerId: id,
          orderNo: '20260804-00$i',
          orderedAt: day,
          amountCents: 100,
        );
      }

      // 删掉中间一条，新号按最大号推进而不是按条数，所以不会撞上仍存在的 003。
      await db.orderDao.deleteOrder(
        (await db.orderDao.findByOrderNo('20260804-002'))!.id,
      );
      final next = await db.orderDao.nextOrderNo(at: day);
      expect(next, '20260804-004');

      // 确认真的能插进去，也就是没撞唯一约束。
      await db.orderDao.insertOrder(
        customerId: id,
        orderNo: next,
        orderedAt: day,
        amountCents: 100,
      );
      expect(await db.orderDao.countOf(id), 3);
    });
  });

  group('计划状态流转', () {
    test('listDue 只取到期的 pending', () async {
      final id = await seedCustomer(db, name: '待跟进客户');
      final now = DateTime(2026, 8, 4, 12);

      final duePlan = await db.planDao.insertPlan(
        customerId: id,
        title: '已到期',
        planAt: now.subtract(const Duration(hours: 1)),
      );
      await db.planDao.insertPlan(
        customerId: id,
        title: '未到期',
        planAt: now.add(const Duration(hours: 1)),
      );
      final notifiedPlan = await db.planDao.insertPlan(
        customerId: id,
        title: '已提醒过',
        planAt: now.subtract(const Duration(hours: 2)),
      );
      await db.planDao.markNotified(notifiedPlan, at: now);

      final due = await db.planDao.listDue(now: now);
      expect(due.map((e) => e.plan.id), [duePlan]);
      // 带上客户名，列表页不用再查一次。
      expect(due.single.customerName, '待跟进客户');
    });

    test('listUpcoming 只取未来的 pending，供重启后重建闹钟', () async {
      final id = await seedCustomer(db);
      final now = DateTime(2026, 8, 4, 12);

      await db.planDao.insertPlan(
        customerId: id,
        title: '过去',
        planAt: now.subtract(const Duration(days: 1)),
      );
      final future = await db.planDao.insertPlan(
        customerId: id,
        title: '未来',
        planAt: now.add(const Duration(days: 1)),
      );

      final upcoming = await db.planDao.listUpcoming(now: now);
      expect(upcoming.map((e) => e.id), [future]);
    });

    test('markNotified 记录真实触发时刻', () async {
      final id = await seedCustomer(db);
      final planAt = DateTime(2026, 8, 4, 9);
      final planId = await db.planDao.insertPlan(
        customerId: id,
        title: '提醒',
        planAt: planAt,
      );

      // 系统延迟了 15 分钟才触发。
      final firedAt = planAt.add(const Duration(minutes: 15));
      await db.planDao.markNotified(planId, at: firedAt);

      final row = (await db.planDao.findById(planId))!;
      expect(PlanStatus.fromDb(row.status), PlanStatus.notified);
      expect(row.notifiedAt, firedAt.toUtc().millisecondsSinceEpoch);
      // 存的是实际触发时间而不是计划时间，阶段 2 靠这个差值判断系统有没有掐闹钟。
      expect(row.notifiedAt, isNot(row.planAt));
    });

    test('markCompleted 记录完成时间', () async {
      final id = await seedCustomer(db);
      final planId = await db.planDao.insertPlan(
        customerId: id,
        title: 'x',
        planAt: DateTime(2026, 8, 4),
      );

      final at = DateTime(2026, 8, 4, 10);
      await db.planDao.markCompleted(planId, at: at);

      final row = (await db.planDao.findById(planId))!;
      expect(PlanStatus.fromDb(row.status), PlanStatus.completed);
      expect(row.completedAt, at.toUtc().millisecondsSinceEpoch);
    });

    test('postpone 顺延并清掉 notifiedAt 以便重新排期', () async {
      final id = await seedCustomer(db);
      final planAt = DateTime(2026, 8, 4, 9);
      final planId = await db.planDao.insertPlan(
        customerId: id,
        title: 'x',
        planAt: planAt,
      );
      await db.planDao.markNotified(planId, at: planAt);

      await db.planDao.postpone(planId);

      final row = (await db.planDao.findById(planId))!;
      expect(
        row.planAt,
        planAt.add(const Duration(days: 1)).toUtc().millisecondsSinceEpoch,
      );
      expect(
        PlanStatus.fromDb(row.status),
        PlanStatus.pending,
        reason: '推迟后要回到 pending，否则闹钟不会被重新排期',
      );
      expect(
        row.notifiedAt,
        isNull,
        reason: 'notifiedAt 未清掉的话下次触发会被 listDue 漏掉',
      );
    });

    test('postpone 不存在的计划返回 0', () async {
      expect(await db.planDao.postpone(99999), 0);
    });

    test('markOverdue 只标超过 24 小时的未完成计划', () async {
      final id = await seedCustomer(db);
      final now = DateTime(2026, 8, 4, 12);

      final longOverdue = await db.planDao.insertPlan(
        customerId: id,
        title: '逾期三天',
        planAt: now.subtract(const Duration(days: 3)),
      );
      final justPassed = await db.planDao.insertPlan(
        customerId: id,
        title: '刚过点',
        planAt: now.subtract(const Duration(hours: 2)),
      );
      final done = await db.planDao.insertPlan(
        customerId: id,
        title: '已完成',
        planAt: now.subtract(const Duration(days: 5)),
      );
      await db.planDao.markCompleted(done, at: now);

      final affected = await db.planDao.markOverdue(now: now);
      expect(affected, 1);

      expect(
        PlanStatus.fromDb((await db.planDao.findById(longOverdue))!.status),
        PlanStatus.overdue,
      );
      expect(
        PlanStatus.fromDb((await db.planDao.findById(justPassed))!.status),
        PlanStatus.pending,
      );
      expect(
        PlanStatus.fromDb((await db.planDao.findById(done))!.status),
        PlanStatus.completed,
        reason: '已完成的计划不应被标为逾期',
      );
    });

    test('listOpenUntil 取今日与逾期，排除已完成', () async {
      final id = await seedCustomer(db);
      final now = DateTime(2026, 8, 4, 12);
      final endOfToday = DateTime(2026, 8, 4, 23, 59, 59);

      final overdue = await db.planDao.insertPlan(
        customerId: id,
        title: '逾期',
        planAt: now.subtract(const Duration(days: 2)),
      );
      final today = await db.planDao.insertPlan(
        customerId: id,
        title: '今天晚些',
        planAt: now.add(const Duration(hours: 5)),
      );
      await db.planDao.insertPlan(
        customerId: id,
        title: '明天',
        planAt: now.add(const Duration(days: 1)),
      );
      final done = await db.planDao.insertPlan(
        customerId: id,
        title: '已完成',
        planAt: now.subtract(const Duration(hours: 1)),
      );
      await db.planDao.markCompleted(done, at: now);

      final open = await db.planDao.listOpenUntil(until: endOfToday);
      // 逾期在前，今日在后，按计划时间升序。
      expect(open.map((e) => e.plan.id), [overdue, today]);
    });

    test('listOpenOf 排除已完成并按时间、主键稳定排序', () async {
      final id = await seedCustomer(db);
      final sameTime = DateTime(2026, 8, 8, 9);
      final first = await db.planDao.insertPlan(
        customerId: id,
        title: '同时间第一条',
        planAt: sameTime,
      );
      final second = await db.planDao.insertPlan(
        customerId: id,
        title: '同时间第二条',
        planAt: sameTime,
      );
      final earlier = await db.planDao.insertPlan(
        customerId: id,
        title: '更早',
        planAt: sameTime.subtract(const Duration(days: 1)),
      );
      final completed = await db.planDao.insertPlan(
        customerId: id,
        title: '已完成',
        planAt: sameTime.subtract(const Duration(days: 2)),
      );
      await db.planDao.markCompleted(completed, at: sameTime);

      final open = await db.planDao.listOpenOf(id);
      expect(open.map((plan) => plan.id), [earlier, first, second]);
    });

    test('取消任务保留记录但从所有开放查询中排除', () async {
      final id = await seedCustomer(db);
      final now = DateTime(2026, 8, 8, 9);
      final cancelled = await db.planDao.insertPlan(
        customerId: id,
        title: '取消的任务',
        planAt: now.subtract(const Duration(hours: 1)),
      );
      final open = await db.planDao.insertPlan(
        customerId: id,
        title: '仍开放',
        planAt: now,
      );

      expect(
        await db.planDao.markCancelled(cancelled, at: DateTime(2026, 8, 8, 10)),
        1,
      );
      final row = await db.planDao.findById(cancelled);
      expect(PlanStatus.fromDb(row!.status), PlanStatus.cancelled);
      expect(row.cancelledAt, DateTime(2026, 8, 8, 10).millisecondsSinceEpoch);
      expect(await db.planDao.markCancelled(cancelled), 0);
      expect((await db.planDao.listOpenOf(id)).map((e) => e.id), [open]);
      expect(
        (await db.planDao.listOpenUntil(until: now)).map((e) => e.plan.id),
        [open],
      );
      expect(await db.planDao.markCompleted(cancelled), 0);
      expect(await db.planDao.postpone(cancelled), 0);
    });

    test('listToday 联表过滤、排序与旧快照回退', () async {
      final now = DateTime(2026, 8, 5, 12);
      final oldCustomer = await db.customerDao.insertCustomer(
        name: '旧客户',
        grade: CustomerGrade.d,
        now: now,
      );
      final highCustomer = await db.customerDao.insertCustomer(
        name: '高等级客户',
        grade: CustomerGrade.a,
        now: now,
      );
      final closedCustomer = await db.customerDao.insertCustomer(
        name: '关闭客户',
        now: now,
      );
      final oldOpportunity = await db.opportunityDao.insertOpportunity(
        customerId: oldCustomer,
        name: 'CT 注射器',
        productCategory: '耗材',
        latestFeedback: '待反馈',
        now: now,
      );
      final highOpportunity = await db.opportunityDao.insertOpportunity(
        customerId: highCustomer,
        name: '高优先级项目',
        importance: OpportunityImportance.high,
        now: now,
      );
      final closedOpportunity = await db.opportunityDao.insertOpportunity(
        customerId: closedCustomer,
        name: '已关闭项目',
        status: OpportunityStatus.closed,
        now: now,
      );
      final oldest = await db.planDao.insertPlan(
        customerId: oldCustomer,
        opportunityId: oldOpportunity,
        planAt: now.subtract(const Duration(days: 3)),
        title: '旧任务',
      );
      final graded = await db.planDao.insertPlan(
        customerId: highCustomer,
        opportunityId: highOpportunity,
        planAt: now.subtract(const Duration(hours: 2)),
        reason: '催报价',
        nextAction: '电话确认',
      );
      final today = await db.planDao.insertPlan(
        customerId: highCustomer,
        opportunityId: highOpportunity,
        planAt: now.add(const Duration(hours: 2)),
        title: '今天任务',
      );
      await db.planDao.insertPlan(
        customerId: closedCustomer,
        opportunityId: closedOpportunity,
        planAt: now,
        title: '不应显示',
      );
      await db.planDao.insertPlan(
        customerId: highCustomer,
        opportunityId: highOpportunity,
        planAt: now.add(const Duration(days: 1)),
        title: '明天任务',
      );

      final rows = await db.planDao.listToday(now: now);
      expect(rows.map((item) => item.plan.id), [oldest, graded, today]);
      expect(rows.first.projectLabel, 'CT 注射器');
      expect(rows.first.productLabel, '耗材');
      expect(rows.first.latestFeedback, '待反馈');
      expect(rows.first.reason, '历史任务');
      expect(rows.first.nextAction, '旧任务');
      expect(rows.first.overdueDays(now), 3);
    });
  });

  group('客户组合筛选', () {
    test('关键字、阶段、标签同时生效且可搜索联系人电话', () async {
      final now = DateTime(2026, 8, 4, 12);
      final target = await db.customerDao.insertCustomer(
        name: '目标客户',
        stage: CustomerStage.intent,
        now: now,
      );
      final wrongStage = await db.customerDao.insertCustomer(
        name: '阶段不符',
        stage: CustomerStage.contacted,
        now: now,
      );
      final wrongTag = await db.customerDao.insertCustomer(
        name: '标签不符',
        stage: CustomerStage.intent,
        now: now,
      );
      await db.contactDao.insertContact(
        customerId: target,
        name: '目标联系人',
        phone: '010-76543210',
      );
      await db.contactDao.insertContact(
        customerId: wrongStage,
        name: '其他联系人',
        phone: '010-76543210',
      );
      await db.contactDao.insertContact(
        customerId: wrongTag,
        name: '其他联系人',
        phone: '010-76543210',
      );
      final selectedTag = await db.customerDao.ensureTag('重点');
      final otherTag = await db.customerDao.ensureTag('普通');
      await db.customerDao.attachTag(target, selectedTag);
      await db.customerDao.attachTag(wrongStage, selectedTag);
      await db.customerDao.attachTag(wrongTag, otherTag);

      final rows = await db.customerDao.listFilteredByUrgency(
        now: now,
        keyword: '7654',
        customerStage: CustomerStage.intent,
        tagId: selectedTag,
      );
      expect(rows.map((row) => row.customer.id), [target]);
    });

    test('国家、等级、供应商、切入点、销售阶段和负责人同时生效', () async {
      final now = DateTime(2026, 8, 4, 12);
      final target = await db.customerDao.insertCustomer(
        name: '目标客户',
        country: '智利',
        grade: CustomerGrade.a,
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: target,
        name: '目标项目',
        currentSupplier: '供应商 A',
        entryPoint: '第二供应商',
        stage: OpportunityStage.quoted,
        owner: '王销售',
        now: now,
      );

      for (final mismatch in <({String country, CustomerGrade grade})>[
        (country: '巴西', grade: CustomerGrade.a),
        (country: '智利', grade: CustomerGrade.b),
      ]) {
        final id = await db.customerDao.insertCustomer(
          name: '客户 ${mismatch.country}-${mismatch.grade.label}',
          country: mismatch.country,
          grade: mismatch.grade,
          now: now,
        );
        await db.opportunityDao.insertOpportunity(
          customerId: id,
          name: '匹配项目',
          currentSupplier: '供应商 A',
          entryPoint: '第二供应商',
          stage: OpportunityStage.quoted,
          owner: '王销售',
          now: now,
        );
      }

      final projectMismatches =
          <
            ({
              String supplier,
              String entryPoint,
              OpportunityStage stage,
              String owner,
            })
          >[
            (
              supplier: '供应商 B',
              entryPoint: '第二供应商',
              stage: OpportunityStage.quoted,
              owner: '王销售',
            ),
            (
              supplier: '供应商 A',
              entryPoint: '样品测试',
              stage: OpportunityStage.quoted,
              owner: '王销售',
            ),
            (
              supplier: '供应商 A',
              entryPoint: '第二供应商',
              stage: OpportunityStage.sampleTesting,
              owner: '王销售',
            ),
            (
              supplier: '供应商 A',
              entryPoint: '第二供应商',
              stage: OpportunityStage.quoted,
              owner: '李销售',
            ),
          ];
      for (var index = 0; index < projectMismatches.length; index++) {
        final mismatch = projectMismatches[index];
        final id = await db.customerDao.insertCustomer(
          name: '项目条件不符 $index',
          country: '智利',
          grade: CustomerGrade.a,
          now: now,
        );
        await db.opportunityDao.insertOpportunity(
          customerId: id,
          name: '不匹配项目',
          currentSupplier: mismatch.supplier,
          entryPoint: mismatch.entryPoint,
          stage: mismatch.stage,
          owner: mismatch.owner,
          now: now,
        );
      }

      final rows = await db.customerDao.listFilteredByUrgency(
        now: now,
        country: '智利',
        customerGrade: CustomerGrade.a,
        currentSupplier: '供应商 A',
        entryPoint: '第二供应商',
        opportunityStage: OpportunityStage.quoted,
        owner: '王销售',
      );
      expect(rows.map((row) => row.customer.id), [target]);
    });

    test('多个项目筛选条件必须由同一个项目满足', () async {
      final now = DateTime(2026, 8, 4, 12);
      final split = await db.customerDao.insertCustomer(
        name: '拆分命中客户',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: split,
        name: '只匹配供应商',
        currentSupplier: '供应商 A',
        stage: OpportunityStage.sampleTesting,
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: split,
        name: '只匹配阶段',
        currentSupplier: '供应商 B',
        stage: OpportunityStage.quoted,
        now: now,
      );
      final same = await db.customerDao.insertCustomer(
        name: '同项目命中客户',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: same,
        name: '同时匹配',
        currentSupplier: '供应商 A',
        stage: OpportunityStage.quoted,
        now: now,
      );

      final rows = await db.customerDao.listFilteredByUrgency(
        now: now,
        currentSupplier: '供应商 A',
        opportunityStage: OpportunityStage.quoted,
      );
      expect(rows.map((row) => row.customer.id), [same]);
    });

    test(r'项目文本精确匹配 %、_、\，空白筛选不启用', () async {
      final now = DateTime(2026, 8, 4, 12);
      final literal = await db.customerDao.insertCustomer(
        name: '特殊字符客户',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: literal,
        name: '特殊字符项目',
        currentSupplier: r'供%应_商\A',
        entryPoint: r'切%入_点\B',
        owner: '王销售',
        now: now,
      );
      final ordinary = await db.customerDao.insertCustomer(
        name: '普通客户',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: ordinary,
        name: '普通项目',
        currentSupplier: '供应商 A',
        entryPoint: '第二供应商',
        owner: '李销售',
        now: now,
      );

      final exact = await db.customerDao.listFilteredByUrgency(
        now: now,
        currentSupplier: r' 供%应_商\A ',
        entryPoint: r' 切%入_点\B ',
      );
      expect(exact.map((row) => row.customer.id), [literal]);

      final blank = await db.customerDao.listFilteredByUrgency(
        now: now,
        country: '   ',
        currentSupplier: ' ',
        entryPoint: '\n',
        owner: '\t',
      );
      expect(blank.map((row) => row.customer.id), [literal, ordinary]);
    });

    test('动态筛选选项去空、去重并排序', () async {
      final now = DateTime(2026, 8, 4, 12);
      final first = await db.customerDao.insertCustomer(
        name: '甲',
        country: ' 智利 ',
        now: now,
      );
      final second = await db.customerDao.insertCustomer(
        name: '乙',
        country: '巴西',
        now: now,
      );
      await db.customerDao.insertCustomer(name: '丙', country: ' ', now: now);
      await db.opportunityDao.insertOpportunity(
        customerId: first,
        name: '项目甲',
        currentSupplier: ' 供应商 B ',
        entryPoint: ' 自定义切入 ',
        owner: ' 王销售 ',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: second,
        name: '项目乙',
        currentSupplier: '供应商 A',
        entryPoint: '第二供应商',
        owner: '李销售',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: second,
        name: '项目丙',
        currentSupplier: '供应商 B',
        entryPoint: '自定义切入',
        owner: '王销售',
        now: now,
      );

      final options = await db.customerDao.listFilterOptions();
      expect(options.countries, ['巴西', '智利']);
      expect(options.currentSuppliers, ['供应商 A', '供应商 B']);
      expect(options.entryPoints, ['第二供应商', '自定义切入']);
      expect(options.owners, ['李销售', '王销售']);
    });

    test('筛选后仍保持原有紧急度排序', () async {
      final now = DateTime(2026, 8, 4, 12);
      final noPlan = await db.customerDao.insertCustomer(
        name: '无计划',
        country: '智利',
        now: now,
      );
      final overdue = await db.customerDao.insertCustomer(
        name: '逾期',
        country: '智利',
        now: now,
      );
      await db.planDao.insertPlan(
        customerId: overdue,
        title: '逾期任务',
        planAt: now.subtract(const Duration(days: 2)),
      );

      final rows = await db.customerDao.listFilteredByUrgency(
        now: now,
        country: '智利',
      );
      expect(rows.map((row) => row.customer.id), [overdue, noPlan]);
    });

    test(r'关键字把 %、_、\ 当作普通字符', () async {
      final now = DateTime(2026, 8, 4, 12);
      final percent = await db.customerDao.insertCustomer(
        name: '折扣 10% 客户',
        now: now,
      );
      final underscore = await db.customerDao.insertCustomer(
        name: '编号 A_1',
        now: now,
      );
      final backslash = await db.customerDao.insertCustomer(
        name: r'路径 C:\CRM',
        now: now,
      );
      await db.customerDao.insertCustomer(name: '折扣 100 客户', now: now);
      await db.customerDao.insertCustomer(name: '编号 AB1', now: now);

      expect(
        (await db.customerDao.listFilteredByUrgency(
          now: now,
          keyword: '%',
        )).map((row) => row.customer.id),
        [percent],
      );
      expect(
        (await db.customerDao.listFilteredByUrgency(
          now: now,
          keyword: '_',
        )).map((row) => row.customer.id),
        [underscore],
      );
      expect(
        (await db.customerDao.listFilteredByUrgency(
          now: now,
          keyword: r'\',
        )).map((row) => row.customer.id),
        [backslash],
      );
    });

    test('空筛选与默认紧急度查询结果一致', () async {
      final now = DateTime(2026, 8, 4, 12);
      final first = await db.customerDao.insertCustomer(name: '甲', now: now);
      await db.customerDao.insertCustomer(name: '乙', now: now);
      await db.planDao.insertPlan(
        customerId: first,
        title: '待办',
        planAt: now.subtract(const Duration(days: 1)),
      );

      final defaultRows = await db.customerDao.listByUrgency(now: now);
      final filteredRows = await db.customerDao.listFilteredByUrgency(now: now);
      expect(
        filteredRows.map((row) => row.customer.id),
        defaultRows.map((row) => row.customer.id),
      );
    });
  });

  group('listByUrgency 排序细节', () {
    test('无计划客户按分级 A>B>C>D 排序', () async {
      final now = DateTime(2026, 8, 4, 12);
      await db.customerDao.insertCustomer(
        name: 'C级',
        grade: CustomerGrade.c,
        now: now,
      );
      await db.customerDao.insertCustomer(
        name: 'A级',
        grade: CustomerGrade.a,
        now: now,
      );
      await db.customerDao.insertCustomer(
        name: 'B级',
        grade: CustomerGrade.b,
        now: now,
      );
      await db.customerDao.insertCustomer(
        name: 'D级',
        grade: CustomerGrade.d,
        now: now,
      );

      final rows = await db.customerDao.listByUrgency(now: now);
      expect(rows.map((e) => e.customer.name), ['A级', 'B级', 'C级', 'D级']);
    });

    test('逾期 > 今日 > 未来 > 无计划', () async {
      final now = DateTime(2026, 8, 4, 12);

      final none = await db.customerDao.insertCustomer(name: '无计划', now: now);
      final future = await db.customerDao.insertCustomer(name: '未来', now: now);
      final today = await db.customerDao.insertCustomer(name: '今日', now: now);
      final over = await db.customerDao.insertCustomer(name: '逾期', now: now);

      await db.planDao.insertPlan(
        customerId: future,
        title: 'p',
        planAt: now.add(const Duration(days: 5)),
      );
      await db.planDao.insertPlan(
        customerId: today,
        title: 'p',
        planAt: now.add(const Duration(hours: 3)),
      );
      await db.planDao.insertPlan(
        customerId: over,
        title: 'p',
        planAt: now.subtract(const Duration(days: 2)),
      );

      final rows = await db.customerDao.listByUrgency(now: now);
      expect(rows.map((e) => e.customer.id), [over, today, future, none]);
    });

    test('overdueDays 计算逾期天数', () async {
      final now = DateTime(2026, 8, 4, 12);
      final id = await db.customerDao.insertCustomer(name: 'x', now: now);
      await db.planDao.insertPlan(
        customerId: id,
        title: 'p',
        planAt: now.subtract(const Duration(days: 3)),
      );

      final row = (await db.customerDao.listByUrgency(now: now)).single;
      expect(row.overdueDays(now), 3);
      expect(row.openPlanCount, 1);
    });

    test('已完成计划不计入 openPlanCount', () async {
      final now = DateTime(2026, 8, 4, 12);
      final id = await db.customerDao.insertCustomer(name: 'x', now: now);
      final planId = await db.planDao.insertPlan(
        customerId: id,
        title: 'p',
        planAt: now.add(const Duration(days: 1)),
      );
      await db.planDao.markCompleted(planId, at: now);

      final row = (await db.customerDao.listByUrgency(now: now)).single;
      expect(row.openPlanCount, 0);
      expect(row.nextPlanAt, isNull);
    });
  });
}
