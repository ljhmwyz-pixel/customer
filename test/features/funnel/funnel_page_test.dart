import 'package:customer/data/database_provider.dart';
import 'package:customer/features/funnel/funnel_page.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('管理看板显示统计与可解释异常', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final now = DateTime.now();
    await db.customerDao.insertCustomer(
      name: '长期沉默客户',
      now: now.subtract(const Duration(days: 90)),
    );
    final customerId = await db.customerDao.insertCustomer(
      name: '业务任务客户',
      now: now,
    );
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '海外项目',
      now: now,
    );
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      sourceType: TaskSourceType.registration,
      nextAction: '补齐注册资料',
      planAt: now.subtract(const Duration(hours: 3)),
      now: now,
    );
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      sourceType: TaskSourceType.tender,
      nextAction: '确认投标文件',
      planAt: now.subtract(const Duration(hours: 2)),
      now: now,
    );
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      sourceType: TaskSourceType.repurchase,
      nextAction: '联系客户确认复购',
      planAt: now.subtract(const Duration(hours: 1)),
      now: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: FunnelPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('客户总数'), findsOneWidget);
    expect(find.text('客户等级'), findsOneWidget);
    expect(find.text('未来三个月加权预计'), findsOneWidget);
    expect(find.textContaining('长期沉默'), findsOneWidget);
    expect(find.textContaining('注册节点到期'), findsOneWidget);
    expect(find.textContaining('招标临近截止'), findsOneWidget);
    expect(find.textContaining('近期复购'), findsOneWidget);
    expect(find.text('补齐注册资料'), findsOneWidget);
    expect(find.text('确认投标文件'), findsOneWidget);
    expect(find.text('联系客户确认复购'), findsOneWidget);
    expect(
      find.byKey(ValueKey('dashboard-anomaly-$customerId-registrationDue')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('dashboard-anomaly-$customerId-tenderImminent')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('dashboard-anomaly-$customerId-repurchaseDue')),
      findsOneWidget,
    );
    expect(find.textContaining('报价、样品、注册、招标、复购'), findsNothing);
  });

  testWidgets('管理看板空状态覆盖全部业务异常', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: FunnelPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前没有需要处理的业务异常'), findsOneWidget);
  });
}
