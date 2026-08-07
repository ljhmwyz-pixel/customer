import 'package:customer/widgets/form_error_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('revealFormError scrolls to and focuses a mounted target', (
    tester,
  ) async {
    final targetKey = GlobalKey();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 1200),
                KeyedSubtree(
                  key: targetKey,
                  child: TextField(focusNode: focusNode),
                ),
                const SizedBox(height: 600),
              ],
            ),
          ),
        ),
      ),
    );

    final reveal = revealFormError(targetKey: targetKey, focusNode: focusNode);
    await tester.pump();
    await tester.pumpAndSettle();
    await reveal;
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
    expect(find.byType(TextField).hitTestable(), findsOneWidget);
  });

  testWidgets('revealFormError ignores an unmounted target', (tester) async {
    final targetKey = GlobalKey();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    final reveal = revealFormError(targetKey: targetKey);
    await tester.pump();
    await reveal;
  });
}
