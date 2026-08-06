import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../models/enums.dart';
import 'supplier_substitution.dart';

class OpportunityDraft {
  const OpportunityDraft({
    required this.name,
    this.productCategory,
    this.productModel,
    this.equipmentBrand,
    this.equipmentModel,
    this.estimatedAnnualVolume,
    this.forecastAmountMinor,
    this.currency = 'USD',
    this.probabilityPercent,
    this.expectedCloseAt,
    this.currentSupplier,
    this.currentPurchaseBrand,
    this.currentPurchasePriceMinor,
    this.supplierStability,
    this.supplierProblem,
    this.changeWillingness,
    this.substitutionDifficulty,
    this.latestQuoteMinor,
    this.targetPriceMinor,
    this.entryPoint,
    this.investmentAdvice,
    this.needsSample = false,
    this.needsRegistration = false,
    this.needsAuthorization = false,
    this.stage = OpportunityStage.newLead,
    this.status = OpportunityStatus.active,
    this.latestFeedback,
    this.currentObstacle,
    this.nextAction,
    this.nextFollowAt,
  });

  final String name;
  final String? productCategory;
  final String? productModel;
  final String? equipmentBrand;
  final String? equipmentModel;
  final int? estimatedAnnualVolume;
  final int? forecastAmountMinor;
  final String currency;
  final int? probabilityPercent;
  final DateTime? expectedCloseAt;
  final String? currentSupplier;
  final String? currentPurchaseBrand;
  final int? currentPurchasePriceMinor;
  final String? supplierStability;
  final String? supplierProblem;
  final String? changeWillingness;
  final String? substitutionDifficulty;
  final int? latestQuoteMinor;
  final int? targetPriceMinor;
  final String? entryPoint;
  final String? investmentAdvice;
  final bool needsSample;
  final bool needsRegistration;
  final bool needsAuthorization;
  final OpportunityStage stage;
  final OpportunityStatus status;
  final String? latestFeedback;
  final String? currentObstacle;
  final String? nextAction;
  final DateTime? nextFollowAt;
}

class OpportunityValidationException implements Exception {
  const OpportunityValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpportunityService {
  OpportunityService(this._db);

  final AppDatabase _db;

  Future<OpportunityRow?> findForCustomer(int customerId, int id) async {
    final value = await _db.opportunityDao.findById(id);
    return value?.customerId == customerId ? value : null;
  }

  Future<int> createOpportunity(int customerId, OpportunityDraft draft) async {
    await _requireCustomer(customerId);
    final value = _normalize(draft);
    return _db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: value.name,
      productCategory: value.productCategory,
      productModel: value.productModel,
      equipmentBrand: value.equipmentBrand,
      equipmentModel: value.equipmentModel,
      estimatedAnnualVolume: value.estimatedAnnualVolume,
      forecastAmountMinor: value.forecastAmountMinor,
      currency: value.currency,
      probabilityPercent: value.probabilityPercent,
      expectedCloseAt: value.expectedCloseAt,
      currentSupplier: value.currentSupplier,
      currentPurchaseBrand: value.currentPurchaseBrand,
      currentPurchasePriceMinor: value.currentPurchasePriceMinor,
      supplierStability: value.supplierStability,
      supplierProblem: value.supplierProblem,
      changeWillingness: value.changeWillingness,
      substitutionDifficulty: value.substitutionDifficulty,
      latestQuoteMinor: value.latestQuoteMinor,
      targetPriceMinor: value.targetPriceMinor,
      entryPoint: value.entryPoint,
      investmentAdvice: value.investmentAdvice,
      needsSample: value.needsSample,
      needsRegistration: value.needsRegistration,
      needsAuthorization: value.needsAuthorization,
      stage: value.stage,
      status: value.status,
      latestFeedback: value.latestFeedback,
      currentObstacle: value.currentObstacle,
      nextAction: value.nextAction,
      nextFollowAt: value.nextFollowAt,
    );
  }

  Future<void> updateOpportunity(
    int customerId,
    int id,
    OpportunityDraft draft,
  ) async {
    final existing = await _requireOpportunity(customerId, id);
    final value = _normalize(draft, existing: existing);
    await _db.opportunityDao.updateOpportunity(
      id,
      name: value.name,
      productCategory: Value(value.productCategory),
      productModel: Value(value.productModel),
      equipmentBrand: Value(value.equipmentBrand),
      equipmentModel: Value(value.equipmentModel),
      estimatedAnnualVolume: Value(value.estimatedAnnualVolume),
      forecastAmountMinor: Value(value.forecastAmountMinor),
      currency: value.currency,
      probabilityPercent: Value(value.probabilityPercent),
      expectedCloseAt: Value(value.expectedCloseAt),
      currentSupplier: Value(value.currentSupplier),
      currentPurchaseBrand: Value(value.currentPurchaseBrand),
      currentPurchasePriceMinor: Value(value.currentPurchasePriceMinor),
      supplierStability: Value(value.supplierStability),
      supplierProblem: Value(value.supplierProblem),
      changeWillingness: Value(value.changeWillingness),
      substitutionDifficulty: Value(value.substitutionDifficulty),
      latestQuoteMinor: Value(value.latestQuoteMinor),
      targetPriceMinor: Value(value.targetPriceMinor),
      entryPoint: Value(value.entryPoint),
      investmentAdvice: Value(value.investmentAdvice),
      needsSample: value.needsSample,
      needsRegistration: value.needsRegistration,
      needsAuthorization: value.needsAuthorization,
      stage: value.stage,
      status: value.status,
      latestFeedback: Value(value.latestFeedback),
      currentObstacle: Value(value.currentObstacle),
      nextAction: Value(value.nextAction),
      nextFollowAt: Value(value.nextFollowAt),
    );
  }

