import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/orders.dart';

part 'order_dao.g.dart';

/// 订单数据访问。老客户订单跟踪。
@DriftAccessor(tables: [Orders])
class OrderDao extends DatabaseAccessor<AppDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  Future<int> insertOrder({
    required int customerId,
    required String orderNo,
    required DateTime orderedAt,
    required int amountCents,
    String? description,
    OrderStatus status = OrderStatus.pending,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(orders).insert(
      OrdersCompanion.insert(
        customerId: customerId,
        orderNo: orderNo,
        orderedAt: orderedAt.toUtc().millisecondsSinceEpoch,
        amountCents: amountCents,
        description: Value(description),
        status: Value(status.dbValue),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<OrderRow?> findById(int id) =>
      (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<OrderRow?> findByOrderNo(String orderNo) =>
      (select(orders)..where((t) => t.orderNo.equals(orderNo)))
          .getSingleOrNull();

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
  /// 排除 cancelled：取消的订单不算业绩。这里在 SQL 层过滤而不是取回全部
  /// 订单再在 Dart 里筛，客户订单多起来后差别明显。
  Future<int> sumAmountByCustomer(int customerId) async {
    final sum = orders.amountCents.sum();
    final q = selectOnly(orders)
      ..addColumns([sum])
      ..where(
        orders.customerId.equals(customerId) &
            orders.status.isNotValue(OrderStatus.cancelled.dbValue),
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
      ..where(orders.status.isNotValue(OrderStatus.cancelled.dbValue))
      ..groupBy([orders.customerId]);

    final rows = await q.get();
    return {
      for (final row in rows)
        row.read(orders.customerId)!: row.read(sum) ?? 0,
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
    String? orderNo,
    DateTime? orderedAt,
    int? amountCents,
    String? description,
    OrderStatus? status,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(orders)..where((t) => t.id.equals(id))).write(
      OrdersCompanion(
        orderNo: orderNo == null ? const Value.absent() : Value(orderNo),
        orderedAt: orderedAt == null
            ? const Value.absent()
            : Value(orderedAt.toUtc().millisecondsSinceEpoch),
        amountCents: amountCents == null
            ? const Value.absent()
            : Value(amountCents),
        description: description == null
            ? const Value.absent()
            : Value(description),
        status: status == null ? const Value.absent() : Value(status.dbValue),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> updateStatus(int id, OrderStatus status, {DateTime? now}) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(orders)..where((t) => t.id.equals(id))).write(
      OrdersCompanion(status: Value(status.dbValue), updatedAt: Value(ts)),
    );
  }

  /// 删除订单。其附件记录由外键级联删除。
  Future<int> deleteOrder(int id) =>
      (delete(orders)..where((t) => t.id.equals(id))).go();
}
