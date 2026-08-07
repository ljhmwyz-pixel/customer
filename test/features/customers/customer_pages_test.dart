import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/data/daos/customer_dao.dart';
import 'package:customer/features/customers/contact_actions.dart';
import 'package:customer/features/customers/contact_form_page.dart';
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
import 'package:customer/widgets/app_dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('长表单首个错误自动定位：订单金额', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '订单定位客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '订单定位项目',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: OrderFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('order-description')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-order')));
    await tester.pumpAndSettle();

    expect(find.text('请输入有效金额，最多保留两位小数'), findsOneWidget);
    expect(
      _editableTextHasFocus(tester, const ValueKey('order-amount')),
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('order-amount')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('长表单首个错误自动定位：跟进反馈', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '跟进定位客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '跟进定位项目',
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
      find.byKey(const ValueKey('followup-next-choice')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-followup')));
    await tester.pumpAndSettle();

    expect(find.text('客户反馈不能为空'), findsOneWidget);
    expect(
      _editableTextHasFocus(tester, const ValueKey('followup-feedback')),
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('followup-feedback')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('长表单首个错误自动定位：项目名称', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '项目定位客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: OpportunityFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-opportunity')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-opportunity')));
    await tester.pumpAndSettle();

    expect(find.text('请输入项目名称'), findsOneWidget);
    expect(
      _editableTextHasFocus(tester, const ValueKey('opportunity-name')),
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('opportunity-name')).hitTestable(),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('opportunity-name')),
      '有效项目',
    );
    await tester.enterText(
      find.byKey(const ValueKey('opportunity-estimatedAnnualVolume')),
      'abc',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-opportunity')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('save-opportunity')));
    await tester.pumpAndSettle();

    expect(find.text('预计年用量需为整数'), findsOneWidget);
    expect(
      _editableTextHasFocus(
        tester,
        const ValueKey('opportunity-estimatedAnnualVolume'),
      ),
      isTrue,
    );
  });

  testWidgets('剩余表单退出保护：客户和联系人支持恢复初始值', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '基线客户');
    final contactId = await db.contactDao.insertContact(
      customerId: customerId,
      name: '基线联系人',
      isDecisionMaker: true,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    harness.router.push('/customers/new');
    await tester.pumpAndSettle();
    final customerName = find.byKey(const ValueKey('customer-name'));
    await tester.enterText(customerName, '临时客户');
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(customerName, '');
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);

    harness.router.push('/customers/$customerId/edit');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);

    harness.router.push('/customers/$customerId/contacts/new');
    await tester.pumpAndSettle();
    final decisionMaker = find.byKey(const ValueKey('contact-decision-maker'));
    await tester.tap(decisionMaker);
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    await tester.tap(decisionMaker);
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);

    harness.router.push(
      '/customers/$customerId/contacts/new?name=预填联系人&phone=13900000000',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);

    harness.router.push('/customers/$customerId/contacts/$contactId/edit');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);
  });

  testWidgets('核心表单未保存修改保护：订单、跟进和项目', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '退出保护客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '退出保护项目',
    );
    final orderId = await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'ORDER-GUARD',
      orderedAt: DateTime(2026, 8, 7),
      amountCents: 10000,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    Future<void> expectDirtyGuard(String location, Key fieldKey) async {
      harness.router.push(location);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(fieldKey), '用户修改');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('放弃未保存的修改？'), findsOneWidget);
      await tester.tap(find.text('放弃修改'));
      await tester.pumpAndSettle();
    }

    await expectDirtyGuard(
      '/customers/$customerId/orders/new',
      const ValueKey('order-no'),
    );
    await expectDirtyGuard(
      '/customers/$customerId/followups/new',
      const ValueKey('followup-feedback'),
    );
    await expectDirtyGuard(
      '/customers/$customerId/opportunities/new',
      const ValueKey('opportunity-name'),
    );

    harness.router.push('/customers/$customerId/orders/$orderId/edit');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);

    Future<void> discardCurrentForm() async {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('放弃未保存的修改？'), findsOneWidget);
      await tester.tap(find.text('放弃修改'));
      await tester.pumpAndSettle();
    }

    harness.router.push('/customers/$customerId/orders/new');
    await tester.pumpAndSettle();
    await _scrollOrderFieldIntoView(tester, 'order-payment-status');
    await _selectDropdownValue<PaymentStatus>(
      tester,
      'order-payment-status',
      PaymentStatus.partial,
    );
    await discardCurrentForm();

    harness.router.push('/customers/$customerId/followups/new');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('暂不跟进'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('暂不跟进'));
    await tester.pump();
    await discardCurrentForm();

    harness.router.push('/customers/$customerId/opportunities/new');
    await tester.pumpAndSettle();
    await _selectDropdownValue<OpportunityStage>(
      tester,
      'opportunity-stage',
      OpportunityStage.contactEstablished,
    );
    await discardCurrentForm();
  });

  test('customer advanced filter state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(customerFilterProvider.notifier);

    notifier.setProductCategory('  体外诊断  ');
    notifier.setProductModel('Model X');
    notifier.setEquipmentBrand('Brand A');
    notifier.setOpportunityStatus(OpportunityStatus.active);
    notifier.setExpectedCloseFrom(DateTime(2026, 8, 1));
    notifier.setExpectedCloseTo(DateTime(2026, 8, 31));
    notifier.toggleAnomaly(CustomerAnomalyFilter.stalledQuote);
    notifier.toggleAnomaly(CustomerAnomalyFilter.longSilence);

    var state = container.read(customerFilterProvider);
    expect(state.productCategory, '体外诊断');
    expect(state.productModel, 'Model X');
    expect(state.equipmentBrand, 'Brand A');
    expect(state.opportunityStatus, OpportunityStatus.active);
    expect(state.expectedCloseFrom, DateTime(2026, 8, 1));
    expect(state.expectedCloseTo, DateTime(2026, 8, 31));
    expect(state.anomalies, {
      CustomerAnomalyFilter.stalledQuote,
      CustomerAnomalyFilter.longSilence,
    });
    expect(state.activeFilterCount, 8);

    notifier.toggleAnomaly(CustomerAnomalyFilter.stalledQuote);
    notifier.setProductModel('   ');
    notifier.setExpectedCloseFrom(DateTime(2026, 9, 1));
    state = container.read(customerFilterProvider);
    expect(state.anomalies, {CustomerAnomalyFilter.longSilence});
    expect(state.productModel, isNull);
    expect(state.expectedCloseFrom, DateTime(2026, 9, 1));
    expect(state.expectedCloseTo, isNull);

    notifier.setExpectedCloseTo(DateTime(2026, 8, 31));
    expect(container.read(customerFilterProvider).expectedCloseTo, isNull);

    final source = {CustomerAnomalyFilter.stalledSample};
    final copied = state.copyWith(anomalies: source);
    source.add(CustomerAnomalyFilter.stalledQuote);
    expect(copied.anomalies, {CustomerAnomalyFilter.stalledSample});
    expect(
      () => copied.anomalies.add(CustomerAnomalyFilter.longSilence),
      throwsUnsupportedError,
    );
  });

  test('customer advanced filter clear behavior', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(customerFilterProvider.notifier);

    notifier.setKeyword('目标客户');
    notifier.setCustomerStage(CustomerStage.potential);
    notifier.setProductCategory('耗材');
    notifier.setExpectedCloseFrom(DateTime(2026, 8, 1));
    notifier.toggleAnomaly(CustomerAnomalyFilter.stalledSample);
    notifier.clearNonKeywordFilters();

    var state = container.read(customerFilterProvider);
    expect(state.keyword, '目标客户');
    expect(state.activeFilterCount, 0);
    expect(state.productCategory, isNull);
    expect(state.expectedCloseFrom, isNull);
    expect(state.anomalies, isEmpty);

    notifier.setEquipmentBrand('Brand B');
    notifier.toggleAnomaly(CustomerAnomalyFilter.longSilence);
    notifier.setKeyword('');
    state = container.read(customerFilterProvider);
    expect(state.keyword, isEmpty);
    expect(state.equipmentBrand, 'Brand B');
    expect(state.anomalies, {CustomerAnomalyFilter.longSilence});
    expect(state.activeFilterCount, 2);

    notifier.clear();
    state = container.read(customerFilterProvider);
    expect(state.hasFilters, isFalse);
    expect(state.anomalies, isEmpty);
  });

  test(
    'customer detail groups saved business history by opportunity',
    () async {
      final db = await openTestDb();
      final customerId = await seedCustomer(db);
      final firstOpportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '项目一',
      );
      final secondOpportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '项目二',
      );
      final quoteId = await db.quoteDao.insertVersion(
        opportunityId: firstOpportunityId,
        quoteNo: 'Q-HISTORY',
        quantity: 10,
        quotedAt: DateTime(2026, 8, 6),
      );
      final sampleId = await db.sampleDao.insertSample(
        opportunityId: secondOpportunityId,
        sampleModel: 'S-HISTORY',
        quantity: 2,
      );
      final registrationId = await db.registrationDao.insertRegistration(
        opportunityId: firstOpportunityId,
        country: '德国',
      );
      final tenderId = await db.tenderDao.insertTender(
        opportunityId: secondOpportunityId,
        projectNo: 'T-HISTORY',
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final detail = await container.read(
        customerDetailProvider(customerId).future,
      );

      expect(
        detail!.businessByOpportunity[firstOpportunityId]!.quotes.map(
          (row) => row.id,
        ),
        [quoteId],
      );
      expect(
        detail.businessByOpportunity[firstOpportunityId]!.registrations.map(
          (row) => row.id,
        ),
        [registrationId],
      );
      expect(
        detail.businessByOpportunity[firstOpportunityId]!.samples,
        isEmpty,
      );
      expect(
        detail.businessByOpportunity[secondOpportunityId]!.samples.map(
          (row) => row.id,
        ),
        [sampleId],
      );
      expect(
        detail.businessByOpportunity[secondOpportunityId]!.tenders.map(
          (row) => row.id,
        ),
        [tenderId],
      );
      expect(
        detail.businessByOpportunity[secondOpportunityId]!.quotes,
        isEmpty,
      );
    },
  );

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
        .setCustomerStage(CustomerStage.potential);
    harness.container.read(customerFilterProvider.notifier).setTag(tagId);

    await harness.pump(tester);

    expect(find.text('客户 A'), findsOneWidget);
    expect(find.text('客户 B'), findsNothing);
    expect(find.text('客户 C'), findsNothing);
  });

  testWidgets('CustomersPage combines customer and same-project filters', (
    tester,
  ) async {
    final db = await openTestDb();
    final targetId = await db.customerDao.insertCustomer(
      name: '目标客户',
      country: '德国',
      grade: CustomerGrade.a,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: targetId,
      name: '目标项目',
      currentSupplier: 'Supplier A',
      entryPoint: '第二供应商',
      owner: 'Alice',
      stage: OpportunityStage.quoted,
    );

    final wrongCountryId = await db.customerDao.insertCustomer(
      name: '国家不匹配客户',
      country: '法国',
      grade: CustomerGrade.a,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: wrongCountryId,
      name: '国家不匹配项目',
      currentSupplier: 'Supplier A',
      owner: 'Alice',
      stage: OpportunityStage.quoted,
    );

    final partialProjectId = await db.customerDao.insertCustomer(
      name: '项目部分匹配客户',
      country: '德国',
      grade: CustomerGrade.a,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: partialProjectId,
      name: '项目部分匹配',
      currentSupplier: 'Supplier A',
      owner: 'Alice',
      stage: OpportunityStage.newLead,
    );

    final splitProjectId = await db.customerDao.insertCustomer(
      name: '项目条件分散客户',
      country: '德国',
      grade: CustomerGrade.a,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: splitProjectId,
      name: '仅供应商匹配',
      currentSupplier: 'Supplier A',
      owner: 'Alice',
      stage: OpportunityStage.newLead,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: splitProjectId,
      name: '仅阶段匹配',
      currentSupplier: 'Supplier B',
      owner: 'Alice',
      stage: OpportunityStage.quoted,
    );

    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: const CustomersPage(),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await _selectCustomerFilter<String>(
      tester,
      'customer-country-filter',
      '德国',
    );
    await _selectCustomerFilter<String>(
      tester,
      'customer-supplier-filter',
      'Supplier A',
    );
    await _selectCustomerFilter<OpportunityStage>(
      tester,
      'customer-opportunity-stage-filter',
      OpportunityStage.quoted,
    );
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('目标客户'), findsOneWidget);
    expect(find.text('国家不匹配客户'), findsNothing);
    expect(find.text('项目部分匹配客户'), findsNothing);
    expect(find.text('项目条件分散客户'), findsNothing);
  });

  testWidgets('CustomersPage keeps search independent from filter clearing', (
    tester,
  ) async {
    final db = await openTestDb();
    await db.customerDao.insertCustomer(
      name: '目标客户',
      country: '德国',
      grade: CustomerGrade.a,
    );
    await db.customerDao.insertCustomer(
      name: '其他客户',
      country: '法国',
      grade: CustomerGrade.c,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: const CustomersPage(),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.enterText(find.byKey(const ValueKey('customer-search')), '目标');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await _selectCustomerFilter<String>(
      tester,
      'customer-country-filter',
      '德国',
    );
    await _selectCustomerFilter<CustomerGrade>(
      tester,
      'customer-grade-filter',
      CustomerGrade.a,
    );
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('customer-filter-count')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('customer-filter-chip-country')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('customer-filter-chip-grade')),
      findsOneWidget,
    );

    tester
        .widget<InputChip>(
          find.byKey(const ValueKey('customer-filter-chip-country')),
        )
        .onDeleted!();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('customer-filter-chip-country')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('clear-customer-filters')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('customer-filter-count')), findsNothing);
    expect(
      find.byKey(const ValueKey('customer-filter-chip-grade')),
      findsNothing,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('customer-search')))
          .controller!
          .text,
      '目标',
    );
    expect(find.text('目标客户'), findsOneWidget);
    expect(find.text('其他客户'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear-customer-search')));
    await tester.pumpAndSettle();
    expect(find.text('目标客户'), findsOneWidget);
    expect(find.text('其他客户'), findsOneWidget);
  });

  testWidgets('customer advanced filter controls', (tester) async {
    final db = await openTestDb();
    final customerId = await db.customerDao.insertCustomer(name: '高级筛选客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '高级筛选项目',
      productCategory: '体外诊断',
      productModel: 'Model X',
      equipmentBrand: 'Brand A',
      status: OpportunityStatus.active,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: const CustomersPage(),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await _selectCustomerFilter<String>(
      tester,
      'customer-product-category-filter',
      '体外诊断',
    );
    await _selectCustomerFilter<String>(
      tester,
      'customer-product-model-filter',
      'Model X',
    );
    await _selectCustomerFilter<String>(
      tester,
      'customer-equipment-brand-filter',
      'Brand A',
    );
    await _selectCustomerFilter<OpportunityStatus>(
      tester,
      'customer-opportunity-status-filter',
      OpportunityStatus.active,
    );

    var filter = harness.container.read(customerFilterProvider);
    expect(filter.productCategory, '体外诊断');
    expect(filter.productModel, 'Model X');
    expect(filter.equipmentBrand, 'Brand A');
    expect(filter.opportunityStatus, OpportunityStatus.active);
    expect(filter.activeFilterCount, 4);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('customer-filter-count')), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    for (final entry in {
      'customer-product-category-filter': '体外诊断',
      'customer-product-model-filter': 'Model X',
      'customer-equipment-brand-filter': 'Brand A',
      'customer-opportunity-status-filter': OpportunityStatus.active.label,
    }.entries) {
      final key = entry.key;
      await _ensureCustomerFilterVisible(tester, key);
      final dropdown = find.byKey(ValueKey(key));
      expect(dropdown, findsOneWidget);
      expect(
        find.descendant(of: dropdown, matching: find.text(entry.value)),
        findsOneWidget,
      );
    }
    filter = harness.container.read(customerFilterProvider);
    expect(filter.activeFilterCount, 4);
  });

  testWidgets('customer expected close date controls', (tester) async {
    final harness = await _TestHarness.create(home: const CustomersPage());
    addTearDown(() => harness.dispose(tester));
    final notifier = harness.container.read(customerFilterProvider.notifier);
    notifier.setExpectedCloseFrom(DateTime(2026, 8, 20));
    notifier.setExpectedCloseTo(DateTime(2026, 8, 31));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await _ensureCustomerFilterVisible(tester, 'customer-expected-close-from');
    expect(find.text('2026-08-20'), findsOneWidget);
    await _ensureCustomerFilterVisible(tester, 'customer-expected-close-to');
    expect(find.text('2026-08-31'), findsOneWidget);

    notifier.setExpectedCloseTo(DateTime(2026, 8, 19));
    await tester.pumpAndSettle();
    expect(
      harness.container.read(customerFilterProvider).expectedCloseTo,
      DateTime(2026, 8, 31),
    );
    expect(find.text('2026-08-31'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('customer-expected-close-from-clear')),
    );
    await tester.pumpAndSettle();
    var filter = harness.container.read(customerFilterProvider);
    expect(filter.expectedCloseFrom, isNull);
    expect(filter.expectedCloseTo, DateTime(2026, 8, 31));

    await tester.tap(
      find.byKey(const ValueKey('customer-expected-close-to-clear')),
    );
    await tester.pumpAndSettle();
    filter = harness.container.read(customerFilterProvider);
    expect(filter.expectedCloseFrom, isNull);
    expect(filter.expectedCloseTo, isNull);
  });

  testWidgets('customer date picker handles dates outside default bounds', (
    tester,
  ) async {
    final harness = await _TestHarness.create(home: const CustomersPage());
    addTearDown(() => harness.dispose(tester));
    harness.container
        .read(customerFilterProvider.notifier)
        .setExpectedCloseFrom(DateTime(1999, 12, 31));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await _ensureCustomerFilterVisible(tester, 'customer-expected-close-from');
    await tester.tap(
      find.byKey(const ValueKey('customer-expected-close-from')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();
    harness.container
        .read(customerFilterProvider.notifier)
        .setExpectedCloseFrom(DateTime(2101, 1, 1));
    await tester.pumpAndSettle();
    await _ensureCustomerFilterVisible(tester, 'customer-expected-close-to');
    await tester.tap(find.byKey(const ValueKey('customer-expected-close-to')));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('customer anomaly multi select', (tester) async {
    final harness = await _TestHarness.create(home: const CustomersPage());
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    for (final key in [
      'customer-anomaly-stalled-quote',
      'customer-anomaly-stalled-sample',
      'customer-anomaly-long-silence',
    ]) {
      await _ensureCustomerFilterVisible(tester, key);
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
    }

    var filter = harness.container.read(customerFilterProvider);
    expect(filter.anomalies, CustomerAnomalyFilter.values.toSet());
    expect(filter.activeFilterCount, 3);

    await _ensureCustomerFilterVisible(
      tester,
      'customer-anomaly-stalled-sample',
    );
    await tester.tap(
      find.byKey(const ValueKey('customer-anomaly-stalled-sample')),
    );
    await tester.pumpAndSettle();
    filter = harness.container.read(customerFilterProvider);
    expect(filter.anomalies, {
      CustomerAnomalyFilter.stalledQuote,
      CustomerAnomalyFilter.longSilence,
    });
    expect(filter.activeFilterCount, 2);
  });

  testWidgets('customer advanced filter summary chips', (tester) async {
    final harness = await _TestHarness.create(home: const CustomersPage());
    addTearDown(() => harness.dispose(tester));
    final notifier = harness.container.read(customerFilterProvider.notifier);
    notifier.setKeyword('目标');
    notifier.setProductCategory('体外诊断');
    notifier.setProductModel('Model X');
    notifier.setEquipmentBrand('Brand A');
    notifier.setOpportunityStatus(OpportunityStatus.active);
    notifier.setExpectedCloseFrom(DateTime(2026, 8, 1));
    notifier.setExpectedCloseTo(DateTime(2026, 8, 31));
    notifier.toggleAnomaly(CustomerAnomalyFilter.stalledQuote);
    notifier.toggleAnomaly(CustomerAnomalyFilter.stalledSample);
    notifier.toggleAnomaly(CustomerAnomalyFilter.longSilence);
    await harness.pump(tester);

    const chipKeys = [
      'customer-filter-chip-product-category',
      'customer-filter-chip-product-model',
      'customer-filter-chip-equipment-brand',
      'customer-filter-chip-opportunity-status',
      'customer-filter-chip-expected-close-from',
      'customer-filter-chip-expected-close-to',
      'customer-filter-chip-stalled-quote',
      'customer-filter-chip-stalled-sample',
      'customer-filter-chip-long-silence',
    ];
    for (final key in chipKeys) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    expect(find.text('预计成交自 2026-08-01'), findsOneWidget);
    expect(find.text('预计成交至 2026-08-31'), findsOneWidget);
    expect(
      harness.container.read(customerFilterProvider).activeFilterCount,
      chipKeys.length,
    );

    for (var index = 0; index < chipKeys.length; index++) {
      final key = chipKeys[index];
      tester.widget<InputChip>(find.byKey(ValueKey(key))).onDeleted!();
      await tester.pumpAndSettle();

      final filter = harness.container.read(customerFilterProvider);
      expect(filter.keyword, '目标');
      expect(filter.activeFilterCount, chipKeys.length - index - 1);
      expect(find.byKey(ValueKey(key)), findsNothing);
      for (final remainingKey in chipKeys.skip(index + 1)) {
        expect(find.byKey(ValueKey(remainingKey)), findsOneWidget);
      }
      switch (key) {
        case 'customer-filter-chip-product-category':
          expect(filter.productCategory, isNull);
          break;
        case 'customer-filter-chip-product-model':
          expect(filter.productModel, isNull);
          break;
        case 'customer-filter-chip-equipment-brand':
          expect(filter.equipmentBrand, isNull);
          break;
        case 'customer-filter-chip-opportunity-status':
          expect(filter.opportunityStatus, isNull);
          break;
        case 'customer-filter-chip-expected-close-from':
          expect(filter.expectedCloseFrom, isNull);
          break;
        case 'customer-filter-chip-expected-close-to':
          expect(filter.expectedCloseTo, isNull);
          break;
        case 'customer-filter-chip-stalled-quote':
          expect(
            filter.anomalies,
            isNot(contains(CustomerAnomalyFilter.stalledQuote)),
          );
          break;
        case 'customer-filter-chip-stalled-sample':
          expect(
            filter.anomalies,
            isNot(contains(CustomerAnomalyFilter.stalledSample)),
          );
          break;
        case 'customer-filter-chip-long-silence':
          expect(
            filter.anomalies,
            isNot(contains(CustomerAnomalyFilter.longSilence)),
          );
          break;
      }
    }

    expect(find.byKey(const ValueKey('customer-filter-count')), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('customer-search')))
          .controller!
          .text,
      '目标',
    );
  });

  testWidgets('customer advanced filters clear independently from keyword', (
    tester,
  ) async {
    final harness = await _TestHarness.create(home: const CustomersPage());
    addTearDown(() => harness.dispose(tester));
    final notifier = harness.container.read(customerFilterProvider.notifier);
    notifier.setKeyword('目标');
    notifier.setProductCategory('体外诊断');
    notifier.setExpectedCloseFrom(DateTime(2026, 8, 1));
    notifier.toggleAnomaly(CustomerAnomalyFilter.stalledQuote);
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('clear-customer-filters')));
    await tester.pumpAndSettle();
    var filter = harness.container.read(customerFilterProvider);
    expect(filter.keyword, '目标');
    expect(filter.activeFilterCount, 0);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('customer-search')))
          .controller!
          .text,
      '目标',
    );

    notifier.setEquipmentBrand('Brand A');
    notifier.setOpportunityStatus(OpportunityStatus.active);
    notifier.toggleAnomaly(CustomerAnomalyFilter.longSilence);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('clear-customer-search')));
    await tester.pumpAndSettle();
    filter = harness.container.read(customerFilterProvider);
    expect(filter.keyword, isEmpty);
    expect(filter.equipmentBrand, 'Brand A');
    expect(filter.opportunityStatus, OpportunityStatus.active);
    expect(filter.anomalies, {CustomerAnomalyFilter.longSilence});
    expect(filter.activeFilterCount, 3);

    await tester.enterText(
      find.byKey(const ValueKey('customer-search')),
      '第二次搜索',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('clear-customer-filter-sheet')));
    await tester.pumpAndSettle();
    filter = harness.container.read(customerFilterProvider);
    expect(filter.keyword, '第二次搜索');
    expect(filter.activeFilterCount, 0);
    expect(filter.equipmentBrand, isNull);
    expect(filter.opportunityStatus, isNull);
    expect(filter.anomalies, isEmpty);
  });

  testWidgets('customer advanced filters fit 320x700', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await db.customerDao.insertCustomer(name: '高级窄屏客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '高级窄屏项目',
      productCategory: '体外诊断',
      productModel: 'Model X',
      equipmentBrand: 'Brand A',
      status: OpportunityStatus.active,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: const CustomersPage(),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    await _ensureCustomerFilterVisible(
      tester,
      'customer-product-category-filter',
    );
    final categoryDropdown = find.byKey(
      const ValueKey('customer-product-category-filter'),
    );
    final triggerRect = tester.getRect(categoryDropdown);
    expect(triggerRect.left, moreOrLessEquals(16, epsilon: 1));
    expect(triggerRect.right, moreOrLessEquals(304, epsilon: 1));
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    final categoryItem = find.byKey(appDropdownMenuItemKey('体外诊断'));
    final menuItemRect = tester.getRect(categoryItem.last);
    expect(menuItemRect.left, moreOrLessEquals(triggerRect.left, epsilon: 1));
    expect(menuItemRect.right, moreOrLessEquals(triggerRect.right, epsilon: 1));
    expect(menuItemRect.width, moreOrLessEquals(triggerRect.width, epsilon: 1));
    await tester.tapAt(tester.getCenter(categoryItem.last));
    await tester.pumpAndSettle();
    await _selectCustomerFilter<String>(
      tester,
      'customer-product-model-filter',
      'Model X',
    );
    await _selectCustomerFilter<String>(
      tester,
      'customer-equipment-brand-filter',
      'Brand A',
    );
    await _selectCustomerFilter<OpportunityStatus>(
      tester,
      'customer-opportunity-status-filter',
      OpportunityStatus.active,
    );
    for (final key in [
      'customer-anomaly-stalled-quote',
      'customer-anomaly-stalled-sample',
      'customer-anomaly-long-silence',
    ]) {
      await _ensureCustomerFilterVisible(tester, key);
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(FilledButton, '完成'));
    await tester.pumpAndSettle();
    expect(harness.container.read(customerFilterProvider).activeFilterCount, 7);
    expect(
      find.byKey(const ValueKey('customer-filter-chip-product-category')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('customer-filter-chip-long-silence')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomersPage filter sheet supports a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await db.customerDao.insertCustomer(
      name: '窄屏客户',
      country: '德国',
      grade: CustomerGrade.a,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '窄屏项目',
      currentSupplier: 'Supplier A',
      entryPoint: '第二供应商',
      owner: 'Alice',
      stage: OpportunityStage.quoted,
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: const CustomersPage(),
    );
    addTearDown(() => harness.dispose(tester));
    await harness.pump(tester);

    await tester.tap(find.byKey(const ValueKey('open-customer-filters')));
    await tester.pumpAndSettle();
    for (final key in [
      'customer-stage-filter',
      'customer-tag-filter',
      'customer-country-filter',
      'customer-supplier-filter',
      'customer-entry-point-filter',
      'customer-grade-filter',
      'customer-opportunity-stage-filter',
      'customer-owner-filter',
    ]) {
      await _ensureCustomerFilterVisible(tester, key);
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }

    expect(tester.takeException(), isNull);
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
        _dropdownWidget<OpportunityStage>(
          tester,
          'followup-stage',
        ).initialValue,
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
      _dropdownWidget<OpportunityStage>(tester, 'followup-stage').initialValue,
      OpportunityStage.needsConfirmed,
    );

    await tester.tap(find.byKey(const ValueKey('followup-opportunity')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('项目 A').last);
    await tester.pumpAndSettle();

    expect(
      _dropdownWidget<OpportunityStage>(tester, 'followup-stage').initialValue,
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

    final fieldWidths = <double>[];
    for (final key in [
      'followup-method',
      'followup-occurred-at',
      'followup-plan-at',
    ]) {
      final field = find.byKey(ValueKey(key));
      await tester.scrollUntilVisible(
        field,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      fieldWidths.add(tester.getSize(field).width);
    }
    expect(fieldWidths, everyElement(moreOrLessEquals(288, epsilon: 1)));
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
    await _tapCustomerTab(tester, '动态');
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

  testWidgets('CustomerDetailPage exposes attachments for six saved records', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '附件入口客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '附件入口项目',
    );
    final followupId = await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: opportunityId,
      occurredAt: DateTime.utc(2026, 8, 6),
      method: FollowMethod.wechat,
      content: '附件入口跟进',
    );
    final orderId = await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'O-ATT',
      orderedAt: DateTime.utc(2026, 8, 6),
      amountCents: 10000,
    );
    final quoteId = await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-ATT',
      quantity: 10,
      quotedAt: DateTime.utc(2026, 8, 6),
    );
    final sampleId = await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      sampleModel: 'S-ATT',
      quantity: 2,
    );
    final registrationId = await db.registrationDao.insertRegistration(
      opportunityId: opportunityId,
      country: '德国',
    );
    final tenderId = await db.tenderDao.insertTender(
      opportunityId: opportunityId,
      projectNo: 'T-ATT',
    );
    final owners = <(String, int, AttachmentOwner)>[
      ('followup', followupId, FollowupAttachmentOwner(followupId)),
      ('order', orderId, OrderAttachmentOwner(orderId)),
      ('quote', quoteId, QuoteAttachmentOwner(quoteId)),
      ('sample', sampleId, SampleAttachmentOwner(sampleId)),
      (
        'registration',
        registrationId,
        RegistrationAttachmentOwner(registrationId),
      ),
      ('tender', tenderId, TenderAttachmentOwner(tenderId)),
    ];
    for (final (segment, id, owner) in owners) {
      await db.attachmentDao.insertAttachment(
        owner: owner,
        relativePath: 'attachments/2026/08/$segment-$id.pdf',
        originalName: '$segment-$id.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 10,
      );
    }
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await _tapCustomerTab(tester, '业务');

    expect(find.text('报价 Q-ATT · v1'), findsOneWidget);
    expect(find.text('样品 S-ATT'), findsOneWidget);
    expect(find.text('注册 德国'), findsOneWidget);
    expect(find.text('招标 T-ATT'), findsOneWidget);

    for (final (segment, id, _) in owners) {
      await _tapCustomerTab(tester, segment == 'followup' ? '动态' : '业务');
      final action = find.byKey(ValueKey('attachment-$segment-$id'));
      await _scrollToLazyChild(tester, action);
      expect(
        find.descendant(of: action, matching: find.text('1')),
        findsOneWidget,
      );

      final button = tester.widget<IconButton>(
        find.descendant(of: action, matching: find.byType(IconButton)),
      );
      expect(button.onPressed, isNotNull);
      button.onPressed!();
      await tester.pumpAndSettle();
      expect(find.text('附件:$segment:$id'), findsOneWidget);

      harness.router.pop();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
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

  testWidgets('CustomerDetailPage exposes four focused tabs', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '页签客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(find.byType(Tab), findsNWidgets(4));
    expect(find.text('概览'), findsOneWidget);
    expect(find.text('项目'), findsWidgets);
    expect(find.text('业务'), findsWidgets);
    expect(find.text('动态'), findsOneWidget);
    expect(find.text('页签客户'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomerDetailPage opens Dynamic for a highlighted plan', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '提醒客户');
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '提醒项目',
    );
    final planId = await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      title: '指定提醒计划',
      planAt: DateTime.now(),
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(
        customerId: customerId,
        highlightedPlanId: planId,
      ),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(
      DefaultTabController.of(tester.element(find.byType(TabBar))).index,
      3,
    );
    await tester.tap(find.byType(Tab).last);
    await tester.pumpAndSettle();
    // ignore: avoid_print
    expect(find.textContaining('跟进计划'), findsOneWidget);
    expect(find.text('指定提醒计划'), findsOneWidget);
  });

  testWidgets('CustomerDetailPage exposes first-screen quick actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '快捷操作客户');
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '快捷操作项目',
    );
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    expect(
      find.byKey(const ValueKey('customer-quick-actions')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('quick-add-contact')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-add-opportunity')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-add-business')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-add-order')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-add-business')));
    await tester.pumpAndSettle();

    expect(find.text('新增业务记录'), findsOneWidget);
    expect(find.text('快捷操作项目'), findsWidgets);
    expect(find.byKey(const ValueKey('business-action-quote')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('business-action-sample')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('business-action-registration')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('business-action-tender')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomerDetailPage guides business entry without a project', (
    tester,
  ) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '无项目客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.tap(find.byKey(const ValueKey('quick-add-business')));
    await tester.pumpAndSettle();

    expect(find.text('先创建项目'), findsOneWidget);
    expect(find.text('报价、样品、注册和招标都需要关联到具体项目。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('business-create-opportunity')),
      findsOneWidget,
    );
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

  testWidgets('CustomerDetailPage contact form keeps narrow-screen gutters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '窄屏联系人客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.tap(find.byTooltip('新增联系人'));
    await tester.pumpAndSettle();

    expect(find.text('新增联系人'), findsWidgets);
    final nameRect = tester.getRect(find.byKey(const ValueKey('contact-name')));
    expect(nameRect.left, moreOrLessEquals(16));
    expect(nameRect.right, moreOrLessEquals(304));
    expect(find.byKey(const ValueKey('contact-save')), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    await _tapCustomerTab(tester, '业务');

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
    await _scrollToLazyChild(tester, find.text('ORDER-CREATE-001'));
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
    await tester.tap(find.byKey(const ValueKey('quick-add-opportunity')));
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
    await _tapCustomerTab(tester, '项目');

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
    await _tapCustomerTab(tester, '项目');

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
    await _tapCustomerTab(tester, '项目');

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
    await _tapCustomerTab(tester, '项目');
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
    await _tapCustomerTab(tester, '项目');

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
      _dropdownWidget<String>(tester, 'opportunity-entryPoint').initialValue,
      '价格替代',
    );
    expect(
      _dropdownWidget<String>(
        tester,
        'opportunity-investmentAdvice',
      ).initialValue,
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
    final formFieldWidths = <double>[];
    for (final key in [
      'opportunity-stage',
      'opportunity-status',
      'opportunity-expected-close-at',
      'opportunity-next-follow-at',
    ]) {
      final field = find.byKey(ValueKey(key));
      await tester.scrollUntilVisible(
        field,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      formFieldWidths.add(tester.getSize(field).width);
    }
    expect(formFieldWidths, everyElement(moreOrLessEquals(288, epsilon: 1)));
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
      _dropdownWidget<PaymentStatus>(
        tester,
        'order-payment-status',
      ).initialValue,
      PaymentStatus.partial,
    );
    await _selectDropdownValue<PaymentStatus>(
      tester,
      'order-payment-status',
      PaymentStatus.paid,
    );
    await _scrollOrderFieldIntoView(tester, 'order-production-status');
    expect(
      _dropdownWidget<ProductionStatus>(
        tester,
        'order-production-status',
      ).initialValue,
      ProductionStatus.inProgress,
    );
    await _selectDropdownValue<ProductionStatus>(
      tester,
      'order-production-status',
      ProductionStatus.completed,
    );
    await _scrollOrderFieldIntoView(tester, 'order-shipping-status');
    expect(
      _dropdownWidget<ShippingStatus>(
        tester,
        'order-shipping-status',
      ).initialValue,
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
      _dropdownWidget<OrderResult>(tester, 'order-result').initialValue,
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
    await _tapCustomerTab(tester, '业务');

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
    await _scrollToLazyChild(tester, find.text('ORDER-EDITED'));
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
    await _tapCustomerTab(tester, '业务');
    await _tapCustomerTab(tester, '概览');
    expect(find.text('¥0.00'), findsOneWidget);
    await _tapCustomerTab(tester, '业务');

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
    await _tapCustomerTab(tester, '概览');
    await tester.scrollUntilVisible(
      find.text('¥123.45'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('¥123.45'), findsOneWidget);
    await _tapCustomerTab(tester, '业务');
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
    await _tapCustomerTab(tester, '业务');
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
    final contactId = await db.contactDao.insertContact(
      customerId: customerId,
      name: '这是一个用于验证联系人正文宽度的特别特别长的联系人姓名',
      position: '国际采购与供应链决策负责人',
      phone: '13800138000',
      isDecisionMaker: true,
    );
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '这是一个用于验证项目正文与操作按钮分离的特别特别长的项目名称',
      productCategory: '医疗设备与耗材综合解决方案',
      nextAction: '完成跨部门评审并确认下一轮商务谈判时间',
    );
    final orderId = await db.orderDao.insertOrder(
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

    await _tapCustomerTab(tester, '概览');
    final contactActions = find.byKey(ValueKey('contact-actions-$contactId'));
    await tester.scrollUntilVisible(
      contactActions,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.getRect(contactActions).right, lessThanOrEqualTo(304.1));

    await _tapCustomerTab(tester, '项目');
    final opportunityActions = find.byKey(
      ValueKey('opportunity-actions-$opportunityId'),
    );
    await tester.scrollUntilVisible(
      opportunityActions,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.getRect(opportunityActions).right, lessThanOrEqualTo(304.1));

    await _tapCustomerTab(tester, '业务');
    final orderActions = find.byKey(ValueKey('order-actions-$orderId'));
    await tester.scrollUntilVisible(
      orderActions,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.getRect(orderActions).right, lessThanOrEqualTo(304.1));
    /*
    for (final key in [
      'contact-actions-$contactId',
      'opportunity-actions-$opportunityId',
      'order-actions-$orderId',
    ]) {
      final actions = find.byKey(ValueKey(key));
      await tester.scrollUntilVisible(
        actions,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.getRect(actions).right, lessThanOrEqualTo(304.1));
    }
    */
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
        GoRoute(
          path: '/attachments/:ownerType/:ownerId',
          builder: (_, state) => Scaffold(
            body: Text(
              '附件:${state.pathParameters['ownerType']}:${state.pathParameters['ownerId']}',
            ),
          ),
        ),
        GoRoute(path: '/customers', builder: (_, _) => const CustomersPage()),
        GoRoute(
          path: '/customers/new',
          builder: (_, _) => const CustomerFormPage(),
        ),
        GoRoute(
          path: '/customers/:id/edit',
          builder: (_, state) => CustomerFormPage(
            customerId: int.parse(state.pathParameters['id']!),
          ),
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
              path: 'contacts/new',
              builder: (_, state) => ContactFormPage(
                customerId: int.parse(state.pathParameters['id']!),
                initialName: state.uri.queryParameters['name'],
                initialPhone: state.uri.queryParameters['phone'],
              ),
            ),
            GoRoute(
              path: 'contacts/:contactId/edit',
              builder: (_, state) => ContactFormPage(
                customerId: int.parse(state.pathParameters['id']!),
                contactId: int.parse(state.pathParameters['contactId']!),
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
  final actionButton = find.byKey(ValueKey('order-menu-$orderId'));
  await tester.scrollUntilVisible(
    actionButton,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(actionButton);
  await tester.pumpAndSettle();
  await tester.tap(actionButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

Future<void> _scrollToLazyChild(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.drag(scrollable, const Offset(0, 3000));
  await tester.pumpAndSettle();
  for (var attempt = 0; attempt < 20 && target.evaluate().isEmpty; attempt++) {
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
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
  final item = find.byKey(appDropdownMenuItemKey(value));
  await tester.ensureVisible(item.last);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getCenter(item.last));
  await tester.pumpAndSettle();
}

Future<void> _ensureCustomerFilterVisible(
  WidgetTester tester,
  String key,
) async {
  final dropdown = find.byKey(ValueKey(key));
  final panelScrollable = find.descendant(
    of: find.byKey(const ValueKey('customer-filters-list')),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(dropdown, 250, scrollable: panelScrollable);
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
}

Future<void> _selectCustomerFilter<T>(
  WidgetTester tester,
  String key,
  T value,
) async {
  await _ensureCustomerFilterVisible(tester, key);
  final dropdown = find.byKey(ValueKey(key));
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  final item = find.byKey(appDropdownMenuItemKey(value));
  await tester.tapAt(tester.getCenter(item.last));
  await tester.pumpAndSettle();
}

AppDropdownFormField<T> _dropdownWidget<T>(WidgetTester tester, String key) =>
    tester.widget<AppDropdownFormField<T>>(
      find.ancestor(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(AppDropdownFormField<T>),
      ),
    );

bool _editableTextHasFocus(WidgetTester tester, Key fieldKey) {
  final editable = find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(EditableText),
  );
  return tester.widget<EditableText>(editable).focusNode.hasFocus;
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

Future<void> _tapCustomerTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(Tab, label).first);
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
  final actionButton = find.byKey(ValueKey('opportunity-menu-$opportunityId'));
  await tester.scrollUntilVisible(
    actionButton,
    300,
    scrollable: find.byType(Scrollable).first,
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
