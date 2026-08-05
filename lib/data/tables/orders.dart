import 'package:drift/drift.dart';

import 'customers.dart';
import 'opportunities.dart';

/// 订单表。老客户订单跟踪。
@DataClassName('OrderRow')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  /// v2 项目归属。为兼容原表结构保持可空，迁移会为全部旧记录回填。
  IntColumn get opportunityId => integer().nullable().references(
    Opportunities,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 订单编号。唯一，可由系统按日期序号自动生成。
  TextColumn get orderNo => text().withLength(min: 1, max: 50).unique()();

  /// 下单日期，UTC 毫秒。
  IntColumn get orderedAt => integer()();

  /// 金额，单位分。
  ///
  /// 字段名带单位是刻意的：写 amount 迟早有人塞进去一个元为单位的 double，
  /// 浮点误差在金额上不可接受。
  IntColumn get amountCents => integer()();

  /// 商品或服务描述。
  TextColumn get description => text().nullable()();

  /// 状态，存 OrderStatus.dbValue。
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// PI/PO 单号。与内部订单编号分开保存。
  TextColumn get piPoNo => text().nullable()();

  TextColumn get currency => text().withDefault(const Constant('CNY'))();

  TextColumn get paymentStatus =>
      text().withDefault(const Constant('pending'))();

  TextColumn get productionStatus =>
      text().withDefault(const Constant('pending'))();

  TextColumn get shippingStatus =>
      text().withDefault(const Constant('pending'))();

  IntColumn get estimatedArrivalAt => integer().nullable()();

  TextColumn get orderResult =>
      text().withDefault(const Constant('inProgress'))();

  IntColumn get estimatedRepurchaseAt => integer().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  List<String> get customConstraints => [
    'CHECK (amount_cents >= 0)',
    "CHECK (payment_status IN ('pending', 'partial', 'paid', 'cancelled'))",
    "CHECK (production_status IN ('pending', 'inProgress', 'completed', 'cancelled'))",
    "CHECK (shipping_status IN ('pending', 'shipped', 'delivered', 'cancelled'))",
    "CHECK (order_result IN ('inProgress', 'completed', 'cancelled'))",
  ];
}
