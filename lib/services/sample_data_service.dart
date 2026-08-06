// Public named parameters intentionally differ from private backing fields.
// ignore_for_file: prefer_initializing_formals

import '../data/database.dart';
import '../models/enums.dart';
import 'attachment_service.dart';
import 'reminder_scheduler.dart';

enum SampleImportResult { imported, alreadyImported }

class SampleDataState {
  const SampleDataState({required this.customerCount});

  final int customerCount;

  bool get isImported => customerCount > 0;

  @override
  bool operator ==(Object other) =>
      other is SampleDataState && other.customerCount == customerCount;

  @override
  int get hashCode => customerCount.hashCode;
}

class SampleUndoResult {
  const SampleUndoResult({
    required this.deletedCustomerCount,
    required this.cleanupReport,
  });

  final int deletedCustomerCount;
  final AttachmentCleanupReport cleanupReport;
}

class SampleDataService {
  SampleDataService({
    required AppDatabase db,
    required ReminderScheduler reminderScheduler,
    required AttachmentGraphCleaner attachmentCleaner,
    DateTime Function()? clock,
  }) : _db = db,
       _reminderScheduler = reminderScheduler,
       _attachmentCleaner = attachmentCleaner,
       _clock = clock ?? DateTime.now;

  static const batchId = 'phase-f-samples-v1';
  static const sampleOrderNo = 'SAMPLE-ORDER-001';

  final AppDatabase _db;
  final ReminderScheduler _reminderScheduler;
  final AttachmentGraphCleaner _attachmentCleaner;
  final DateTime Function() _clock;

  Future<SampleDataState> inspect() async => SampleDataState(
    customerCount: await _db.customerDao.countBySampleBatch(batchId),
  );

  Future<SampleImportResult> importAll() async {
    final now = _clock().toUtc();
    final result = await _db.transaction(() async {
      if (await _db.customerDao.countBySampleBatch(batchId) > 0) {
        return SampleImportResult.alreadyImported;
      }
      await _createAll(now);
      return SampleImportResult.imported;
    });
    if (result == SampleImportResult.imported) {
      try {
        await _reminderScheduler.rescheduleAll();
      } catch (_) {
        // 已持久化的计划会在下次启动时统一重建提醒。
      }
    }
    return result;
  }

  Future<SampleUndoResult> undoAll() async {
    final customers = await _db.customerDao.listBySampleBatch(batchId);
    if (customers.isEmpty) {
      return const SampleUndoResult(
        deletedCustomerCount: 0,
        cleanupReport: AttachmentCleanupReport(),
      );
    }

    final attachments = <AttachmentRow>[];
    final planIds = <int>[];
    for (final customer in customers) {
      attachments.addAll(await _db.attachmentDao.listOfCustomer(customer.id));
      planIds.addAll(
        (await _db.planDao.listOpenOf(customer.id)).map((plan) => plan.id),
      );
    }
    for (final planId in planIds.toSet()) {
      await _reminderScheduler.cancelForPlan(planId);
    }

    final report = await _attachmentCleaner.deleteGraph(
      loadAttachments: () async => attachments,
      deleteDatabaseGraph: () => _db.transaction(
        () async => _db.customerDao.deleteSampleBatchRoots(batchId),
      ),
    );
    return SampleUndoResult(
      deletedCustomerCount: customers.length,
      cleanupReport: report,
    );
  }

  Future<void> _createAll(DateTime now) async {
    await _createMedtron(now);
    await _createAntmed(now);
    await _createUlrich(now);
    await _createHighPressureTube(now);
    await _createSyringeTender(now);
    await _createFirstTender(now);
    await _createTestingSample(now);
    await _createStalledQuote(now);
    await _createWonRepurchase(now);
  }

  Future<void> _createMedtron(DateTime now) async {
    await _createScenario(
      now: now,
      customerName: '示例｜Medtron 合作商',
      company: 'Nordic Imaging Partner',
      country: '德国',
      stage: CustomerStage.intent,
      grade: CustomerGrade.a,
      opportunityName: 'Medtron 连接管切入项目',
      opportunityStage: OpportunityStage.needsConfirmed,
      importance: OpportunityImportance.high,
      productCategory: '连接管及配件',
      productModel: 'Patient Line 24h',
      equipmentBrand: 'Medtron',
      estimatedAnnualVolume: 12000,
      currentSupplier: '当地配套供应商',
      supplierStability: '设备合作稳定，耗材可补充',
      entryPoint: '从连接管和 Patient Line 非冲突耗材切入',
      investmentAdvice: '优先提供适配清单，不正面替换设备合作',
      latestFeedback: '愿意评估连接管兼容型号',
      nextAction: '发送 Medtron 适配连接管清单',
      followupContent: '确认现有 Medtron 设备型号与管路使用周期',
    );
  }

