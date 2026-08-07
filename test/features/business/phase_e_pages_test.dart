import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/attachments/attachment_providers.dart';
import 'package:customer/features/business/registration_form_page.dart';
import 'package:customer/features/business/tender_form_page.dart';
import 'package:customer/features/customers/customer_detail_page.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/widgets/app_dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('注册表单暴露稳定字段、默认值并可保存', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));

    await fixture.pump(
      tester,
      RegistrationFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );

    for (final key in _registrationKeys) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }
    expect(
      _dropdownWidget<RegistrationDocumentStatus>(
        tester,
        'registration-document-status',
      ).initialValue,
      RegistrationDocumentStatus.pending,
    );
    expect(
      _dropdownWidget<RegistrationStatus>(
        tester,
        'registration-status',
      ).initialValue,
      RegistrationStatus.preparing,
    );

    await _tapSave(tester, 'registration-save');
    expect(
      (await fixture.db.registrationDao.listOf(fixture.opportunityId)),
      hasLength(1),
    );
  });

  testWidgets('注册受阻时必须填写下一步行动', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));
    await fixture.pump(
      tester,
      RegistrationFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );

    await _selectDropdown(
      tester,
      'registration-status',
      RegistrationStatus.blocked,
    );
    await _tapSave(tester, 'registration-save');

    expect(find.text('注册受阻时必须填写下一步行动'), findsOneWidget);
    expect(
      await fixture.db.registrationDao.listOf(fixture.opportunityId),
      isEmpty,
    );
  });

  testWidgets('招标表单暴露稳定字段、默认中高风险和高风险确认', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));
    await fixture.pump(
      tester,
      TenderFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );

    for (final key in _tenderKeys) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }
    expect(
      _dropdownWidget<TenderRiskLevel>(
        tester,
        'tender-risk-level',
      ).initialValue,
      TenderRiskLevel.mediumHigh,
    );

    await _selectDropdown(tester, 'tender-risk-level', TenderRiskLevel.high);
    await tester.enterText(
      find.byKey(const ValueKey('tender-floor-price-support')),
      '申请底价支持',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tender-risk-warning')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tender-risk-acknowledged')),
      findsOneWidget,
    );
  });

  testWidgets('高风险底价支持必须确认风险后才能保存', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));
    await fixture.pump(
      tester,
      TenderFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );

    await _selectDropdown(
      tester,
      'tender-document-status',
      TenderDocumentStatus.complete,
    );
    await _selectDropdown(
      tester,
      'tender-qualification-status',
      TenderQualificationStatus.qualified,
    );
    await tester.enterText(
      find.byKey(const ValueKey('tender-bidder')),
      '当地投标主体',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tender-deposit-minor')),
      '10000',
    );
    await _selectDropdown(
      tester,
      'tender-local-team-status',
      TenderVerificationStatus.confirmed,
    );
    await _selectDropdown(
      tester,
      'tender-funding-status',
      TenderVerificationStatus.confirmed,
    );
    await _selectDropdown(tester, 'tender-risk-level', TenderRiskLevel.high);
    await tester.enterText(
      find.byKey(const ValueKey('tender-floor-price-support')),
      '申请底价支持',
    );

    await _tapSave(tester, 'tender-save');
    expect(find.text('高风险授权或底价支持必须明确确认风险'), findsOneWidget);
    expect(await fixture.db.tenderDao.listOf(fixture.opportunityId), isEmpty);

    ScaffoldMessenger.of(
      tester.element(find.byType(TenderFormPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    final riskAcknowledgement = find.byKey(
      const ValueKey('tender-risk-acknowledged'),
    );
    await tester.scrollUntilVisible(
      riskAcknowledgement,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(riskAcknowledgement);
    await tester.pumpAndSettle();

    await _tapSave(tester, 'tender-save');
    final tender = (await fixture.db.tenderDao.listOf(
      fixture.opportunityId,
    )).single;
    expect(tender.riskLevel, TenderRiskLevel.high.dbValue);
    expect(tender.floorPriceSupport, '申请底价支持');
  });

  testWidgets('招标表单在 320 宽度下字段和下拉菜单保持页面边距', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));
    await fixture.pump(
      tester,
      TenderFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );

    final date = find.byKey(const ValueKey('tender-deadline-at'));
    final dropdown = find.byKey(const ValueKey('tender-document-status'));
    final dateRect = tester.getRect(date);
    final dropdownRect = tester.getRect(dropdown);
    expect(dateRect.left, moreOrLessEquals(16, epsilon: 1));
    expect(dateRect.right, moreOrLessEquals(304, epsilon: 1));
    expect(dropdownRect.width, moreOrLessEquals(dateRect.width, epsilon: 1));
    final dateLabel = find.descendant(of: date, matching: find.text('投标截止日期'));
    final datePlaceholder = find.descendant(
      of: date,
      matching: find.text('请选择'),
    );
    expect(dateLabel, findsOneWidget);
    expect(datePlaceholder, findsOneWidget);
    expect(
      tester.getRect(dateLabel).bottom,
      lessThanOrEqualTo(tester.getRect(datePlaceholder).top),
    );

    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    final menuItem = find.byKey(
      appDropdownMenuItemKey(TenderDocumentStatus.complete),
    );
    final menuRect = tester.getRect(menuItem);
    expect(menuRect.left, moreOrLessEquals(dropdownRect.left, epsilon: 1));
    expect(menuRect.right, moreOrLessEquals(dropdownRect.right, epsilon: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('项目操作可进入注册和招标表单并携带项目编号', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));
    final router = GoRouter(
      initialLocation: '/customers/${fixture.customerId}',
      routes: [
        GoRoute(
          path: '/customers/:id',
          builder: (_, state) => CustomerDetailPage(
            customerId: int.parse(state.pathParameters['id']!),
          ),
          routes: [
            GoRoute(
              path: 'opportunities/:opportunityId/registrations/new',
              builder: (_, state) => Text(
                '注册:${state.pathParameters['id']}:${state.pathParameters['opportunityId']}',
              ),
            ),
            GoRoute(
              path: 'opportunities/:opportunityId/tenders/new',
              builder: (_, state) => Text(
                '招标:${state.pathParameters['id']}:${state.pathParameters['opportunityId']}',
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fixture.db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await _selectOpportunityAction(tester, fixture.opportunityId, '新增注册');
    expect(
      find.text('注册:${fixture.customerId}:${fixture.opportunityId}'),
      findsOneWidget,
    );

    router.go('/customers/${fixture.customerId}');
    await tester.pumpAndSettle();
    await _selectOpportunityAction(tester, fixture.opportunityId, '新增招标');
    expect(
      find.text('招标:${fixture.customerId}:${fixture.opportunityId}'),
      findsOneWidget,
    );
  });

  testWidgets('已有注册和招标直接暴露正确附件与删除动作', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));
    final registrationId = await fixture.db.registrationDao.insertRegistration(
      opportunityId: fixture.opportunityId,
      country: '德国',
      status: RegistrationStatus.submitted,
    );
    final tenderId = await fixture.db.tenderDao.insertTender(
      opportunityId: fixture.opportunityId,
      projectNo: 'T-UX',
      name: '医院项目',
      status: TenderStatus.open,
    );

    Future<void> expectOwner(Widget page, AttachmentOwnerRoute owner) async {
      await fixture.pump(tester, page, attachmentOwner: owner);
      expect(
        find.byKey(
          ValueKey('business-record-attachments-${owner.segment}-${owner.id}'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey('business-record-delete-${owner.segment}-${owner.id}'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(
          ValueKey('business-record-attachments-${owner.segment}-${owner.id}'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('附件:${owner.segment}:${owner.id}'), findsOneWidget);
    }

    await expectOwner(
      RegistrationFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
        registrationId: registrationId,
      ),
      AttachmentOwnerRoute(
        type: AttachmentOwnerType.registration,
        id: registrationId,
      ),
    );
    await expectOwner(
      TenderFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
        tenderId: tenderId,
      ),
      AttachmentOwnerRoute(type: AttachmentOwnerType.tender, id: tenderId),
    );
  });

  testWidgets('新增注册和招标不显示附件与删除动作', (tester) async {
    final fixture = await _BusinessFixture.create();
    addTearDown(() => fixture.dispose(tester));

    await fixture.pump(
      tester,
      RegistrationFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );
    expect(find.textContaining('附件（'), findsNothing);
    expect(find.text('删除记录'), findsNothing);

    await fixture.pump(
      tester,
      TenderFormPage(
        customerId: fixture.customerId,
        opportunityId: fixture.opportunityId,
      ),
    );
    expect(find.textContaining('附件（'), findsNothing);
    expect(find.text('删除记录'), findsNothing);
  });
}

const _registrationKeys = [
  'registration-country',
  'registration-requirements',
  'registration-document-checklist',
  'registration-document-status',
  'registration-submitted-at',
  'registration-expected-completed-at',
  'registration-actual-completed-at',
  'registration-cost-bearer',
  'registration-status',
  'registration-current-obstacle',
  'registration-next-action',
  'registration-document-due-at',
  'registration-milestone-at',
  'registration-milestone-title',
  'registration-save',
];

const _tenderKeys = [
  'tender-project-no',
  'tender-name',
  'tender-deadline-at',
  'tender-document-status',
  'tender-qualification-status',
  'tender-bidder',
  'tender-deposit-minor',
  'tender-customer-experience',
  'tender-local-team-status',
  'tender-funding-status',
  'tender-risk-level',
  'tender-authorization-type',
  'tender-authorization-expires-at',
  'tender-exclusive-quote-scope',
  'tender-floor-price-support',
  'tender-status',
  'tender-next-action',
  'tender-save',
];

class _BusinessFixture {
  _BusinessFixture(this.db, this.customerId, this.opportunityId);

  static Future<_BusinessFixture> create() async {
    final db = await openTestDb();
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    return _BusinessFixture(db, customerId, opportunityId);
  }

  final AppDatabase db;
  final int customerId;
  final int opportunityId;
  GoRouter? _router;

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    AttachmentOwnerRoute? attachmentOwner,
  }) async {
    _router?.dispose();
    _router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('客户详情')),
        GoRoute(path: '/form', builder: (_, _) => page),
        GoRoute(path: '/customers/:id', builder: (_, _) => const Text('客户详情')),
        if (attachmentOwner != null)
          GoRoute(
            path: '/attachments/:ownerType/:ownerId',
            builder: (_, state) => Text(
              '附件:${state.pathParameters['ownerType']}:${state.pathParameters['ownerId']}',
            ),
          ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: _router!),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    _router?.dispose();
    await db.close();
  }
}

Future<void> _selectDropdown<T>(
  WidgetTester tester,
  String key,
  T value,
) async {
  final finder = find.byKey(ValueKey(key));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder.hitTestable());
  await tester.pumpAndSettle();
  final item = find.byKey(appDropdownMenuItemKey(value));
  expect(item, findsOneWidget, reason: 'menu item for $key');
  await tester.tapAt(tester.getCenter(item));
  await tester.pumpAndSettle();
}

AppDropdownFormField<T> _dropdownWidget<T>(WidgetTester tester, String key) =>
    tester.widget<AppDropdownFormField<T>>(
      find.ancestor(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(AppDropdownFormField<T>),
      ),
    );

Future<void> _tapSave(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _selectOpportunityAction(
  WidgetTester tester,
  int opportunityId,
  String action,
) async {
  final button = find.byKey(ValueKey('opportunity-menu-$opportunityId'));
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}
