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

class AttachmentService {
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