  Future<void> deleteOpportunity(int customerId, int id) async {
    await _requireOpportunity(customerId, id);
    if (await _db.opportunityDao.hasLinkedBusinessRecords(id)) {
      throw const OpportunityValidationException('该项目已有跟进、计划或订单，不能删除');
    }
    await _db.opportunityDao.deleteOpportunity(id);
  }

  Future<void> _requireCustomer(int id) async {
    if (await _db.customerDao.findById(id) == null) {
      throw const OpportunityValidationException('客户不存在');
    }
  }

  Future<OpportunityRow> _requireOpportunity(int customerId, int id) async {
    final value = await _db.opportunityDao.findById(id);
    if (value == null) {
      throw const OpportunityValidationException('项目不存在');
    }
    if (value.customerId != customerId) {
      throw const OpportunityValidationException('项目不属于当前客户');
    }
    return value;
  }

  OpportunityDraft _normalize(
    OpportunityDraft value, {
    OpportunityRow? existing,
  }) {
    final name = value.name.trim();
    if (name.isEmpty) {
      throw const OpportunityValidationException('项目名称不能为空');
    }
    if (name.length > 100) {
      throw const OpportunityValidationException('项目名称不能超过 100 个字符');
    }
    final currency = value.currency.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw const OpportunityValidationException('币种需为 3 位字母代码');
    }
    if (value.probabilityPercent case final probability?) {
      if (probability < 0 || probability > 100) {
        throw const OpportunityValidationException('成交概率需在 0 到 100 之间');
      }
    }
    for (final entry in <String, int?>{
      '预计年用量': value.estimatedAnnualVolume,
      '预计项目金额': value.forecastAmountMinor,
      '当前采购价': value.currentPurchasePriceMinor,
      '最新报价': value.latestQuoteMinor,
      '目标价': value.targetPriceMinor,
    }.entries) {
      if (entry.value != null && entry.value! < 0) {
        throw OpportunityValidationException('${entry.key}不能为负数');
      }
    }
    String? text(String? raw) {
      final result = raw?.trim();
      return result == null || result.isEmpty ? null : result;
    }

    String? fixedOption({
      required String fieldName,
      required String? raw,
      required List<String> options,
      required String? legacyValue,
    }) {
      final result = text(raw);
      final normalizedLegacyValue = text(legacyValue);
      if (result == null ||
          options.contains(result) ||
          result == normalizedLegacyValue) {
        return result;
      }
      throw OpportunityValidationException('$fieldName必须选择固定选项');
    }

    return OpportunityDraft(
      name: name,
      productCategory: text(value.productCategory),
      productModel: text(value.productModel),
      equipmentBrand: text(value.equipmentBrand),
      equipmentModel: text(value.equipmentModel),
      estimatedAnnualVolume: value.estimatedAnnualVolume,
      forecastAmountMinor: value.forecastAmountMinor,
      currency: currency,
      probabilityPercent: value.probabilityPercent,
      expectedCloseAt: value.expectedCloseAt,
      currentSupplier: text(value.currentSupplier),
      currentPurchaseBrand: text(value.currentPurchaseBrand),
      currentPurchasePriceMinor: value.currentPurchasePriceMinor,
      supplierStability: text(value.supplierStability),
      supplierProblem: fixedOption(
        fieldName: '供应商问题',
        raw: value.supplierProblem,
        options: supplierProblemOptions,
        legacyValue: existing?.supplierProblem,
      ),
      changeWillingness: fixedOption(
        fieldName: '更换意愿',
        raw: value.changeWillingness,
        options: changeWillingnessOptions,
        legacyValue: existing?.changeWillingness,
      ),
      substitutionDifficulty: fixedOption(
        fieldName: '替代难度',
        raw: value.substitutionDifficulty,
        options: substitutionDifficultyOptions,
        legacyValue: existing?.substitutionDifficulty,
      ),
      latestQuoteMinor: value.latestQuoteMinor,
      targetPriceMinor: value.targetPriceMinor,
      entryPoint: fixedOption(
        fieldName: '推荐切入点',
        raw: value.entryPoint,
        options: entryPointOptions,
        legacyValue: existing?.entryPoint,
      ),
      investmentAdvice: fixedOption(
        fieldName: '投入建议',
        raw: value.investmentAdvice,
        options: investmentAdviceOptions,
        legacyValue: existing?.investmentAdvice,
      ),
      needsSample: value.needsSample,
      needsRegistration: value.needsRegistration,
      needsAuthorization: value.needsAuthorization,
      stage: value.stage,
      status: value.status,
      latestFeedback: text(value.latestFeedback),
      currentObstacle: text(value.currentObstacle),
      nextAction: text(value.nextAction),
      nextFollowAt: value.nextFollowAt,
    );
  }
}

final opportunityServiceProvider = Provider<OpportunityService>(
  (ref) => OpportunityService(ref.watch(databaseProvider)),
);
