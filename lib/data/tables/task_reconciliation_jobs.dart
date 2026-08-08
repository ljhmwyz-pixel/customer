import 'package:drift/drift.dart';

import 'opportunities.dart';

/// 自动业务任务未能同步时留下的持久化修复队列。
@DataClassName('TaskReconciliationJobRow')
class TaskReconciliationJobs extends Table {
  IntColumn get opportunityId =>
      integer().references(Opportunities, #id, onDelete: KeyAction.cascade)();

  IntColumn get attemptCount => integer().withDefault(const Constant(1))();

  TextColumn get lastError => text().nullable()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {opportunityId};
}
