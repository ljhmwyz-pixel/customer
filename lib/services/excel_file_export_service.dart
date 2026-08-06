import 'dart:io';

import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../data/daos/export_dao.dart';
import 'excel_export_service.dart';

class ExcelExportResult {
  const ExcelExportResult({required this.fileName, required this.sizeBytes});

  final String fileName;
  final int sizeBytes;
}

abstract interface class ExcelFileSharer {
  Future<void> share(File file);
}

class SharePlusExcelFileSharer implements ExcelFileSharer {
  const SharePlusExcelFileSharer();

  @override
  Future<void> share(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        subject: '客户业务导出',
      ),
    );
  }
}

abstract interface class ExcelExportService {
  Future<ExcelExportResult> exportAndShare();
}

class DefaultExcelExportService implements ExcelExportService {
  DefaultExcelExportService({
    required this.loadSnapshot,
    required this.builder,
    required this.sharer,
    required this.cacheDirectory,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final Future<ExcelExportSnapshot> Function(DateTime now) loadSnapshot;
  final ExcelWorkbookBuilder builder;
  final ExcelFileSharer sharer;
  final Future<Directory> Function() cacheDirectory;
  final DateTime Function() clock;

  @override
  Future<ExcelExportResult> exportAndShare() async {
    final now = clock().toLocal();
    final snapshot = await loadSnapshot(now);
    final bytes = builder.build(snapshot);
    final directory = await cacheDirectory();
    final fileName = '客户业务导出_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx';
    final file = File('${directory.path}/$fileName');
    final temp = File('${file.path}.tmp');
    try {
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(file.path);
      await sharer.share(file);
      return ExcelExportResult(fileName: fileName, sizeBytes: bytes.length);
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }
}
