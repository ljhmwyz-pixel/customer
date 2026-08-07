import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer/widgets/unsaved_changes_guard.dart';

void main() {
  testWidgets('clean page pops without confirmation', (tester) async {
    await tester.pumpWidget(_Harness(initialDirty: false));
    await tester.tap(find.text('打开表单'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('放弃未保存的修改？'), findsNothing);
  });

  testWidgets('dirty page can continue editing and then discard', (
    tester,
  ) async {
    await tester.pumpWidget(_Harness(initialDirty: true));
    await tester.tap(find.text('打开表单'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('guard-input')), '已修改');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('guard-input')), findsOneWidget);
    expect(find.text('放弃未保存的修改？'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('放弃修改'));
    await tester.pumpAndSettle();
    expect(find.text('首页'), findsOneWidget);
  });

  testWidgets('repeated back presses show only one confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(_Harness(initialDirty: true));
    await tester.tap(find.text('打开表单'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.tap(find.byType(BackButton), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('放弃未保存的修改？'), findsOneWidget);
  });

  testWidgets('system back uses the same confirmation', (tester) async {
    await tester.pumpWidget(_Harness(initialDirty: true));
    await tester.tap(find.text('打开表单'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('放弃未保存的修改？'), findsOneWidget);
  });
}

class _Harness extends StatefulWidget {
  const _Harness({required this.initialDirty});

  final bool initialDirty;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          const Text('首页'),
          Builder(
            builder: (context) => FilledButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => _GuardForm(initialDirty: widget.initialDirty),
                ),
              ),
              child: const Text('打开表单'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _GuardForm extends StatefulWidget {
  const _GuardForm({required this.initialDirty});

  final bool initialDirty;

  @override
  State<_GuardForm> createState() => _GuardFormState();
}

class _GuardFormState extends State<_GuardForm> {
  late bool dirty = widget.initialDirty;

  @override
  Widget build(BuildContext context) => UnsavedChangesGuard(
    hasUnsavedChanges: dirty,
    child: Scaffold(
      appBar: AppBar(title: const Text('表单')),
      body: TextField(
        key: const ValueKey('guard-input'),
        onChanged: (_) => setState(() => dirty = true),
      ),
    ),
  );
}
