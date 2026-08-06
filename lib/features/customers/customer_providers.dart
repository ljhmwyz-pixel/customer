import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daos/customer_dao.dart';
import '../../data/daos/plan_dao.dart';
import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../../services/reminder_scheduler.dart';
import '../../services/service_providers.dart';
import '../opportunities/supplier_substitution.dart';

class CustomerDraft {
  const CustomerDraft({
    required this.name,
    this.company,
    this.phone,
    this.wechat,
    this.address,
    this.source,
    this.note,
    this.stage = CustomerStage.potential,
    this.grade = CustomerGrade.c,
    this.tagNames = const [],
  });

  final String name;
  final String? company;
  final String? phone;
  final String? wechat;
  final String? address;
  final String? source;
  final String? note;
  final CustomerStage stage;
  final CustomerGrade grade;
  final List<String> tagNames;
}

class ContactDraft {
  const ContactDraft({
    required this.name,
    this.position,
    this.phone,
    this.isDecisionMaker = false,
  });

  final String name;
  final String? position;
  final String? phone;
  final bool isDecisionMaker;
}

class PlanDraft {
  const PlanDraft({
    required this.opportunityId,
    required this.reason,
    required this.talkingDirection,
    required this.nextAction,
    this.owner = '本人',
    required this.planAt,
  });

  final int opportunityId;
  final String reason;
  final String talkingDirection;
  final String nextAction;
  final String owner;
  final DateTime planAt;
}

class FollowupDraft {
  const FollowupDraft({
    required this.opportunityId,
    required this.occurredAt,
    required this.method,
    required this.feedback,
    required this.stage,
    required this.nextAction,
    this.content,
    this.nextFollowAt,
    this.pauseReason,
  });

  final int opportunityId;
  final DateTime occurredAt;
  final FollowMethod method;
  final String feedback;
  final OpportunityStage stage;
  final String nextAction;
  final String? content;
  final DateTime? nextFollowAt;
  final String? pauseReason;
}

class WriteResult<T> {
  const WriteResult(this.value, {this.warning});

  final T value;
  final String? warning;

  bool get hasWarning => warning != null;
}

class CustomerValidationException implements Exception {
  const CustomerValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 按 SPRD 第 9 节给任务提供可解释的沟通方向，不自动生成外发消息。
String talkingDirectionForStage(
  OpportunityStage stage, [
  SupplierSubstitutionRecommendation? recommendation,
]) {
  final stageDirection = switch (stage) {
    OpportunityStage.newLead ||
    OpportunityStage.contactEstablished => '确认设备品牌/型号、经营品牌、现有供应商、医院覆盖和产品需求',
    OpportunityStage.needsConfirmed => '确认年用量、具体型号、采购时间和注册要求',
    OpportunityStage.quoted ||
    OpportunityStage.priceNegotiation => '确认报价是否收到、内部反馈、目标价格、竞争价格和决策时间',
    OpportunityStage.samplePreparing ||
    OpportunityStage.sampleTesting => '确认物流、签收、测试负责人、测试日期、初步结果和正式报告',
    OpportunityStage.registrationInProgress ||
    OpportunityStage.tenderPreparing => '确认文件截止、投标主体、资质、保证金、授权和项目时间表',
    OpportunityStage.awaitingOrder => '确认 PI/PO、付款安排、采购审批和预计下单时间',
    OpportunityStage.won => '确认库存、销售速度、终端反馈和下一次补货时间',
    OpportunityStage.paused ||
    OpportunityStage.lost => '确认暂停或流失原因，以及是否存在恢复推进的条件',
  };
  if (recommendation == null) return stageDirection;
  return '$stageDirection；替代建议：${recommendation.entryPoint}，'
      '${recommendation.investmentAdvice}';
}

class CustomerFilter {
  CustomerFilter({
    this.keyword = '',
    this.customerStage,
    this.tagId,
    this.country,
    this.customerGrade,
    this.currentSupplier,
    this.entryPoint,
    this.opportunityStage,
    this.owner,
    this.productCategory,
    this.productModel,
    this.equipmentBrand,
    this.opportunityStatus,
    this.expectedCloseFrom,
    this.expectedCloseTo,
    Set<CustomerAnomalyFilter> anomalies = const {},
  }) : anomalies = Set.unmodifiable(anomalies);

