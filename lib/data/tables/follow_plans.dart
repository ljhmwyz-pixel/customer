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

  /// 业务来源，存 TaskSourceType.dbValue。
  TextColumn get sourceType => text().withDefault(const Constant('legacy'))();

  /// 来源业务记录主键。手工和历史任务为空。
  IntColumn get sourceId => integer().nullable()();

  /// 自动任务规则稳定键，与 sourceType/sourceId 共同用于去重。
  TextColumn get ruleKey => text().nullable()();

  /// 事项标题，如「催合同」。
  TextColumn get title => text().withLength(min: 1, max: 100)();

  /// 任务生成或手工安排的原因。历史任务保持为空。
  TextColumn get reason => text().nullable()();

  /// 建议沟通重点，只提供方向，不生成对外消息。
  TextColumn get talkingDirection => text().nullable()();

  /// 任务创建时的下一步行动快照。
  TextColumn get nextAction => text().nullable()();

  /// 任务负责人快照。单人版默认本人。
  TextColumn get owner => text().withDefault(const Constant('本人'))();

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

  IntColumn get cancelledAt => integer().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
