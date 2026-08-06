import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:customer/data/database.dart';
import 'package:customer/services/backup_restore_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late AppDatabase database;
  late Directory directory;
  late File databaseFile;

  setUp(() async {
    database = AppDatabase.memory();
    directory = await Directory.systemTemp.createTemp('backup-restore-');
    databaseFile = File('${directory.path}/customer.sqlite');
    await databaseFile.writeAsBytes(_sqliteHeader);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('备份写出带 manifest 的 zip 并分享最终文件', () async {
    final shared = <File>[];
    final service = BackupRestoreService(
      database: database,
      databaseFile: () async => databaseFile,
      outputDirectory: () async => directory,
      sharer: _FakeSharer(shared),
      clock: () => DateTime(2026, 8, 6, 10, 11, 12),
    );

    final result = await service.backupAndShare();
    final archive = ZipDecoder().decodeBytes(await shared.single.readAsBytes());
    final manifest =
        jsonDecode(
              utf8.decode(
                archive.findFile('manifest.json')!.content as List<int>,
              ),
            )
            as Map<String, dynamic>;

    expect(result.fileName, '客户跟进备份_20260806_101112.zip');
    expect(manifest['formatVersion'], 1);
    expect(manifest['schemaVersion'], 8);
    expect(archive.findFile('customer.sqlite')!.content, _sqliteHeader);
    expect(await File('${shared.single.path}.tmp').exists(), isFalse);
  });

  test('合法备份写入待恢复文件，错误数据库被拒绝', () async {
    final service = BackupRestoreService(
      database: database,
      databaseFile: () async => databaseFile,
      outputDirectory: () async => directory,
      sharer: const _NoopSharer(),
    );
    final backup = File('${directory.path}/input.zip');
    final valid = await _createValidDatabase(directory);
    await backup.writeAsBytes(_zip(await valid.readAsBytes()));

    await service.stageRestore(backup);
    expect(
      await File('${databaseFile.path}.restore-pending').readAsBytes(),
      await valid.readAsBytes(),
    );

    final invalid = File('${directory.path}/invalid.zip');
    await invalid.writeAsBytes(_zip([1, 2, 3]));
    await expectLater(service.stageRestore(invalid), throwsFormatException);
  });

  test('备份包含附件文件和相对路径清单', () async {
    final root = Directory('${directory.path}/attachments/2026/08')
      ..createSync(recursive: true);
    File('${root.path}/note.txt').writeAsStringSync('attachment');
    final shared = <File>[];
    final service = BackupRestoreService(
      database: database,
      databaseFile: () async => databaseFile,
      outputDirectory: () async => directory,
      attachmentDirectory: () async =>
          Directory('${directory.path}/attachments'),
      sharer: _FakeSharer(shared),
      clock: () => DateTime(2026, 8, 6, 10, 11, 12),
    );

    await service.backupAndShare();
    final archive = ZipDecoder().decodeBytes(await shared.single.readAsBytes());
    final manifest =
        jsonDecode(
              utf8.decode(
                archive.findFile('manifest.json')!.content as List<int>,
              ),
            )
            as Map<String, dynamic>;
    expect(manifest['attachments'], ['attachments/2026/08/note.txt']);
    expect(
      utf8.decode(
        archive.findFile('attachments/2026/08/note.txt')!.content as List<int>,
      ),
      'attachment',
    );
  });

  test('启动应用恢复后只消费一次，并清理 WAL sidecar', () async {
    await databaseFile.writeAsBytes([1, 2, 3]);
    final pending = File('${databaseFile.path}.restore-pending')
      ..writeAsBytesSync([4, 5, 6]);
    File('${databaseFile.path}-wal').writeAsBytesSync([7]);
    File('${databaseFile.path}-shm').writeAsBytesSync([8]);

    await applyPendingRestore(databaseFile);
    expect(await databaseFile.readAsBytes(), [4, 5, 6]);
    expect(await pending.exists(), isFalse);
    expect(await File('${databaseFile.path}-wal').exists(), isFalse);
    expect(await File('${databaseFile.path}-shm').exists(), isFalse);

    await databaseFile.writeAsBytes([9]);
    await applyPendingRestore(databaseFile);
    expect(await databaseFile.readAsBytes(), [9]);
  });
}

const _sqliteHeader = [
  83,
  81,
  76,
  105,
  116,
  101,
  32,
  102,
  111,
  114,
  109,
  97,
  116,
  32,
  51,
  0,
];

List<int> _zip(List<int> databaseBytes) {
  final archive = Archive()
    ..addFile(
      ArchiveFile('customer.sqlite', databaseBytes.length, databaseBytes),
    )
    ..addFile(
      ArchiveFile.string(
        'manifest.json',
        jsonEncode({
          'formatVersion': 1,
          'schemaVersion': 8,
          'createdAt': '2026-08-06T02:00:00Z',
        }),
      ),
    );
  return ZipEncoder().encode(archive)!;
}

Future<File> _createValidDatabase(Directory directory) async {
  final file = File('${directory.path}/valid.sqlite');
  final raw = sqlite.sqlite3.open(file.path);
  raw.execute('CREATE TABLE customers (id INTEGER PRIMARY KEY)');
  raw.execute('CREATE TABLE attachments (id INTEGER PRIMARY KEY)');
  raw.execute('PRAGMA user_version = 8');
  raw.close();
  return file;
}

class _FakeSharer implements BackupFileSharer {
  _FakeSharer(this.files);
  final List<File> files;

  @override
  Future<void> share(File file) async => files.add(file);
}

class _NoopSharer implements BackupFileSharer {
  const _NoopSharer();

  @override
  Future<void> share(File file) async {}
}
