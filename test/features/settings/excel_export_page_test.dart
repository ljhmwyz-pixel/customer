import 'dart:async';
import 'package:customer/services/excel_export_providers.dart';
import 'package:customer/services/excel_file_export_service.dart';
import 'package:customer/features/settings/excel_export_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('打开页面不自动导出，点击后显示结果', (tester) async {
    final service = _fakeService();
    await _pump(tester, service);

    expect(service.calls, 0);
    await tester.tap(find.text('生成并分享 Excel'));
    await tester.pumpAndSettle();

    expect(service.calls, 1);
    expect(find.text('已生成并打开分享面板'), findsOneWidget);
    expect(find.textContaining('客户业务导出_20260806_091011.xlsx'), findsOneWidget);
    expect(find.textContaining('2.0 KB'), findsOneWidget);
  });

  testWidgets('生成中阻止重复点击，失败后可重试', (tester) async {
    final completer = Completer<ExcelExportResult>();
    final service = _fakeService(completer: completer);
    await _pump(tester, service);

    await tester.tap(find.text('生成并分享 Excel'));
    await tester.pump();
    await tester.tap(find.text('正在生成…'));
    expect(service.calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.completeError(StateError('share failed'));
    await tester.pumpAndSettle();
    expect(find.text('导出或分享失败，请重试。'), findsOneWidget);

    await tester.tap(find.text('生成并分享 Excel'));
    await tester.pumpAndSettle();
    expect(service.calls, 2);
  });
}

Future<void> _pump(WidgetTester tester, ExcelExportService service) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [excelExportServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const ExcelExportPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

_CountingExcelExportService _fakeService({
  Completer<ExcelExportResult>? completer,
}) {
  return _CountingExcelExportService(completer: completer);
}

class _CountingExcelExportService implements ExcelExportService {
  _CountingExcelExportService({this.completer});

  final Completer<ExcelExportResult>? completer;
  int calls = 0;

  @override
  Future<ExcelExportResult> exportAndShare() {
    calls++;
    if (completer != null) return completer!.future;
    return Future.value(
      const ExcelExportResult(
        fileName: '客户业务导出_20260806_091011.xlsx',
        sizeBytes: 2048,
      ),
    );
  }
}
