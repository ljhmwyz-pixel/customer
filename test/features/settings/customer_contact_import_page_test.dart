import 'package:customer/data/database_provider.dart';
import 'package:customer/features/settings/customer_contact_import_page.dart';
import 'package:customer/services/customer_contact_import_service.dart';
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
    expect(find.text('第 1 步'), findsOneWidget);
    expect(find.text('第 2 步'), findsOneWidget);
    expect(find.textContaining('导入前建议先在'), findsOneWidget);
  });

  testWidgets('错误预览按行归组并可在应用内修正字段', (tester) async {
    final row = CustomerContactImportRow(
      line: 2,
      values: const {
        '客户编号': 'C-1',
        '客户名称': '',
        '联系人姓名': '李经理',
        '联系人邮箱': 'bad-email',
      },
    );
    final preview = CustomerContactImportPreview(
      rows: [row],
      issues: const [
        CustomerContactImportIssue(line: 2, field: '客户名称', message: '客户名称不能为空'),
        CustomerContactImportIssue(
          line: 2,
          field: '联系人邮箱',
          message: '联系人邮箱格式无效',
        ),
      ],
      headers: const ['客户编号', '客户名称', '联系人姓名', '联系人邮箱'],
    );
    CustomerContactImportRow? corrected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerContactImportPreviewPanel(
            preview: preview,
            busy: false,
            onImport: () {},
            onCorrected: (row) => corrected = row,
            onRemoved: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('第 2 行'), findsOneWidget);
    expect(find.text('2 个问题'), findsOneWidget);
    expect(find.text('客户名称：未填写'), findsOneWidget);
    expect(find.text('联系人邮箱：bad-email'), findsOneWidget);
    expect(find.text('修正或排除问题行后可导入'), findsOneWidget);

    await tester.tap(find.text('修正本行'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '客户名称'), '修正客户');
    await tester.enterText(
      find.widgetWithText(TextFormField, '联系人邮箱'),
      'li@example.com',
    );
    await tester.tap(find.text('应用修正'));
    await tester.pumpAndSettle();

    expect(corrected, isNotNull);
    expect(corrected!.line, 2);
    expect(corrected!.name, '修正客户');
    expect(corrected!.contactName, '李经理');
    expect(corrected!.contactEmail, 'li@example.com');
  });

  testWidgets('排除问题行需要确认且取消不会触发回调', (tester) async {
    final row = CustomerContactImportRow(line: 4, values: const {'客户名称': ''});
    final preview = CustomerContactImportPreview(
      rows: [row],
      issues: const [
        CustomerContactImportIssue(line: 4, field: '客户名称', message: '客户名称不能为空'),
      ],
      headers: const ['客户名称'],
    );
    var removed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerContactImportPreviewPanel(
            preview: preview,
            busy: false,
            onImport: () {},
            onCorrected: (_) {},
            onRemoved: (_) => removed++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('不导入此行'));
    await tester.pumpAndSettle();
    expect(find.text('排除第 4 行？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(removed, 0);

    await tester.tap(find.text('不导入此行'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认排除'));
    await tester.pumpAndSettle();
    expect(removed, 1);
  });

  testWidgets('错误预览在 320px 深色界面不溢出', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final row = CustomerContactImportRow(
      line: 18,
      values: const {'客户名称': '', '联系人邮箱': 'very-long-invalid-email-value'},
    );
    final preview = CustomerContactImportPreview(
      rows: [row],
      issues: const [
        CustomerContactImportIssue(
          line: 18,
          field: '客户名称',
          message: '客户名称不能为空',
        ),
        CustomerContactImportIssue(
          line: 18,
          field: '联系人邮箱',
          message: '联系人邮箱格式无效',
        ),
      ],
      headers: const ['客户名称', '联系人邮箱'],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CustomerContactImportPreviewPanel(
              preview: preview,
              busy: false,
              onImport: () {},
              onCorrected: (_) {},
              onRemoved: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('修正本行'), findsOneWidget);
    expect(find.text('不导入此行'), findsOneWidget);
  });
}
