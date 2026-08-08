import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/home/home_page.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:customer/services/service_providers.dart';
import 'package:customer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('home exposes and repairs queued automatic task sync', (
    tester,
  ) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db, name: '修复客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '修复项目',
    );
    await db.planDao.enqueueTaskReconciliation(
      opportunityId,
      error: StateError('temporary failure'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(_Scheduler()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1 个项目的自动任务待同步'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('retry-task-sync')));
    await tester.pumpAndSettle();

    expect(find.textContaining('自动任务待同步'), findsNothing);
    expect(await db.planDao.countTaskReconciliationJobs(), 0);
  });
}

class _Scheduler implements ReminderScheduler {
  @override
  Future<void> cancelForPlan(int planId) async {}

  @override
  Future<void> init() async {}

  @override
  Future<List<int>> pendingIds() async => [];

  @override
  Future<int> rescheduleAll() async => 0;

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async {}
}
