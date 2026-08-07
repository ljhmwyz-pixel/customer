import 'package:customer/data/database_provider.dart';
import 'package:customer/features/home/home_page.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('Today 首屏提供高频客户操作', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('新建客户'), findsOneWidget);
    expect(find.text('客户列表'), findsOneWidget);
    expect(find.text('导入客户'), findsOneWidget);
  });

  testWidgets('Today 页面展示完整任务上下文并排除未来任务', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await db.customerDao.insertCustomer(
      name: '北方医院',
      grade: CustomerGrade.a,
    );
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: 'CT 注射器',
      productModel: 'CT-01',
    );
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      reason: '确认报价',
      talkingDirection: '确认采购周期',
      nextAction: '电话确认',
      planAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      title: '未来任务',
      planAt: DateTime.now().add(const Duration(days: 2)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('北方医院'), findsOneWidget);
    expect(find.textContaining('CT 注射器'), findsOneWidget);
    expect(find.textContaining('确认报价'), findsOneWidget);
    expect(find.text('未来任务'), findsNothing);
  });

  testWidgets('Today 页面在 320 宽度下长任务和操作区不溢出', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await db.customerDao.insertCustomer(
      name: '这是一个用于验证首页窄屏任务布局的特别特别长的客户名称',
      country: '中华人民共和国',
      grade: CustomerGrade.a,
    );
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '跨区域医疗设备与耗材综合采购项目',
      productModel: 'MODEL-WITH-A-VERY-LONG-NAME',
      latestFeedback: '客户希望补充完整技术参数并重新核对长期供应计划',
      nextAction: '组织跨部门评审并确认下一轮商务谈判时间',
      owner: '国际业务负责人',
    );
    final planId = await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      reason: '报价、交期与注册资料仍需多方确认',
      talkingDirection: '逐项确认采购节奏、预算审批和技术准入要求',
      nextAction: '组织跨部门评审并确认下一轮商务谈判时间',
      planAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    final actions = find.byKey(ValueKey('home-plan-actions-$planId'));
    await tester.scrollUntilVisible(
      actions,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(ValueKey('home-plan-complete-$planId')), findsOneWidget);
    expect(find.byKey(ValueKey('home-plan-menu-$planId')), findsOneWidget);
    expect(tester.getRect(actions).right, lessThanOrEqualTo(292.1));
    expect(tester.takeException(), isNull);
  });
}
