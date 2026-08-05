import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/customers.dart';
import '../tables/opportunities.dart';

part 'opportunity_dao.g.dart';

/// 客户项目的数据访问层。业务模块通过项目关联报价、样品、跟进与订单。
@DriftAccessor(tables: [Opportunities, Customers])
class OpportunityDao extends DatabaseAccessor<AppDatabase>
    with _$OpportunityDaoMixin {
  OpportunityDao(super.db);

  Future<int> insertOpportunity({
    required int customerId,
    required String name,
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

  Future<int> deleteOpportunity(int id) =>
      (delete(opportunities)..where((table) => table.id.equals(id))).go();
}
