import 'package:customer/data/database_provider.dart';
import 'package:customer/features/business/quote_form_page.dart';
import 'package:customer/features/business/sample_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
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
}
