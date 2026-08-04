import 'package:drift/drift.dart';

import 'customers.dart';

/// 标签表。自由多选，如「价格敏感」「决策人」「同行推荐」。
@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 标签名。唯一，避免同名标签堆积。
  TextColumn get name => text().withLength(min: 1, max: 20).unique()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}

/// 客户与标签的多对多关联表。
@DataClassName('CustomerTagRow')
class CustomerTags extends Table {
  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  IntColumn get createdAt => integer()();

  /// 联合主键，天然防重复关联，不需要额外的唯一索引。
  @override
  Set<Column<Object>> get primaryKey => {customerId, tagId};
}
