import 'package:customer/data/database.dart';
import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/features/orders/order_form_page.dart';
import 'package:customer/features/orders/order_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  group('OrderService', () {
    test('删除订单时按订单归属清理附件', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '附件项目',
      );
      final orderId = await db.orderDao.insertOrder(
        customerId: customerId,
        opportunityId: opportunityId,
        orderNo: 'ATTACHMENT-ORDER',
        orderedAt: testDate,
        amountCents: 100,
      );
      await db.attachmentDao.insertAttachment(
        owner: OrderAttachmentOwner(orderId),
        relativePath: 'attachments/2026/08/order.pdf',
        originalName: 'order.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 1,
      );
      final cleaner = _RecordingAttachmentCleaner();
      final service = OrderService(db, attachmentCleaner: cleaner);

      await service.deleteOrder(customerId, orderId);

      expect(await db.orderDao.findById(orderId), isNull);
      expect(cleaner.loadedPaths, ['attachments/2026/08/order.pdf']);
    });

    test('创建、读取、编辑和删除订单，并规范化文本', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '年度采购项目',
      );
      final service = OrderService(db);

      final orderId = await service.createOrder(
        customerId,
        OrderDraft(
          opportunityId: opportunityId,
          orderNo: '  O-100  ',
          orderedAt: DateTime(2026, 8, 5),
          amountCents: 12345,
          piPoNo: '  PI-100  ',
          currency: ' usd ',
          paymentStatus: PaymentStatus.partial,
          productionStatus: ProductionStatus.inProgress,
          shippingStatus: ShippingStatus.pending,
          estimatedArrivalAt: DateTime(2026, 8, 20),
          orderResult: OrderResult.inProgress,
          estimatedRepurchaseAt: DateTime(2026, 12, 5),
          description: '  首次采购  ',
        ),
      );
      var order = await service.findOrderForCustomer(customerId, orderId);
      expect(order?.orderNo, 'O-100');
      expect(order?.amountCents, 12345);
      expect(order?.description, '首次采购');
      expect(order?.status, OrderStatus.pending.dbValue);
      expect(order?.opportunityId, opportunityId);
      expect(order?.piPoNo, 'PI-100');
      expect(order?.currency, 'USD');
      expect(order?.paymentStatus, PaymentStatus.partial.dbValue);
      expect(order?.productionStatus, ProductionStatus.inProgress.dbValue);
      expect(order?.shippingStatus, ShippingStatus.pending.dbValue);
      expect(
        order?.estimatedArrivalAt,
        DateTime(2026, 8, 20).toUtc().millisecondsSinceEpoch,
      );
      expect(order?.orderResult, OrderResult.inProgress.dbValue);
      expect(
        order?.estimatedRepurchaseAt,
        DateTime(2026, 12, 5).toUtc().millisecondsSinceEpoch,
      );

      await service.updateOrder(
        customerId,
        orderId,
        OrderDraft(
          opportunityId: opportunityId,
          orderNo: ' O-101 ',
          orderedAt: DateTime(2026, 8, 6),
          amountCents: 20000,
          piPoNo: '   ',
          currency: ' eur ',
          paymentStatus: PaymentStatus.paid,
          productionStatus: ProductionStatus.completed,
          shippingStatus: ShippingStatus.delivered,
          orderResult: OrderResult.completed,
          description: '   ',
        ),
      );
      order = await service.findOrderForCustomer(customerId, orderId);
      expect(order?.orderNo, 'O-101');
      expect(order?.amountCents, 20000);
      expect(order?.description, isNull);
      expect(order?.piPoNo, isNull);
      expect(order?.currency, 'EUR');
      expect(order?.paymentStatus, PaymentStatus.paid.dbValue);
      expect(order?.productionStatus, ProductionStatus.completed.dbValue);
      expect(order?.shippingStatus, ShippingStatus.delivered.dbValue);
      expect(order?.orderResult, OrderResult.completed.dbValue);
      expect(order?.status, OrderStatus.completed.dbValue);

      await service.deleteOrder(customerId, orderId);
      expect(await db.orderDao.findById(orderId), isNull);
    });

    test('拒绝不存在的客户、订单及错误归属', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db, name: '甲');
      final otherCustomerId = await seedCustomer(db, name: '乙');
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '甲项目',
      );
      final otherOpportunityId = await db.opportunityDao.insertOpportunity(
        customerId: otherCustomerId,
        name: '乙项目',
      );
      final service = OrderService(db);
      final draft = OrderDraft(
        opportunityId: opportunityId,
        orderNo: 'O-200',
        orderedAt: testDate,
        amountCents: 100,
      );

      await expectLater(
        service.createOrder(999999, draft),
        _throwsOrderMessage('客户不存在'),
      );
      await expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            orderNo: 'NO-PROJECT',
            orderedAt: testDate,
            amountCents: 100,
          ),
        ),
        _throwsOrderMessage('请选择关联项目'),
      );
      await expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: 999999,
            orderNo: 'MISSING-PROJECT',
            orderedAt: testDate,
            amountCents: 100,
          ),
        ),
        _throwsOrderMessage('项目不存在'),
      );
      await expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: otherOpportunityId,
            orderNo: 'WRONG-PROJECT',
            orderedAt: testDate,
            amountCents: 100,
          ),
        ),
        _throwsOrderMessage('项目不属于当前客户'),
      );
      await expectLater(
        service.updateOrder(customerId, 999999, draft),
        _throwsOrderMessage('订单不存在'),
      );
      final orderId = await service.createOrder(customerId, draft);
      expect(
        await service.findOrderForCustomer(otherCustomerId, orderId),
        isNull,
      );
      await expectLater(
        service.deleteOrder(otherCustomerId, orderId),
        _throwsOrderMessage('订单不属于当前客户'),
      );
      await expectLater(
        service.updateOrder(
          customerId,
          orderId,
          OrderDraft(
            opportunityId: otherOpportunityId,
            orderNo: 'O-200',
            orderedAt: testDate,
            amountCents: 100,
          ),
        ),
        _throwsOrderMessage('项目不属于当前客户'),
      );
    });

    test('校验订单号、金额、币种和业务日期', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '项目',
      );
      final service = OrderService(db);

      Future<void> expectInvalid(
        String orderNo,
        int amountCents,
        String message,
      ) => expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: opportunityId,
            orderNo: orderNo,
            orderedAt: testDate,
            amountCents: amountCents,
          ),
        ),
        _throwsOrderMessage(message),
      );

      await expectInvalid('   ', 100, '订单号不能为空');
      await expectInvalid(List.filled(51, 'x').join(), 100, '订单号不能超过 50 个字符');
      await expectInvalid('ZERO', 0, '订单金额必须大于 0');
      await expectInvalid('NEGATIVE', -1, '订单金额必须大于 0');
      await expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: opportunityId,
            orderNo: 'BAD-CURRENCY',
            orderedAt: testDate,
            amountCents: 100,
            currency: 'US1',
          ),
        ),
        _throwsOrderMessage('币种必须是三位英文字母'),
      );
      await expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: opportunityId,
            orderNo: 'BAD-ARRIVAL',
            orderedAt: testDate,
            amountCents: 100,
            estimatedArrivalAt: testDate.subtract(const Duration(days: 1)),
          ),
        ),
        _throwsOrderMessage('预计到货日期不得早于下单日期'),
      );
      await expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: opportunityId,
            orderNo: 'BAD-REPURCHASE',
            orderedAt: testDate,
            amountCents: 100,
            estimatedRepurchaseAt: testDate.subtract(const Duration(days: 1)),
          ),
        ),
        _throwsOrderMessage('预计复购日期不得早于下单日期'),
      );

      await service.createOrder(
        customerId,
        OrderDraft(
          opportunityId: opportunityId,
          orderNo: 'UNIQUE',
          orderedAt: testDate,
          amountCents: 100,
        ),
      );
      await expectInvalid(' UNIQUE ', 200, '订单号已存在');
    });

    test('由拆分状态派生兼容状态，且结果状态优先', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '状态项目',
      );
      final service = OrderService(db);

      Future<OrderRow?> create(
        String orderNo, {
        PaymentStatus payment = PaymentStatus.pending,
        ShippingStatus shipping = ShippingStatus.pending,
        OrderResult result = OrderResult.inProgress,
      }) async {
        final id = await service.createOrder(
          customerId,
          OrderDraft(
            opportunityId: opportunityId,
            orderNo: orderNo,
            orderedAt: testDate,
            amountCents: 100,
            paymentStatus: payment,
            shippingStatus: shipping,
            orderResult: result,
          ),
        );
        return db.orderDao.findById(id);
      }

      expect((await create('PENDING'))?.status, OrderStatus.pending.dbValue);
      expect(
        (await create('SHIPPED', shipping: ShippingStatus.shipped))?.status,
        OrderStatus.shipped.dbValue,
      );
      expect(
        (await create('PAID', payment: PaymentStatus.paid))?.status,
        OrderStatus.paid.dbValue,
      );
      expect(
        (await create('DONE', result: OrderResult.completed))?.status,
        OrderStatus.completed.dbValue,
      );
      expect(
        (await create(
          'CANCELLED',
          payment: PaymentStatus.paid,
          shipping: ShippingStatus.delivered,
          result: OrderResult.cancelled,
        ))?.status,
        OrderStatus.cancelled.dbValue,
      );
    });

    test('创建订单会完成同客户同项目的全部开放复购任务', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db, name: '当前客户');
      final otherCustomerId = await seedCustomer(db, name: '其他客户');
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '当前项目',
      );
      final otherOpportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '其他项目',
      );
      final foreignOpportunityId = await db.opportunityDao.insertOpportunity(
        customerId: otherCustomerId,
        name: '外部项目',
      );
      final oldDate = testDate.subtract(const Duration(days: 5));

      final overdueId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        nextAction: '逾期复购',
        planAt: oldDate,
      );
      await db.planDao.markOverdue(now: testDate);
      final pendingId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        nextAction: '待处理复购',
        planAt: testDate,
      );
      final notifiedId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        nextAction: '已提醒复购',
        planAt: testDate,
      );
      await db.planDao.markNotified(notifiedId, at: testDate);
      final unaffectedIds = <int>[
        await db.planDao.insertPlan(
          customerId: customerId,
          opportunityId: otherOpportunityId,
          sourceType: TaskSourceType.repurchase,
          nextAction: '其他项目',
          planAt: testDate,
        ),
        await db.planDao.insertPlan(
          customerId: otherCustomerId,
          opportunityId: foreignOpportunityId,
          sourceType: TaskSourceType.repurchase,
          nextAction: '其他客户',
          planAt: testDate,
        ),
        await db.planDao.insertPlan(
          customerId: customerId,
          opportunityId: opportunityId,
          sourceType: TaskSourceType.manual,
          nextAction: '手工任务',
          planAt: testDate,
        ),
      ];
      final completedId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        nextAction: '已完成',
        planAt: testDate,
      );
      await db.planDao.markCompleted(completedId, at: testDate);
      final cancelledId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        nextAction: '已取消',
        planAt: testDate,
      );
      await db.planDao.markCancelled(cancelledId, at: testDate);

      final estimatedRepurchaseAt = testDate.add(const Duration(days: 90));
      final orderId = await OrderService(db).createOrder(
        customerId,
        OrderDraft(
          opportunityId: opportunityId,
          orderNo: 'REPURCHASE',
          orderedAt: testDate,
          amountCents: 100,
          estimatedRepurchaseAt: estimatedRepurchaseAt,
        ),
      );

      for (final id in [pendingId, notifiedId, overdueId]) {
        final plan = await db.planDao.findById(id);
        expect(plan?.status, PlanStatus.completed.dbValue);
        expect(plan?.completedAt, isNotNull);
      }
      for (final id in unaffectedIds) {
        expect(
          PlanStatus.fromDb((await db.planDao.findById(id))!.status).isOpen,
          isTrue,
        );
      }
      expect(
        (await db.planDao.findById(completedId))?.status,
        PlanStatus.completed.dbValue,
      );
      expect(
        (await db.planDao.findById(cancelledId))?.status,
        PlanStatus.cancelled.dbValue,
      );
      expect(
        (await db.orderDao.findById(orderId))?.estimatedRepurchaseAt,
        estimatedRepurchaseAt.toUtc().millisecondsSinceEpoch,
      );
    });

    test('完整推进状态机并拒绝跳转和终态流转', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '流程项目',
      );
      final service = OrderService(db);
      final orderId = await service.createOrder(
        customerId,
        OrderDraft(
          opportunityId: opportunityId,
          orderNo: 'FLOW',
          orderedAt: testDate,
          amountCents: 100,
        ),
      );

      await expectLater(
        service.transitionOrder(customerId, orderId, OrderStatus.paid),
        _throwsOrderMessage('订单不能从“待确认”变为“已收款”'),
      );
      await service.transitionOrder(customerId, orderId, OrderStatus.shipped);
      await service.transitionOrder(customerId, orderId, OrderStatus.paid);
      await service.transitionOrder(customerId, orderId, OrderStatus.completed);
      expect(
        (await db.orderDao.findById(orderId))?.status,
        OrderStatus.completed.dbValue,
      );
      await expectLater(
        service.cancelOrder(customerId, orderId),
        _throwsOrderMessage('订单不能从“已完成”变为“已取消”'),
      );
    });

    test('待确认、已发货和已收款均可取消，取消后不可推进', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final service = OrderService(db);

      for (final status in [
        OrderStatus.pending,
        OrderStatus.shipped,
        OrderStatus.paid,
      ]) {
        final orderId = await db.orderDao.insertOrder(
          customerId: customerId,
          orderNo: 'CANCEL-${status.dbValue}',
          orderedAt: testDate,
          amountCents: 100,
          status: status,
        );
        await service.cancelOrder(customerId, orderId);
        expect(
          (await db.orderDao.findById(orderId))?.status,
          OrderStatus.cancelled.dbValue,
        );
        await expectLater(
          service.transitionOrder(customerId, orderId, OrderStatus.pending),
          _throwsOrderMessage('订单不能从“已取消”变为“待确认”'),
        );
      }
    });
  });

  group('订单金额转换', () {
    test('精确解析元并格式化分', () {
      expect(parseAmountCents(' 12 '), 1200);
      expect(parseAmountCents('12.3'), 1230);
      expect(parseAmountCents('12.34'), 1234);
      expect(formatAmountCents(1234), '¥12.34');
      expect(formatAmountCents(-5), '-¥0.05');
    });

    test('支持 int64 最大分金额并拒绝溢出', () {
      expect(parseAmountCents('92233720368547758.07'), 9223372036854775807);
      expect(
        () => parseAmountCents('92233720368547758.08'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            '订单金额超出支持范围',
          ),
        ),
      );
    });

    test('拒绝空白、非法、小数超过两位及零金额', () {
      for (final value in ['', 'abc', '1.234', '-1', '.5']) {
        expect(() => parseAmountCents(value), throwsFormatException);
      }
      expect(
        () => parseAmountCents('0'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            '订单金额必须大于 0',
          ),
        ),
      );
    });
  });
}

class _RecordingAttachmentCleaner implements AttachmentGraphCleaner {
  final loadedPaths = <String>[];

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async {
    loadedPaths.addAll(
      (await loadAttachments()).map((row) => row.relativePath),
    );
    await deleteDatabaseGraph();
    return const AttachmentCleanupReport();
  }

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async =>
      const AttachmentCleanupReport();
}

final testDate = DateTime(2026, 8, 5);

Matcher _throwsOrderMessage(String message) => throwsA(
  isA<OrderValidationException>().having(
    (error) => error.message,
    'message',
    message,
  ),
);
