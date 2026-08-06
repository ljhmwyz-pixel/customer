import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/registrations.dart';

part 'registration_dao.g.dart';

@DriftAccessor(tables: [Registrations])
class RegistrationDao extends DatabaseAccessor<AppDatabase>
    with _$RegistrationDaoMixin {
  RegistrationDao(super.db);

  Future<int> insertRegistration({
    required int opportunityId,
    String? country,
    String? requirements,
    String? documentChecklist,
    RegistrationDocumentStatus documentStatus =
        RegistrationDocumentStatus.pending,
    DateTime? submittedAt,
    DateTime? expectedCompletedAt,
    DateTime? actualCompletedAt,
    String? costBearer,
    RegistrationStatus status = RegistrationStatus.preparing,
    String? currentObstacle,
    String? nextAction,
    DateTime? documentDueAt,
    DateTime? milestoneAt,
    String? milestoneTitle,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(registrations).insert(
      RegistrationsCompanion.insert(
        opportunityId: opportunityId,
        country: Value(country?.trim()),
        requirements: Value(requirements?.trim()),
        documentChecklist: Value(documentChecklist?.trim()),
        documentStatus: Value(documentStatus.dbValue),
        submittedAt: Value(submittedAt?.toUtc().millisecondsSinceEpoch),
        expectedCompletedAt: Value(
          expectedCompletedAt?.toUtc().millisecondsSinceEpoch,
        ),
        actualCompletedAt: Value(
          actualCompletedAt?.toUtc().millisecondsSinceEpoch,
        ),
        costBearer: Value(costBearer?.trim()),
        status: Value(status.dbValue),
        currentObstacle: Value(currentObstacle?.trim()),
        nextAction: Value(nextAction?.trim()),
        documentDueAt: Value(documentDueAt?.toUtc().millisecondsSinceEpoch),
        milestoneAt: Value(milestoneAt?.toUtc().millisecondsSinceEpoch),
        milestoneTitle: Value(milestoneTitle?.trim()),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<RegistrationRow?> findById(int id) =>
      (select(registrations)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<RegistrationRow>> listOf(int opportunityId) =>
      (select(registrations)
            ..where((t) => t.opportunityId.equals(opportunityId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Stream<List<RegistrationRow>> watchOf(int opportunityId) =>
      (select(registrations)
            ..where((t) => t.opportunityId.equals(opportunityId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  Future<int> updateRegistration(
    int id, {
    Value<String?> country = const Value.absent(),
    Value<String?> requirements = const Value.absent(),
    Value<String?> documentChecklist = const Value.absent(),
    RegistrationDocumentStatus? documentStatus,
    Value<DateTime?> submittedAt = const Value.absent(),
    Value<DateTime?> expectedCompletedAt = const Value.absent(),
    Value<DateTime?> actualCompletedAt = const Value.absent(),
    Value<String?> costBearer = const Value.absent(),
    RegistrationStatus? status,
    Value<String?> currentObstacle = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<DateTime?> documentDueAt = const Value.absent(),
    Value<DateTime?> milestoneAt = const Value.absent(),
    Value<String?> milestoneTitle = const Value.absent(),
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(registrations)..where((t) => t.id.equals(id))).write(
      RegistrationsCompanion(
        country: _trimmed(country),
        requirements: _trimmed(requirements),
        documentChecklist: _trimmed(documentChecklist),
        documentStatus: documentStatus == null
            ? const Value.absent()
            : Value(documentStatus.dbValue),
        submittedAt: _dateValue(submittedAt),
        expectedCompletedAt: _dateValue(expectedCompletedAt),
        actualCompletedAt: _dateValue(actualCompletedAt),
        costBearer: _trimmed(costBearer),
        status: status == null ? const Value.absent() : Value(status.dbValue),
        currentObstacle: _trimmed(currentObstacle),
        nextAction: _trimmed(nextAction),
        documentDueAt: _dateValue(documentDueAt),
        milestoneAt: _dateValue(milestoneAt),
        milestoneTitle: _trimmed(milestoneTitle),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> deleteRegistration(int id) =>
      (delete(registrations)..where((t) => t.id.equals(id))).go();

  Future<List<RegistrationRow>> listDue({
    required DateTime from,
    required DateTime to,
  }) async {
    final fromMs = from.toUtc().millisecondsSinceEpoch;
    final toMs = to.toUtc().millisecondsSinceEpoch;
    Expression<bool> inWindow(GeneratedColumn<int> column) =>
        column.isBiggerOrEqualValue(fromMs) &
        column.isSmallerOrEqualValue(toMs);
    final rows =
        await (select(registrations)..where(
              (t) =>
                  t.status.isNotIn([
                    RegistrationStatus.completed.dbValue,
                    RegistrationStatus.cancelled.dbValue,
                  ]) &
                  (inWindow(t.expectedCompletedAt) |
                      inWindow(t.documentDueAt) |
                      inWindow(t.milestoneAt)),
            ))
            .get();
    rows.sort((a, b) {
      int earliest(RegistrationRow row) =>
          [row.expectedCompletedAt, row.documentDueAt, row.milestoneAt]
              .whereType<int>()
              .where((value) => value >= fromMs && value <= toMs)
              .reduce((left, right) => left < right ? left : right);
      final dateOrder = earliest(a).compareTo(earliest(b));
      return dateOrder != 0 ? dateOrder : a.id.compareTo(b.id);
    });
    return rows;
  }

  Value<String?> _trimmed(Value<String?> value) =>
      value.present ? Value(value.value?.trim()) : const Value.absent();

  Value<int?> _dateValue(Value<DateTime?> value) => value.present
      ? Value(value.value?.toUtc().millisecondsSinceEpoch)
      : const Value.absent();
}
