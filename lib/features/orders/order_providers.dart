import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../models/enums.dart';

class OrderDraft {
  const OrderDraft({
    required this.orderNo,
    required this.orderedAt,
    required this.amountCents,
    this.description,
  });

  final String orderNo;
  final DateTime orderedAt;
  final int amountCents;
  final String? description;
}

class OrderValidationException implements Exception {
  const OrderValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OrderService {
  OrderService(this._db);

  final AppDatabase _db;

  Future<String> nextOrderNo({DateTime? at}) =>
      _db.orderDao.nextOrderNo(at: at);

  Future<OrderRow?> findOrderForCustomer(int customerId, int orderId) async {
    final order = await _db.orderDao.findById(orderId);
    return order?.customerId == customerId ? order : null;
  }

  Future<int> createOrder(int customerId, OrderDraft draft) async {
    final customer = await _requireCustomer(customerId);
    final normalized = await _normalizeDraft(draft);
    final opportunityId = await _db.opportunityDao
        .ensureLegacyDefaultForCustomer(
          customerId,
          legacyStage: CustomerStage.fromDb(customer.stage),
        );
    return _db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: normalized.orderNo,
      orderedAt: normalized.orderedAt,
      amountCents: normalized.amountCents,
      description: normalized.description,
    );
  }

  Future<void> updateOrder(
    int customerId,
    int orderId,
    OrderDraft draft,
  ) async {
    final order = await _requireOrder(customerId, orderId);
    final normalized = await _normalizeDraft(draft, currentOrderId: order.id);
    await _db.orderDao.updateOrder(
      order.id,
      orderNo: normalized.orderNo,
      orderedAt: normalized.orderedAt,
      amountCents: normalized.amountCents,
      description: Value(normalized.description),
    );
  }

  Future<void> transitionOrder(
    int customerId,
    int orderId,
    OrderStatus target,
  ) async {
    final order = await _requireOrder(customerId, orderId);
    final current = OrderStatus.fromDb(order.status);
    if (!current.canTransitionTo(target)) {
      throw OrderValidationException(
        '订单不能从“${current.label}”变为“${target.label}”',
      );
    }
    await _db.orderDao.updateStatus(order.id, target);
  }

  Future<void> cancelOrder(int customerId, int orderId) =>
      transitionOrder(customerId, orderId, OrderStatus.cancelled);

  Future<void> deleteOrder(int customerId, int orderId) async {
    final order = await _requireOrder(customerId, orderId);
    await _db.orderDao.deleteOrder(order.id);
  }

  Future<CustomerRow> _requireCustomer(int customerId) async {
    final customer = await _db.customerDao.findById(customerId);
    if (customer == null) {
      throw const OrderValidationException('客户不存在');
    }
    return customer;
  }

  Future<OrderRow> _requireOrder(int customerId, int orderId) async {
    final order = await _db.orderDao.findById(orderId);
    if (order == null) {
      throw const OrderValidationException('订单不存在');
    }
    if (order.customerId != customerId) {
      throw const OrderValidationException('订单不属于当前客户');
    }
    return order;
  }

  Future<OrderDraft> _normalizeDraft(
    OrderDraft draft, {
    int? currentOrderId,
  }) async {
    final orderNo = draft.orderNo.trim();
    if (orderNo.isEmpty) {
      throw const OrderValidationException('订单号不能为空');
    }
    if (orderNo.length > 50) {
      throw const OrderValidationException('订单号不能超过 50 个字符');
    }
    if (draft.amountCents <= 0) {
      throw const OrderValidationException('订单金额必须大于 0');
    }

    final existing = await _db.orderDao.findByOrderNo(orderNo);
    if (existing != null && existing.id != currentOrderId) {
      throw const OrderValidationException('订单号已存在');
    }
    final description = draft.description?.trim();
    return OrderDraft(
      orderNo: orderNo,
      orderedAt: draft.orderedAt,
      amountCents: draft.amountCents,
      description: description == null || description.isEmpty
          ? null
          : description,
    );
  }
}

final orderServiceProvider = Provider<OrderService>(
  (ref) => OrderService(ref.watch(databaseProvider)),
);
