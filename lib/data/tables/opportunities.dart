import 'package:drift/drift.dart';

import 'customers.dart';

/// 客户下的独立产品机会。同一客户可以同时推进多个项目。
@DataClassName('OpportunityRow')
class Opportunities extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get productCategory => text().nullable()();

  TextColumn get productModel => text().nullable()();

  TextColumn get equipmentBrand => text().nullable()();

  TextColumn get equipmentModel => text().nullable()();

  IntColumn get estimatedAnnualVolume => integer().nullable()();

  /// 预计项目金额，单位为 [currency] 的最小货币单位。
  IntColumn get forecastAmountMinor => integer().nullable()();

  TextColumn get currency => text().withDefault(const Constant('USD'))();

  IntColumn get probabilityPercent => integer().nullable()();

  IntColumn get expectedCloseAt => integer().nullable()();

  TextColumn get currentSupplier => text().nullable()();

  TextColumn get currentPurchaseBrand => text().nullable()();

  IntColumn get currentPurchasePriceMinor => integer().nullable()();

  TextColumn get supplierStability => text().nullable()();

  TextColumn get supplierProblem => text().nullable()();

  TextColumn get changeWillingness => text().nullable()();

  TextColumn get substitutionDifficulty => text().nullable()();

  IntColumn get latestQuoteMinor => integer().nullable()();

  IntColumn get targetPriceMinor => integer().nullable()();

  TextColumn get entryPoint => text().nullable()();

  TextColumn get investmentAdvice => text().nullable()();

  BoolColumn get needsSample => boolean().withDefault(const Constant(false))();

  BoolColumn get needsRegistration =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get needsAuthorization =>
      boolean().withDefault(const Constant(false))();

  /// 存 OpportunityStage.dbValue。
  TextColumn get stage => text().withDefault(const Constant('new_lead'))();

  /// 存 OpportunityStatus.dbValue。
  TextColumn get status => text().withDefault(const Constant('active'))();

  TextColumn get latestFeedback => text().nullable()();

  TextColumn get currentObstacle => text().nullable()();

  TextColumn get nextAction => text().nullable()();

  IntColumn get nextFollowAt => integer().nullable()();

  /// v1 升级时为每个客户创建的历史承接项目。
  BoolColumn get isLegacyDefault =>
      boolean().withDefault(const Constant(false))();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  List<String> get customConstraints => [
    'CHECK (probability_percent IS NULL '
        'OR probability_percent BETWEEN 0 AND 100)',
    'CHECK (forecast_amount_minor IS NULL OR forecast_amount_minor >= 0)',
    'CHECK (estimated_annual_volume IS NULL OR estimated_annual_volume >= 0)',
  ];
}
