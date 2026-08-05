import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/quotes.dart';

part 'quote_dao.g.dart';

@DriftAccessor(tables: [Quotes])
class QuoteDao extends DatabaseAccessor<AppDatabase> with _$QuoteDaoMixin {
  QuoteDao(super.db);

  Future<int> nextVersion(int opportunityId, String quoteNo) async {
    final max = quotes.version.max();
    final row =
        await (selectOnly(quotes)
              ..addColumns([max])
              ..where(
                quotes.opportunityId.equals(opportunityId) &
                    quotes.quoteNo.equals(quoteNo),
              ))
            .getSingle();
    return (row.read(max) ?? 0) + 1;
  }

  Future<int> insertVersion({
    required int opportunityId,
    required String quoteNo,
    int? version,
    String? productModel,
    required int quantity,
    String currency = 'USD',
    int? unitPriceMinor,
    int? totalAmountMinor,
    required DateTime quotedAt,
    DateTime? validUntil,
    bool customerReceived = false,
    String? customerFeedback,
    DateTime? nextFollowAt,
    String? result,
    DateTime? now,
  }) async {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final normalizedNo = quoteNo.trim();
    if (normalizedNo.isEmpty) throw ArgumentError('quoteNo is required');
    final resolvedVersion =
        version ?? await nextVersion(opportunityId, normalizedNo);
    return into(quotes).insert(
      QuotesCompanion.insert(
        opportunityId: opportunityId,
        quoteNo: normalizedNo,
        version: resolvedVersion,
        productModel: Value(productModel?.trim()),
        quantity: quantity,
        currency: Value(currency.trim().isEmpty ? 'USD' : currency.trim()),
        unitPriceMinor: Value(unitPriceMinor),
        totalAmountMinor: Value(totalAmountMinor),
        quotedAt: quotedAt.toUtc().millisecondsSinceEpoch,
        validUntil: Value(validUntil?.toUtc().millisecondsSinceEpoch),
        customerReceived: Value(customerReceived),
        customerFeedback: Value(customerFeedback?.trim()),
        nextFollowAt: Value(nextFollowAt?.toUtc().millisecondsSinceEpoch),
        result: Value(result?.trim()),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<List<QuoteRow>> listVersions(int opportunityId) =>
      (select(quotes)
            ..where((t) => t.opportunityId.equals(opportunityId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.quotedAt),
              (t) => OrderingTerm.desc(t.version),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<QuoteRow?> latest(int opportunityId) async {
    final rows =
        await (select(quotes)
              ..where((t) => t.opportunityId.equals(opportunityId))
              ..orderBy([(t) => OrderingTerm.desc(t.version)])
              ..limit(1))
            .get();
    return rows.firstOrNull;
  }
}
