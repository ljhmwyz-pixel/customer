import 'package:customer/data/attachment_path.dart';
import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 验收第 6 项：附件表仅存相对路径，应用目录变化后仍能正确解析。
///
/// 应用目录会变：重装、系统升级迁移、备份恢复到另一台设备，
/// Android 的 `/data/user/0/<pkg>/files` 都可能换掉。
/// 存绝对路径的话所有附件在那一刻集体失联。
void main() {
  // 两个「不同设备/不同安装」的应用目录。
  const dirA = '/data/user/0/com.example.customer/app_flutter';
  const dirB = '/data/user/10/com.example.customer/app_flutter';

  group('relativeFor', () {
    test('按年月分目录，一律 / 分隔', () {
      final path = AttachmentPath.relativeFor(
        at: DateTime(2026, 8, 4),
        fileId: 'abc123',
        extension: 'jpg',
      );
      expect(path, 'attachments/2026/08/abc123.jpg');
      expect(path, isNot(contains(r'\')));
    });

    test('月份补零', () {
      expect(
        AttachmentPath.relativeFor(
          at: DateTime(2026, 1, 9),
          fileId: 'x',
          extension: 'png',
        ),
        'attachments/2026/01/x.png',
      );
    });

    test('扩展名带点也能正确处理', () {
      expect(
        AttachmentPath.relativeFor(
          at: DateTime(2026, 12, 31),
          fileId: 'y',
          extension: '.pdf',
        ),
        'attachments/2026/12/y.pdf',
      );
    });

    test('返回值一定是相对路径', () {
      final path = AttachmentPath.relativeFor(
        at: DateTime(2026, 8, 4),
        fileId: 'z',
        extension: 'jpg',
      );
      expect(path.startsWith('/'), isFalse);
    });
  });

  group('resolve', () {
    test('同一相对路径在两个应用目录下都解析正确', () {
      const rel = 'attachments/2026/08/abc123.jpg';

      expect(
        AttachmentPath.resolve(appDir: dirA, relativePath: rel),
        '$dirA/attachments/2026/08/abc123.jpg',
      );
      expect(
        AttachmentPath.resolve(appDir: dirB, relativePath: rel),
        '$dirB/attachments/2026/08/abc123.jpg',
      );
    });

    test('appDir 末尾带斜杠不产生双斜杠', () {
      expect(
        AttachmentPath.resolve(
          appDir: '$dirA/',
          relativePath: 'attachments/2026/08/a.jpg',
        ),
        '$dirA/attachments/2026/08/a.jpg',
      );
    });

    test('传绝对路径直接抛错', () {
      expect(
        () => AttachmentPath.resolve(
          appDir: dirA,
          relativePath: '/data/user/0/other/a.jpg',
        ),
        throwsArgumentError,
      );
    });

    for (final invalidPath in [
      '',
      'attachments',
      'other/2026/08/a.jpg',
      'attachments-other/2026/08/a.jpg',
      '../outside.txt',
      'attachments/../../outside.txt',
    ]) {
      test('拒绝不安全路径：${invalidPath.isEmpty ? '<empty>' : invalidPath}', () {
        expect(
          () => AttachmentPath.resolve(appDir: dirA, relativePath: invalidPath),
          throwsArgumentError,
        );
      });
    }

    test('归一化后仍在附件根目录内', () {
      expect(
        AttachmentPath.resolve(
          appDir: dirA,
          relativePath: 'attachments/2026/../08/a.jpg',
        ),
        '$dirA/attachments/08/a.jpg',
      );
    });

    test('resolveDir 返回所在目录', () {
      expect(
        AttachmentPath.resolveDir(
          appDir: dirA,
          relativePath: 'attachments/2026/08/a.jpg',
        ),
        '$dirA/attachments/2026/08',
      );
    });
  });

  group('与数据库记录配合', () {
    late AppDatabase db;

    setUp(() async => db = await openTestDb());
    tearDown(() async => db.close());

    test('库里存的是相对路径，换目录后同一条记录仍能解析', () async {
      final customerId = await seedCustomer(db);
      final followupId = await db.followupDao.insertAndTouchCustomer(
        customerId: customerId,
        occurredAt: DateTime(2026, 8, 4),
        method: FollowMethod.meeting,
        content: '拍了合同照片',
      );

      final rel = AttachmentPath.relativeFor(
        at: DateTime(2026, 8, 4),
        fileId: 'contract-001',
        extension: 'jpg',
      );
      final id = await db.attachmentDao.insertAttachment(
        owner: FollowupAttachmentOwner(followupId),
        relativePath: rel,
        originalName: '合同.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      );

      final row = (await db.attachmentDao.findById(id))!;
      // 落库的值不含任何设备相关前缀。
      expect(row.relativePath, rel);
      expect(row.relativePath.startsWith('/'), isFalse);
      expect(row.relativePath, isNot(contains('com.example')));

      // 同一条记录，换到另一个应用目录仍指向正确位置。
      expect(db.attachmentDao.absolutePathOf(row, appDir: dirA), '$dirA/$rel');
      expect(db.attachmentDao.absolutePathOf(row, appDir: dirB), '$dirB/$rel');
    });

    test('全表扫一遍确认没有任何绝对路径混进去', () async {
      final customerId = await seedCustomer(db);
      final orderId = await db.orderDao.insertOrder(
        customerId: customerId,
        orderNo: 'P-1',
        orderedAt: DateTime(2026, 8, 4),
        amountCents: 100,
      );

      for (var i = 0; i < 3; i++) {
        await db.attachmentDao.insertAttachment(
          owner: OrderAttachmentOwner(orderId),
          relativePath: AttachmentPath.relativeFor(
            at: DateTime(2026, 8, 4),
            fileId: 'f$i',
            extension: 'pdf',
          ),
          originalName: 'f$i.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 10,
        );
      }

      final all = await db.attachmentDao.listAll();
      expect(all, hasLength(3));
      for (final row in all) {
        expect(row.relativePath.startsWith('attachments/'), isTrue);
        expect(row.relativePath.startsWith('/'), isFalse);
      }
    });
  });
}