  static const _unset = Object();

  final String keyword;
  final CustomerStage? customerStage;
  final int? tagId;
  final String? country;
  final CustomerGrade? customerGrade;
  final String? currentSupplier;
  final String? entryPoint;
  final OpportunityStage? opportunityStage;
  final String? owner;
  final String? productCategory;
  final String? productModel;
  final String? equipmentBrand;
  final OpportunityStatus? opportunityStatus;
  final DateTime? expectedCloseFrom;
  final DateTime? expectedCloseTo;
  final Set<CustomerAnomalyFilter> anomalies;

  int get activeFilterCount =>
      [
        customerStage,
        tagId,
        country,
        customerGrade,
        currentSupplier,
        entryPoint,
        opportunityStage,
        owner,
        productCategory,
        productModel,
        equipmentBrand,
        opportunityStatus,
        expectedCloseFrom,
        expectedCloseTo,
      ].where((value) => value != null).length +
      anomalies.length;

  bool get hasNonKeywordFilters => activeFilterCount > 0;

  bool get hasFilters => keyword.trim().isNotEmpty || hasNonKeywordFilters;

  CustomerFilter copyWith({
    String? keyword,
    Object? customerStage = _unset,
    Object? tagId = _unset,
    Object? country = _unset,
    Object? customerGrade = _unset,
    Object? currentSupplier = _unset,
    Object? entryPoint = _unset,
    Object? opportunityStage = _unset,
    Object? owner = _unset,
    Object? productCategory = _unset,
    Object? productModel = _unset,
    Object? equipmentBrand = _unset,
    Object? opportunityStatus = _unset,
    Object? expectedCloseFrom = _unset,
    Object? expectedCloseTo = _unset,
    Object? anomalies = _unset,
  }) => CustomerFilter(
    keyword: keyword ?? this.keyword,
    customerStage: identical(customerStage, _unset)
        ? this.customerStage
        : customerStage as CustomerStage?,
    tagId: identical(tagId, _unset) ? this.tagId : tagId as int?,
    country: identical(country, _unset) ? this.country : country as String?,
    customerGrade: identical(customerGrade, _unset)
        ? this.customerGrade
        : customerGrade as CustomerGrade?,
    currentSupplier: identical(currentSupplier, _unset)
        ? this.currentSupplier
        : currentSupplier as String?,
    entryPoint: identical(entryPoint, _unset)
        ? this.entryPoint
        : entryPoint as String?,
    opportunityStage: identical(opportunityStage, _unset)
        ? this.opportunityStage
        : opportunityStage as OpportunityStage?,
    owner: identical(owner, _unset) ? this.owner : owner as String?,
    productCategory: identical(productCategory, _unset)
        ? this.productCategory
        : productCategory as String?,
    productModel: identical(productModel, _unset)
        ? this.productModel
        : productModel as String?,
    equipmentBrand: identical(equipmentBrand, _unset)
        ? this.equipmentBrand
        : equipmentBrand as String?,
    opportunityStatus: identical(opportunityStatus, _unset)
        ? this.opportunityStatus
        : opportunityStatus as OpportunityStatus?,
    expectedCloseFrom: identical(expectedCloseFrom, _unset)
        ? this.expectedCloseFrom
        : expectedCloseFrom as DateTime?,
    expectedCloseTo: identical(expectedCloseTo, _unset)
        ? this.expectedCloseTo
        : expectedCloseTo as DateTime?,
    anomalies: identical(anomalies, _unset)
        ? this.anomalies
        : anomalies as Set<CustomerAnomalyFilter>,
  );
}

class CustomerListData {
  const CustomerListData({required this.items, required this.tagsByCustomer});

