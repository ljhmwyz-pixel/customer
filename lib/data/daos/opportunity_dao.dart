import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/customers.dart';
import '../tables/follow_plans.dart';
import '../tables/followups.dart';
import '../tables/opportunities.dart';
import '../tables/orders.dart';

part 'opportunity_dao.g.dart';

/// 客户项目的数据访问层。业务模块通过项目关联报价、样品、跟进与订单。
@DriftAccessor(
  tables: [Opportunities, Customers, Followups, FollowPlans, Orders],
)
class OpportunityDao extends DatabaseAccessor<AppDatabase>
    with _$OpportunityDaoMixin {
  OpportunityDao(super.db);

  Future<int> insertOpportunity({
    required int customerId,
    required String name,
    String owner = '本人',
    OpportunityImportance importance = OpportunityImportance.normal,
    String? productCategory,
    String? productModel,
    String? equipmentBrand,
    String? equipmentModel,
    int? estimatedAnnualVolume,
    int? forecastAmountMinor,
    String currency = 'USD',
    int? probabilityPercent,
    DateTime? expectedCloseAt,
    String? currentSupplier,
    String? currentPurchaseBrand,
    int? currentPurchasePriceMinor,
    String? supplierStability,
    String? supplierProblem,
    String? changeWillingness,
    String? substitutionDifficulty,
    int? latestQuoteMinor,
    int? targetPriceMinor,
    String? entryPoint,
    String? investmentAdvice,
    bool needsSample = false,
    bool needsRegistration = false,
    bool needsAuthorization = false,
    OpportunityStage stage = OpportunityStage.newLead,
    OpportunityStatus status = OpportunityStatus.active,
    String? latestFeedback,
    String? currentObstacle,
    String? nextAction,
    DateTime? nextFollowAt,
    bool isLegacyDefault = false,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(opportunities).insert(
      OpportunitiesCompanion.insert(
        customerId: customerId,
        name: name,
        owner: Value(owner),
        importance: Value(importance.dbValue),
        productCategory: Value(productCategory),
        productModel: Value(productModel),
        equipmentBrand: Value(equipmentBrand),
        equipmentModel: Value(equipmentModel),
        estimatedAnnualVolume: Value(estimatedAnnualVolume),
        forecastAmountMinor: Value(forecastAmountMinor),
        currency: Value(currency),
        probabilityPercent: Value(probabilityPercent),
        expectedCloseAt: Value(expectedCloseAt?.toUtc().millisecondsSinceEpoch),
        currentSupplier: Value(currentSupplier),
        currentPurchaseBrand: Value(currentPurchaseBrand),
        currentPurchasePriceMinor: Value(currentPurchasePriceMinor),
        supplierStability: Value(supplierStability),
        supplierProblem: Value(supplierProblem),
        changeWillingness: Value(changeWillingness),
        substitutionDifficulty: Value(substitutionDifficulty),
        latestQuoteMinor: Value(latestQuoteMinor),
        targetPriceMinor: Value(targetPriceMinor),
        entryPoint: Value(entryPoint),
        investmentAdvice: Value(investmentAdvice),
        needsSample: Value(needsSample),
        needsRegistration: Value(needsRegistration),
        needsAuthorization: Value(needsAuthorization),
        stage: Value(stage.dbValue),
        status: Value(status.dbValue),
        latestFeedback: Value(latestFeedback),
        currentObstacle: Value(currentObstacle),
        nextAction: Value(nextAction),
        nextFollowAt: Value(nextFollowAt?.toUtc().millisecondsSinceEpoch),
        isLegacyDefault: Value(isLegacyDefault),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<OpportunityRow?> findById(int id) => (select(
    opportunities,
  )..where((table) => table.id.equals(id))).getSingleOrNull();

  /// 仅用时间严格较新的跟进快照刷新项目现状，补录和同时间记录不覆盖。
  Future<bool> syncLatestFollowup({
    required int opportunityId,
    required DateTime occurredAt,
    required String feedback,
    required OpportunityStage stage,
    required String nextAction,
    DateTime? nextFollowAt,
    DateTime? now,
  }) async {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final occurredMs = occurredAt.toUtc().millisecondsSinceEpoch;
    final affected =
        await (update(opportunities)..where(
              (table) =>
                  table.id.equals(opportunityId) &
                  (table.lastFollowAt.isNull() |
                      table.lastFollowAt.isSmallerThanValue(occurredMs)),
            ))
            .write(
              OpportunitiesCompanion(
                lastFollowAt: Value(occurredMs),
                latestFeedback: Value(feedback),
                stage: Value(stage.dbValue),
                nextAction: Value(nextAction),
                nextFollowAt: Value(
                  nextFollowAt?.toUtc().millisecondsSinceEpoch,
                ),
                updatedAt: Value(ts),
              ),
            );
    return affected > 0;
  }

  Future<int> updateOpportunity(
    int id, {
    required String name,
    required String currency,
    required OpportunityStage stage,
    required OpportunityStatus status,
    Value<String?> productCategory = const Value.absent(),
    Value<String?> productModel = const Value.absent(),
    Value<String?> equipmentBrand = const Value.absent(),
    Value<String?> equipmentModel = const Value.absent(),
    Value<int?> estimatedAnnualVolume = const Value.absent(),
    Value<int?> forecastAmountMinor = const Value.absent(),
    Value<int?> probabilityPercent = const Value.absent(),
    Value<DateTime?> expectedCloseAt = const Value.absent(),
    Value<String?> currentSupplier = const Value.absent(),
    Value<String?> currentPurchaseBrand = const Value.absent(),
    Value<int?> currentPurchasePriceMinor = const Value.absent(),
    Value<String?> supplierStability = const Value.absent(),
    Value<String?> supplierProblem = const Value.absent(),
    Value<String?> changeWillingness = const Value.absent(),
    Value<String?> substitutionDifficulty = const Value.absent(),
    Value<int?> latestQuoteMinor = const Value.absent(),
    Value<int?> targetPriceMinor = const Value.absent(),
    Value<String?> entryPoint = const Value.absent(),
    Value<String?> investmentAdvice = const Value.absent(),
    bool? needsSample,
    bool? needsRegistration,
    bool? needsAuthorization,
    Value<String?> latestFeedback = const Value.absent(),
    Value<String?> currentObstacle = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<DateTime?> nextFollowAt = const Value.absent(),
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(opportunities)..where((table) => table.id.equals(id))).write(
      OpportunitiesCompanion(
        name: Value(name),
        productCategory: productCategory,
        productModel: productModel,
        equipmentBrand: equipmentBrand,
        equipmentModel: equipmentModel,
        estimatedAnnualVolume: estimatedAnnualVolume,
        forecastAmountMinor: forecastAmountMinor,
        currency: Value(currency),
        probabilityPercent: probabilityPercent,
        expectedCloseAt: expectedCloseAt.present
            ? Value(expectedCloseAt.value?.toUtc().millisecondsSinceEpoch)
            : const Value.absent(),
        currentSupplier: currentSupplier,
        currentPurchaseBrand: currentPurchaseBrand,
        currentPurchasePriceMinor: currentPurchasePriceMinor,
        supplierStability: supplierStability,
        supplierProblem: supplierProblem,
        changeWillingness: changeWillingness,
        substitutionDifficulty: substitutionDifficulty,
        latestQuoteMinor: latestQuoteMinor,
        targetPriceMinor: targetPriceMinor,
        entryPoint: entryPoint,
        investmentAdvice: investmentAdvice,
        needsSample: needsSample == null
            ? const Value.absent()
            : Value(needsSample),
        needsRegistration: needsRegistration == null
            ? const Value.absent()
            : Value(needsRegistration),
        needsAuthorization: needsAuthorization == null
            ? const Value.absent()
            : Value(needsAuthorization),
        stage: Value(stage.dbValue),
        status: Value(status.dbValue),
        latestFeedback: latestFeedback,
        currentObstacle: currentObstacle,
        nextAction: nextAction,
        nextFollowAt: nextFollowAt.present
            ? Value(nextFollowAt.value?.toUtc().millisecondsSinceEpoch)
            : const Value.absent(),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<List<OpportunityRow>> listOfCustomer(int customerId) =>
      (select(opportunities)
            ..where((table) => table.customerId.equals(customerId))
            ..orderBy([
              (table) => OrderingTerm.desc(table.updatedAt),
              (table) => OrderingTerm.desc(table.id),
            ]))
          .get();

  Future<OpportunityRow?> findLegacyDefaultOfCustomer(int customerId) =>
      (select(opportunities)..where(
            (table) =>
                table.customerId.equals(customerId) &
                table.isLegacyDefault.equals(true),
          ))
          .getSingleOrNull();

  /// 兼容尚未接入项目选择器的 v1 页面：每个客户只创建一个承接项目。
  Future<int> ensureLegacyDefaultForCustomer(
    int customerId, {
    String name = '待确认项目',
    CustomerStage? legacyStage,
    DateTime? now,
  }) async {
    final existing = await findLegacyDefaultOfCustomer(customerId);
    if (existing != null) return existing.id;
    final stage = legacyStage == null
        ? OpportunityStage.newLead
        : OpportunityStage.fromLegacyCustomerStage(legacyStage);
    final status = switch (stage) {
      OpportunityStage.won => OpportunityStatus.won,
      OpportunityStage.lost => OpportunityStatus.closed,
      _ => OpportunityStatus.active,
    };
    return insertOpportunity(
      customerId: customerId,
      name: name,
      stage: stage,
      status: status,
      isLegacyDefault: true,
      now: now,
    );
  }

  /// v1 客户编辑页仍在修改客户阶段时，同步兼容项目，避免两套阶段漂移。
  Future<void> syncLegacyStageForCustomer(
    int customerId,
    CustomerStage legacyStage, {
    DateTime? now,
  }) async {
    final id = await ensureLegacyDefaultForCustomer(
      customerId,
      legacyStage: legacyStage,
      now: now,
    );
    final stage = OpportunityStage.fromLegacyCustomerStage(legacyStage);
    final status = switch (stage) {
      OpportunityStage.won => OpportunityStatus.won,
      OpportunityStage.lost => OpportunityStatus.closed,
      _ => OpportunityStatus.active,
    };
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    await (update(opportunities)..where((table) => table.id.equals(id))).write(
      OpportunitiesCompanion(
        stage: Value(stage.dbValue),
        status: Value(status.dbValue),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> countAll() async {
    final count = opportunities.id.count();
    final query = selectOnly(opportunities)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<bool> hasLinkedBusinessRecords(int id) async {
    final row = await customSelect(
      '''
        SELECT EXISTS (
          SELECT 1 FROM followups WHERE opportunity_id = ?
          UNION ALL
          SELECT 1 FROM follow_plans WHERE opportunity_id = ?
          UNION ALL
          SELECT 1 FROM orders WHERE opportunity_id = ?
          LIMIT 1
        ) AS has_records
      ''',
      variables: [
        Variable.withInt(id),
        Variable.withInt(id),
        Variable.withInt(id),
      ],
      readsFrom: {followups, followPlans, orders},
    ).getSingle();
    return row.read<int>('has_records') == 1;
  }

  Future<int> deleteOpportunity(int id) =>
      (delete(opportunities)..where((table) => table.id.equals(id))).go();
}
