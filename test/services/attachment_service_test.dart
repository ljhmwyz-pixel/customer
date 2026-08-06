import 'dart:io';

import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/attachment_file_service.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/helpers.dart';

void main() {
  late AppDatabase db;
  late int followupId;
  late File source;
  late _FakeAttachmentFileStore fileStore;
  late _FakeAttachmentOpener opener;
  late AttachmentService service;

  setUp(() async {
    db = await openTestDb();
    final customerId = await seedCustomer(db);
    followupId = await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      occurredAt: DateTime(2026, 8, 6),
      method: FollowMethod.wechat,
      content: '发送报价附件',
    );
    source = File('/tmp/source.pdf');
    fileStore = _FakeAttachmentFileStore();
    opener = _FakeAttachmentOpener();
    service = AttachmentService(
      dao: db.attachmentDao,
      fileStore: fileStore,
      opener: opener,
    );
  });

  tearDown(() async => db.close());

  Future<int> seedAttachment() => db.attachmentDao.insertAttachment(
    owner: FollowupAttachmentOwner(followupId),
    relativePath: fileStore.stored.relativePath,
    originalName: fileStore.stored.originalName,
    mimeType: fileStore.stored.mimeType,
    sizeBytes: fileStore.stored.sizeBytes,
  );

  test('add 先保存文件再写入真实元数据', () async {
    final row = await service.add(
      owner: FollowupAttachmentOwner(followupId),
      source: source,
      originalName: '报价单.pdf',
      mimeType: 'application/pdf',
    );

    expect(fileStore.storeCalls, hasLength(1));
    expect(fileStore.storeCalls.single.source, source);
    expect(row.relativePath, fileStore.stored.relativePath);
    expect(row.originalName, fileStore.stored.originalName);
    expect(row.mimeType, fileStore.stored.mimeType);
    expect(row.sizeBytes, fileStore.stored.sizeBytes);
    expect(await db.attachmentDao.countAll(), 1);
  });

  test('数据库插入失败时清理新文件并继续抛出原异常', () async {
    Object? caught;
    try {
      await service.add(
        owner: const FollowupAttachmentOwner(-999),
        source: source,
        originalName: '报价单.pdf',
        mimeType: 'application/pdf',
      );
      fail('外键无效时应抛出数据库异常');
    } catch (error) {
      caught = error;
    }

    expect(caught, isNotNull);
    expect(fileStore.deletedPaths, [fileStore.stored.relativePath]);
    expect(await db.attachmentDao.countAll(), 0);
  });

  test('delete 在记录不存在时不访问文件系统', () async {
    expect(await service.delete(999), AttachmentDeleteResult.recordNotFound);
    expect(fileStore.deletedPaths, isEmpty);
  });

  test('delete 删除数据库后稳定报告物理文件不存在', () async {
    final id = await seedAttachment();
    fileStore.deleteResult = AttachmentFileDeleteResult.notFound;

    expect(await service.delete(id), AttachmentDeleteResult.fileNotFound);
    expect(await db.attachmentDao.findById(id), isNull);
  });

  test('delete 同时删除数据库记录和物理文件', () async {
    final id = await seedAttachment();

    expect(await service.delete(id), AttachmentDeleteResult.deleted);
    expect(fileStore.deletedPaths, [fileStore.stored.relativePath]);
    expect(await db.attachmentDao.findById(id), isNull);
  });

  test('delete 将物理删除失败映射为稳定清理失败', () async {
    final id = await seedAttachment();
    fileStore.deleteResult = AttachmentFileDeleteResult.failed;

    expect(await service.delete(id), AttachmentDeleteResult.cleanupFailed);
    expect(await db.attachmentDao.findById(id), isNull);
  });

  test('open 在记录不存在时不访问文件系统和平台适配器', () async {
    expect(await service.open(999), AttachmentOpenResult.recordNotFound);
    expect(fileStore.existsPaths, isEmpty);
    expect(opener.paths, isEmpty);
  });

  test('open 在物理文件不存在时不调用平台适配器', () async {
    final id = await seedAttachment();
    fileStore.fileExists = false;

    expect(await service.open(id), AttachmentOpenResult.fileNotFound);
    expect(opener.paths, isEmpty);
  });

  test('open 将内部适配器结果映射为稳定公共结果', () async {
    final id = await seedAttachment();
    const cases = {
      AttachmentOpenAdapterResult.opened: AttachmentOpenResult.opened,
      AttachmentOpenAdapterResult.fileNotFound:
          AttachmentOpenResult.fileNotFound,
      AttachmentOpenAdapterResult.noAppToOpen: AttachmentOpenResult.noAppToOpen,
      AttachmentOpenAdapterResult.permissionDenied:
          AttachmentOpenResult.permissionDenied,
      AttachmentOpenAdapterResult.platformFailure:
          AttachmentOpenResult.platformFailure,
      AttachmentOpenAdapterResult.failed: AttachmentOpenResult.failed,
    };

    for (final entry in cases.entries) {
      opener.result = entry.key;
      expect(await service.open(id), entry.value);
    }
    expect(opener.paths, everyElement(fileStore.absolute));
  });

  test('open 捕获适配器异常且不向公共 API 泄露插件异常', () async {
    final id = await seedAttachment();
    opener.error = StateError('platform plugin error');

    expect(await service.open(id), AttachmentOpenResult.failed);
  });
}

class _StoreCall {
  const _StoreCall(this.source, this.originalName, this.mimeType);

  final File source;
  final String originalName;
  final String mimeType;
}

class _FakeAttachmentFileStore implements AttachmentFileStore {
  final stored = const StoredAttachmentFile(
    relativePath: 'attachments/2026/08/stored.pdf',
    absolutePath: '/private/app/attachments/2026/08/stored.pdf',
    originalName: '报价单.pdf',
    mimeType: 'application/pdf',
    sizeBytes: 2048,
  );
  final storeCalls = <_StoreCall>[];
  final existsPaths = <String>[];
  final deletedPaths = <String>[];
  bool fileExists = true;
  AttachmentFileDeleteResult deleteResult = AttachmentFileDeleteResult.deleted;

  String get absolute => stored.absolutePath;

  @override
  Future<StoredAttachmentFile> store({
    required File source,
    required String originalName,
    required String mimeType,
  }) async {
    storeCalls.add(_StoreCall(source, originalName, mimeType));
    return stored;
  }

  @override
  Future<bool> exists(String relativePath) async {
    existsPaths.add(relativePath);
    return fileExists;
  }

  @override
  Future<AttachmentFileDeleteResult> delete(String relativePath) async {
    deletedPaths.add(relativePath);
    return deleteResult;
  }

  @override
  Future<String> absolutePath(String relativePath) async => absolute;
}

class _FakeAttachmentOpener implements AttachmentOpener {
  final paths = <String>[];
  AttachmentOpenAdapterResult result = AttachmentOpenAdapterResult.opened;
  Object? error;

  @override
  Future<AttachmentOpenAdapterResult> open(String absolutePath) async {
    paths.add(absolutePath);
    final currentError = error;
    if (currentError != null) throw currentError;
    return result;
  }
}