  final List<CustomerListItem> items;
  final Map<int, List<TagRow>> tagsByCustomer;
}

class CustomerDetailData {
  const CustomerDetailData({
    required this.customer,
    required this.tags,
    required this.contacts,
    required this.opportunities,
    required this.plans,
    required this.followups,
    required this.orders,
    required this.businessByOpportunity,
    required this.completedAmountCents,
  });

  final CustomerRow customer;
  final List<TagRow> tags;
  final List<ContactRow> contacts;
  final List<OpportunityRow> opportunities;
  final List<FollowPlanRow> plans;
  final List<FollowupRow> followups;
  final List<OrderRow> orders;
  final Map<int, OpportunityBusinessRecords> businessByOpportunity;
  final int completedAmountCents;
}

class OpportunityBusinessRecords {
  const OpportunityBusinessRecords({
    required this.quotes,
    required this.samples,
    required this.registrations,
    required this.tenders,
  });

  final List<QuoteRow> quotes;
  final List<SampleRow> samples;
  final List<RegistrationRow> registrations;
  final List<TenderRow> tenders;
}

class DashboardData {
  const DashboardData({required this.metrics, required this.anomalies});

  final DashboardMetrics metrics;
  final List<DashboardAnomaly> anomalies;
}

class CustomerService {
  CustomerService(this._db, this._scheduler);

  final AppDatabase _db;
  final ReminderScheduler _scheduler;

  Future<int> createCustomer(CustomerDraft draft) async {
    final normalized = _normalizeCustomer(draft);
    return _db.transaction(() async {
      final id = await _db.customerDao.insertCustomer(
        name: normalized.name,
        company: normalized.company,
        phone: normalized.phone,
        wechat: normalized.wechat,
        address: normalized.address,
        source: normalized.source,
        note: normalized.note,
        stage: normalized.stage,
        grade: normalized.grade,
      );
      await _db.opportunityDao.ensureLegacyDefaultForCustomer(
        id,
        legacyStage: normalized.stage,
      );
      await _syncTags(id, normalized.tagNames);
      return id;
    });
  }

  Future<void> updateCustomer(int id, CustomerDraft draft) async {
    final normalized = _normalizeCustomer(draft);
    await _requireCustomer(id);
    await _db.transaction(() async {
      await _db.customerDao.updateCustomer(
        id,
        name: normalized.name,
        company: Value(normalized.company),
        phone: Value(normalized.phone),
        wechat: Value(normalized.wechat),
        address: Value(normalized.address),
        source: Value(normalized.source),
        note: Value(normalized.note),
        stage: normalized.stage,
        grade: normalized.grade,
      );
      await _db.opportunityDao.syncLegacyStageForCustomer(id, normalized.stage);
      await _syncTags(id, normalized.tagNames);
    });
  }

  Future<int> createContact(int customerId, ContactDraft draft) async {
    await _requireCustomer(customerId);
    final normalized = _normalizeContact(draft);
    return _db.contactDao.insertContact(
      customerId: customerId,
      name: normalized.name,
      position: normalized.position,
      phone: normalized.phone,
      isDecisionMaker: normalized.isDecisionMaker,
    );
  }

  Future<void> updateContact(int id, ContactDraft draft) async {
    if (await _db.contactDao.findById(id) == null) {
      throw const CustomerValidationException('联系人不存在');
    }
    final normalized = _normalizeContact(draft);
    await _db.contactDao.updateContact(
      id,
      name: normalized.name,
      position: Value(normalized.position),
      phone: Value(normalized.phone),
      isDecisionMaker: normalized.isDecisionMaker,
    );
  }

  Future<void> deleteContact(int id) async {
    await _db.contactDao.deleteContact(id);
  }

