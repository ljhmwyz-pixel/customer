import 'dart:io';

import 'package:customer/data/daos/export_dao.dart';
import 'package:customer/services/excel_export_service.dart';
import 'package:customer/services/excel_file_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('写入缓存并分享 xlsx，临时文件原子重命名', () async {
    final directory = await Directory.systemTemp.createTemp('xlsx-export-');
    final shared = <File>[];
    try {
      final service = ExcelExportService(
        loadSnapshot: (_) async => const ExcelExportSnapshot(
          todayTasks: [],
          customerProjects: [],
          followups: [],
          businessEvents: [],
        ),
        builder: const ExcelWorkbookBuilder(),
        sharer: _FakeSharer(shared),
        cacheDirectory: () async => directory,
        clock: () => DateTime(2026, 8, 6, 9, 10, 11),
      );

      final result = await service.exportAndShare();

      expect(result.fileName, '客户业务导出_20260806_091011.xlsx');
      expect(result.sizeBytes, greaterThan(0));
      expect(shared, hasLength(1));
      expect(shared.single.path, endsWith(result.fileName));
      expect(await File('${shared.single.path}.tmp').exists(), isFalse);
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('分享失败仍清理临时文件并保留最终文件供重试', () async {
    final directory = await Directory.systemTemp.createTemp(
      'xlsx-export-fail-',
    );
    try {
      final service = ExcelExportService(
        loadSnapshot: (_) async => const ExcelExportSnapshot(
          todayTasks: [],
          customerProjects: [],
          followups: [],
          businessEvents: [],
        ),
        builder: const ExcelWorkbookBuilder(),
        sharer: const _ThrowingSharer(),
        cacheDirectory: () async => directory,
        clock: () => DateTime.utc(2026, 8, 6, 9),
      );

      await expectLater(service.exportAndShare(), throwsA(anything));
      final files = (await directory.list().toList()).whereType<File>();
      expect(files.single.path, endsWith('.xlsx'));
      expect(files.any((file) => file.path.endsWith('.tmp')), isFalse);
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

class _FakeSharer implements ExcelFileSharer {
  _FakeSharer(this.files);
  final List<File> files;

  @override
  Future<void> share(File file) async => files.add(file);
}

class _ThrowingSharer implements ExcelFileSharer {
  const _ThrowingSharer();

  @override
  Future<void> share(File file) async => throw StateError('share failed');
}
