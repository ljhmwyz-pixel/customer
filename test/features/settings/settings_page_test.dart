import 'package:customer/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('发布模式隐藏示例数据入口', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsPage(showSampleData: false)),
    );

    expect(find.text('示例数据'), findsNothing);
    expect(find.text('导入或整体撤销业务示例'), findsNothing);
    expect(find.text('Excel 导出'), findsOneWidget);
  });
}
