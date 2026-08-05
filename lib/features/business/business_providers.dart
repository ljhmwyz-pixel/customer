import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;

import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../customers/customer_providers.dart';

class BusinessService {
  BusinessService(this._db);
  final AppDatabase _db;

  Future<int> createQuoteVersion({
    required int customerId,
    required int opportunityId,
    required String quoteNo,
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
  }) async {
    await _requireOpportunity(customerId, opportunityId);
    _validateAmount(quantity, '数量');
    _validateAmount(unitPriceMinor, '单价');
    _validateAmount(totalAmountMinor, '总金额');
    if (validUntil != null && validUntil.isBefore(quotedAt)) {
      throw const CustomerValidationException('有效期不能早于报价日期');
    }
    return _db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: quoteNo,
      productModel: productModel,
      quantity: quantity,
      currency: currency,
      unitPriceMinor: unitPriceMinor,
      totalAmountMinor: totalAmountMinor,
      quotedAt: quotedAt,
      validUntil: validUntil,
      customerReceived: customerReceived,
      customerFeedback: customerFeedback,
      nextFollowAt: nextFollowAt,
      result: result,
    );
  }

  Future<int> createSample({
    required int customerId,
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
  }) async {
    await _requireOpportunity(customerId, opportunityId);
    _validateAmount(quantity, '数量');
    _validateAmount(feeMinor, '样品费用');
    if (sentAt != null && deliveredAt != null && deliveredAt.isBefore(sentAt)) {
      throw const CustomerValidationException('签收日期不能早于寄出日期');
    }
    return _db.sampleDao.insertSample(
      opportunityId: opportunityId,
      sampleModel: sampleModel,
      quantity: quantity,
      feeMinor: feeMinor,
      sentAt: sentAt,
      carrier: carrier,
      trackingNo: trackingNo,
      deliveredAt: deliveredAt,
      recipient: recipient,
      tester: tester,
      plannedTestAt: plannedTestAt,
      status: status,
      testResult: testResult,
      nextAction: nextAction,
    );
  }

  Future<int> updateSampleMilestone(
    int customerId,
    int sampleId, {
    Value<DateTime?> sentAt = const Value.absent(),
    Value<DateTime?> deliveredAt = const Value.absent(),
    Value<String?> recipient = const Value.absent(),
    Value<String?> tester = const Value.absent(),
    Value<DateTime?> plannedTestAt = const Value.absent(),
    SampleStatus? status,
    Value<String?> testResult = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
  }) async {
    final sample = await _db.sampleDao.findById(sampleId);
    if (sample == null) throw const CustomerValidationException('样品记录不存在');
    await _requireOpportunity(customerId, sample.opportunityId);
    return _db.sampleDao.updateMilestone(
      sampleId,
      sentAt: sentAt,
      deliveredAt: deliveredAt,
      recipient: recipient,
      tester: tester,
      plannedTestAt: plannedTestAt,
      status: status,
      testResult: testResult,
      nextAction: nextAction,
    );
  }

  void _validateAmount(int? value, String label) {
    if (value != null && value < 0) {
      throw CustomerValidationException('$label不能为负数');
    }
  }

  Future<OpportunityRow> _requireOpportunity(
    int customerId,
    int opportunityId,
  ) async {
    final opportunity = await _db.opportunityDao.findById(opportunityId);
    if (opportunity == null || opportunity.customerId != customerId) {
      throw const CustomerValidationException('项目不存在或不属于当前客户');
    }
    if (OpportunityStatus.fromDb(opportunity.status).isClosed ||
        OpportunityStage.fromDb(opportunity.stage) == OpportunityStage.lost) {
      throw const CustomerValidationException('已关闭项目不能新增报价或样品');
    }
    return opportunity;
  }
}

final businessServiceProvider = Provider<BusinessService>(
  (ref) => BusinessService(ref.watch(databaseProvider)),
);
