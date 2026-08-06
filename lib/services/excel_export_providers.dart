import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database_provider.dart';
import 'excel_export_service.dart';
import 'excel_file_export_service.dart';

final excelExportServiceProvider = Provider<ExcelExportService>((ref) {
  final db = ref.watch(databaseProvider);
  return ExcelExportService(
    loadSnapshot: (now) => db.exportDao.loadExcelSnapshot(now: now),
    builder: const ExcelWorkbookBuilder(),
    sharer: const SharePlusExcelFileSharer(),
    cacheDirectory: getTemporaryDirectory,
  );
});