  Future<WriteResult<int>> createPlan(int customerId, PlanDraft draft) async {
    final customer = await _requireCustomer(customerId);
    final opportunity = await _db.opportunityDao.findById(draft.opportunityId);
    if (opportunity == null || opportunity.customerId != customerId) {
      throw const CustomerValidationException('项目不存在或不属于当前客户');
    }
    final normalized = _normalizePlan(draft);
    final planId = await _db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: normalized.opportunityId,
      sourceType: TaskSourceType.manual,
      reason: normalized.reason,
      talkingDirection: normalized.talkingDirection,
      nextAction: normalized.nextAction,
      owner: normalized.owner,
      planAt: normalized.planAt,
    );
    final warning = await _schedule(planId, customer.name);
    return WriteResult(planId, warning: warning);
  }

  Future<WriteResult<int>> addFollowup(
    int customerId,
    FollowupDraft draft,
  ) async {
    final customer = await _requireCustomer(customerId);
    final opportunity = await _db.opportunityDao.findById(draft.opportunityId);
    if (opportunity == null || opportunity.customerId != customerId) {
      throw const CustomerValidationException('项目不存在或不属于当前客户');
    }

    final feedback = _required(draft.feedback, '客户反馈', 10000);
    final nextAction = _required(draft.nextAction, '下一步行动', 100);
    final pauseReason = _optional(draft.pauseReason);
    final content = _optional(draft.content) ?? feedback;
    final owner = _required(opportunity.owner, '负责人', 100);
    final hasNextFollowAt = draft.nextFollowAt != null;
    final hasPauseReason = pauseReason != null;
    if (hasNextFollowAt == hasPauseReason) {
      throw const CustomerValidationException('请选择下一次跟进时间，或填写暂不跟进原因');
    }
    final substitutionRecommendation = recommendSupplierSubstitution(
      SupplierSubstitutionInput(
        equipmentBrand: opportunity.equipmentBrand,
        equipmentModel: opportunity.equipmentModel,
        currentSupplier: opportunity.currentSupplier,
        currentPurchaseBrand: opportunity.currentPurchaseBrand,
        supplierStability: opportunity.supplierStability,
        supplierProblem: opportunity.supplierProblem,
        changeWillingness: opportunity.changeWillingness,
        substitutionDifficulty: opportunity.substitutionDifficulty,
        estimatedAnnualVolume: opportunity.estimatedAnnualVolume,
        expectedCloseAt: opportunity.expectedCloseAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                opportunity.expectedCloseAt!,
                isUtc: true,
              ),
        stage: draft.stage,
      ),
    );

    late int followupId;
    int? planId;
    await _db.transaction(() async {
      followupId = await _db.followupDao.insertAndTouchCustomer(
        customerId: customerId,
        opportunityId: draft.opportunityId,
        occurredAt: draft.occurredAt,
        method: draft.method,
        content: content,
        feedback: feedback,
        stage: draft.stage,
        nextAction: nextAction,
        nextFollowAt: draft.nextFollowAt,
        pauseReason: pauseReason,
      );
      await _db.opportunityDao.syncLatestFollowup(
        opportunityId: draft.opportunityId,
        occurredAt: draft.occurredAt,
        feedback: feedback,
        stage: draft.stage,
        nextAction: nextAction,
        nextFollowAt: draft.nextFollowAt,
      );
      if (draft.nextFollowAt != null) {
        planId = await _db.planDao.insertPlan(
          customerId: customerId,
          opportunityId: draft.opportunityId,
          sourceType: TaskSourceType.followup,
          sourceId: followupId,
          ruleKey: 'next_followup',
          reason: '按计划继续跟进',
          talkingDirection: talkingDirectionForStage(
            draft.stage,
            substitutionRecommendation,
          ),
          nextAction: nextAction,
          owner: owner,
          planAt: draft.nextFollowAt!,
        );
      }
    });

