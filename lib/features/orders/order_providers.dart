// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/daos/attachment_dao.dart';
import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../../services/attachment_service.dart';
import '../../services/attachment_service_providers.dart';
import '../../services/business_task_rules.dart';
import '../../services/service_providers.dart';

class OrderDraft {
  const OrderDraft({
    this.opportunityId,
    required this.orderNo,
    required this.orderedAt,
    required this.amountCents,
    this.piPoNo,
    this.currency = 'CNY',
    this.paymentStatus = PaymentStatus.pending,
    this.productionStatus = ProductionStatus.pending,
    this.shippingStatus = ShippingStatus.pending,
    this.estimatedArrivalAt,
    this.orderResult = OrderResult.inProgress,
    this.estimatedRepurchaseAt,
    this.description,
  });

  final int? opportunityId;
  final String orderNo;
  final DateTime orderedAt;
  final int amountCents;
  final String? piPoNo;
  final String currency;
  final PaymentStatus paymentStatus;
  final ProductionStatus productionStatus;
  final ShippingStatus shippingStatus;
  final DateTime? estimatedArrivalAt;
  final OrderResult orderResult;
  final DateTime? estimatedRepurchaseAt;
  final String? description;
}

class OrderValidationException implements Exception {
  const OrderValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OrderService {
  OrderService(
    this._db, {
    AttachmentGraphCleaner attachmentCleaner =
        const PassthroughAttachmentGraphCleaner(),
    BusinessTaskRules? taskRules,
  }) : _attachmentCleaner = attachmentCleaner,
       _taskRules = taskRules;

  final AppDatabase _db;
  final AttachmentGraphCleaner _attachmentCleaner;
  final BusinessTaskRules? _taskRules;

  Future<String> nextOrderNo({DateTime? at}) =>
      _db.orderDao.nextOrderNo(at: at);

  Future<OrderRow?> findOrderForCustomer(int customerId, int orderId) async {
    final order = await _db.orderDao.findById(orderId);
    return order?.customerId == customerId ? order : null;
  }

  Future<int> createOrder(int customerId, OrderDraft draft) async {
    await _requireCustomer(customerId);
    final opportunityId = await _requireOpportunity(
      customerId,
      draft.opportunityId,
    );
    final normalized = await _normalizeDraft(draft);
    final repurchasePlanIds = (await _db.planDao.listOpenOf(customerId))
        .where(
          (plan) =>
              plan.opportunityId == opportunityId &&
              plan.sourceType == TaskSourceType.repurchase.dbValue,
        )
        .map((plan) => plan.id)
        .toList(growable: false);
    final orderId = await _db.transaction(() async {
      final orderId = await _db.orderDao.insertOrder(
        customerId: customerId,
        opportunityId: opportunityId,
        orderNo: normalized.orderNo,
        orderedAt: normalized.orderedAt,
        amountCents: normalized.amountCents,
        piPoNo: normalized.piPoNo,
        currency: normalized.currency,
        paymentStatus: normalized.paymentStatus,
        productionStatus: normalized.productionStatus,
        shippingStatus: normalized.shippingStatus,
        estimatedArrivalAt: normalized.estimatedArrivalAt,
        orderResult: normalized.orderResult,
        estimatedRepurchaseAt: normalized.estimatedRepurchaseAt,
        description: normalized.description,
      );
      await _db.orderDao.completeOpenRepurchaseTasks(
        customerId: customerId,
        opportunityId: opportunityId,
      );
      return orderId;
    });
    await _taskRules?.cancelScheduledPlans(repurchasePlanIds);
    await _syncTasks(opportunityId);
    return orderId;
  }

  Future<void> updateOrder(
    int customerId,
    int orderId,
    OrderDraft draft,
  ) async {
    final order = await _requireOrder(customerId, orderId);
    final opportunityId = await _requireOpportunity(
      customerId,
      draft.opportunityId,
    );
    final normalized = await _normalizeDraft(draft, currentOrderId: order.id);
    await _db.orderDao.updateOrder(
      order.id,
      opportunityId: Value(opportunityId),
      orderNo: normalized.orderNo,
      orderedAt: normalized.orderedAt,
      amountCents: normalized.amountCents,
      piPoNo: Value(normalized.piPoNo),
      currency: normalized.currency,
      paymentStatus: normalized.paymentStatus,
      productionStatus: normalized.productionStatus,
      shippingStatus: normalized.shippingStatus,
      estimatedArrivalAt: Value(normalized.estimatedArrivalAt),
      orderResult: normalized.orderResult,
      estimatedRepurchaseAt: Value(normalized.estimatedRepurchaseAt),
      description: Value(normalized.description),
    );
    await _syncTasks(opportunityId);
    if (order.opportunityId != null && order.opportunityId != opportunityId) {
      await _syncTasks(order.opportunityId!);
    }
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

  Future<AttachmentCleanupReport> deleteOrder(
    int customerId,
    int orderId,
  ) async {
    final order = await _requireOrder(customerId, orderId);
    final report = await _attachmentCleaner.deleteGraph(
      loadAttachments: () =>
          _db.attachmentDao.listOf(OrderAttachmentOwner(order.id)),
      deleteDatabaseGraph: () => _db.transaction(() async {
        await _db.orderDao.deleteOrder(order.id);
      }),
    );
    if (order.opportunityId != null) await _syncTasks(order.opportunityId!);
    return report;
  }

  Future<CustomerRow> _requireCustomer(int customerId) async {
    final customer = await _db.customerDao.findById(customerId);
    if (customer == null) {
      throw const OrderValidationException('客户不存在');
    }
    return customer;
  }

  Future<int> _requireOpportunity(int customerId, int? opportunityId) async {
    if (opportunityId == null) {
      throw const OrderValidationException('请选择关联项目');
    }
    final opportunity = await _db.opportunityDao.findById(opportunityId);
    if (opportunity == null) {
      throw const OrderValidationException('项目不存在');
    }
    if (opportunity.customerId != customerId) {
      throw const OrderValidationException('项目不属于当前客户');
    }
    return opportunity.id;
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
    final currency = draft.currency.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw const OrderValidationException('币种必须是三位英文字母');
    }
    if (draft.estimatedArrivalAt?.isBefore(draft.orderedAt) ?? false) {
      throw const OrderValidationException('预计到货日期不得早于下单日期');
    }
    if (draft.estimatedRepurchaseAt?.isBefore(draft.orderedAt) ?? false) {
      throw const OrderValidationException('预计复购日期不得早于下单日期');
    }

    final existing = await _db.orderDao.findByOrderNo(orderNo);
    if (existing != null && existing.id != currentOrderId) {
      throw const OrderValidationException('订单号已存在');
    }
    final description = draft.description?.trim();
    final piPoNo = draft.piPoNo?.trim();
    return OrderDraft(
      opportunityId: draft.opportunityId,
      orderNo: orderNo,
      orderedAt: draft.orderedAt,
      amountCents: draft.amountCents,
      piPoNo: piPoNo == null || piPoNo.isEmpty ? null : piPoNo,
      currency: currency,
      paymentStatus: draft.paymentStatus,
      productionStatus: draft.productionStatus,
      shippingStatus: draft.shippingStatus,
      estimatedArrivalAt: draft.estimatedArrivalAt,
      orderResult: draft.orderResult,
      estimatedRepurchaseAt: draft.estimatedRepurchaseAt,
      description: description == null || description.isEmpty
          ? null
          : description,
    );
  }

  Future<void> _syncTasks(int opportunityId) async {
    await _taskRules?.reconcileOrQueue(opportunityId, now: DateTime.now());
  }
}

final orderServiceProvider = Provider<OrderService>(
  (ref) => OrderService(
    ref.watch(databaseProvider),
    attachmentCleaner: ref.watch(attachmentServiceProvider),
    taskRules: ref.watch(businessTaskRulesProvider),
  ),
);
