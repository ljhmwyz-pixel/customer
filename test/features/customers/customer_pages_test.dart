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

  testWidgets('FollowupFormPage can save without a next plan', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '待跟进客户');
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: FollowupFormPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('followup-content')),
      '已发送产品资料',
    );
    final pageScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('next-plan-title')),
      200,
      scrollable: pageScrollable,
    );
    await tester.enterText(find.byKey(const ValueKey('next-plan-title')), '');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-followup')),
      200,
      scrollable: pageScrollable,
    );
    await tester.tap(find.byKey(const ValueKey('save-followup')));
    await tester.pump();
    expect(find.text('计划标题不能为空'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('followup-next-choice')),
      -200,
      scrollable: pageScrollable,
    );
    await tester.tap(find.text('暂不跟进'));
    await tester.pump();
    expect(find.byKey(const ValueKey('next-plan-title')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-followup')),
      200,
      scrollable: pageScrollable,
    );
    await tester.tap(find.byKey(const ValueKey('save-followup')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(await db.followupDao.countOf(customerId), 1);
    expect(await db.planDao.listOf(customerId), isEmpty);
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
    final harness = _TestHarness(
      db: db,
      scheduler: _FakeReminderScheduler(),
      contactActions: _FakeContactActions(),
      home: CustomerDetailPage(customerId: customerId),
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    await tester.tap(find.byTooltip('新增订单'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('order-no')),
      'ORDER-CREATE-001',
    );
    await tester.enterText(
      find.byKey(const ValueKey('order-amount')),
      '123.45',
    );
    await tester.enterText(
      find.byKey(const ValueKey('order-description')),
      '年度服务套餐',
    );
    await tester.tap(find.byKey(const ValueKey('save-order')));
    await tester.pumpAndSettle();

    final orders = await db.orderDao.listOf(customerId);
    expect(orders, hasLength(1));
    expect(orders.single.orderNo, 'ORDER-CREATE-001');
    expect(orders.single.amountCents, 12345);
    expect(orders.single.description, '年度服务套餐');
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

  testWidgets('CustomerDetailPage edits an existing order', (tester) async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db, name: '编辑订单客户');
    final orderId = await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: 'ORDER-OLD',
      orderedAt: DateTime(2026, 8, 5),
      amountCents: 100,
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
    await tester.enterText(
      find.byKey(const ValueKey('order-no')),
      'ORDER-EDITED',
    );
    await tester.enterText(find.byKey(const ValueKey('order-amount')), '88.80');
    await tester.enterText(
      find.byKey(const ValueKey('order-description')),
      '更新后的服务内容',
    );
    await tester.tap(find.byKey(const ValueKey('save-order')));
    await tester.pumpAndSettle();

    final order = await db.orderDao.findById(orderId);
    expect(order?.orderNo, 'ORDER-EDITED');
    expect(order?.amountCents, 8880);
    expect(order?.description, '更新后的服务内容');
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