  Future<void> _createAntmed(DateTime now) async {
    await _createScenario(
      now: now,
      customerName: '示例｜Antmed 成熟客户',
      company: 'Central Radiology Supply',
      country: '波兰',
      stage: CustomerStage.contacted,
      grade: CustomerGrade.b,
      opportunityName: 'Antmed 第二供应商评估',
      opportunityStage: OpportunityStage.contactEstablished,
      productCategory: '高压注射器耗材',
      equipmentBrand: 'Antmed',
      estimatedAnnualVolume: 8000,
      currentSupplier: 'Antmed',
      supplierStability: '关系稳定',
      supplierProblem: '暂无明显问题',
      changeWillingness: '低，仅考虑第二供应商',
      substitutionDifficulty: '高',
      entryPoint: '补充型号和紧急交期备选',
      investmentAdvice: '低频维护，先确认不满点再安排样品',
      latestFeedback: '现有供应稳定，可保留备选资料',
      currentObstacle: '缺少明确切换动机',
      nextAction: '确认可接受的第二供应商场景',
      followupContent: '客户确认 Antmed 供货稳定，暂不主动替换',
    );
  }

  Future<void> _createUlrich(DateTime now) async {
    await _createScenario(
      now: now,
      customerName: '示例｜Ulrich 价格敏感客户',
      company: 'Alpine Contrast Center',
      country: '奥地利',
      stage: CustomerStage.intent,
      grade: CustomerGrade.c,
      opportunityName: 'Ulrich 小批量耗材项目',
      opportunityStage: OpportunityStage.priceNegotiation,
      productCategory: '高压注射器耗材',
      productModel: 'Ulrich 双筒套装',
      equipmentBrand: 'Ulrich',
      estimatedAnnualVolume: 1200,
      currentPurchasePriceMinor: 1680,
      latestQuoteMinor: 1550,
      targetPriceMinor: 1350,
      entryPoint: '小批量试单',
      investmentAdvice: '价格支持与年度数量承诺绑定',
      latestFeedback: '认可规格，但目标价偏低',
      currentObstacle: '数量小且价格敏感',
      nextAction: '确认合并订单后的年度数量',
      followupContent: '讨论小批量报价和年度采购承诺',
    );
  }

  Future<void> _createHighPressureTube(DateTime now) async {
    await _createScenario(
      now: now,
      customerName: '示例｜高压连接管潜客',
      company: 'Andes Diagnostic Imports',
      country: '智利',
      stage: CustomerStage.intent,
      grade: CustomerGrade.b,
      opportunityName: '1200 PSI 高压连接管',
      opportunityStage: OpportunityStage.needsConfirmed,
      productCategory: '连接管及配件',
      productModel: 'Y 型 1200 PSI 连接管',
      equipmentBrand: 'Bayer Medrad',
      estimatedAnnualVolume: 24000,
      needsSample: true,
      latestFeedback: '需要确认耐压和接头兼容性',
      currentObstacle: '设备型号与接头照片尚未齐全',
      nextAction: '收集设备型号并确认送样规格',
      followupContent: '客户咨询 1200 PSI Y 型连接管',
    );
  }

  Future<void> _createSyringeTender(DateTime now) async {
    final scenario = await _createScenario(
      now: now,
      customerName: '示例｜普通注射器招标客户',
      company: 'National Medical Procurement',
      country: '肯尼亚',
      stage: CustomerStage.intent,
      grade: CustomerGrade.a,
      opportunityName: '普通注射器政府招标',
      opportunityStage: OpportunityStage.tenderPreparing,
      importance: OpportunityImportance.high,
      productCategory: '一次性注射器',
      productModel: '三件式 Luer Slip 5mL',
      estimatedAnnualVolume: 2000000,
      needsAuthorization: true,
      latestFeedback: '招标文件已发布，需核对注册资质',
      nextAction: '完成规格、资质和交付期核对',
      followupContent: '收到普通注射器政府招标文件',
    );
    await _db.tenderDao.insertTender(
      opportunityId: scenario.opportunityId,
      projectNo: 'TENDER-SYR-2026',
      name: '国家医院普通注射器采购',
      deadlineAt: now.add(const Duration(days: 28)),
      documentStatus: TenderDocumentStatus.incomplete,
      qualificationStatus: TenderQualificationStatus.qualified,
      riskLevel: TenderRiskLevel.medium,
      status: TenderStatus.open,
      nextAction: '补齐样品与产能证明',
      now: now,
    );
  }

