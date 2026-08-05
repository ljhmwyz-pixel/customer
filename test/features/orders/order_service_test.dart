import 'package:customer/features/orders/order_form_page.dart';
import 'package:customer/features/orders/order_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  group('OrderService', () {
    test('创建、读取、编辑和删除订单，并规范化文本', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final service = OrderService(db);

      final orderId = await service.createOrder(
        customerId,
        OrderDraft(
          orderNo: '  O-100  ',
          orderedAt: DateTime(2026, 8, 5),
          amountCents: 12345,
          description: '  首次采购  ',
        ),
      );
      var order = await service.findOrderForCustomer(customerId, orderId);
      expect(order?.orderNo, 'O-100');
      expect(order?.amountCents, 12345);
      expect(order?.description, '首次采购');
      expect(order?.status, OrderStatus.pending.dbValue);
      expect(order?.opportunityId, isNotNull);
      expect(
        order?.opportunityId,
        (await db.opportunityDao.findLegacyDefaultOfCustomer(customerId))?.id,
      );

      await service.updateOrder(
        customerId,
        orderId,
        OrderDraft(
          orderNo: ' O-101 ',
          orderedAt: DateTime(2026, 8, 6),
          amountCents: 20000,
          description: '   ',
        ),
      );
      order = await service.findOrderForCustomer(customerId, orderId);
      expect(order?.orderNo, 'O-101');
      expect(order?.amountCents, 20000);
      expect(order?.description, isNull);

      await service.deleteOrder(customerId, orderId);
      expect(await db.orderDao.findById(orderId), isNull);
    });

    test('拒绝不存在的客户、订单及错误归属', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db, name: '甲');
      final otherCustomerId = await seedCustomer(db, name: '乙');
      final service = OrderService(db);
      final draft = OrderDraft(
        orderNo: 'O-200',
        orderedAt: testDate,
        amountCents: 100,
      );

      await expectLater(
        service.createOrder(999999, draft),
        _throwsOrderMessage('客户不存在'),
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
    });

    test('校验订单号唯一性、长度和金额', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final service = OrderService(db);

      Future<void> expectInvalid(
        String orderNo,
        int amountCents,
        String message,
      ) => expectLater(
        service.createOrder(
          customerId,
          OrderDraft(
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

      await service.createOrder(
        customerId,
        OrderDraft(orderNo: 'UNIQUE', orderedAt: testDate, amountCents: 100),
      );
      await expectInvalid(' UNIQUE ', 200, '订单号已存在');
    });

    test('完整推进状态机并拒绝跳转和终态流转', () async {
      final db = await openTestDb();
      addTearDown(db.close);
      final customerId = await seedCustomer(db);
      final service = OrderService(db);
      final orderId = await service.createOrder(
        customerId,
        OrderDraft(orderNo: 'FLOW', orderedAt: testDate, amountCents: 100),
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

final testDate = DateTime(2026, 8, 5);

Matcher _throwsOrderMessage(String message) => throwsA(
  isA<OrderValidationException>().having(
    (error) => error.message,
    'message',
    message,
  ),
);
