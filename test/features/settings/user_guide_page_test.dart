import 'package:customer/features/settings/user_guide_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('显示试用入口和核心操作章节', (tester) async {
    await tester.pumpWidget(MaterialApp(home: const UserGuidePage()));
    await tester.pumpAndSettle();

    expect(find.text('使用说明'), findsOneWidget);
    expect(find.text('三分钟开始试用'), findsOneWidget);
    expect(find.text('去导入示例数据'), findsOneWidget);
    expect(find.text('1. 今日：处理跟进任务'), findsOneWidget);
    expect(find.text('7. 数据：导出和备份'), findsOneWidget);
  });

  testWidgets('发布模式隐藏示例数据说明和入口', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UserGuidePage(showSampleData: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('去导入示例数据'), findsNothing);
    expect(find.textContaining('先导入示例数据'), findsNothing);
    expect(find.text('1. 今日：处理跟进任务'), findsOneWidget);
  });
}
