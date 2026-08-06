import 'package:customer/features/settings/sample_data_page.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:customer/services/sample_data_providers.dart';
import 'package:customer/services/sample_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('打开页面只读取状态，不会自动导入', (tester) async {
    final service = _FakeSampleDataService();
    await _pump(tester, service);

    expect(find.text('尚未导入'), findsOneWidget);
    expect(find.text('导入 9 条示例数据'), findsOneWidget);
    expect(service.inspectCalls, 1);
    expect(service.importCalls, 0);
  });

  testWidgets('取消导入确认不会写入，确认后刷新为已导入', (tester) async {
    final service = _FakeSampleDataService();
    await _pump(tester, service);

    await tester.tap(find.text('导入 9 条示例数据'));
    await tester.pumpAndSettle();
    expect(find.text('确认导入示例数据？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(service.importCalls, 0);

    await tester.tap(find.text('导入 9 条示例数据'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '确认导入'));
    await tester.pumpAndSettle();

    expect(service.importCalls, 1);
    expect(find.text('已导入 9 条'), findsOneWidget);
    expect(find.text('撤销全部示例数据'), findsOneWidget);
    expect(find.text('9 条示例数据已导入'), findsOneWidget);
  });

  testWidgets('撤销要求危险确认并展示清理失败路径数', (tester) async {
    final service = _FakeSampleDataService(customerCount: 9)
      ..undoReport = const AttachmentCleanupReport(
        failedPaths: ['attachments/a.pdf'],
      );
    await _pump(tester, service);

    await tester.tap(find.text('撤销全部示例数据'));
    await tester.pumpAndSettle();
    expect(find.text('撤销全部示例数据？'), findsOneWidget);
    expect(find.textContaining('正式客户不会受影响'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认撤销'));
    await tester.pumpAndSettle();

    expect(service.undoCalls, 1);
    expect(find.text('尚未导入'), findsOneWidget);
    expect(find.textContaining('1 个附件文件待下次启动重试'), findsOneWidget);
  });

  testWidgets('操作失败保留当前状态并允许重试', (tester) async {
    final service = _FakeSampleDataService()..importError = StateError('boom');
    await _pump(tester, service);

    await tester.tap(find.text('导入 9 条示例数据'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '确认导入'));
    await tester.pumpAndSettle();

    expect(find.text('尚未导入'), findsOneWidget);
    expect(find.text('导入失败，请重试'), findsOneWidget);
    expect(find.text('导入 9 条示例数据'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, _FakeSampleDataService service) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sampleDataServiceProvider.overrideWithValue(service)],
      child: const MaterialApp(home: SampleDataPage()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeSampleDataService implements SampleDataService {
  _FakeSampleDataService({this.customerCount = 0});

  int customerCount;
  int inspectCalls = 0;
  int importCalls = 0;
  int undoCalls = 0;
  Object? importError;
  AttachmentCleanupReport undoReport = const AttachmentCleanupReport();

  @override
  Future<SampleImportResult> importAll() async {
    importCalls++;
    if (importError case final error?) throw error;
    customerCount = 9;
    return SampleImportResult.imported;
  }

  @override
  Future<SampleDataState> inspect() async {
    inspectCalls++;
    return SampleDataState(customerCount: customerCount);
  }

  @override
  Future<SampleUndoResult> undoAll() async {
    undoCalls++;
    final deleted = customerCount;
    customerCount = 0;
    return SampleUndoResult(
      deletedCustomerCount: deleted,
      cleanupReport: undoReport,
    );
  }
}
