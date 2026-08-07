import 'package:customer/features/attachments/attachment_providers.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:customer/widgets/business_record_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const owner = AttachmentOwnerRoute(type: AttachmentOwnerType.quote, id: 42);

  testWidgets('显示记录上下文和附件数量并进入正确归属', (tester) async {
    final router = GoRouter(
      initialLocation: '/record',
      routes: [
        GoRoute(
          path: '/record',
          builder: (_, _) => Scaffold(
            body: BusinessRecordActions(
              title: 'Q-2026 · v2',
              statusLabel: '客户已收到',
              contextLabel: '报价记录',
              attachmentOwner: owner,
              onDelete: () async => const AttachmentCleanupReport(),
              onDeleted: (_) {},
            ),
          ),
        ),
        GoRoute(
          path: '/attachments/:ownerType/:ownerId',
          builder: (_, state) => Text(
            '${state.pathParameters['ownerType']}:${state.pathParameters['ownerId']}',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attachmentCountProvider.overrideWith((ref, route) async => 2),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Q-2026 · v2'), findsOneWidget);
    expect(find.text('报价记录 · 当前状态：客户已收到'), findsOneWidget);
    expect(find.text('附件（2）'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('business-record-attachments-quote-42')),
    );
    await tester.pumpAndSettle();

    expect(find.text('quote:42'), findsOneWidget);
  });

  testWidgets('取消不删除，确认后只删除一次并回传清理结果', (tester) async {
    var deleteCalls = 0;
    AttachmentCleanupReport? deletedReport;
    const report = AttachmentCleanupReport(
      failedPaths: ['attachments/failed.pdf'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attachmentCountProvider.overrideWith((ref, route) async => 0),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BusinessRecordActions(
              title: '样品 A',
              statusLabel: '测试中',
              contextLabel: '样品记录',
              attachmentOwner: const AttachmentOwnerRoute(
                type: AttachmentOwnerType.sample,
                id: 7,
              ),
              onDelete: () async {
                deleteCalls += 1;
                return report;
              },
              onDeleted: (value) => deletedReport = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(
      const ValueKey('business-record-delete-sample-7'),
    );
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(find.text('确认删除样品记录？'), findsOneWidget);
    expect(find.textContaining('关联附件'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(deleteCalls, 0);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(deleteCalls, 1);
    expect(deletedReport, same(report));
  });
}
