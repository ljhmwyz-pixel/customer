import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/tenders.dart';

part 'tender_dao.g.dart';

@DriftAccessor(tables: [Tenders])
class TenderDao extends DatabaseAccessor<AppDatabase> with _$TenderDaoMixin {
  TenderDao(super.db);

  Future<int> insertTender({
    required int opportunityId,
    String? projectNo,
    String? name,
    DateTime? deadlineAt,
    TenderDocumentStatus documentStatus = TenderDocumentStatus.incomplete,
    TenderQualificationStatus qualificationStatus =
        TenderQualificationStatus.pending,
    String? bidder,
    int? depositMinor,
    String? customerExperience,
    TenderVerificationStatus localTeamStatus = TenderVerificationStatus.pending,
    TenderVerificationStatus fundingStatus = TenderVerificationStatus.pending,
    TenderRiskLevel riskLevel = TenderRiskLevel.low,
    TenderAuthorizationType authorizationType = TenderAuthorizationType.none,
    DateTime? authorizationExpiresAt,
    String? exclusiveQuoteScope,
    String? floorPriceSupport,
    TenderStatus status = TenderStatus.preparing,
    String? nextAction,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(tenders).insert(
      TendersCompanion.insert(
        opportunityId: opportunityId,
        projectNo: Value(projectNo?.trim()),
        name: Value(name?.trim()),
        deadlineAt: Value(deadlineAt?.toUtc().millisecondsSinceEpoch),
        documentStatus: Value(documentStatus.dbValue),
        qualificationStatus: Value(qualificationStatus.dbValue),
        bidder: Value(bidder?.trim()),
        depositMinor: Value(depositMinor),
        customerExperience: Value(customerExperience?.trim()),
        localTeamStatus: Value(localTeamStatus.dbValue),
        fundingStatus: Value(fundingStatus.dbValue),
        riskLevel: Value(riskLevel.dbValue),
        authorizationType: Value(authorizationType.dbValue),
        authorizationExpiresAt: Value(
          authorizationExpiresAt?.toUtc().millisecondsSinceEpoch,
        ),
        exclusiveQuoteScope: Value(exclusiveQuoteScope?.trim()),
        floorPriceSupport: Value(floorPriceSupport?.trim()),
        status: Value(status.dbValue),
        nextAction: Value(nextAction?.trim()),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<TenderRow?> findById(int id) =>
      (select(tenders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<TenderRow>> listOf(int opportunityId) async {
    final rows = await _activeOf(opportunityId).get();
    _sortByDeadline(rows);
    return rows;
  }

  Stream<List<TenderRow>> watchOf(int opportunityId) =>
      _activeOf(opportunityId).watch().map((rows) {
        _sortByDeadline(rows);
        return rows;
      });

  Future<int> updateTender(
    int id, {
    Value<String?> projectNo = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<DateTime?> deadlineAt = const Value.absent(),
    TenderDocumentStatus? documentStatus,
    TenderQualificationStatus? qualificationStatus,
    Value<String?> bidder = const Value.absent(),
    Value<int?> depositMinor = const Value.absent(),
    Value<String?> customerExperience = const Value.absent(),
    TenderVerificationStatus? localTeamStatus,
    TenderVerificationStatus? fundingStatus,
    TenderRiskLevel? riskLevel,
    TenderAuthorizationType? authorizationType,
    Value<DateTime?> authorizationExpiresAt = const Value.absent(),
    Value<String?> exclusiveQuoteScope = const Value.absent(),
    Value<String?> floorPriceSupport = const Value.absent(),
    TenderStatus? status,
    Value<String?> nextAction = const Value.absent(),
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(tenders)..where((t) => t.id.equals(id))).write(
      TendersCompanion(
        projectNo: _trimmed(projectNo),
        name: _trimmed(name),
        deadlineAt: _dateValue(deadlineAt),
        documentStatus: documentStatus == null
            ? const Value.absent()
            : Value(documentStatus.dbValue),
        qualificationStatus: qualificationStatus == null
            ? const Value.absent()
            : Value(qualificationStatus.dbValue),
        bidder: _trimmed(bidder),
        depositMinor: depositMinor,
        customerExperience: _trimmed(customerExperience),
        localTeamStatus: localTeamStatus == null
            ? const Value.absent()
            : Value(localTeamStatus.dbValue),
        fundingStatus: fundingStatus == null
            ? const Value.absent()
            : Value(fundingStatus.dbValue),
        riskLevel: riskLevel == null
            ? const Value.absent()
            : Value(riskLevel.dbValue),
        authorizationType: authorizationType == null
            ? const Value.absent()
            : Value(authorizationType.dbValue),
        authorizationExpiresAt: _dateValue(authorizationExpiresAt),
        exclusiveQuoteScope: _trimmed(exclusiveQuoteScope),
        floorPriceSupport: _trimmed(floorPriceSupport),
        status: status == null ? const Value.absent() : Value(status.dbValue),
        nextAction: _trimmed(nextAction),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> deleteTender(int id) =>
      (delete(tenders)..where((t) => t.id.equals(id))).go();

  Future<List<TenderRow>> listOpenDeadlines({
    required DateTime from,
    required DateTime to,
  }) =>
      (select(tenders)
            ..where(
              (t) =>
                  t.status.equals(TenderStatus.open.dbValue) &
                  t.deadlineAt.isBiggerOrEqualValue(
                    from.toUtc().millisecondsSinceEpoch,
                  ) &
                  t.deadlineAt.isSmallerOrEqualValue(
                    to.toUtc().millisecondsSinceEpoch,
                  ),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(t.deadlineAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

  SimpleSelectStatement<$TendersTable, TenderRow> _activeOf(
    int opportunityId,
  ) => select(tenders)
    ..where(
      (t) =>
          t.opportunityId.equals(opportunityId) &
          t.status.isNotIn([
            TenderStatus.won.dbValue,
            TenderStatus.lost.dbValue,
            TenderStatus.closed.dbValue,
            TenderStatus.abandoned.dbValue,
            TenderStatus.disqualified.dbValue,
          ]),
    );

  void _sortByDeadline(List<TenderRow> rows) {
    rows.sort((left, right) {
      final leftDeadline = left.deadlineAt;
      final rightDeadline = right.deadlineAt;
      if (leftDeadline == null && rightDeadline != null) return 1;
      if (leftDeadline != null && rightDeadline == null) return -1;
      final deadlineOrder = leftDeadline == null
          ? 0
          : leftDeadline.compareTo(rightDeadline!);
      return deadlineOrder != 0 ? deadlineOrder : left.id.compareTo(right.id);
    });
  }

  Value<String?> _trimmed(Value<String?> value) =>
      value.present ? Value(value.value?.trim()) : const Value.absent();

  Value<int?> _dateValue(Value<DateTime?> value) => value.present
      ? Value(value.value?.toUtc().millisecondsSinceEpoch)
      : const Value.absent();
}
