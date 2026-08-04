import 'package:drift/drift.dart';

import 'customers.dart';

/// 订单表。老客户订单跟踪。
@DataClassName('OrderRow')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

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

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
