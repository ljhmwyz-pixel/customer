import 'package:customer/app.dart';
import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/customers/plan_form_page.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/router.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:customer/services/service_providers.dart';
import 'package:customer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('customer activity opens the manual task form', (tester) async {
    final db = await openTestDb();
    addTearDown(() async {
      router.go('/');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
    });
    final customerId = await seedCustomer(db, name: '入口客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '入口项目',
    );
    router.go('/customers/$customerId');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(_Scheduler()),
        ],
        child: const CustomerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, '动态'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-manual-plan')));
    await tester.pumpAndSettle();

    expect(find.text('新建任务'), findsOneWidget);
    expect(find.text('新增订单'), findsNothing);
  });

  testWidgets('manual task form exposes the complete task fields', (
    tester,
  ) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db, name: '手工任务客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '手工任务项目',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(_Scheduler()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PlanFormPage(customerId: customerId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('新建任务'), findsOneWidget);
    expect(find.text('项目：手工任务项目'), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-reason')), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-direction')), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-next-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-owner')), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-at')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save-plan')));
    await tester.pumpAndSettle();
    expect(find.text('跟进原因不能为空'), findsOneWidget);
  });

  testWidgets('manual task edit form loads saved task fields', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db, name: '编辑任务客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '编辑任务项目',
    );
    final planId = await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      sourceType: TaskSourceType.manual,
      reason: '回访原因',
      talkingDirection: '确认意见',
      nextAction: '发送方案',
      owner: '销售 A',
      planAt: DateTime.utc(2026, 8, 10, 9),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(_Scheduler()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PlanFormPage(customerId: customerId, planId: planId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('编辑任务'), findsOneWidget);
    expect(find.text('回访原因'), findsOneWidget);
    expect(find.text('确认意见'), findsOneWidget);
    expect(find.text('发送方案'), findsOneWidget);
    expect(find.text('销售 A'), findsOneWidget);
    expect(find.text('保存修改'), findsOneWidget);
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
