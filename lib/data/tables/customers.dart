import 'package:drift/drift.dart';

/// 客户表。核心实体，其余业务表都挂在它下面。
///
/// 只有 name 必填，其余全部可空。录入负担越低，实际用起来才越可能坚持记。
@DataClassName('CustomerRow')
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 客户名称。唯一必填项。
  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get company => text().nullable()();

  TextColumn get customerNo => text().nullable()();

  TextColumn get customerType => text().nullable()();

  TextColumn get owner => text().withDefault(const Constant('本人'))();

  /// 国家/地区。v4 增量字段，旧客户无法可靠推断所以保持可空。
  TextColumn get country => text().nullable()();

  /// 电话。建索引以支持模糊搜索。
  TextColumn get phone => text().nullable()();

  TextColumn get wechat => text().nullable()();

  TextColumn get address => text().nullable()();

  /// 来源渠道。自由文本，不做枚举，实际来源太杂。
  TextColumn get source => text().nullable()();

  TextColumn get note => text().nullable()();

  TextColumn get tenderExperience => text().nullable()();

  TextColumn get tenderQualification => text().nullable()();

  TextColumn get tenderBidder => text().nullable()();

  TextColumn get localTeamStatus => text().nullable()();

  TextColumn get fundingStatus => text().nullable()();

  /// 客户阶段，存 CustomerStage.dbValue。
  TextColumn get stage => text().withDefault(const Constant('potential'))();

  /// 客户分级，存 CustomerGrade.dbValue。
  TextColumn get grade => text().withDefault(const Constant('c'))();

  /// 可整体撤销的示例数据批次。正式客户始终为空，不在界面中暴露。
  TextColumn get sampleBatchId => text().nullable()();

  /// 最后一次跟进时间，UTC 毫秒。
  ///
  /// 冗余字段，由 FollowupDao 在写入跟进记录时同步维护。
  /// 「久未联系」查询需要按它过滤，每次对 followups 做聚合在 500 客户下太慢。
  IntColumn get lastFollowAt => integer().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
