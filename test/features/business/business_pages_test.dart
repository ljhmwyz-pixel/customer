import 'package:customer/features/attachments/attachment_providers.dart';
import 'package:customer/features/business/quote_outcome_page.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/business/quote_form_page.dart';
import 'package:customer/features/business/registration_form_page.dart';
import 'package:customer/features/business/sample_form_page.dart';
import 'package:customer/features/business/tender_form_page.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('样品新增修改后返回会提示且继续编辑保留输入', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/form',
          builder: (_, _) => SampleFormPage(
            customerId: customerId,
            opportunityId: opportunityId,
          ),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('首页')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/form');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('sample-milestone-model')),
      '已修改型号',
    );
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('已修改型号'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('business-save-sample')));
    await tester.pumpAndSettle();
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('放弃未保存的修改？'), findsNothing);
  });

  testWidgets('注册和招标文本修改后返回使用同一确认', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );

    Future<void> expectGuard(Widget page, Key fieldKey) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const Text('首页')),
          GoRoute(path: '/form', builder: (_, _) => page),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      router.push('/form');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(fieldKey), '用户修改');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('放弃未保存的修改？'), findsOneWidget);
      await tester.tap(find.text('放弃修改'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      router.dispose();
    }

    await expectGuard(
      RegistrationFormPage(
        customerId: customerId,
        opportunityId: opportunityId,
      ),
      const ValueKey('registration-country'),
    );
    await expectGuard(
      TenderFormPage(customerId: customerId, opportunityId: opportunityId),
      const ValueKey('tender-name'),
    );
  });

  testWidgets('报价结果异步加载后未修改可直接返回，开关修改会提示', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    final quoteId = await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-GUARD',
      quantity: 1,
      quotedAt: DateTime(2026, 8, 7),
    );
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/form',
          builder: (_, _) => QuoteOutcomePage(
            customerId: customerId,
            opportunityId: opportunityId,
            quoteId: quoteId,
          ),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('首页')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/form');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsNothing);

    router.push('/form');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quote-customer-received')));
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
  });

  testWidgets('报价和样品表单使用稳定字段并可保存', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: QuoteFormPage(
            customerId: customerId,
            opportunityId: opportunityId,
          ),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('quote-version-no')),
      'Q-1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quote-version-amount')),
      '1000',
    );
    await tester.tap(find.byKey(const ValueKey('business-save-quote')));
    await tester.pumpAndSettle();
    expect(await db.quoteDao.latest(opportunityId), isNotNull);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: SampleFormPage(
            customerId: customerId,
            opportunityId: opportunityId,
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('sample-milestone-model')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('business-save-sample')), findsOneWidget);
  });

  testWidgets('已有报价和样品直接暴露正确附件与删除动作', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    final quoteId = await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-UX',
      quantity: 1,
      quotedAt: DateTime(2026, 8, 7),
      customerReceived: true,
    );
    final sampleId = await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      sampleModel: 'M-UX',
      quantity: 1,
      status: SampleStatus.testing,
    );

    Future<void> expectOwner(Widget page, AttachmentOwnerRoute owner) async {
      final router = GoRouter(
        initialLocation: '/form',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('客户详情')),
          GoRoute(path: '/form', builder: (_, _) => page),
          GoRoute(
            path: '/attachments/:ownerType/:ownerId',
            builder: (_, state) => Text(
              '附件:${state.pathParameters['ownerType']}:${state.pathParameters['ownerId']}',
            ),
          ),
          GoRoute(
            path: '/customers/:id',
            builder: (_, _) => const Text('客户详情'),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

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
      if (owner.type == AttachmentOwnerType.sample) {
        expect(
          tester
              .widget<TextField>(
                find.byKey(const ValueKey('sample-milestone-model')),
              )
              .readOnly,
          isTrue,
        );
        expect(find.textContaining('当前页面只推进样品节点'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('sample-milestone-result')),
          '附件往返前的输入',
        );
        await tester.pump();
      }
      await tester.tap(
        find.byKey(
          ValueKey('business-record-attachments-${owner.segment}-${owner.id}'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('附件:${owner.segment}:${owner.id}'), findsOneWidget);
      expect(find.text('放弃未保存的修改？'), findsNothing);
      if (owner.type == AttachmentOwnerType.sample) {
        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('附件往返前的输入'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('sample-milestone-quantity')),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          tester
              .widget<TextField>(
                find.byKey(const ValueKey('sample-milestone-quantity')),
              )
              .readOnly,
          isTrue,
        );
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      router.dispose();
    }

    await expectOwner(
      QuoteOutcomePage(
        customerId: customerId,
        opportunityId: opportunityId,
        quoteId: quoteId,
      ),
      AttachmentOwnerRoute(type: AttachmentOwnerType.quote, id: quoteId),
    );
    await expectOwner(
      SampleFormPage(
        customerId: customerId,
        opportunityId: opportunityId,
        sampleId: sampleId,
      ),
      AttachmentOwnerRoute(type: AttachmentOwnerType.sample, id: sampleId),
    );
  });

  testWidgets('新增样品不显示附件和删除动作', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: SampleFormPage(
            customerId: customerId,
            opportunityId: opportunityId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('sample-milestone-model')),
          )
          .readOnly,
      isFalse,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('sample-milestone-quantity')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('sample-milestone-quantity')),
          )
          .readOnly,
      isFalse,
    );
    expect(find.textContaining('附件（'), findsNothing);
    expect(find.text('删除记录'), findsNothing);
  });

  testWidgets('样品维护页确认删除后移除记录并返回客户详情', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    final sampleId = await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      sampleModel: '待删除样品',
      quantity: 1,
    );
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (_, _) => SampleFormPage(
            customerId: customerId,
            opportunityId: opportunityId,
            sampleId: sampleId,
          ),
        ),
        GoRoute(
          path: '/customers/:id',
          builder: (_, state) => Text('客户详情:${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('sample-milestone-result')),
      '删除前修改',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(ValueKey('business-record-delete-sample-$sampleId')),
    );
    await tester.pumpAndSettle();
    expect(find.text('确认删除样品记录？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(await db.sampleDao.findById(sampleId), isNull);
    expect(find.text('客户详情:$customerId'), findsOneWidget);
    expect(find.text('放弃未保存的修改？'), findsNothing);
  });
}
