import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/samples.dart';

part 'sample_dao.g.dart';

@DriftAccessor(tables: [Samples])
class SampleDao extends DatabaseAccessor<AppDatabase> with _$SampleDaoMixin {
  SampleDao(super.db);

  Future<int> insertSample({
    required int opportunityId,
    String? sampleModel,
    required int quantity,
    int? feeMinor,
    DateTime? sentAt,
    String? carrier,
    String? trackingNo,
    DateTime? deliveredAt,
    String? recipient,
    String? tester,
    DateTime? plannedTestAt,
    SampleStatus status = SampleStatus.preparing,
    String? testResult,
    String? nextAction,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(samples).insert(
      SamplesCompanion.insert(
        opportunityId: opportunityId,
        sampleModel: Value(sampleModel?.trim()),
        quantity: quantity,
        feeMinor: Value(feeMinor),
        sentAt: Value(sentAt?.toUtc().millisecondsSinceEpoch),
        carrier: Value(carrier?.trim()),
        trackingNo: Value(trackingNo?.trim()),
        deliveredAt: Value(deliveredAt?.toUtc().millisecondsSinceEpoch),
        recipient: Value(recipient?.trim()),
        tester: Value(tester?.trim()),
        plannedTestAt: Value(plannedTestAt?.toUtc().millisecondsSinceEpoch),
        status: Value(status.dbValue),
        testResult: Value(testResult?.trim()),
        nextAction: Value(nextAction?.trim()),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<SampleRow?> findById(int id) =>
      (select(samples)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SampleRow>> listOf(int opportunityId) =>
      (select(samples)
            ..where((t) => t.opportunityId.equals(opportunityId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<int> updateMilestone(
    int id, {
    Value<DateTime?> sentAt = const Value.absent(),
    Value<DateTime?> deliveredAt = const Value.absent(),
    Value<String?> recipient = const Value.absent(),
    Value<String?> tester = const Value.absent(),
    Value<DateTime?> plannedTestAt = const Value.absent(),
    SampleStatus? status,
    Value<String?> testResult = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(samples)..where((t) => t.id.equals(id))).write(
      SamplesCompanion(
        sentAt: sentAt.present
            ? Value(sentAt.value?.toUtc().millisecondsSinceEpoch)
            : const Value.absent(),
        deliveredAt: deliveredAt.present
            ? Value(deliveredAt.value?.toUtc().millisecondsSinceEpoch)
            : const Value.absent(),
        recipient: recipient,
        tester: tester,
        plannedTestAt: plannedTestAt.present
            ? Value(plannedTestAt.value?.toUtc().millisecondsSinceEpoch)
            : const Value.absent(),
        status: status == null ? const Value.absent() : Value(status.dbValue),
        testResult: testResult,
        nextAction: nextAction,
        updatedAt: Value(ts),
      ),
    );
  }
}