  Future<void> _createFirstTender(DateTime now) async {
    final scenario = await _createScenario(
      now: now,
      customerName: '示例｜首次招标新客户',
      company: 'New Horizon Healthcare',
      country: '加纳',
      stage: CustomerStage.contacted,
      grade: CustomerGrade.b,
      opportunityName: '首次政府招标授权评估',
      opportunityStage: OpportunityStage.tenderPreparing,
      importance: OpportunityImportance.high,
      productCategory: '一次性注射器',
      productModel: 'Safety Syringe 5mL',
      needsAuthorization: true,
      latestFeedback: '首次参加政府招标，需要项目授权',
      currentObstacle: '本地团队与资金尚未完全核实',
      nextAction: '核实团队、资金和投标资质',
      followupContent: '新客户申请首次政府招标授权',
    );
    await _db.tenderDao.insertTender(
      opportunityId: scenario.opportunityId,
      projectNo: 'TENDER-FIRST-2026',
      name: '首次政府安全注射器招标',
      deadlineAt: now.add(const Duration(days: 42)),
      customerExperience: '首次参加政府招标',
      localTeamStatus: TenderVerificationStatus.pending,
      fundingStatus: TenderVerificationStatus.pending,
      riskLevel: TenderRiskLevel.mediumHigh,
      authorizationType: TenderAuthorizationType.nonExclusiveProject,
      authorizationExpiresAt: now.add(const Duration(days: 60)),
      exclusiveQuoteScope: '仅限本项目和指定规格',
      floorPriceSupport: '数量确认后提供项目底价',
      status: TenderStatus.open,
      nextAction: '完成资质与资金核验后出具限定授权',
      now: now,
    );
  }

  Future<void> _createTestingSample(DateTime now) async {
    final scenario = await _createScenario(
      now: now,
      customerName: '示例｜样品测试客户',
      company: 'Baltic Imaging Lab',
      country: '立陶宛',
      stage: CustomerStage.intent,
      grade: CustomerGrade.a,
      opportunityName: 'CT 双筒样品测试',
      opportunityStage: OpportunityStage.sampleTesting,
      importance: OpportunityImportance.high,
      productCategory: '高压注射器耗材',
      productModel: 'CT 200mL 双筒套装',
      equipmentBrand: 'Stellant',
      needsSample: true,
      latestFeedback: '样品已上机，等待三轮测试结果',
      nextAction: '确认测试负责人和结果日期',
      followupContent: '样品已签收并开始兼容性测试',
    );
    await _db.sampleDao.insertSample(
      opportunityId: scenario.opportunityId,
      sampleModel: 'CT 200mL 双筒套装',
      quantity: 6,
      sentAt: now.subtract(const Duration(days: 10)),
      carrier: 'DHL',
      trackingNo: 'SAMPLE-DEMO-001',
      deliveredAt: now.subtract(const Duration(days: 7)),
      recipient: 'Anna',
      tester: 'Dr. Jonas',
      plannedTestAt: now.subtract(const Duration(days: 2)),
      status: SampleStatus.testing,
      nextAction: '三天后收集测试记录',
      now: now,
    );
  }

  Future<void> _createStalledQuote(DateTime now) async {
    final scenario = await _createScenario(
      now: now,
      customerName: '示例｜报价未回复客户',
      company: 'Pacific Hospital Supply',
      country: '秘鲁',
      stage: CustomerStage.intent,
      grade: CustomerGrade.c,
      opportunityName: 'MRI 注射器报价',
      opportunityStage: OpportunityStage.quoted,
      productCategory: '高压注射器耗材',
      productModel: 'MRI 65mL 双筒套装',
      forecastAmountMinor: 4800000,
      probabilityPercent: 35,
      latestQuoteMinor: 2400,
      latestFeedback: '报价已送达，客户长期未回复',
      currentObstacle: '报价后 45 天未回复',
      nextAction: '重新确认项目真实性和采购时间',
      followupContent: '确认客户已收到报价，等待内部评估',
    );
    await _db.quoteDao.insertVersion(
      opportunityId: scenario.opportunityId,
      quoteNo: 'SAMPLE-QUOTE-001',
      productModel: 'MRI 65mL 双筒套装',
      quantity: 2000,
      unitPriceMinor: 2400,
      totalAmountMinor: 4800000,
      quotedAt: now.subtract(const Duration(days: 45)),
      validUntil: now.subtract(const Duration(days: 15)),
      customerReceived: true,
      customerFeedback: '已收到，之后未回复',
      nextFollowAt: now.subtract(const Duration(days: 31)),
      result: '等待反馈',
      now: now,
    );
  }

