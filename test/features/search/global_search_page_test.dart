import 'package:customer/data/database_provider.dart';
import 'package:customer/features/search/global_search_page.dart';
import 'package:customer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('全局搜索展示业务类型并进入所属客户', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    final customerId = await seedCustomer(db, name: '远航工业');
    final contactId = await db.contactDao.insertContact(
      customerId: customerId,
      name: '林采购',
      phone: '13900000000',
    );
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(path: '/search', builder: (_, _) => const GlobalSearchPage()),
        GoRoute(
          path: '/customers/:id',
          builder: (_, state) => Text('客户 ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      '林采购',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('联系人 · 远航工业'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('global-search-contact-$contactId')));
    await tester.pumpAndSettle();
    expect(find.text('客户 $customerId'), findsOneWidget);
  });
}
