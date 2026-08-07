import 'package:customer/widgets/form_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('区块默认折叠，点击标题展开内容', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormSection(
            sectionKey: 'documents',
            title: '资料与时间',
            child: const Text('资料清单'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('资料清单'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('form-section-header-documents')),
    );
    await tester.pumpAndSettle();
    expect(find.text('资料清单'), findsOneWidget);
  });

  testWidgets('错误标记可见且不替用户展开区块', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormSection(
            sectionKey: 'risk',
            title: '授权与风险',
            hasError: true,
            child: const Text('我已确认风险'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('form-section-error-risk')),
      findsOneWidget,
    );
    expect(find.text('我已确认风险'), findsNothing);
  });
}
