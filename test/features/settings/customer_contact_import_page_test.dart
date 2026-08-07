import 'package:customer/data/database_provider.dart';
import 'package:customer/features/settings/customer_contact_import_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  testWidgets('导入页面提供模板和文件选择入口', (tester) async {
    final db = await openTestDb();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: CustomerContactImportPage()),
      ),
    );
    expect(find.text('下载导入模板'), findsOneWidget);
    expect(find.text('选择 Excel / CSV 文件'), findsOneWidget);
    expect(find.textContaining('导入前建议先在'), findsOneWidget);
  });
}
