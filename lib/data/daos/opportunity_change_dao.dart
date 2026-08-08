import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/opportunity_changes.dart';

part 'opportunity_change_dao.g.dart';

class OpportunityFieldChange {
  const OpportunityFieldChange(this.oldValue, this.newValue);

  final String? oldValue;
  final String? newValue;
}

@DriftAccessor(tables: [OpportunityChanges])
class OpportunityChangeDao extends DatabaseAccessor<AppDatabase>
    with _$OpportunityChangeDaoMixin {
  OpportunityChangeDao(super.db);

  Future<void> recordChanges({
    required int customerId,
    required int opportunityId,
    required Map<String, OpportunityFieldChange> changes,
    DateTime? at,
  }) async {
    if (changes.isEmpty) return;
    final changedAt = (at ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    await batch((batch) {
      batch.insertAll(
        opportunityChanges,
        changes.entries
            .map(
              (entry) => OpportunityChangesCompanion.insert(
                customerId: customerId,
                opportunityId: opportunityId,
                fieldKey: entry.key,
                oldValue: Value(entry.value.oldValue),
                newValue: Value(entry.value.newValue),
                changedAt: changedAt,
              ),
            )
            .toList(growable: false),
      );
    });
  }

  Future<List<OpportunityChangeRow>> listOfOpportunity(int opportunityId) =>
      (select(opportunityChanges)
            ..where((row) => row.opportunityId.equals(opportunityId))
            ..orderBy([
              (row) => OrderingTerm.desc(row.changedAt),
              (row) => OrderingTerm.desc(row.id),
            ]))
          .get();

  Future<List<OpportunityChangeRow>> listOfCustomer(int customerId) =>
      (select(opportunityChanges)
            ..where((row) => row.customerId.equals(customerId))
            ..orderBy([
              (row) => OrderingTerm.desc(row.changedAt),
              (row) => OrderingTerm.desc(row.id),
            ]))
          .get();
}
