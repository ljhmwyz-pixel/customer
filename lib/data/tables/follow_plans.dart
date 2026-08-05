import 'package:drift/drift.dart';

import 'customers.dart';
import 'opportunities.dart';

/// 跟进计划表。待办与提醒的载体。
///
/// 做成独立表而非客户表上的一个 next_follow_at 字段，原因有两个：
/// 一个客户可能有多条并行待办（催合同、送样品、节日问候），
/// 且提醒本身需要状态机。
///
/// 提醒一律一次性，不做周期性重复。
@DataClassName('FollowPlanRow')
class FollowPlans extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  /// v2 项目归属。为兼容原表结构保持可空，迁移会为全部旧记录回填。
  IntColumn get opportunityId => integer().nullable().references(
    Opportunities,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 事项标题，如「催合同」。
  TextColumn get title => text().withLength(min: 1, max: 100)();

  /// 计划时间，UTC 毫秒。建索引，待办查询与闹钟排期都按它过滤。
  IntColumn get planAt => integer()();

  /// 状态，存 PlanStatus.dbValue。
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// 提醒实际触发时间，UTC 毫秒。
  ///
  /// 对应 PRD 5.3 的可靠性自查要求：阶段 2 在一加 13 上连续验证时，
  /// 靠它与 planAt 的偏差判断 ColorOS 有没有掐掉闹钟。
  IntColumn get notifiedAt => integer().nullable()();

  IntColumn get completedAt => integer().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
