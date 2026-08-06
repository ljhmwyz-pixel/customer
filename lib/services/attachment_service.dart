// Public named parameters intentionally differ from private backing fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import '../data/daos/attachment_dao.dart';
import '../data/database.dart';
import 'attachment_file_service.dart';

enum AttachmentOpenAdapterResult {
  opened,
  fileNotFound,
  noAppToOpen,
  permissionDenied,
  platformFailure,
  failed,
}

abstract interface class AttachmentOpener {
  Future<AttachmentOpenAdapterResult> open(String absolutePath);
}

enum AttachmentDeleteResult {
  deleted,
  recordNotFound,
  fileNotFound,
  cleanupFailed,
}

enum AttachmentOpenResult {
  opened,
  recordNotFound,
  fileNotFound,
  noAppToOpen,
  permissionDenied,
  platformFailure,
  failed,
}

class AttachmentCleanupReport {
  const AttachmentCleanupReport({
    this.deletedPaths = const [],
    this.missingPaths = const [],
    this.failedPaths = const [],
  });

  final List<String> deletedPaths;
  final List<String> missingPaths;
  final List<String> failedPaths;

  bool get hasFailures => failedPaths.isNotEmpty;
}

abstract interface class AttachmentGraphCleaner {
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  });

  Future<AttachmentCleanupReport> retryOrphanCleanup();
}

class PassthroughAttachmentGraphCleaner implements AttachmentGraphCleaner {
  const PassthroughAttachmentGraphCleaner();

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async {
    await loadAttachments();
    await deleteDatabaseGraph();
    return const AttachmentCleanupReport();
  }

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async =>
      const AttachmentCleanupReport();
}

class AttachmentService implements AttachmentGraphCleaner {
  const AttachmentService({
    required AttachmentDao dao,
    required AttachmentFileStore fileStore,
    required AttachmentOpener opener,
  }) : _dao = dao,
       _fileStore = fileStore,
       _opener = opener;

  final AttachmentDao _dao;
  final AttachmentFileStore _fileStore;
  final AttachmentOpener _opener;

  Future<AttachmentRow> add({
    required AttachmentOwner owner,
    required File source,
    required String originalName,
    required String mimeType,
  }) async {
    final stored = await _fileStore.store(
      source: source,
      originalName: originalName,
      mimeType: mimeType,
    );
    late final int id;
    try {
      id = await _dao.insertAttachment(
        owner: owner,
        relativePath: stored.relativePath,
        originalName: stored.originalName,
        mimeType: stored.mimeType,
        sizeBytes: stored.sizeBytes,
      );
    } catch (_) {
      try {
        await _fileStore.delete(stored.relativePath);
      } catch (_) {
        // 清理失败不能覆盖真正需要上报的数据库异常。
      }
      rethrow;
    }
    final row = await _dao.findById(id);
    if (row == null) {
      throw StateError('附件写入成功后无法读取：$id');
    }
    return row;
  }

  Future<AttachmentDeleteResult> delete(int attachmentId) async {
    final row = await _dao.findById(attachmentId);
    if (row == null) return AttachmentDeleteResult.recordNotFound;
    await _dao.deleteAttachment(attachmentId);
    final result = await _fileStore.delete(row.relativePath);
    return switch (result) {
      AttachmentFileDeleteResult.deleted => AttachmentDeleteResult.deleted,
      AttachmentFileDeleteResult.notFound =>
        AttachmentDeleteResult.fileNotFound,
      AttachmentFileDeleteResult.failed => AttachmentDeleteResult.cleanupFailed,
    };
  }

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async {
    final paths =
        (await loadAttachments())
            .map((row) => row.relativePath)
            .toSet()
            .toList()
          ..sort();
    await deleteDatabaseGraph();
    return _cleanupPaths(paths);
  }

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async {
    final storedPaths = await _fileStore.listStoredPaths();
    final referencedPaths = (await _dao.listAll())
        .map((row) => row.relativePath)
        .toSet();
    final orphanedPaths = storedPaths.difference(referencedPaths).toList()
      ..sort();
    return _cleanupPaths(orphanedPaths);
  }

  Future<AttachmentCleanupReport> _cleanupPaths(Iterable<String> paths) async {
    final deleted = <String>[];
    final missing = <String>[];
    final failed = <String>[];
    for (final path in paths) {
      final result = await _fileStore.delete(path);
      switch (result) {
        case AttachmentFileDeleteResult.deleted:
          deleted.add(path);
        case AttachmentFileDeleteResult.notFound:
          missing.add(path);
        case AttachmentFileDeleteResult.failed:
          failed.add(path);
      }
    }
    return AttachmentCleanupReport(
      deletedPaths: List.unmodifiable(deleted),
      missingPaths: List.unmodifiable(missing),
      failedPaths: List.unmodifiable(failed),
    );
  }

  Future<AttachmentOpenResult> open(int attachmentId) async {
    final row = await _dao.findById(attachmentId);
    if (row == null) return AttachmentOpenResult.recordNotFound;
    if (!await _fileStore.exists(row.relativePath)) {
      return AttachmentOpenResult.fileNotFound;
    }
    try {
      final absolutePath = await _fileStore.absolutePath(row.relativePath);
      final result = await _opener.open(absolutePath);
      return switch (result) {
        AttachmentOpenAdapterResult.opened => AttachmentOpenResult.opened,
        AttachmentOpenAdapterResult.fileNotFound =>
          AttachmentOpenResult.fileNotFound,
        AttachmentOpenAdapterResult.noAppToOpen =>
          AttachmentOpenResult.noAppToOpen,
        AttachmentOpenAdapterResult.permissionDenied =>
          AttachmentOpenResult.permissionDenied,
        AttachmentOpenAdapterResult.platformFailure =>
          AttachmentOpenResult.platformFailure,
        AttachmentOpenAdapterResult.failed => AttachmentOpenResult.failed,
      };
    } catch (_) {
      return AttachmentOpenResult.failed;
    }
  }
}
