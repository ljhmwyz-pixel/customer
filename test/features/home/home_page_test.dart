import 'package:customer/data/database_provider.dart';
import 'package:customer/features/home/home_page.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
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
}
