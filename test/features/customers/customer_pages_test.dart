import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/customers/contact_actions.dart';
import 'package:customer/features/customers/customer_detail_page.dart';
import 'package:customer/features/customers/customer_form_page.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:customer/features/customers/customers_page.dart';
import 'package:customer/features/customers/followup_form_page.dart';
import 'package:customer/features/orders/order_form_page.dart';
import 'package:customer/features/opportunities/opportunity_form_page.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:customer/services/service_providers.dart';
import 'package:customer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('CustomerFormPage creates a customer with only a name', (
    tester,
  ) async {
    final harness = await _TestHarness.create(home: const CustomerFormPage());
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.enterText(find.byKey(const ValueKey('customer-name')), '星河科技');
    await tester.tap(find.byKey(const ValueKey('save-customer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('客户已创建'), findsOneWidget);
    expect(await harness.db.customerDao.countAll(), 1);
    expect((await harness.db.customerDao.allCustomers()).single.name, '星河科技');
  });

  testWidgets('CustomersPage combines stage and tag filters', (tester) async {
    final db = await openTestDb();
    final scheduler = _FakeReminderScheduler();
    final service = CustomerService(db, scheduler);
    await service.createCustomer(
      const CustomerDraft(
        name: '客户 A',
        stage: CustomerStage.potential,
        tagNames: ['重点'],
      ),
    );
    await service.createCustomer(
      const CustomerDraft(
        name: '客户 B',
        stage: CustomerStage.potential,
        tagNames: ['普通'],
      ),
    );
    await service.createCustomer(
      const CustomerDraft(
        name: '客户 C',
        stage: CustomerStage.contacted,
        tagNames: ['重点'],
      ),
    );
    final tagId = (await db.customerDao.allTags())
        .singleWhere((tag) => tag.name == '重点')
        .id;
    final harness = _TestHarness(
      db: db,
      scheduler: scheduler,
      contactActions: _FakeContactActions(),
      home: const CustomersPage(),
    );
    addTearDown(() => harness.dispose(tester));
    harness.container
        .read(customerFilterProvider.notifier)
        .setStage(CustomerStage.potential);
    harness.container.read(customerFilterProvider.notifier).setTag(tagId);

    await harness.pump(tester);

    expect(find.text('客户 A'), findsOneWidget);
    expect(find.text('客户 B'), findsNothing);
    expect(find.text('客户 C'), findsNothing);
  });

  testWidgets(
    'FollowupFormPage defaults the only project and saves five fields',
    (tester) async {
      final db = await openTestDb();
      final customerId = await seedCustomer(db, name: '待跟进客户');
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: 'CT 注射器',
        stage: OpportunityStage.quoted,
      );
      final harness = _TestHarness(
        db: db,
        scheduler: _FakeReminderScheduler(),
        contactActions: _FakeContactActions(),
        home: FollowupFormPage(customerId: customerId),
      );
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      expect(find.text('项目：CT 注射器'), findsOneWidget);
      expect(find.byKey(const ValueKey('followup-opportunity')), findsNothing);
      expect(
        tester
            .widget<DropdownButtonFormField<OpportunityStage>>(
              find.byKey(const ValueKey('followup-stage')),
            )
            .initialValue,
        OpportunityStage.quoted,
      );
      await tester.enterText(
        find.byKey(const ValueKey('followup-feedback')),
        ' 客户认可方案 ',
      );
      await tester.enterText(
        find.byKey(const ValueKey('followup-next-action')),
        ' 发送正式报价 ',
      );
      final pageScrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('save-followup')),
        200,
        scrollable: pageScrollable,
      );
      await tester.tap(find.byKey(const ValueKey('save-followup')));
      await tester.pumpAndSettle();

      final followup = (await db.followupDao.listOf(customerId)).single;
      expect(followup.opportunityId, opportunityId);
      expect(followup.feedback, '客户认可方案');
      expect(followup.stage, OpportunityStage.quoted.dbValue);
      expect(followup.nextAction, '发送正式报价');
      expect(followup.nextFollowAt, isNotNull);
      expect(followup.pauseReason, isNull);
      final plan = (await db.planDao.listOf(customerId)).single;
      expect(plan.opportunityId, opportunityId);
      expect(plan.title, '发送正式报价');
    },
  );

  testWidgets('FollowupFormPage selects a project and resets its stage', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '多项目客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '项目 A',
      stage: OpportunityStage.quoted,
      now: DateTime.utc(2026, 8, 5, 9),
    );
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '项目 B',
      stage: OpportunityStage.needsConfirmed,
      now: DateTime.utc(2026, 8, 5, 10),
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: FollowupFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    expect(find.byKey(const ValueKey('followup-opportunity')), findsOneWidget);
    expect(
      tester
          .widget<DropdownButtonFormField<OpportunityStage>>(
            find.byKey(const ValueKey('followup-stage')),
          )
          .initialValue,
      OpportunityStage.needsConfirmed,
    );

    await tester.tap(find.byKey(const ValueKey('followup-opportunity')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('项目 A').last);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DropdownButtonFormField<OpportunityStage>>(
            find.byKey(const ValueKey('followup-stage')),
          )
          .initialValue,
      OpportunityStage.quoted,
    );
  });

  testWidgets('FollowupFormPage validates required five-field inputs', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '校验客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '校验项目',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: FollowupFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-followup')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    tester
        .widget<FilledButton>(find.byKey(const ValueKey('save-followup')))
        .onPressed!();
    await tester.pump();

    expect(find.text('客户反馈不能为空'), findsOneWidget);
    expect(find.text('下一步行动不能为空'), findsOneWidget);
    expect(await db.followupDao.countOf(customerId), 0);
  });

  testWidgets('FollowupFormPage requires a reason when follow-up is paused', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '暂停客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '暂停项目',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: FollowupFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('followup-feedback')),
      '客户暂缓项目',
    );
    await tester.enterText(
      find.byKey(const ValueKey('followup-next-action')),
      '等待客户预算确认',
    );
    await tester.scrollUntilVisible(
      find.text('暂不跟进'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('暂不跟进'));
    await tester.pump();
    expect(find.byKey(const ValueKey('followup-pause-reason')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-followup')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-followup')));
    await tester.pump();
    tester
        .widget<FilledButton>(find.byKey(const ValueKey('save-followup')))
        .onPressed!();
    await tester.pump();
    expect(find.text('暂停原因不能为空'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('followup-pause-reason')),
      ' 预算冻结 ',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-followup')));
    await tester.pump();
    tester
        .widget<FilledButton>(find.byKey(const ValueKey('save-followup')))
        .onPressed!();
    await tester.pumpAndSettle();

    final followup = (await db.followupDao.listOf(customerId)).single;
    expect(followup.pauseReason, '预算冻结');
    expect(followup.nextFollowAt, isNull);
    expect(await db.planDao.listOf(customerId), isEmpty);
  });

  testWidgets('FollowupFormPage handles a narrow dark viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '窄屏客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '特别特别长的医疗器械出口项目名称',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: FollowupFormPage(customerId: customerId),
      themeMode: ThemeMode.dark,
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomerDetailPage keeps independent follow-up snapshots', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '历史客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '输注项目',
    );
    await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: opportunityId,
      occurredAt: DateTime.utc(2026, 8, 3, 9),
      method: FollowMethod.phone,
      content: '第一次补充记录',
      feedback: '首次确认参数',
      stage: OpportunityStage.quoted,
      nextAction: '发送正式报价',
      nextFollowAt: DateTime.utc(2026, 8, 6, 9),
    );
    await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: opportunityId,
      occurredAt: DateTime.utc(2026, 8, 4, 9),
      method: FollowMethod.wechat,
      content: '第二次补充记录',
      feedback: '客户要求调整价格',
      stage: OpportunityStage.priceNegotiation,
      nextAction: '确认目标价格',
      pauseReason: '客户团队休假',
    );
    await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      occurredAt: DateTime.utc(2026, 8, 2, 9),
      method: FollowMethod.meeting,
      content: '历史正文',
      conclusion: '历史结论',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 2000);
    await tester.pumpAndSettle();

    expect(find.text('客户反馈：首次确认参数'), findsOneWidget);
    expect(find.text('项目阶段：已报价'), findsOneWidget);
    expect(find.text('下一步行动：发送正式报价'), findsOneWidget);
    expect(find.textContaining('下次跟进：'), findsOneWidget);
    expect(find.text('客户反馈：客户要求调整价格'), findsOneWidget);
    expect(find.text('项目阶段：价格谈判'), findsOneWidget);
    expect(find.text('下一步行动：确认目标价格'), findsOneWidget);
    expect(find.text('暂不跟进：客户团队休假'), findsOneWidget);
    expect(find.text('历史正文'), findsOneWidget);
    expect(find.text('结论：历史结论'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage reports an invalid customer id', (
    tester,
  ) async {
    final harness = await _TestHarness.create(
      home: const CustomerDetailPage(customerId: null),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(find.text('客户编号无效'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage reports an invalid highlighted plan', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '有效客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId, invalidPlanId: true),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(find.text('指定的跟进计划不存在'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage delegates phone calls to ContactActions', (
    tester,
  ) async {
    final db = await openTestDb();
    const phone = '13800138000';
    final customerId = await seedCustomer(db, name: '电话客户', phone: phone);
    final actions = _FakeContactActions();
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: actions,
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.tap(find.byTooltip('拨打电话'));
    await tester.pump();

    expect(actions.calledPhone, phone);
  });

  testWidgets('CustomerDetailPage creates an order through the form', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '新增订单客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '订单项目',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final addOrderButton = find.byTooltip('新增订单');
    await tester.scrollUntilVisible(
      addOrderButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(addOrderButton);
    await tester.pumpAndSettle();
    await _enterOrderText(tester, 'order-no', 'ORDER-CREATE-001');
    await _enterOrderText(tester, 'order-amount', '123.45');
    await _enterOrderText(tester, 'order-pi-po-no', 'PI-2026-001');
    await _enterOrderText(tester, 'order-currency', 'usd');
    await _selectDropdownValue<PaymentStatus>(
      tester,
      'order-payment-status',
      PaymentStatus.partial,
    );
    await _selectDropdownValue<ProductionStatus>(
      tester,
      'order-production-status',
      ProductionStatus.inProgress,
    );
    await _selectDropdownValue<ShippingStatus>(
      tester,
      'order-shipping-status',
      ShippingStatus.shipped,
    );
    await _selectDropdownValue<OrderResult>(
      tester,
      'order-result',
      OrderResult.inProgress,
    );
    await _enterOrderText(tester, 'order-description', '年度服务套餐');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-order')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-order')));
    await tester.pumpAndSettle();

    final orders = await db.orderDao.listOf(customerId);
    expect(orders, hasLength(1));
    expect(orders.single.orderNo, 'ORDER-CREATE-001');
    expect(orders.single.amountCents, 12345);
    expect(orders.single.description, '年度服务套餐');
    expect(orders.single.opportunityId, opportunityId);
    expect(orders.single.piPoNo, 'PI-2026-001');
    expect(orders.single.currency, 'USD');
    expect(orders.single.paymentStatus, PaymentStatus.partial.dbValue);
    expect(orders.single.productionStatus, ProductionStatus.inProgress.dbValue);
    expect(orders.single.shippingStatus, ShippingStatus.shipped.dbValue);
    expect(orders.single.orderResult, OrderResult.inProgress.dbValue);
    expect(find.text('ORDER-CREATE-001'), findsOneWidget);
    expect(find.textContaining('¥123.45'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage creates and displays a project', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '新增项目客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.tap(find.byTooltip('新增项目'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-name')),
      'CT 注射器项目',
    );
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-forecastAmount')),
      '1000.50',
    );
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-probabilityPercent')),
      '40',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-opportunity')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-opportunity')));
    await tester.pumpAndSettle();

    final values = await db.opportunityDao.listOfCustomer(customerId);
    expect(values, hasLength(1));
    expect(values.single.name, 'CT 注射器项目');
    expect(values.single.forecastAmountMinor, 100050);
    expect(find.text('CT 注射器项目'), findsOneWidget);
    expect(find.textContaining('加权 USD 400.20'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage prioritizes saved substitution decisions', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '已决策客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '已决策项目',
      supplierProblem: '价格高',
      estimatedAnnualVolume: 1200,
      entryPoint: '第二供应商',
      investmentAdvice: '限制样品投入',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(find.text('第二供应商 · 限制样品投入'), findsOneWidget);
    expect(find.text('建议：价格替代 · 继续投入'), findsNothing);
  });

  testWidgets('CustomerDetailPage shows a calculated substitution suggestion', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '待决策客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '待决策项目',
      supplierProblem: '价格高',
      estimatedAnnualVolume: 1200,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(find.text('建议：价格替代 · 继续投入'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage edits an existing project', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '编辑项目客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '旧项目名',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await _selectOpportunityAction(tester, opportunityId, '编辑');
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-name')),
      '更新后的项目',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-opportunity')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-opportunity')));
    await tester.pumpAndSettle();

    expect((await db.opportunityDao.findById(opportunityId))?.name, '更新后的项目');
    expect(find.text('更新后的项目'), findsOneWidget);
  });

  testWidgets('OpportunityFormPage applies a supplier recommendation on save', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '替代建议客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: OpportunityFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-name')),
      '价格替代项目',
    );
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-estimatedAnnualVolume')),
      '1200',
    );
    await tester.scrollUntilVisible(
      find.text('供应商与价格信息'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('供应商与价格信息'));
    await tester.pumpAndSettle();
    await _selectDropdownValue<String>(
      tester,
      'opportunity-supplierProblem',
      '价格高',
    );
    await tester.scrollUntilVisible(
      find.text('投入建议与前置事项'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('投入建议与前置事项'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('supplier-recommendation-card')),
      findsOneWidget,
    );
    expect(find.text('建议切入点：价格替代'), findsOneWidget);
    expect(find.text('建议投入：继续投入'), findsOneWidget);
    expect(find.textContaining('明确采购条件'), findsOneWidget);
    expect(find.textContaining('已有年用量或采购时间证据'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('apply-supplier-recommendation')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('apply-supplier-recommendation')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('apply-supplier-recommendation')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const ValueKey('opportunity-entryPoint')),
          )
          .initialValue,
      '价格替代',
    );
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const ValueKey('opportunity-investmentAdvice')),
          )
          .initialValue,
      '继续投入',
    );
    expect(await db.opportunityDao.listOfCustomer(customerId), isEmpty);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-opportunity')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-opportunity')));
    await tester.pumpAndSettle();

    final value = (await db.opportunityDao.listOfCustomer(customerId)).single;
    expect(value.supplierProblem, '价格高');
    expect(value.entryPoint, '价格替代');
    expect(value.investmentAdvice, '继续投入');
  });

  testWidgets('OpportunityFormPage preserves legacy supplier values', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '历史项目客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '历史项目',
      supplierProblem: '旧系统供应商描述',
      changeWillingness: '旧系统意愿',
      substitutionDifficulty: '旧系统难度',
      entryPoint: '旧系统切入策略',
      investmentAdvice: '旧系统投入判断',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: OpportunityFormPage(
        customerId: customerId,
        opportunityId: opportunityId,
      ),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.scrollUntilVisible(
      find.text('供应商与价格信息'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('供应商与价格信息'));
    await tester.pumpAndSettle();
    expect(find.text('历史值：旧系统供应商描述'), findsOneWidget);
    expect(find.text('历史值：旧系统意愿'), findsOneWidget);
    expect(find.text('历史值：旧系统难度'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('投入建议与前置事项'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('投入建议与前置事项'));
    await tester.pumpAndSettle();
    expect(find.text('历史值：旧系统切入策略'), findsOneWidget);
    expect(find.text('历史值：旧系统投入判断'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-opportunity')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-opportunity')));
    await tester.pumpAndSettle();

    final value = await db.opportunityDao.findById(opportunityId);
    expect(value?.supplierProblem, '旧系统供应商描述');
    expect(value?.changeWillingness, '旧系统意愿');
    expect(value?.substitutionDifficulty, '旧系统难度');
    expect(value?.entryPoint, '旧系统切入策略');
    expect(value?.investmentAdvice, '旧系统投入判断');
  });

  testWidgets('OpportunityFormPage handles recommendations on narrow dark UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '窄屏替代建议客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: OpportunityFormPage(customerId: customerId),
      themeMode: ThemeMode.dark,
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.scrollUntilVisible(
      find.text('供应商与价格信息'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('供应商与价格信息'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('投入建议与前置事项'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('投入建议与前置事项'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('supplier-recommendation-card')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const ValueKey('supplier-recommendation-card')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomerDetailPage edits an existing order', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '编辑订单客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '编辑订单项目',
    );
    final orderId = await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'ORDER-OLD',
      orderedAt: DateTime(2026, 8, 5),
      amountCents: 100,
      piPoNo: 'PI-OLD',
      currency: 'EUR',
      paymentStatus: PaymentStatus.partial,
      productionStatus: ProductionStatus.inProgress,
      shippingStatus: ShippingStatus.shipped,
      estimatedArrivalAt: DateTime(2026, 8, 20),
      orderResult: OrderResult.inProgress,
      estimatedRepurchaseAt: DateTime(2027, 2, 5),
      description: '旧描述',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await _selectOrderAction(tester, orderId, '编辑');
    await _enterOrderText(tester, 'order-no', 'ORDER-EDITED');
    await _enterOrderText(tester, 'order-amount', '88.80');
    await _scrollOrderFieldIntoView(tester, 'order-pi-po-no');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('order-pi-po-no')))
          .controller
          ?.text,
      'PI-OLD',
    );
    await tester.enterText(
      find.byKey(const ValueKey('order-pi-po-no')),
      'PI-UPDATED',
    );
    await _scrollOrderFieldIntoView(tester, 'order-currency');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('order-currency')))
          .controller
          ?.text,
      'EUR',
    );
    await tester.enterText(find.byKey(const ValueKey('order-currency')), 'gbp');
    await _scrollOrderFieldIntoView(tester, 'order-payment-status');
    expect(
      tester
          .widget<DropdownButtonFormField<PaymentStatus>>(
            find.byKey(const ValueKey('order-payment-status')),
          )
          .initialValue,
      PaymentStatus.partial,
    );
    await _selectDropdownValue<PaymentStatus>(
      tester,
      'order-payment-status',
      PaymentStatus.paid,
    );
    await _scrollOrderFieldIntoView(tester, 'order-production-status');
    expect(
      tester
          .widget<DropdownButtonFormField<ProductionStatus>>(
            find.byKey(const ValueKey('order-production-status')),
          )
          .initialValue,
      ProductionStatus.inProgress,
    );
    await _selectDropdownValue<ProductionStatus>(
      tester,
      'order-production-status',
      ProductionStatus.completed,
    );
    await _scrollOrderFieldIntoView(tester, 'order-shipping-status');
    expect(
      tester
          .widget<DropdownButtonFormField<ShippingStatus>>(
            find.byKey(const ValueKey('order-shipping-status')),
          )
          .initialValue,
      ShippingStatus.shipped,
    );
    await _selectDropdownValue<ShippingStatus>(
      tester,
      'order-shipping-status',
      ShippingStatus.delivered,
    );
    await _scrollOrderFieldIntoView(tester, 'order-estimated-arrival');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('order-estimated-arrival')),
          )
          .controller
          ?.text,
      '2026-08-20',
    );
    await _scrollOrderFieldIntoView(tester, 'order-result');
    expect(
      tester
          .widget<DropdownButtonFormField<OrderResult>>(
            find.byKey(const ValueKey('order-result')),
          )
          .initialValue,
      OrderResult.inProgress,
    );
    await _selectDropdownValue<OrderResult>(
      tester,
      'order-result',
      OrderResult.completed,
    );
    await _scrollOrderFieldIntoView(tester, 'order-estimated-repurchase');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('order-estimated-repurchase')),
          )
          .controller
          ?.text,
      '2027-02-05',
    );
    await _enterOrderText(tester, 'order-description', '更新后的服务内容');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-order')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-order')));
    await tester.pumpAndSettle();

    final order = await db.orderDao.findById(orderId);
    expect(order?.orderNo, 'ORDER-EDITED');
    expect(order?.amountCents, 8880);
    expect(order?.description, '更新后的服务内容');
    expect(order?.piPoNo, 'PI-UPDATED');
    expect(order?.currency, 'GBP');
    expect(order?.paymentStatus, PaymentStatus.paid.dbValue);
    expect(order?.productionStatus, ProductionStatus.completed.dbValue);
    expect(order?.shippingStatus, ShippingStatus.delivered.dbValue);
    expect(order?.orderResult, OrderResult.completed.dbValue);
    expect(
      order?.estimatedArrivalAt,
      DateTime(2026, 8, 20).toUtc().millisecondsSinceEpoch,
    );
    expect(
      order?.estimatedRepurchaseAt,
      DateTime(2027, 2, 5).toUtc().millisecondsSinceEpoch,
    );
    expect(find.text('ORDER-EDITED'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage advances an order and refreshes revenue', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '订单流转客户');
    final orderId = await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: 'ORDER-FLOW',
      orderedAt: DateTime(2026, 8, 5),
      amountCents: 12345,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    expect(find.text('¥0.00'), findsOneWidget);

    await _selectOrderAction(tester, orderId, '推进至已发货');
    expect(
      (await db.orderDao.findById(orderId))?.status,
      OrderStatus.shipped.dbValue,
    );
    await _selectOrderAction(tester, orderId, '推进至已收款');
    expect(
      (await db.orderDao.findById(orderId))?.status,
      OrderStatus.paid.dbValue,
    );
    await _selectOrderAction(tester, orderId, '推进至已完成');

    expect(
      (await db.orderDao.findById(orderId))?.status,
      OrderStatus.completed.dbValue,
    );
    await tester.scrollUntilVisible(
      find.text('¥123.45'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('¥123.45'), findsOneWidget);
    expect(find.textContaining('已完成'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage confirms cancellation and deletion', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '订单终止客户');
    final cancelledOrderId = await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: 'ORDER-CANCEL',
      orderedAt: DateTime(2026, 8, 5),
      amountCents: 200,
    );
    final deletedOrderId = await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: 'ORDER-DELETE',
      orderedAt: DateTime(2026, 8, 5),
      amountCents: 300,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await _selectOrderAction(tester, cancelledOrderId, '取消订单');
    expect(find.text('确定取消订单“ORDER-CANCEL”吗？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认取消'));
    await tester.pumpAndSettle();
    expect(
      (await db.orderDao.findById(cancelledOrderId))?.status,
      OrderStatus.cancelled.dbValue,
    );
    expect(find.textContaining('已取消'), findsOneWidget);

    await _selectOrderAction(tester, deletedOrderId, '删除');
    expect(find.text('删除订单'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(await db.orderDao.findById(deletedOrderId), isNull);
    expect(find.text('ORDER-DELETE'), findsNothing);
  });

  testWidgets('CustomerDetailPage handles a narrow dark viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await seedCustomer(
      db,
      name: '这是一个用于验证窄屏布局不会溢出的特别特别长的客户名称',
    );
    await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: List.filled(50, 'X').join(),
      orderedAt: DateTime(2026, 8, 5),
      amountCents: 12345,
      description: '这是一段用于验证订单列表窄屏显示的特别特别长的商品和服务描述内容',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
      themeMode: ThemeMode.dark,
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(tester.takeException(), isNull);
  });
}

class _TestHarness {
  _TestHarness({
    required this.db,
    required this.scheduler,
    required this.contactActions,
    required this.home,
    this.themeMode = ThemeMode.light,
  }) {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        reminderSchedulerProvider.overrideWithValue(scheduler),
        contactActionsProvider.overrideWithValue(contactActions),
      ],
    );
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => home),
        GoRoute(path: '/customers', builder: (_, _) => const CustomersPage()),
        GoRoute(
          path: '/customers/new',
          builder: (_, _) => const CustomerFormPage(),
        ),
        GoRoute(
          path: '/customers/:id',
          builder: (_, state) => CustomerDetailPage(
            customerId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
          routes: [
            GoRoute(
              path: 'followups/new',
              builder: (_, state) => FollowupFormPage(
                customerId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: 'opportunities/new',
              builder: (_, state) => OpportunityFormPage(
                customerId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: 'opportunities/:opportunityId/edit',
              builder: (_, state) => OpportunityFormPage(
                customerId: int.parse(state.pathParameters['id']!),
                opportunityId: int.parse(
                  state.pathParameters['opportunityId']!,
                ),
              ),
            ),
            GoRoute(
              path: 'orders/new',
              builder: (_, state) => OrderFormPage(
                customerId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: 'orders/:orderId/edit',
              builder: (_, state) => OrderFormPage(
                customerId: int.parse(state.pathParameters['id']!),
                orderId: int.parse(state.pathParameters['orderId']!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<_TestHarness> create({required Widget home}) async {
    return _TestHarness(
      db: await openTestDb(),
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: home,
    );
  }

  final AppDatabase db;
  final ReminderScheduler scheduler;
  final ContactActions contactActions;
  final Widget home;
  final ThemeMode themeMode;
  late final ProviderContainer container;
  late final GoRouter router;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
    container.dispose();
    await db.close();
  }
}

Future<void> _selectOrderAction(
  WidgetTester tester,
  int orderId,
  String action,
) async {
  final tile = find.byKey(ValueKey('order-$orderId'));
  await tester.scrollUntilVisible(
    tile,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  final actionButton = find.descendant(
    of: tile,
    matching: find.byTooltip('订单操作'),
  );
  await tester.ensureVisible(actionButton);
  await tester.pumpAndSettle();
  await tester.tap(actionButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

Future<void> _selectDropdownValue<T>(
  WidgetTester tester,
  String key,
  T value,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  final dropdown = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    dropdown,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  final item = find.byWidgetPredicate(
    (widget) => widget is DropdownMenuItem<T> && widget.value == value,
  );
  await tester.ensureVisible(item.last);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getCenter(item.last));
  await tester.pumpAndSettle();
}

Future<void> _scrollOrderFieldIntoView(WidgetTester tester, String key) async {
  final field = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    field,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
}

Future<void> _enterOrderText(
  WidgetTester tester,
  String key,
  String value,
) async {
  await _scrollOrderFieldIntoView(tester, key);
  await tester.enterText(find.byKey(ValueKey(key)), value);
}

Future<void> _selectOpportunityAction(
  WidgetTester tester,
  int opportunityId,
  String action,
) async {
  final tile = find.byKey(ValueKey('opportunity-$opportunityId'));
  await tester.scrollUntilVisible(
    tile,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  final actionButton = find.descendant(
    of: tile,
    matching: find.byTooltip('项目操作'),
  );
  await tester.ensureVisible(actionButton);
  await tester.pumpAndSettle();
  await tester.tap(actionButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

class _FakeContactActions implements ContactActions {
  String? calledPhone;
  ImportedContact? pickedContact;

  @override
  Future<void> call(String phone) async => calledPhone = phone;

  @override
  Future<ImportedContact?> pickContact() async => pickedContact;
}

class _FakeReminderScheduler implements ReminderScheduler {
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
