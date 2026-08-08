import 'package:customer/data/database_provider.dart';
import 'package:customer/features/customers/customer_detail_page.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:customer/features/opportunities/opportunity_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('activity tab shows field-aware opportunity changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db, name: '历史客户');
    final service = OpportunityService(db);
    final opportunityId = await service.createOpportunity(
      customerId,
      const OpportunityDraft(name: '历史项目'),
    );
    await service.updateOpportunity(
      customerId,
      opportunityId,
      const OpportunityDraft(
        name: '历史项目',
        stage: OpportunityStage.quoted,
        nextAction: '确认客户报价反馈',
      ),
    );

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    expect(
      (await container.read(
        customerDetailProvider(customerId).future,
      ))?.opportunityChanges,
      hasLength(2),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: CustomerDetailPage(customerId: customerId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, '动态'));
    await tester.pumpAndSettle();
    final addPlan = find.byKey(const ValueKey('add-manual-plan'));
    expect(addPlan, findsOneWidget);
    expect(addPlan.hitTestable(), findsOneWidget);
    expect(tester.getSize(addPlan), const Size(48, 48));
    expect(find.textContaining('项目变更'), findsOneWidget);
    expect(find.text('销售阶段'), findsOneWidget);
    expect(find.textContaining('新线索 → 已报价'), findsOneWidget);
    expect(find.text('下一步行动'), findsOneWidget);
    expect(find.textContaining('确认客户报价反馈'), findsOneWidget);
  });
}
