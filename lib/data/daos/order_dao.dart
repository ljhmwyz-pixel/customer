import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/follow_plans.dart';
import '../tables/orders.dart';

part 'order_dao.g.dart';

/// 订单数据访问。老客户订单跟踪。
@DriftAccessor(tables: [Orders, FollowPlans])
class OrderDao extends DatabaseAccessor<AppDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  Future<int> insertOrder({
    required int customerId,
    int? opportunityId,
    required String orderNo,
    required DateTime orderedAt,
    required int amountCents,
    String? piPoNo,
    String currency = 'CNY',
    PaymentStatus paymentStatus = PaymentStatus.pending,
    ProductionStatus productionStatus = ProductionStatus.pending,
    ShippingStatus shippingStatus = ShippingStatus.pending,
    DateTime? estimatedArrivalAt,
    OrderResult orderResult = OrderResult.inProgress,
    DateTime? estimatedRepurchaseAt,
    String? description,
    OrderStatus? status,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final split = status == null ? null : _splitStatus(status);
    final effectivePayment = split?.payment ?? paymentStatus;
    final effectiveProduction = split?.production ?? productionStatus;
    final effectiveShipping = split?.shipping ?? shippingStatus;
    final effectiveResult = split?.result ?? orderResult;
    final effectiveStatus =
        status ??
        _legacyStatus(
          payment: effectivePayment,
          shipping: effectiveShipping,
          result: effectiveResult,
        );
    return into(orders).insert(
      OrdersCompanion.insert(
        customerId: customerId,
        opportunityId: Value(opportunityId),
        orderNo: orderNo,
        orderedAt: orderedAt.toUtc().millisecondsSinceEpoch,
        amountCents: amountCents,
        description: Value(description),
        status: Value(effectiveStatus.dbValue),
        piPoNo: Value(piPoNo),
        currency: Value(currency),
        paymentStatus: Value(effectivePayment.dbValue),
        productionStatus: Value(effectiveProduction.dbValue),
        shippingStatus: Value(effectiveShipping.dbValue),
        estimatedArrivalAt: Value(
          estimatedArrivalAt?.toUtc().millisecondsSinceEpoch,
        ),
        orderResult: Value(effectiveResult.dbValue),
        estimatedRepurchaseAt: Value(
          estimatedRepurchaseAt?.toUtc().millisecondsSinceEpoch,
        ),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<OrderRow?> findById(int id) =>
      (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<OrderRow?> findByOrderNo(String orderNo) => (select(
    orders,
  )..where((t) => t.orderNo.equals(orderNo))).getSingleOrNull();

  /// 某客户的订单，下单时间倒序。
  Future<List<OrderRow>> listOf(int customerId) =>
      (select(orders)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.orderedAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<int> countOf(int customerId) async {
    final q = selectOnly(orders)
      ..addColumns([orders.id.count()])
      ..where(orders.customerId.equals(customerId));
    final row = await q.getSingle();
    return row.read(orders.id.count()) ?? 0;
  }

  /// 客户累计成交金额，单位分。
  ///
  /// 只有 completed 订单计入业绩。这里在 SQL 层过滤而不是取回全部
  /// 订单再在 Dart 里筛，客户订单多起来后差别明显。
  Future<int> sumAmountByCustomer(int customerId) async {
    final sum = orders.amountCents.sum();
    final q = selectOnly(orders)
      ..addColumns([sum])
      ..where(
        orders.customerId.equals(customerId) &
            orders.status.equals(OrderStatus.completed.dbValue),
      );
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// 全部客户的累计成交金额，key 为 customerId。
  ///
  /// 客户列表要展示成交金额时用它一次取全，避免每行一次查询。
  Future<Map<int, int>> sumAmountGroupedByCustomer() async {
    final sum = orders.amountCents.sum();
    final q = selectOnly(orders)
      ..addColumns([orders.customerId, sum])
      ..where(orders.status.equals(OrderStatus.completed.dbValue))
      ..groupBy([orders.customerId]);

    final rows = await q.get();
    return {
      for (final row in rows) row.read(orders.customerId)!: row.read(sum) ?? 0,
    };
  }

  /// 生成一个未被占用的订单号，形如 `20260804-001`。
  ///
  /// 序号在同一天内递增。查的是当天已有的最大序号而不是当天订单条数，
  /// 因为删掉一条订单后按条数算会撞上已存在的编号。
  ///
  /// 已知行为：删掉当天最后一条订单后，下一次生成会重用那个号。
  /// 唯一约束仍然成立（旧记录已不存在），对单人本地使用够用。
  /// 若日后需要「号码永不重用」，得单独加一张号码水位表来记住已发到哪一号。
  Future<String> nextOrderNo({DateTime? at}) async {
    final day = at ?? DateTime.now();
    final prefix =
        '${day.year.toString().padLeft(4, '0')}'
        '${day.month.toString().padLeft(2, '0')}'
        '${day.day.toString().padLeft(2, '0')}';

    final rows =
        await (select(orders)
              ..where((t) => t.orderNo.like('$prefix-%'))
              ..orderBy([(t) => OrderingTerm.desc(t.orderNo)])
              ..limit(1))
            .get();

    var seq = 1;
    if (rows.isNotEmpty) {
      final tail = rows.first.orderNo.split('-').last;
      seq = (int.tryParse(tail) ?? 0) + 1;
    }
    return '$prefix-${seq.toString().padLeft(3, '0')}';
  }

  Future<int> updateOrder(
    int id, {
    Value<int?> opportunityId = const Value.absent(),
    String? orderNo,
    DateTime? orderedAt,
    int? amountCents,
    Value<String?> piPoNo = const Value.absent(),
    String? currency,
    PaymentStatus? paymentStatus,
    ProductionStatus? productionStatus,
    ShippingStatus? shippingStatus,
    Value<DateTime?> estimatedArrivalAt = const Value.absent(),
    OrderResult? orderResult,
    Value<DateTime?> estimatedRepurchaseAt = const Value.absent(),
    Value<String?> description = const Value.absent(),
    OrderStatus? status,
    DateTime? now,
  }) async {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final changesSplitStatus =
        paymentStatus != null ||
        productionStatus != null ||
        shippingStatus != null ||
        orderResult != null;
    PaymentStatus? effectivePayment;
    ProductionStatus? effectiveProduction;
    ShippingStatus? effectiveShipping;
    OrderResult? effectiveResult;
    OrderStatus? effectiveStatus;

    if (status != null) {
      final split = _splitStatus(status);
      effectivePayment = split.payment;
      effectiveProduction = split.production;
      effectiveShipping = split.shipping;
      effectiveResult = split.result;
      effectiveStatus = status;
    } else if (changesSplitStatus) {
      final current = await findById(id);
      if (current == null) return 0;
      effectivePayment =
          paymentStatus ?? PaymentStatus.fromDb(current.paymentStatus);
      effectiveProduction =
          productionStatus ?? ProductionStatus.fromDb(current.productionStatus);
      effectiveShipping =
          shippingStatus ?? ShippingStatus.fromDb(current.shippingStatus);
      effectiveResult = orderResult ?? OrderResult.fromDb(current.orderResult);
      effectiveStatus = _legacyStatus(
        payment: effectivePayment,
        shipping: effectiveShipping,
        result: effectiveResult,
      );
    }

    return (update(orders)..where((t) => t.id.equals(id))).write(
      OrdersCompanion(
        opportunityId: opportunityId,
        orderNo: orderNo == null ? const Value.absent() : Value(orderNo),
        orderedAt: orderedAt == null
            ? const Value.absent()
            : Value(orderedAt.toUtc().millisecondsSinceEpoch),
        amountCents: amountCents == null
            ? const Value.absent()
            : Value(amountCents),
        piPoNo: piPoNo,
        currency: currency == null ? const Value.absent() : Value(currency),
        paymentStatus: effectivePayment == null
            ? const Value.absent()
            : Value(effectivePayment.dbValue),
        productionStatus: effectiveProduction == null
            ? const Value.absent()
            : Value(effectiveProduction.dbValue),
        shippingStatus: effectiveShipping == null
            ? const Value.absent()
            : Value(effectiveShipping.dbValue),
        estimatedArrivalAt: _dateValue(estimatedArrivalAt),
        orderResult: effectiveResult == null
            ? const Value.absent()
            : Value(effectiveResult.dbValue),
        estimatedRepurchaseAt: _dateValue(estimatedRepurchaseAt),
        description: description,
        status: effectiveStatus == null
            ? const Value.absent()
            : Value(effectiveStatus.dbValue),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> updateStatus(int id, OrderStatus status, {DateTime? now}) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final split = _splitStatus(status);
    return (update(orders)..where((t) => t.id.equals(id))).write(
      OrdersCompanion(
        status: Value(status.dbValue),
        paymentStatus: Value(split.payment.dbValue),
        productionStatus: Value(split.production.dbValue),
        shippingStatus: Value(split.shipping.dbValue),
        orderResult: Value(split.result.dbValue),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> completeOpenRepurchaseTasks({
    required int customerId,
    required int opportunityId,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(followPlans)..where(
          (t) =>
              t.customerId.equals(customerId) &
              t.opportunityId.equals(opportunityId) &
              t.sourceType.equals(TaskSourceType.repurchase.dbValue) &
              t.status.isIn([
                PlanStatus.pending.dbValue,
                PlanStatus.notified.dbValue,
                PlanStatus.overdue.dbValue,
              ]),
        ))
        .write(
          FollowPlansCompanion(
            status: Value(PlanStatus.completed.dbValue),
            completedAt: Value(ts),
            updatedAt: Value(ts),
          ),
        );
  }

  /// 删除订单。其附件记录由外键级联删除。
  Future<int> deleteOrder(int id) =>
      (delete(orders)..where((t) => t.id.equals(id))).go();

  ({
    PaymentStatus payment,
    ProductionStatus production,
    ShippingStatus shipping,
    OrderResult result,
  })
  _splitStatus(OrderStatus status) => switch (status) {
    OrderStatus.pending => (
      payment: PaymentStatus.pending,
      production: ProductionStatus.pending,
      shipping: ShippingStatus.pending,
      result: OrderResult.inProgress,
    ),
    OrderStatus.shipped => (
      payment: PaymentStatus.pending,
      production: ProductionStatus.completed,
      shipping: ShippingStatus.shipped,
      result: OrderResult.inProgress,
    ),
    OrderStatus.paid => (
      payment: PaymentStatus.paid,
      production: ProductionStatus.completed,
      shipping: ShippingStatus.shipped,
      result: OrderResult.inProgress,
    ),
    OrderStatus.completed => (
      payment: PaymentStatus.paid,
      production: ProductionStatus.completed,
      shipping: ShippingStatus.delivered,
      result: OrderResult.completed,
    ),
    OrderStatus.cancelled => (
      payment: PaymentStatus.cancelled,
      production: ProductionStatus.cancelled,
      shipping: ShippingStatus.cancelled,
      result: OrderResult.cancelled,
    ),
  };

  OrderStatus _legacyStatus({
    required PaymentStatus payment,
    required ShippingStatus shipping,
    required OrderResult result,
  }) {
    if (result == OrderResult.cancelled) return OrderStatus.cancelled;
    if (result == OrderResult.completed) return OrderStatus.completed;
    if (payment == PaymentStatus.paid) return OrderStatus.paid;
    if (shipping == ShippingStatus.shipped ||
        shipping == ShippingStatus.delivered) {
      return OrderStatus.shipped;
    }
    return OrderStatus.pending;
  }

  Value<int?> _dateValue(Value<DateTime?> value) => value.present
      ? Value(value.value?.toUtc().millisecondsSinceEpoch)
      : const Value.absent();
}
