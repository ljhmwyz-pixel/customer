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
    scheduler = _Scheduler();
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
}

class _Scheduler implements ReminderScheduler {
  int scheduled = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async => scheduled++;

  @override
  Future<void> cancelForPlan(int planId) async {}

  @override
  Future<int> rescheduleAll() async => 0;

  @override
  Future<List<int>> pendingIds() async => [];
}
