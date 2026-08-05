import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 验收第 3 项：级联删除。
///
/// 每条断言都要求子表记录数为 0，而不是「删除没抛异常」。
/// SQLite 默认关闭外键，若 PRAGMA 漏执行，删除同样会成功返回，
/// 只是子表记录全部变成孤儿。只有数记录数才能发现这件事。
void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  /// 建一个挂满子记录的客户，返回各子记录 id。
  Future<
    ({
      int customerId,
      int contactId,
      int followupId,
      int planId,
      int orderId,
      int followupAttachmentId,
      int orderAttachmentId,
      int tagId,
    })
  >
  seedFullCustomer() async {
    final customerId = await seedCustomer(db, name: '全量客户');

    final contactId = await db.contactDao.insertContact(
      customerId: customerId,
      name: '联系人',
    );
    final followupId = await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      occurredAt: DateTime(2026, 8, 1),
      method: FollowMethod.phone,
      content: '沟通记录',
    );
    final planId = await db.planDao.insertPlan(
      customerId: customerId,
      title: '回访',
      planAt: DateTime(2026, 8, 10),
    );
    final orderId = await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: 'CASCADE-1',
      orderedAt: DateTime(2026, 8, 4),
      amountCents: 10000,
    );
    final followupAttachmentId = await db.attachmentDao.insertAttachment(
      followupId: followupId,
      relativePath: 'attachments/2026/08/f.jpg',
      originalName: 'f.jpg',
      mimeType: 'image/jpeg',
      sizeBytes: 100,
    );
    final orderAttachmentId = await db.attachmentDao.insertAttachment(
      orderId: orderId,
      relativePath: 'attachments/2026/08/o.pdf',
      originalName: 'o.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 200,
    );
    final tagId = await db.customerDao.ensureTag('级联测试');
    await db.customerDao.attachTag(customerId, tagId);

    return (
      customerId: customerId,
      contactId: contactId,
      followupId: followupId,
      planId: planId,
      orderId: orderId,
      followupAttachmentId: followupAttachmentId,
      orderAttachmentId: orderAttachmentId,
      tagId: tagId,
    );
  }

  test('删除客户后全部子记录一并删除', () async {
    final ids = await seedFullCustomer();

    // 前置确认：子记录确实写进去了，否则后面的「归零」毫无意义。
    expect(await db.contactDao.countOf(ids.customerId), 1);
    expect(await db.followupDao.countOf(ids.customerId), 1);
    expect(await db.planDao.countOf(ids.customerId), 1);
    expect(await db.orderDao.countOf(ids.customerId), 1);
    expect(await db.attachmentDao.countAll(), 2);
    expect(await db.customerDao.tagsOf(ids.customerId), hasLength(1));

    await db.customerDao.deleteCustomer(ids.customerId);

    expect(await db.customerDao.findById(ids.customerId), isNull);
    expect(await db.contactDao.countOf(ids.customerId), 0);
    expect(await db.followupDao.countOf(ids.customerId), 0);
    expect(await db.planDao.countOf(ids.customerId), 0);
    expect(await db.orderDao.countOf(ids.customerId), 0);

    // 两级级联：附件挂在跟进记录与订单上，跟着客户一路删到底。
    expect(await db.attachmentDao.countAll(), 0);
    expect(await db.attachmentDao.findById(ids.followupAttachmentId), isNull);
    expect(await db.attachmentDao.findById(ids.orderAttachmentId), isNull);

    // 客户与标签的关联删除，标签本身保留（其他客户可能还在用）。
    expect(await db.customerDao.listByTag(ids.tagId), isEmpty);
    expect(await db.customerDao.allTags(), hasLength(1));
  });

  test('删除跟进记录只删其附件，不动订单附件', () async {
    final ids = await seedFullCustomer();

    await db.followupDao.deleteFollowup(ids.followupId);

    expect(await db.followupDao.findById(ids.followupId), isNull);
    expect(await db.attachmentDao.findById(ids.followupAttachmentId), isNull);
    expect(
      await db.attachmentDao.findById(ids.orderAttachmentId),
      isNotNull,
      reason: '订单附件不应受跟进记录删除影响',
    );
    // 客户与其他子记录不受影响。
    expect(await db.customerDao.findById(ids.customerId), isNotNull);
    expect(await db.orderDao.countOf(ids.customerId), 1);
  });

  test('删除订单只删其附件', () async {
    final ids = await seedFullCustomer();

    await db.orderDao.deleteOrder(ids.orderId);

    expect(await db.orderDao.findById(ids.orderId), isNull);
    expect(await db.attachmentDao.findById(ids.orderAttachmentId), isNull);
    expect(
      await db.attachmentDao.findById(ids.followupAttachmentId),
      isNotNull,
    );
    expect(await db.followupDao.countOf(ids.customerId), 1);
  });

  test('删除标签时客户关联一并清除，客户本身保留', () async {
    final ids = await seedFullCustomer();

    await db.customStatement('DELETE FROM tags WHERE id = ?', [ids.tagId]);

    expect(await db.customerDao.tagsOf(ids.customerId), isEmpty);
    expect(await db.customerDao.findById(ids.customerId), isNotNull);
  });

  test('外键约束拒绝不存在的客户 id', () async {
    // 外键真开着的话，插入孤儿记录必须失败。这是对 PRAGMA 生效的正面验证。
    expect(
      () => db.contactDao.insertContact(customerId: 99999, name: '孤儿联系人'),
      throwsA(anything),
    );
    expect(
      () => db.planDao.insertPlan(
        customerId: 99999,
        title: '孤儿计划',
        planAt: DateTime(2026, 8, 10),
      ),
      throwsA(anything),
    );
  });

  test('多客户互不影响', () async {
    final a = await seedFullCustomer();
    final keepId = await seedCustomer(db, name: '保留客户');
    await db.followupDao.insertAndTouchCustomer(
      customerId: keepId,
      occurredAt: DateTime(2026, 8, 2),
      method: FollowMethod.wechat,
      content: '保留的记录',
    );

    await db.customerDao.deleteCustomer(a.customerId);

    expect(await db.customerDao.findById(keepId), isNotNull);
    expect(await db.followupDao.countOf(keepId), 1);
    expect(await db.followupDao.countAll(), 1);
  });
}