    final warning = planId == null
        ? null
        : await _schedule(planId!, customer.name);
    return WriteResult(followupId, warning: warning);
  }

  /// 取消任务先写入数据库，再清除通知；通知清除失败不恢复业务状态。
  Future<String?> completePlan(int customerId, int planId) async {
    await _requireCustomer(customerId);
    final plan = await _db.planDao.findById(planId);
    if (plan == null || plan.customerId != customerId) {
      throw const CustomerValidationException('计划不存在或不属于当前客户');
    }
    if (!PlanStatus.fromDb(plan.status).isOpen) {
      throw const CustomerValidationException('只有开放中的计划可以完成');
    }
    final affected = await _db.planDao.markCompleted(planId);
    if (affected == 0) {
      throw const CustomerValidationException('计划状态已变化，请刷新后重试');
    }
    try {
      await _scheduler.cancelForPlan(planId);
      return null;
    } catch (_) {
      return '计划已完成，但提醒清理失败；下次启动会自动重建提醒';
    }
  }

  /// 取消任务先写入数据库，再清除通知；通知清除失败不恢复业务状态。
  Future<String?> cancelPlan(int customerId, int planId) async {
    await _requireCustomer(customerId);
    final plan = await _db.planDao.findById(planId);
    if (plan == null || plan.customerId != customerId) {
      throw const CustomerValidationException('计划不存在或不属于当前客户');
    }
    if (!PlanStatus.fromDb(plan.status).isOpen) {
      throw const CustomerValidationException('只有开放中的计划可以取消');
    }
    final affected = await _db.planDao.markCancelled(planId);
    if (affected == 0) {
      throw const CustomerValidationException('计划状态已变化，请刷新后重试');
    }
    try {
      await _scheduler.cancelForPlan(planId);
      return null;
    } catch (_) {
      return '计划已取消，但提醒清理失败；下次启动会自动重建提醒';
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    await _requireCustomer(customerId);
    final plans = await _db.planDao.listOpenOf(customerId);
    for (final plan in plans) {
      await _scheduler.cancelForPlan(plan.id);
    }
    await _db.customerDao.deleteCustomer(customerId);
  }

  Future<String?> _schedule(int planId, String customerName) async {
    final plan = await _db.planDao.findById(planId);
    if (plan == null) return '计划已保存，但提醒排期失败，请稍后重试';
    try {
      await _scheduler.scheduleForPlan(plan, customerName: customerName);
      return null;
    } catch (_) {
      return '计划已保存，但提醒排期失败；下次启动会自动重建提醒';
    }
  }

  Future<CustomerRow> _requireCustomer(int id) async {
    final customer = await _db.customerDao.findById(id);
    if (customer == null) {
      throw const CustomerValidationException('客户不存在');
    }
    return customer;
  }

  Future<void> _syncTags(int customerId, List<String> names) async {
    final wantedNames = names.toSet();
    final current = await _db.customerDao.tagsOf(customerId);
    for (final tag in current) {
      if (!wantedNames.contains(tag.name)) {
        await _db.customerDao.detachTag(customerId, tag.id);
      }
    }
    for (final name in wantedNames) {
      final tagId = await _db.customerDao.ensureTag(name);
      await _db.customerDao.attachTag(customerId, tagId);
    }
  }

  CustomerDraft _normalizeCustomer(CustomerDraft draft) {
    final tags = <String>[];
    for (final raw in draft.tagNames) {
      final tag = _required(raw, '标签', 20);
      if (!tags.contains(tag)) tags.add(tag);
    }
    return CustomerDraft(
      name: _required(draft.name, '客户名称', 50),
      company: _optional(draft.company),
      phone: _optional(draft.phone),
      wechat: _optional(draft.wechat),
      address: _optional(draft.address),
      source: _optional(draft.source),
      note: _optional(draft.note),
      stage: draft.stage,
      grade: draft.grade,
      tagNames: tags,
    );
  }

  ContactDraft _normalizeContact(ContactDraft draft) => ContactDraft(
    name: _required(draft.name, '联系人名称', 50),
    position: _optional(draft.position),
    phone: _optional(draft.phone),
    isDecisionMaker: draft.isDecisionMaker,
  );

  PlanDraft _normalizePlan(PlanDraft draft) => PlanDraft(
    opportunityId: draft.opportunityId,
    reason: _required(draft.reason, '跟进原因', 100),
    talkingDirection: _required(draft.talkingDirection, '建议话术方向', 500),
    nextAction: _required(draft.nextAction, '下一步行动', 100),
    owner: _required(draft.owner, '负责人', 100),
    planAt: draft.planAt,
  );

  String _required(String raw, String label, int maxLength) {
    final value = raw.trim();
    if (value.isEmpty) throw CustomerValidationException('$label不能为空');
    if (value.length > maxLength) {
      throw CustomerValidationException('$label不能超过 $maxLength 个字符');
    }
    return value;
  }

  String? _optional(String? raw) {
    final value = raw?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

final customerServiceProvider = Provider<CustomerService>(
  (ref) => CustomerService(
    ref.watch(databaseProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

class CustomerFilterNotifier extends Notifier<CustomerFilter> {
  @override
  CustomerFilter build() => CustomerFilter();

  void setKeyword(String value) => state = state.copyWith(keyword: value);

  void setCustomerStage(CustomerStage? value) =>
      state = state.copyWith(customerStage: value);

  void setTag(int? value) => state = state.copyWith(tagId: value);

  void setCountry(String? value) => state = state.copyWith(country: value);

  void setCustomerGrade(CustomerGrade? value) =>
      state = state.copyWith(customerGrade: value);

  void setCurrentSupplier(String? value) =>
      state = state.copyWith(currentSupplier: value);

  void setEntryPoint(String? value) =>
      state = state.copyWith(entryPoint: value);

  void setOpportunityStage(OpportunityStage? value) =>
      state = state.copyWith(opportunityStage: value);

  void setOwner(String? value) => state = state.copyWith(owner: value);

  void setProductCategory(String? value) =>
      state = state.copyWith(productCategory: _normalizeText(value));

  void setProductModel(String? value) =>
      state = state.copyWith(productModel: _normalizeText(value));

  void setEquipmentBrand(String? value) =>
      state = state.copyWith(equipmentBrand: _normalizeText(value));

  void setOpportunityStatus(OpportunityStatus? value) =>
      state = state.copyWith(opportunityStatus: value);

  void setExpectedCloseFrom(DateTime? value) {
    final currentTo = state.expectedCloseTo;
    state = state.copyWith(
      expectedCloseFrom: value,
      expectedCloseTo:
          value != null && currentTo != null && value.isAfter(currentTo)
          ? null
          : currentTo,
    );
  }

  void setExpectedCloseTo(DateTime? value) {
    final currentFrom = state.expectedCloseFrom;
    if (value != null && currentFrom != null && value.isBefore(currentFrom)) {
      return;
    }
    state = state.copyWith(expectedCloseTo: value);
  }

  void toggleAnomaly(CustomerAnomalyFilter value) {
    final next = {...state.anomalies};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(anomalies: next);
  }

  void clearAnomalies() => state = state.copyWith(anomalies: const {});

  void clearNonKeywordFilters() =>
      state = CustomerFilter(keyword: state.keyword);

  void clear() => state = CustomerFilter();

  String? _normalizeText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

final customerFilterProvider =
    NotifierProvider<CustomerFilterNotifier, CustomerFilter>(
      CustomerFilterNotifier.new,
    );

class CustomerRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

final customerRevisionProvider =
    NotifierProvider<CustomerRevisionNotifier, int>(
      CustomerRevisionNotifier.new,
    );

final customerListProvider = FutureProvider<CustomerListData>((ref) async {
  ref.watch(customerRevisionProvider);
  final filter = ref.watch(customerFilterProvider);
  final dao = ref.watch(databaseProvider).customerDao;
  final items = await dao.listFilteredByUrgency(
    now: DateTime.now(),
    keyword: filter.keyword,
    customerStage: filter.customerStage,
    tagId: filter.tagId,
    country: filter.country,
    customerGrade: filter.customerGrade,
    currentSupplier: filter.currentSupplier,
    entryPoint: filter.entryPoint,
    opportunityStage: filter.opportunityStage,
    owner: filter.owner,
    productCategory: filter.productCategory,
    productModel: filter.productModel,
    equipmentBrand: filter.equipmentBrand,
    opportunityStatus: filter.opportunityStatus,
    expectedCloseFrom: filter.expectedCloseFrom,
    expectedCloseTo: filter.expectedCloseTo,
    anomalies: filter.anomalies,
  );
  final tags = await dao.tagsForCustomers(
    items.map((item) => item.customer.id),
  );
  return CustomerListData(items: items, tagsByCustomer: tags);
});

final allCustomerTagsProvider = FutureProvider<List<TagRow>>((ref) {
  ref.watch(customerRevisionProvider);
  return ref.watch(databaseProvider).customerDao.allTags();
});

final customerFilterOptionsProvider = FutureProvider<CustomerFilterOptions>((
  ref,
) async {
  ref.watch(customerRevisionProvider);
  final values = await ref
      .watch(databaseProvider)
      .customerDao
      .listFilterOptions();
  return CustomerFilterOptions(
    countries: values.countries,
    currentSuppliers: values.currentSuppliers,
    entryPoints: List.unmodifiable([
      ...entryPointOptions,
      ...values.entryPoints.where(
        (value) => !entryPointOptions.contains(value),
      ),
    ]),
    owners: values.owners,
    productCategories: values.productCategories,
    productModels: values.productModels,
    equipmentBrands: values.equipmentBrands,
  );
});

final customerDetailProvider = FutureProvider.family<CustomerDetailData?, int>((
  ref,
  id,
) async {
  ref.watch(customerRevisionProvider);
  final db = ref.watch(databaseProvider);
  final customer = await db.customerDao.findById(id);
  if (customer == null) return null;
  final values = await Future.wait<Object>([
    db.customerDao.tagsOf(id),
    db.contactDao.listOf(id),
    db.opportunityDao.listOfCustomer(id),
    db.planDao.listOf(id),
    db.followupDao.listOf(id),
    db.orderDao.listOf(id),
    db.orderDao.sumAmountByCustomer(id),
  ]);
  final opportunities = values[2] as List<OpportunityRow>;
  final businessEntries = await Future.wait(
    opportunities.map((opportunity) async {
      final records = await Future.wait<Object>([
        db.quoteDao.listVersions(opportunity.id),
        db.sampleDao.listOf(opportunity.id),
        db.registrationDao.listOf(opportunity.id),
        db.tenderDao.listOf(opportunity.id),
      ]);
      return MapEntry(
        opportunity.id,
        OpportunityBusinessRecords(
          quotes: List.unmodifiable(records[0] as List<QuoteRow>),
          samples: List.unmodifiable(records[1] as List<SampleRow>),
          registrations: List.unmodifiable(records[2] as List<RegistrationRow>),
          tenders: List.unmodifiable(records[3] as List<TenderRow>),
        ),
      );
    }),
  );
  return CustomerDetailData(
    customer: customer,
    tags: values[0] as List<TagRow>,
    contacts: values[1] as List<ContactRow>,
    opportunities: opportunities,
    plans: values[3] as List<FollowPlanRow>,
    followups: values[4] as List<FollowupRow>,
    orders: values[5] as List<OrderRow>,
    businessByOpportunity: Map.unmodifiable(
      Map<int, OpportunityBusinessRecords>.fromEntries(businessEntries),
    ),
    completedAmountCents: values[6] as int,
  );
});

final homePlansProvider = FutureProvider<List<TodayPlanItem>>((ref) {
  ref.watch(customerRevisionProvider);
  return ref.watch(databaseProvider).planDao.listToday(now: DateTime.now());
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  ref.watch(customerRevisionProvider);
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final values = await Future.wait<Object>([
    db.customerDao.dashboardMetrics(now: now),
    db.customerDao.dashboardAnomalies(now: now),
  ]);
  return DashboardData(
    metrics: values[0] as DashboardMetrics,
    anomalies: values[1] as List<DashboardAnomaly>,
  );
});
