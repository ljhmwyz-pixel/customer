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

class ExcelExportService {
  ExcelExportService({
    required Future<ExcelExportSnapshot> Function(DateTime now) loadSnapshot,
    required ExcelWorkbookBuilder builder,
    required ExcelFileSharer sharer,
    required Future<Directory> Function() cacheDirectory,
    DateTime Function()? clock,
  }) : _loadSnapshot = loadSnapshot,
       _builder = builder,
       _sharer = sharer,
       _cacheDirectory = cacheDirectory,
       _clock = clock ?? DateTime.now;

  final Future<ExcelExportSnapshot> Function(DateTime now) _loadSnapshot;
  final ExcelWorkbookBuilder _builder;
  final ExcelFileSharer _sharer;
  final Future<Directory> Function() _cacheDirectory;
  final DateTime Function() _clock;

  Future<ExcelExportResult> exportAndShare() async {
    final now = _clock().toLocal();
    final snapshot = await _loadSnapshot(now);
    final bytes = _builder.build(snapshot);
    final directory = await _cacheDirectory();
    final fileName = '客户业务导出_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx';
    final file = File('${directory.path}/$fileName');
    final temp = File('${file.path}.tmp');
    try {
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(file.path);
      await _sharer.share(file);
      return ExcelExportResult(fileName: fileName, sizeBytes: bytes.length);
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }
}
