import 'package:drift/drift.dart';

import 'customers.dart';
import 'opportunities.dart';

/// 跟进记录表。已经发生的事，只增不改。
///
/// 与 follow_plans 的区别：这里记已发生，那里记待办。
@DataClassName('FollowupRow')
class Followups extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  /// v2 项目归属。为兼容原表结构保持可空，迁移会为全部旧记录回填。
  IntColumn get opportunityId => integer().nullable().references(
    Opportunities,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 发生时间，UTC 毫秒。可以补录过去的跟进，所以不用 createdAt 代替。
  IntColumn get occurredAt => integer()();

  /// 跟进方式，存 FollowMethod.dbValue。
  TextColumn get method => text()();

  /// 沟通内容。
  TextColumn get content => text()();

  /// 本次结论。可空，不是每次跟进都有明确结论。
  TextColumn get conclusion => text().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