  Future<void> _createWonRepurchase(DateTime now) async {
    final scenario = await _createScenario(
      now: now,
      customerName: '示例｜成交待复购客户',
      company: 'Adriatic Medical Trade',
      country: '克罗地亚',
      stage: CustomerStage.deal,
      grade: CustomerGrade.a,
      opportunityName: 'CT 注射器复购项目',
      opportunityStage: OpportunityStage.won,
      status: OpportunityStatus.won,
      importance: OpportunityImportance.high,
      productCategory: '高压注射器耗材',
      productModel: 'CT 200mL 单筒',
      estimatedAnnualVolume: 12000,
      latestFeedback: '首单已完成，使用反馈良好',
      nextAction: '复购前确认库存和下一批数量',
      followupContent: '客户确认首单产品使用正常',
    );
    await _db.orderDao.insertOrder(
      customerId: scenario.customerId,
      opportunityId: scenario.opportunityId,
      orderNo: sampleOrderNo,
      orderedAt: now.subtract(const Duration(days: 75)),
      amountCents: 2880000,
      piPoNo: 'PI-SAMPLE-001',
      currency: 'USD',
      paymentStatus: PaymentStatus.paid,
      productionStatus: ProductionStatus.completed,
      shippingStatus: ShippingStatus.delivered,
      estimatedArrivalAt: now.subtract(const Duration(days: 45)),
      orderResult: OrderResult.completed,
      estimatedRepurchaseAt: now.add(const Duration(days: 45)),
      description: 'CT 200mL 单筒首单',
      now: now,
    );
  }

  Future<_ScenarioIds> _createScenario({
    required DateTime now,
    required String customerName,
    required String company,
    required String country,
    required CustomerStage stage,
    required CustomerGrade grade,
    required String opportunityName,
    required OpportunityStage opportunityStage,
    required String latestFeedback,
    required String nextAction,
    required String followupContent,
    OpportunityStatus status = OpportunityStatus.active,
    OpportunityImportance importance = OpportunityImportance.normal,
    String? productCategory,
    String? productModel,
    String? equipmentBrand,
    int? estimatedAnnualVolume,
    int? forecastAmountMinor,
    int? probabilityPercent,
    String? currentSupplier,
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
    bool needsAuthorization = false,
    String? currentObstacle,
  }) async {
    final customerId = await _db.customerDao.insertCustomer(
      name: customerName,
      company: company,
      country: country,
      source: '示例数据',
      note: '可在“我的 > 示例数据”中整体撤销',
      stage: stage,
      grade: grade,
      sampleBatchId: batchId,
      now: now,
    );
    final opportunityId = await _db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: opportunityName,
      importance: importance,
      productCategory: productCategory,
      productModel: productModel,
      equipmentBrand: equipmentBrand,
      estimatedAnnualVolume: estimatedAnnualVolume,
      forecastAmountMinor: forecastAmountMinor,
      probabilityPercent: probabilityPercent,
      expectedCloseAt: now.add(const Duration(days: 60)),
      currentSupplier: currentSupplier,
      currentPurchasePriceMinor: currentPurchasePriceMinor,
      supplierStability: supplierStability,
      supplierProblem: supplierProblem,
      changeWillingness: changeWillingness,
      substitutionDifficulty: substitutionDifficulty,
      latestQuoteMinor: latestQuoteMinor,
      targetPriceMinor: targetPriceMinor,
      entryPoint: entryPoint,
      investmentAdvice: investmentAdvice,
      needsSample: needsSample,
      needsAuthorization: needsAuthorization,
      stage: opportunityStage,
      status: status,
      latestFeedback: latestFeedback,
      currentObstacle: currentObstacle,
      nextAction: nextAction,
      nextFollowAt: now.add(const Duration(days: 3)),
      now: now,
    );
    await _db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: opportunityId,
      occurredAt: now.subtract(const Duration(days: 2)),
      method: FollowMethod.other,
      content: followupContent,
      feedback: latestFeedback,
      stage: opportunityStage,
      nextAction: nextAction,
      nextFollowAt: now.add(const Duration(days: 3)),
      now: now,
    );
    await _db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      sourceType: TaskSourceType.manual,
      reason: '示例项目下一步',
      talkingDirection: latestFeedback,
      nextAction: nextAction,
      planAt: now.add(const Duration(days: 3)),
      now: now,
    );
    return _ScenarioIds(customerId, opportunityId);
  }
}

class _ScenarioIds {
  const _ScenarioIds(this.customerId, this.opportunityId);

  final int customerId;
  final int opportunityId;
}
