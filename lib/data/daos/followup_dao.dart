import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/customers.dart';
import '../tables/followups.dart';

part 'followup_dao.g.dart';

/// 跟进记录数据访问。
@DriftAccessor(tables: [Followups, Customers])
class FollowupDao extends DatabaseAccessor<AppDatabase>
    with _$FollowupDaoMixin {
  FollowupDao(super.db);

  /// 写入跟进记录，并同步客户的 lastFollowAt。
  ///
  /// 两步放同一事务：lastFollowAt 是冗余字段，一旦与实际记录脱节，
  /// 「久未联系」列表就会漏掉或误报客户。
  ///
  /// 只在新记录比现有 lastFollowAt 更晚时才更新，因为允许补录过去的跟进，
  /// 补录一条上个月的记录不应该把「最后跟进时间」往前拨。
  Future<int> insertAndTouchCustomer({
    required int customerId,
    required DateTime occurredAt,
    required FollowMethod method,
    required String content,
    String? conclusion,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final occurredMs = occurredAt.toUtc().millisecondsSinceEpoch;

    return transaction(() async {
      final id = await into(followups).insert(
        FollowupsCompanion.insert(
          customerId: customerId,
          occurredAt: occurredMs,
          method: method.dbValue,
          content: content,
          conclusion: Value(conclusion),
          createdAt: ts,
          updatedAt: ts,
        ),
      );

      await (update(customers)..where(
            (t) =>
                t.id.equals(customerId) &
                (t.lastFollowAt.isNull() |
                    t.lastFollowAt.isSmallerThanValue(occurredMs)),
          ))
          .write(
            CustomersCompanion(
              lastFollowAt: Value(occurredMs),
              updatedAt: Value(ts),
            ),
          );

      return id;
    });
  }

  Future<FollowupRow?> findById(int id) =>
      (select(followups)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 某客户的跟进记录，时间倒序。客户详情页的时间线用它。
  Future<List<FollowupRow>> listOf(int customerId, {int? limit}) {
    final q = select(followups)
      ..where((t) => t.customerId.equals(customerId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (limit != null) q.limit(limit);
    return q.get();
  }

  Future<int> countOf(int customerId) async {
    final q = selectOnly(followups)
      ..addColumns([followups.id.count()])
      ..where(followups.customerId.equals(customerId));
    final row = await q.getSingle();
    return row.read(followups.id.count()) ?? 0;
  }

  Future<int> countAll() async {
    final q = selectOnly(followups)..addColumns([followups.id.count()]);
    final row = await q.getSingle();
    return row.read(followups.id.count()) ?? 0;
  }

  Future<int> updateFollowup(
    int id, {
    DateTime? occurredAt,
    FollowMethod? method,
    String? content,
    String? conclusion,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(followups)..where((t) => t.id.equals(id))).write(
      FollowupsCompanion(
        occurredAt: occurredAt == null
            ? const Value.absent()
            : Value(occurredAt.toUtc().millisecondsSinceEpoch),
        method: method == null ? const Value.absent() : Value(method.dbValue),
        content: content == null ? const Value.absent() : Value(content),
        conclusion: conclusion == null
            ? const Value.absent()
            : Value(conclusion),
        updatedAt: Value(ts),
      ),
    );
  }

  /// 删除跟进记录。其附件记录由外键级联删除。
  Future<int> deleteFollowup(int id) =>
      (delete(followups)..where((t) => t.id.equals(id))).go();
}
