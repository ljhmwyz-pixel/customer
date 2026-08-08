import 'package:drift/drift.dart';

import 'customers.dart';
import 'opportunities.dart';

/// 项目关键字段的追加式变更记录，用于复盘而不是回滚。
@DataClassName('OpportunityChangeRow')
class OpportunityChanges extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  IntColumn get opportunityId =>
      integer().references(Opportunities, #id, onDelete: KeyAction.cascade)();

  TextColumn get fieldKey => text().withLength(min: 1, max: 50)();

  TextColumn get oldValue => text().nullable()();

  TextColumn get newValue => text().nullable()();

  IntColumn get changedAt => integer()();
}
