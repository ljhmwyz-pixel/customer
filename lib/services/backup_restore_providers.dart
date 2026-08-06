import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database_provider.dart';
import 'attachment_source_service.dart';
import 'backup_restore_service.dart';

final attachmentSourceServiceProvider = Provider<AttachmentSourceService>(
  (ref) => AttachmentSourceService(),
);

final backupRestoreServiceProvider = Provider<BackupRestoreActions>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupRestoreService(
    database: db,
    databaseFile: () async {
      final directory = await getApplicationDocumentsDirectory();
      return File(p.join(directory.path, 'customer.sqlite'));
    },
    outputDirectory: getTemporaryDirectory,
    sharer: const SharePlusBackupFileSharer(),
    attachmentDirectory: () async {
      final directory = await getApplicationDocumentsDirectory();
      return Directory(p.join(directory.path, 'attachments'));
    },
  );
});
