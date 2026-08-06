import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../data/attachment_path.dart';
import '../data/database.dart';

class BackupResult {
  const BackupResult({required this.fileName, required this.sizeBytes});

  final String fileName;
  final int sizeBytes;
}

abstract interface class BackupFileSharer {
  Future<void> share(File file);
}

abstract interface class BackupRestoreActions {
  Future<BackupResult> backupAndShare();

  Future<void> stageRestore(File backup);
}

class SharePlusBackupFileSharer implements BackupFileSharer {
  const SharePlusBackupFileSharer();

  @override
  Future<void> share(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        subject: '客户跟进备份',
      ),
    );
  }
}

class BackupRestoreService implements BackupRestoreActions {
  BackupRestoreService({
    required this.database,
    required this.databaseFile,
    required this.outputDirectory,
    required this.sharer,
    this.attachmentDirectory,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  static const formatVersion = 1;
  static const manifestName = 'manifest.json';
  static const dataName = 'data.json';
  static const databaseName = 'customer.sqlite';

  final AppDatabase database;
  final Future<File> Function() databaseFile;
  final Future<Directory> Function() outputDirectory;
  final BackupFileSharer sharer;
  final Future<Directory> Function()? attachmentDirectory;
  final DateTime Function() clock;

  @override
  Future<BackupResult> backupAndShare() async {
    await database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final source = await databaseFile();
    if (!await source.exists()) throw StateError('数据库文件不存在');
    final now = clock().toLocal();
    final databaseBytes = await source.readAsBytes();
    final dataBytes = await _snapshotData(source);
    final archive = Archive()
      ..addFile(ArchiveFile(databaseName, databaseBytes.length, databaseBytes))
      ..addFile(ArchiveFile(dataName, dataBytes.length, dataBytes));
    final attachmentPaths = await _addAttachments(archive);
    final checksums = <String, String>{
      databaseName: _checksum(databaseBytes),
      dataName: _checksum(dataBytes),
    };
    for (final path in attachmentPaths) {
      final entry = archive.findFile(path);
      if (entry != null) {
        checksums[path] = _checksum(List<int>.from(entry.content));
      }
    }
    archive.addFile(
      ArchiveFile.string(
        manifestName,
        jsonEncode({
          'formatVersion': formatVersion,
          'schemaVersion': database.schemaVersion,
          'createdAt': now.toUtc().toIso8601String(),
          'attachments': attachmentPaths,
          'checksums': checksums,
        }),
      ),
    );
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) throw StateError('备份压缩失败');
    final directory = await outputDirectory();
    final fileName = '客户跟进备份_${DateFormat('yyyyMMdd_HHmmss').format(now)}.zip';
    final file = File('${directory.path}/$fileName');
    final temp = File('${file.path}.tmp');
    try {
      await temp.writeAsBytes(encoded, flush: true);
      await temp.rename(file.path);
      await sharer.share(file);
      return BackupResult(fileName: fileName, sizeBytes: encoded.length);
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }

  @override
  Future<void> stageRestore(File backup) async {
    final bytes = await backup.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final manifestFile = archive.findFile(manifestName);
    final databaseEntry = archive.findFile(databaseName);
    final dataEntry = archive.findFile(dataName);
    if (manifestFile == null || databaseEntry == null || dataEntry == null) {
      throw const FormatException('备份文件缺少必要内容');
    }
    final manifest = jsonDecode(utf8.decode(manifestFile.content as List<int>));
    if (manifest is! Map ||
        manifest['formatVersion'] != formatVersion ||
        manifest['schemaVersion'] != database.schemaVersion) {
      throw const FormatException('备份版本与当前应用不兼容');
    }
    final databaseBytes = List<int>.from(databaseEntry.content as List<int>);
    final dataBytes = List<int>.from(dataEntry.content as List<int>);
    _verifyChecksum(manifest, databaseName, databaseBytes);
    _verifyChecksum(manifest, dataName, dataBytes);
    try {
      jsonDecode(utf8.decode(dataBytes));
    } catch (_) {
      throw const FormatException('备份数据清单无效');
    }
    const sqliteHeader = [
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
    if (databaseBytes.length < sqliteHeader.length ||
        !const ListEquality().equals(
          databaseBytes.take(sqliteHeader.length).toList(),
          sqliteHeader,
        )) {
      throw const FormatException('备份数据库文件无效');
    }
    final target = await databaseFile();
    final staging = File('${target.path}.restore-validating');
    final pending = File('${target.path}.restore-pending');
    try {
      await staging.writeAsBytes(databaseBytes, flush: true);
      await _validateDatabase(staging);
      await _stageAttachments(archive, target);
      await staging.rename(pending.path);
    } finally {
      if (await staging.exists()) await staging.delete();
    }
  }

  Future<List<int>> _snapshotData(File source) async {
    final raw = sqlite.sqlite3.open(
      source.path,
      mode: sqlite.OpenMode.readOnly,
    );
    try {
      final names = raw
          .select(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .map((row) => row.values.first as String)
          .toList();
      final tables = <String, Object?>{};
      for (final name in names) {
        final rows = raw.select(
          'SELECT * FROM "${name.replaceAll('"', '""')}"',
        );
        tables[name] = rows
            .map(
              (row) => <String, Object?>{
                for (final key in row.keys) key: _jsonValue(row[key]),
              },
            )
            .toList();
      }
      return utf8.encode(
        jsonEncode({'schemaVersion': database.schemaVersion, 'tables': tables}),
      );
    } finally {
      raw.close();
    }
  }

  static Object? _jsonValue(Object? value) {
    if (value is List<int>) return base64Encode(value);
    return value;
  }

  static String _checksum(List<int> bytes) => sha256.convert(bytes).toString();

  static void _verifyChecksum(Object manifest, String name, List<int> bytes) {
    if (manifest is! Map || manifest['checksums'] is! Map) {
      throw const FormatException('备份缺少校验清单');
    }
    final expected = (manifest['checksums'] as Map)[name];
    if (expected is! String || expected != _checksum(bytes)) {
      throw const FormatException('备份文件校验失败');
    }
  }

  Future<List<String>> _addAttachments(Archive archive) async {
    final loader = attachmentDirectory;
    if (loader == null) return const [];
    final root = await loader();
    if (!await root.exists()) return const [];
    final paths = <String>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative = AttachmentPath.normalizeRelative(
        p.posix.join(
          AttachmentPath.rootDirName,
          p.relative(entity.path, from: root.path),
        ),
      );
      archive.addFile(
        ArchiveFile(
          relative,
          await entity.length(),
          await entity.readAsBytes(),
        ),
      );
      paths.add(relative);
    }
    paths.sort();
    return paths;
  }

  Future<void> _stageAttachments(Archive archive, File target) async {
    final loader = attachmentDirectory;
    if (loader == null) return;
    final manifest = archive.findFile(manifestName);
    if (manifest == null) return;
    final decoded = jsonDecode(utf8.decode(manifest.content as List<int>));
    final paths = decoded is Map && decoded['attachments'] is List
        ? List<Object?>.from(decoded['attachments'] as List)
        : const <Object?>[];
    final staging = Directory('${target.path}.restore-attachments-staging');
    final pending = Directory('${target.path}.restore-attachments-pending');
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    try {
      for (final value in paths) {
        if (value is! String) throw const FormatException('备份附件清单无效');
        final relative = AttachmentPath.normalizeRelative(value);
        final entry = archive.findFile(relative);
        if (entry == null) throw const FormatException('备份缺少附件文件');
        _verifyChecksum(decoded, relative, List<int>.from(entry.content));
        final destination = File(
          p.join(
            staging.path,
            relative.substring('${AttachmentPath.rootDirName}/'.length),
          ),
        );
        await destination.parent.create(recursive: true);
        await destination.writeAsBytes(
          List<int>.from(entry.content),
          flush: true,
        );
      }
      if (await pending.exists()) await pending.delete(recursive: true);
      await staging.rename(pending.path);
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<void> _validateDatabase(File file) async {
    final candidate = sqlite.sqlite3.open(
      file.path,
      mode: sqlite.OpenMode.readOnly,
    );
    try {
      final version = candidate
          .select('PRAGMA user_version')
          .first
          .values
          .first;
      if (version != database.schemaVersion) {
        throw const FormatException('备份数据库版本无效');
      }
      final check = candidate.select('PRAGMA quick_check').first.values.first;
      if (check != 'ok') {
        throw const FormatException('备份数据库完整性校验失败');
      }
      final tables = candidate.select(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name IN ('customers', 'attachments')",
      );
      if (tables.length != 2) {
        throw const FormatException('备份数据库结构无效');
      }
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('备份数据库结构无效');
    } finally {
      candidate.close();
    }
  }
}

class ListEquality {
  const ListEquality();

  bool equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
