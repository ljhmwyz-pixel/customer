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

  Future<int> createRegistration({
    required int customerId,
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
  }) async {
    await _requireOpportunity(customerId, opportunityId);
    _validateRegistration(
      submittedAt: submittedAt,
      expectedCompletedAt: expectedCompletedAt,
      actualCompletedAt: actualCompletedAt,
      status: status,
      nextAction: nextAction,
    );
    return _db.registrationDao.insertRegistration(
      opportunityId: opportunityId,
      country: country,
      requirements: requirements,
      documentChecklist: documentChecklist,
      documentStatus: documentStatus,
      submittedAt: submittedAt,
      expectedCompletedAt: expectedCompletedAt,
      actualCompletedAt: actualCompletedAt,
      costBearer: costBearer,
      status: status,
      currentObstacle: currentObstacle,
      nextAction: nextAction,
      documentDueAt: documentDueAt,
      milestoneAt: milestoneAt,
      milestoneTitle: milestoneTitle,
    );
  }

  Future<int> updateRegistration(
    int customerId,
    int registrationId, {
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
  }) async {
    final registration = await _db.registrationDao.findById(registrationId);
    if (registration == null) {
      throw const CustomerValidationException('注册记录不存在');
    }
    await _requireOpportunity(customerId, registration.opportunityId);
    _validateRegistration(
      submittedAt: _mergedDate(submittedAt, registration.submittedAt),
      expectedCompletedAt: _mergedDate(
        expectedCompletedAt,
        registration.expectedCompletedAt,
      ),
      actualCompletedAt: _mergedDate(
        actualCompletedAt,
        registration.actualCompletedAt,
      ),
      status: status ?? RegistrationStatus.fromDb(registration.status),
      nextAction: nextAction.present
          ? nextAction.value
          : registration.nextAction,
    );
    return _db.registrationDao.updateRegistration(
      registrationId,
      country: country,
      requirements: requirements,
      documentChecklist: documentChecklist,
      documentStatus: documentStatus,
      submittedAt: submittedAt,
      expectedCompletedAt: expectedCompletedAt,
      actualCompletedAt: actualCompletedAt,
      costBearer: costBearer,
      status: status,
      currentObstacle: currentObstacle,
      nextAction: nextAction,
      documentDueAt: documentDueAt,
      milestoneAt: milestoneAt,
      milestoneTitle: milestoneTitle,
    );
  }

  Future<int> createTender({
    required int customerId,
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
    TenderRiskLevel? riskLevel,
    TenderAuthorizationType authorizationType = TenderAuthorizationType.none,
    DateTime? authorizationExpiresAt,
    String? exclusiveQuoteScope,
    String? floorPriceSupport,
    TenderStatus status = TenderStatus.preparing,
    String? nextAction,
    bool riskAcknowledged = false,
  }) async {
    await _requireOpportunity(customerId, opportunityId);
    final existing = await _db.tenderDao.listOf(opportunityId);
    final resolvedRisk =
        riskLevel ??
        (existing.isEmpty ? TenderRiskLevel.mediumHigh : TenderRiskLevel.low);
    _validateTender(
      documentStatus: documentStatus,
      qualificationStatus: qualificationStatus,
      bidder: bidder,
      depositMinor: depositMinor,
      localTeamStatus: localTeamStatus,
      fundingStatus: fundingStatus,
      riskLevel: resolvedRisk,
      authorizationType: authorizationType,
      authorizationExpiresAt: authorizationExpiresAt,
      floorPriceSupport: floorPriceSupport,
      riskAcknowledged: riskAcknowledged,
    );
    return _db.tenderDao.insertTender(
      opportunityId: opportunityId,
      projectNo: projectNo,
      name: name,
      deadlineAt: deadlineAt,
      documentStatus: documentStatus,
      qualificationStatus: qualificationStatus,
      bidder: bidder,
      depositMinor: depositMinor,
      customerExperience: customerExperience,
      localTeamStatus: localTeamStatus,
      fundingStatus: fundingStatus,
      riskLevel: resolvedRisk,
      authorizationType: authorizationType,
      authorizationExpiresAt: authorizationExpiresAt,
      exclusiveQuoteScope: exclusiveQuoteScope,
      floorPriceSupport: floorPriceSupport,
      status: status,
      nextAction: nextAction,
    );
  }

  Future<int> updateTender(
    int customerId,
    int tenderId, {
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
    bool riskAcknowledged = false,
  }) async {
    final tender = await _db.tenderDao.findById(tenderId);
    if (tender == null) {
      throw const CustomerValidationException('招标记录不存在');
    }
    await _requireOpportunity(customerId, tender.opportunityId);
    _validateTender(
      documentStatus:
          documentStatus ?? TenderDocumentStatus.fromDb(tender.documentStatus),
      qualificationStatus:
          qualificationStatus ??
          TenderQualificationStatus.fromDb(tender.qualificationStatus),
      bidder: bidder.present ? bidder.value : tender.bidder,
      depositMinor: depositMinor.present
          ? depositMinor.value
          : tender.depositMinor,
      localTeamStatus:
          localTeamStatus ??
          TenderVerificationStatus.fromDb(tender.localTeamStatus),
      fundingStatus:
          fundingStatus ??
          TenderVerificationStatus.fromDb(tender.fundingStatus),
      riskLevel: riskLevel ?? TenderRiskLevel.fromDb(tender.riskLevel),
      authorizationType:
          authorizationType ??
          TenderAuthorizationType.fromDb(tender.authorizationType),
      authorizationExpiresAt: _mergedDate(
        authorizationExpiresAt,
        tender.authorizationExpiresAt,
      ),
      floorPriceSupport: floorPriceSupport.present
          ? floorPriceSupport.value
          : tender.floorPriceSupport,
      riskAcknowledged: riskAcknowledged,
    );
    return _db.tenderDao.updateTender(
      tenderId,
      projectNo: projectNo,
      name: name,
      deadlineAt: deadlineAt,
      documentStatus: documentStatus,
      qualificationStatus: qualificationStatus,
      bidder: bidder,
      depositMinor: depositMinor,
      customerExperience: customerExperience,
      localTeamStatus: localTeamStatus,
      fundingStatus: fundingStatus,
      riskLevel: riskLevel,
      authorizationType: authorizationType,
      authorizationExpiresAt: authorizationExpiresAt,
      exclusiveQuoteScope: exclusiveQuoteScope,
      floorPriceSupport: floorPriceSupport,
      status: status,
      nextAction: nextAction,
    );
  }

  void _validateRegistration({
    required DateTime? submittedAt,
    required DateTime? expectedCompletedAt,
    required DateTime? actualCompletedAt,
    required RegistrationStatus status,
    required String? nextAction,
  }) {
    if (submittedAt != null &&
        expectedCompletedAt != null &&
        expectedCompletedAt.isBefore(submittedAt)) {
      throw const CustomerValidationException('预计完成日期不能早于提交日期');
    }
    if (submittedAt != null &&
        actualCompletedAt != null &&
        actualCompletedAt.isBefore(submittedAt)) {
      throw const CustomerValidationException('实际完成日期不能早于提交日期');
    }
    if (status == RegistrationStatus.blocked &&
        (nextAction == null || nextAction.trim().isEmpty)) {
      throw const CustomerValidationException('注册受阻时必须填写下一步行动');
    }
  }

  void _validateTender({
    required TenderDocumentStatus documentStatus,
    required TenderQualificationStatus qualificationStatus,
    required String? bidder,
    required int? depositMinor,
    required TenderVerificationStatus localTeamStatus,
    required TenderVerificationStatus fundingStatus,
    required TenderRiskLevel riskLevel,
    required TenderAuthorizationType authorizationType,
    required DateTime? authorizationExpiresAt,
    required String? floorPriceSupport,
    required bool riskAcknowledged,
  }) {
    _validateAmount(depositMinor, '保证金');
    if (qualificationStatus == TenderQualificationStatus.qualified &&
        documentStatus != TenderDocumentStatus.complete) {
      throw const CustomerValidationException('资料完整后才能确认投标资格');
    }
    final requestsAuthorization =
        authorizationType != TenderAuthorizationType.none;
    final requestsFloorPrice = floorPriceSupport?.trim().isNotEmpty == true;
    if (requestsAuthorization && authorizationExpiresAt == null) {
      throw const CustomerValidationException('申请授权时必须填写授权有效期');
    }
    if (!requestsAuthorization && !requestsFloorPrice) return;
    if (qualificationStatus != TenderQualificationStatus.qualified ||
        documentStatus != TenderDocumentStatus.complete ||
        bidder == null ||
        bidder.trim().isEmpty ||
        depositMinor == null ||
        localTeamStatus != TenderVerificationStatus.confirmed ||
        fundingStatus != TenderVerificationStatus.confirmed) {
      throw const CustomerValidationException('授权或底价支持所需投标条件尚未完整确认');
    }
    if (riskLevel == TenderRiskLevel.high && !riskAcknowledged) {
      throw const CustomerValidationException('高风险授权或底价支持必须明确确认风险');
    }
  }

  DateTime? _mergedDate(Value<DateTime?> update, int? storedValue) =>
      update.present
      ? update.value
      : storedValue == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(storedValue, isUtc: true);

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
      throw const CustomerValidationException('已关闭项目不能新增业务记录');
    }
    return opportunity;
  }
}

final businessServiceProvider = Provider<BusinessService>(
  (ref) => BusinessService(ref.watch(databaseProvider)),
);
