import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/business/registration_form_page.dart';
import 'package:customer/features/business/tender_form_page.dart';
import 'package:customer/features/customers/customer_detail_page.dart';
import 'package:customer/models/enums.dart';
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
      tester
          .widget<DropdownButtonFormField<RegistrationDocumentStatus>>(
            find.byKey(const ValueKey('registration-document-status')),
          )
          .initialValue,
      RegistrationDocumentStatus.pending,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<RegistrationStatus>>(
            find.byKey(const ValueKey('registration-status')),
          )
          .initialValue,
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
      RegistrationStatus.blocked.label,
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
      tester
          .widget<DropdownButtonFormField<TenderRiskLevel>>(
            find.byKey(const ValueKey('tender-risk-level')),
          )
          .initialValue,
      TenderRiskLevel.mediumHigh,
    );

    await _selectDropdown(
      tester,
      'tender-risk-level',
      TenderRiskLevel.high.label,
    );
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
      TenderDocumentStatus.complete.label,
    );
    await _selectDropdown(
      tester,
      'tender-qualification-status',
      TenderQualificationStatus.qualified.label,
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
      TenderVerificationStatus.confirmed.label,
    );
    await _selectDropdown(
      tester,
      'tender-funding-status',
      TenderVerificationStatus.confirmed.label,
    );
    await _selectDropdown(
      tester,
      'tender-risk-level',
      TenderRiskLevel.high.label,
    );
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

  Future<void> pump(WidgetTester tester, Widget page) async {
    _router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(path: '/form', builder: (_, _) => page),
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

Future<void> _selectDropdown(
  WidgetTester tester,
  String key,
  String label,
) async {
  final finder = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(finder);
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
  final button = find.descendant(of: tile, matching: find.byTooltip('项目操作'));
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}
