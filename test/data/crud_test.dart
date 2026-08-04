import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 验收第 2 项：八张表增删改查。
///
/// 每组按 增 → 查 → 改 → 删 走一遍，改和删都断言落库后的实际值，
/// 而不是只看返回的影响行数。
void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  group('customers', () {
    test('增删改查', () async {
      final id = await db.customerDao.insertCustomer(
        name: '张三',
        company: '甲方公司',
        phone: '13800000000',
        stage: CustomerStage.contacted,
        grade: CustomerGrade.a,
      );

      final row = await db.customerDao.findById(id);
      expect(row, isNotNull);
      expect(row!.name, '张三');
      expect(row.company, '甲方公司');
      expect(CustomerStage.fromDb(row.stage), CustomerStage.contacted);
      expect(CustomerGrade.fromDb(row.grade), CustomerGrade.a);
      expect(await db.customerDao.countAll(), 1);

      await db.customerDao.updateCustomer(id, name: '张三丰', phone: '139');
      final updated = await db.customerDao.findById(id);
      expect(updated!.name, '张三丰');
      expect(updated.phone, '139');
      // 未传的字段保持原值。
      expect(updated.company, '甲方公司');

      await db.customerDao.updateStage(id, CustomerStage.deal);
      expect(
        CustomerStage.fromDb((await db.customerDao.findById(id))!.stage),
        CustomerStage.deal,
      );

      expect(await db.customerDao.deleteCustomer(id), 1);
      expect(await db.customerDao.findById(id), isNull);
      expect(await db.customerDao.countAll(), 0);
    });

    test('search 按名称与电话模糊匹配', () async {
      await db.customerDao.insertCustomer(name: '李四', phone: '13811112222');
      await db.customerDao.insertCustomer(name: '王五', phone: '13933334444');

      expect((await db.customerDao.search('李')).single.name, '李四');
      expect((await db.customerDao.search('1111')).single.name, '李四');
      expect((await db.customerDao.search('139')).single.name, '王五');
      expect(await db.customerDao.search('赵'), isEmpty);
    });

    test('countByStage 覆盖全部阶段且缺失阶段为 0', () async {
      await db.customerDao.insertCustomer(name: 'a');
      await db.customerDao.insertCustomer(
        name: 'b',
        stage: CustomerStage.deal,
      );

      final counts = await db.customerDao.countByStage();
      expect(counts.length, CustomerStage.values.length);
      expect(counts[CustomerStage.potential], 1);
      expect(counts[CustomerStage.deal], 1);
      expect(counts[CustomerStage.lost], 0);
    });
  });

  group('contacts', () {
    test('增删改查', () async {
      final customerId = await seedCustomer(db);
      final id = await db.contactDao.insertContact(
        customerId: customerId,
        name: '采购小王',
        position: '采购经理',
        phone: '010-1234',
        isDecisionMaker: true,
      );

      final row = await db.contactDao.findById(id);
      expect(row!.name, '采购小王');
      expect(row.isDecisionMaker, isTrue);
      expect((await db.contactDao.listOf(customerId)).length, 1);
      expect(await db.contactDao.countOf(customerId), 1);

      await db.contactDao.updateContact(id, position: '总监');
      expect((await db.contactDao.findById(id))!.position, '总监');

      expect(await db.contactDao.deleteContact(id), 1);
      expect(await db.contactDao.countOf(customerId), 0);
    });
  });

  group('followups', () {
    test('增删改查', () async {
      final customerId = await seedCustomer(db);
      final occurred = DateTime(2026, 8, 1, 10);
      final id = await db.followupDao.insertAndTouchCustomer(
        customerId: customerId,
        occurredAt: occurred,
        method: FollowMethod.phone,
        content: '电话沟通了报价',
        conclusion: '下周再谈',
      );

      final row = await db.followupDao.findById(id);
      expect(row!.content, '电话沟通了报价');
      expect(FollowMethod.fromDb(row.method), FollowMethod.phone);
      expect(row.occurredAt, occurred.toUtc().millisecondsSinceEpoch);
      expect(await db.followupDao.countOf(customerId), 1);
      expect(await db.followupDao.countAll(), 1);

      await db.followupDao.updateFollowup(
        id,
        content: '改为微信沟通',
        method: FollowMethod.wechat,
      );
      final updated = await db.followupDao.findById(id);
      expect(updated!.content, '改为微信沟通');
      expect(FollowMethod.fromDb(updated.method), FollowMethod.wechat);

      expect(await db.followupDao.deleteFollowup(id), 1);
      expect(await db.followupDao.countOf(customerId), 0);
    });

    test('listOf 按发生时间倒序', () async {
      final customerId = await seedCustomer(db);
      for (final day in [3, 1, 2]) {
        await db.followupDao.insertAndTouchCustomer(
          customerId: customerId,
          occurredAt: DateTime(2026, 8, day),
          method: FollowMethod.phone,
          content: 'day$day',
        );
      }

      final list = await db.followupDao.listOf(customerId);
      expect(list.map((e) => e.content).toList(), ['day3', 'day2', 'day1']);
      expect((await db.followupDao.listOf(customerId, limit: 2)).length, 2);
    });
  });

  group('follow_plans', () {
    test('增删改查', () async {
      final customerId = await seedCustomer(db);
      final planAt = DateTime(2026, 8, 10, 9);
      final id = await db.planDao.insertPlan(
        customerId: customerId,
        title: '回访确认合同',
        planAt: planAt,
      );

      final row = await db.planDao.findById(id);
      expect(row!.title, '回访确认合同');
      expect(PlanStatus.fromDb(row.status), PlanStatus.pending);
      expect(row.notifiedAt, isNull);
      expect(await db.planDao.countOf(customerId), 1);

      await db.planDao.updatePlan(id, title: '回访并催款');
      expect((await db.planDao.findById(id))!.title, '回访并催款');

      expect(await db.planDao.deletePlan(id), 1);
      expect(await db.planDao.countOf(customerId), 0);
    });
  });

  group('orders', () {
    test('增删改查', () async {
      final customerId = await seedCustomer(db);
      final id = await db.orderDao.insertOrder(
        customerId: customerId,
        orderNo: '20260804-001',
        orderedAt: DateTime(2026, 8, 4),
        amountCents: 123456,
        description: '首批样品',
      );

      final row = await db.orderDao.findById(id);
      expect(row!.orderNo, '20260804-001');
      expect(row.amountCents, 123456);
      expect(OrderStatus.fromDb(row.status), OrderStatus.pending);
      expect((await db.orderDao.findByOrderNo('20260804-001'))!.id, id);
      expect(await db.orderDao.countOf(customerId), 1);

      await db.orderDao.updateOrder(id, amountCents: 200000);
      expect((await db.orderDao.findById(id))!.amountCents, 200000);

      await db.orderDao.updateStatus(id, OrderStatus.paid);
      expect(
        OrderStatus.fromDb((await db.orderDao.findById(id))!.status),
        OrderStatus.paid,
      );

      expect(await db.orderDao.deleteOrder(id), 1);
      expect(await db.orderDao.countOf(customerId), 0);
    });

    test('orderNo 唯一约束生效', () async {
      final customerId = await seedCustomer(db);
      await db.orderDao.insertOrder(
        customerId: customerId,
        orderNo: 'DUP-001',
        orderedAt: DateTime(2026, 8, 4),
        amountCents: 100,
      );

      expect(
        () => db.orderDao.insertOrder(
          customerId: customerId,
          orderNo: 'DUP-001',
          orderedAt: DateTime(2026, 8, 5),
          amountCents: 200,
        ),
        throwsA(anything),
      );
    });
  });

  group('tags 与 customer_tags', () {
    test('增删改查与去重', () async {
      final customerId = await seedCustomer(db);

      final tagId = await db.customerDao.ensureTag(' 重点客户 ');
      // 同名标签重复调用不产生副本，且名称已 trim。
      expect(await db.customerDao.ensureTag('重点客户'), tagId);
      expect((await db.customerDao.allTags()).single.name, '重点客户');

      await db.customerDao.attachTag(customerId, tagId);
      // 重复打同一标签靠联合主键去重，不应抛错也不应产生第二行。
      await db.customerDao.attachTag(customerId, tagId);
      expect((await db.customerDao.tagsOf(customerId)).length, 1);
      expect((await db.customerDao.listByTag(tagId)).single.id, customerId);

      expect(await db.customerDao.detachTag(customerId, tagId), 1);
      expect(await db.customerDao.tagsOf(customerId), isEmpty);
      // 解绑不删标签本身。
      expect((await db.customerDao.allTags()).length, 1);
    });
  });

  group('attachments', () {
    test('挂在跟进记录上的增删改查', () async {
      final customerId = await seedCustomer(db);
      final followupId = await db.followupDao.insertAndTouchCustomer(
        customerId: customerId,
        occurredAt: DateTime(2026, 8, 1),
        method: FollowMethod.meeting,
        content: '上门拜访',
      );

      final id = await db.attachmentDao.insertAttachment(
        followupId: followupId,
        relativePath: 'attachments/2026/08/abc.jpg',
        originalName: '名片.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 2048,
      );

      final row = await db.attachmentDao.findById(id);
      expect(row!.relativePath, 'attachments/2026/08/abc.jpg');
      expect(row.followupId, followupId);
      expect(row.orderId, isNull);
      expect((await db.attachmentDao.listOfFollowup(followupId)).length, 1);
      expect(await db.attachmentDao.countAll(), 1);
      expect(await db.attachmentDao.totalSizeBytes(), 2048);

      expect(await db.attachmentDao.deleteAttachment(id), 1);
      expect(await db.attachmentDao.countAll(), 0);
    });

    test('挂在订单上的附件', () async {
      final customerId = await seedCustomer(db);
      final orderId = await db.orderDao.insertOrder(
        customerId: customerId,
        orderNo: 'A-1',
        orderedAt: DateTime(2026, 8, 4),
        amountCents: 100,
      );

      await db.attachmentDao.insertAttachment(
        orderId: orderId,
        relativePath: 'attachments/2026/08/contract.pdf',
        originalName: '合同.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 4096,
      );

      expect((await db.attachmentDao.listOfOrder(orderId)).single.orderId,
          orderId);
      expect(await db.attachmentDao.listAll(), hasLength(1));
    });

    test('归属不明确时拒绝写入', () async {
      // 两个外键都空。
      expect(
        () => db.attachmentDao.insertAttachment(
          relativePath: 'attachments/2026/08/x.jpg',
          originalName: 'x.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1,
        ),
        throwsArgumentError,
      );

      // 两个外键都有值。
      expect(
        () => db.attachmentDao.insertAttachment(
          followupId: 1,
          orderId: 1,
          relativePath: 'attachments/2026/08/x.jpg',
          originalName: 'x.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1,
        ),
        throwsArgumentError,
      );
    });

    test('拒绝绝对路径', () async {
      expect(
        () => db.attachmentDao.insertAttachment(
          followupId: 1,
          relativePath: '/data/user/0/app/files/x.jpg',
          originalName: 'x.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
