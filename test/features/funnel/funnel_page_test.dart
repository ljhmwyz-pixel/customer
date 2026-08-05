import 'package:customer/data/database_provider.dart';
import 'package:customer/features/funnel/funnel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('管理看板显示统计与可解释异常', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    await db.customerDao.insertCustomer(
      name: '长期沉默客户',
      now: DateTime.now().subtract(const Duration(days: 90)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: FunnelPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('客户总数'), findsOneWidget);
    expect(find.text('客户等级'), findsOneWidget);
    expect(find.text('未来三个月加权预计'), findsOneWidget);
    expect(find.textContaining('长期沉默'), findsOneWidget);
    expect(find.textContaining('报价、样品、注册、招标、复购'), findsOneWidget);
  });
}
