import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/business_task_rules.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/helpers.dart';

void main() {
  late AppDatabase db;
  late _Scheduler scheduler;
  setUp(() async {
    db = await openTestDb();
    scheduler = _Scheduler(db);
  });
  tearDown(() async => db.close());

  test('quote rules use weekdays and are idempotent', () async {
    final now = DateTime(2026, 8, 3, 12); // Monday
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '报价项目',
      now: now,
    );
    await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-1',
      quantity: 1,
      quotedAt: DateTime(2026, 7, 31, 12), // Friday -> +2 workdays Tuesday
      now: now,
    );
    final rules = BusinessTaskRules(db, scheduler);
    final first = await rules.generateForOpportunity(opportunityId, now: now);
    final second = await rules.generateForOpportunity(opportunityId, now: now);
    expect(first, isNotEmpty);
    expect(second, isEmpty);
    final plans = await db.planDao.listOf(customerId);
    expect(
      plans.where((p) => p.sourceType == TaskSourceType.quote.dbValue),
      hasLength(first.length),
    );
    expect(scheduler.scheduled, first.length);
  });

  test('sample rules suppress closed opportunities', () async {
    final now = DateTime(2026, 8, 5);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '关闭项目',
      status: OpportunityStatus.closed,
      now: now,
    );
    await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      quantity: 1,
      sentAt: now.subtract(const Duration(days: 3)),
      now: now,
    );
    expect(
      await BusinessTaskRules(
        db,
        scheduler,
      ).generateForOpportunity(opportunityId, now: now),
      isEmpty,
    );
  });

  test(
    'registration rules create three dated tasks and are idempotent',
    () async {
      final now = DateTime.utc(2026, 8, 5);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '注册项目',
        now: now,
      );
      final registrationId = await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        expectedCompletedAt: DateTime.utc(2026, 9, 20),
        documentDueAt: DateTime.utc(2026, 9, 15),
        milestoneAt: DateTime.utc(2026, 9, 10),
        milestoneTitle: '取得注册证',
        status: RegistrationStatus.inProgress,
        now: now,
      );

      final rules = BusinessTaskRules(db, scheduler);
      final first = await rules.generateForOpportunity(opportunityId, now: now);
      final second = await rules.generateForOpportunity(
        opportunityId,
        now: now,
      );
      final plans = (await db.planDao.listOf(customerId))
          .where(
            (plan) => plan.sourceType == TaskSourceType.registration.dbValue,
          )
          .toList();
      final byRule = {for (final plan in plans) plan.ruleKey: plan};

      expect(first, hasLength(3));
      expect(second, isEmpty);
      expect(byRule.keys, {
        'expected-completion',
        'document-due',
        'user-milestone',
      });
      expect(
        byRule['expected-completion']!.planAt,
        DateTime.utc(2026, 9, 20).millisecondsSinceEpoch,
      );
      expect(
        byRule['document-due']!.planAt,
        DateTime.utc(2026, 9, 15).millisecondsSinceEpoch,
      );
      expect(
        byRule['user-milestone']!.planAt,
        DateTime.utc(2026, 9, 10).millisecondsSinceEpoch,
      );
      expect(byRule['user-milestone']!.nextAction, '取得注册证');
      expect(plans.map((plan) => plan.sourceId).toSet(), {registrationId});
      expect(scheduler.scheduled, 3);
      expect(scheduler.persistedBeforeScheduling, everyElement(isTrue));
    },
  );

  test('registration rules suppress completed and cancelled records', () async {
    final now = DateTime.utc(2026, 8, 5);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '终态注册项目',
      now: now,
    );
    for (final status in [
      RegistrationStatus.completed,
      RegistrationStatus.cancelled,
    ]) {
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        expectedCompletedAt: DateTime.utc(2026, 9, 20),
        documentDueAt: DateTime.utc(2026, 9, 15),
        milestoneAt: DateTime.utc(2026, 9, 10),
        status: status,
        now: now,
      );
    }

    expect(
      await BusinessTaskRules(
        db,
        scheduler,
      ).generateForOpportunity(opportunityId, now: now),
      isEmpty,
    );
  });

  test(
    'open tender creates five exact deadline tasks and is idempotent',
    () async {
      final now = DateTime.utc(2026, 8, 5);
      final deadline = DateTime.utc(2026, 10, 1, 8, 30);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '招标项目',
        now: now,
      );
      final tenderId = await db.tenderDao.insertTender(
        opportunityId: opportunityId,
        name: '医院耗材招标',
        deadlineAt: deadline,
        status: TenderStatus.open,
        now: now,
      );

      final rules = BusinessTaskRules(db, scheduler);
      final first = await rules.generateForOpportunity(opportunityId, now: now);
      final second = await rules.generateForOpportunity(
        opportunityId,
        now: now,
      );
      final plans = (await db.planDao.listOf(customerId))
          .where((plan) => plan.sourceType == TaskSourceType.tender.dbValue)
          .toList();
      final byRule = {for (final plan in plans) plan.ruleKey: plan};

      expect(first, hasLength(5));
      expect(second, isEmpty);
      for (final days in [30, 14, 7, 3, 1]) {
        final plan = byRule['deadline-${days}d'];
        expect(plan, isNotNull);
        expect(
          plan!.planAt,
          deadline.subtract(Duration(days: days)).millisecondsSinceEpoch,
        );
        expect(plan.sourceId, tenderId);
      }
    },
  );

  test('tender rules suppress preparing and terminal records', () async {
    final now = DateTime.utc(2026, 8, 5);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '非开放招标项目',
      now: now,
    );
    for (final status in [
      TenderStatus.preparing,
      TenderStatus.won,
      TenderStatus.lost,
      TenderStatus.closed,
      TenderStatus.abandoned,
      TenderStatus.disqualified,
    ]) {
      await db.tenderDao.insertTender(
        opportunityId: opportunityId,
        deadlineAt: DateTime.utc(2026, 10, 1),
        status: status,
        now: now,
      );
    }

    expect(
      await BusinessTaskRules(
        db,
        scheduler,
      ).generateForOpportunity(opportunityId, now: now),
      isEmpty,
    );
  });

  test('completed order creates one project-scoped repurchase task', () async {
    final now = DateTime.utc(2026, 8, 5);
    final repurchaseAt = DateTime.utc(2026, 12, 1);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '复购项目',
      now: now,
    );
    final otherOpportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '其他项目',
      now: now,
    );
    final completedId = await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'R-1',
      orderedAt: now,
      amountCents: 10000,
      orderResult: OrderResult.completed,
      estimatedRepurchaseAt: repurchaseAt,
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'R-2',
      orderedAt: now,
      amountCents: 10000,
      orderResult: OrderResult.inProgress,
      estimatedRepurchaseAt: repurchaseAt,
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'R-3',
      orderedAt: now,
      amountCents: 10000,
      orderResult: OrderResult.completed,
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: otherOpportunityId,
      orderNo: 'R-4',
      orderedAt: now,
      amountCents: 10000,
      orderResult: OrderResult.completed,
      estimatedRepurchaseAt: repurchaseAt,
      now: now,
    );

    final created = await BusinessTaskRules(
      db,
      scheduler,
    ).generateForOpportunity(opportunityId, now: now);
    final plans = (await db.planDao.listOf(customerId))
        .where((plan) => plan.sourceType == TaskSourceType.repurchase.dbValue)
        .toList();

    expect(created, hasLength(1));
    expect(plans, hasLength(1));
    expect(plans.single.sourceId, completedId);
    expect(plans.single.ruleKey, 'repurchase-30d');
    expect(
      plans.single.planAt,
      repurchaseAt.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
    );
  });

  test('won paused and lost opportunity stages suppress all rules', () async {
    final now = DateTime.utc(2026, 8, 5);
    final customerId = await seedCustomer(db);
    for (final stage in [
      OpportunityStage.won,
      OpportunityStage.paused,
      OpportunityStage.lost,
    ]) {
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '${stage.dbValue} 项目',
        stage: stage,
        now: now,
      );
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        expectedCompletedAt: DateTime.utc(2026, 9, 20),
        now: now,
      );
      expect(
        await BusinessTaskRules(
          db,
          scheduler,
        ).generateForOpportunity(opportunityId, now: now),
        isEmpty,
        reason: stage.dbValue,
      );
    }
  });

  test(
    'scheduling failure keeps the persisted task for startup rebuild',
    () async {
      final now = DateTime.utc(2026, 8, 5);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '调度失败项目',
        now: now,
      );
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        expectedCompletedAt: DateTime.utc(2026, 9, 20),
        now: now,
      );
      scheduler.throwOnSchedule = true;
      final rules = BusinessTaskRules(db, scheduler);

      final created = await rules.generateForOpportunity(
        opportunityId,
        now: now,
      );
      final second = await rules.generateForOpportunity(
        opportunityId,
        now: now,
      );

      expect(created, hasLength(1));
      expect(second, isEmpty);
      expect(scheduler.persistedBeforeScheduling, everyElement(isTrue));
      final plan = await db.planDao.findById(created.single);
      expect(plan, isNotNull);
      expect(plan!.status, PlanStatus.pending.dbValue);
    },
  );

  test(
    'reconcile is idempotent and reports only newly created tasks',
    () async {
      final now = DateTime.utc(2026, 8, 5);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '幂等项目',
        now: now,
      );
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        expectedCompletedAt: DateTime.utc(2026, 9, 20),
        now: now,
      );
      final rules = BusinessTaskRules(db, scheduler);

      final first = await rules.reconcileForOpportunity(
        opportunityId,
        now: now,
      );
      final second = await rules.reconcileForOpportunity(
        opportunityId,
        now: now,
      );

      expect(first.createdIds, hasLength(1));
      expect(second.createdIds, isEmpty);
      expect(second.cancelledIds, isEmpty);
      expect(await db.planDao.listOf(customerId), hasLength(1));
    },
  );

  test('reconcile cancels open tasks that no longer apply', () async {
    final now = DateTime.utc(2026, 8, 5);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '样品节点项目',
      now: now,
    );
    final sampleId = await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      quantity: 1,
      sentAt: DateTime.utc(2026, 8, 6),
      now: now,
    );
    final rules = BusinessTaskRules(db, scheduler);
    final first = await rules.reconcileForOpportunity(opportunityId, now: now);
    expect(first.createdIds, isNotEmpty);

    await db.sampleDao.updateMilestone(
      sampleId,
      status: SampleStatus.cancelled,
      now: now,
    );
    final result = await rules.reconcileForOpportunity(opportunityId, now: now);

    expect(result.cancelledIds, first.createdIds);
    expect(scheduler.cancelled, first.createdIds);
    final plans = await db.planDao.listOf(customerId);
    expect(
      plans.map((plan) => plan.status),
      everyElement(PlanStatus.cancelled.dbValue),
    );
  });
}

class _Scheduler implements ReminderScheduler {
  _Scheduler(this.db);

  final AppDatabase db;
  int scheduled = 0;
  bool throwOnSchedule = false;
  final List<bool> persistedBeforeScheduling = [];
  final List<int> cancelled = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async {
    persistedBeforeScheduling.add(await db.planDao.findById(plan.id) != null);
    scheduled++;
    if (throwOnSchedule) throw StateError('schedule failed');
  }

  @override
  Future<void> cancelForPlan(int planId) async => cancelled.add(planId);

  @override
  Future<int> rescheduleAll() async => 0;

  @override
  Future<List<int>> pendingIds() async => [];
}
