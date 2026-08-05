import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daos/customer_dao.dart';
import '../../data/daos/plan_dao.dart';
import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../../services/reminder_scheduler.dart';
import '../../services/service_providers.dart';

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
  const PlanDraft({required this.title, required this.planAt});

  final String title;
  final DateTime planAt;
}

class FollowupDraft {
  const FollowupDraft({
    required this.occurredAt,
    required this.method,
    required this.content,
    this.conclusion,
    this.nextPlan,
    this.skipNextPlan = false,
  });

  final DateTime occurredAt;
  final FollowMethod method;
  final String content;
  final String? conclusion;
  final PlanDraft? nextPlan;
  final bool skipNextPlan;
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

class CustomerFilter {
  const CustomerFilter({this.keyword = '', this.stage, this.tagId});

  final String keyword;
  final CustomerStage? stage;
  final int? tagId;

  CustomerFilter copyWith({
    String? keyword,
    CustomerStage? stage,
    int? tagId,
    bool clearStage = false,
    bool clearTag = false,
  }) => CustomerFilter(
    keyword: keyword ?? this.keyword,
    stage: clearStage ? null : stage ?? this.stage,
    tagId: clearTag ? null : tagId ?? this.tagId,
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
    required this.completedAmountCents,
  });

  final CustomerRow customer;
  final List<TagRow> tags;
  final List<ContactRow> contacts;
  final List<OpportunityRow> opportunities;
  final List<FollowPlanRow> plans;
  final List<FollowupRow> followups;
  final List<OrderRow> orders;
  final int completedAmountCents;
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
    final normalized = _normalizePlan(draft);
    final opportunityId = await _db.opportunityDao
        .ensureLegacyDefaultForCustomer(
          customerId,
          legacyStage: CustomerStage.fromDb(customer.stage),
        );
    final planId = await _db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      title: normalized.title,
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
    final content = _required(draft.content, '跟进内容', 10000);
    final conclusion = _optional(draft.conclusion);
    if ((draft.nextPlan == null) == !draft.skipNextPlan) {
      throw const CustomerValidationException('请选择下一次跟进计划，或明确暂不跟进');
    }
    final nextPlan = draft.nextPlan == null
        ? null
        : _normalizePlan(draft.nextPlan!);
    final opportunityId = await _db.opportunityDao
        .ensureLegacyDefaultForCustomer(
          customerId,
          legacyStage: CustomerStage.fromDb(customer.stage),
        );

    late int followupId;
    int? planId;
    await _db.transaction(() async {
      followupId = await _db.followupDao.insertAndTouchCustomer(
        customerId: customerId,
        opportunityId: opportunityId,
        occurredAt: draft.occurredAt,
        method: draft.method,
        content: content,
        conclusion: conclusion,
      );
      if (nextPlan != null) {
        planId = await _db.planDao.insertPlan(
          customerId: customerId,
          opportunityId: opportunityId,
          title: nextPlan.title,
          planAt: nextPlan.planAt,
        );
      }
    });

    final warning = planId == null
        ? null
        : await _schedule(planId!, customer.name);
    return WriteResult(followupId, warning: warning);
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
    title: _required(draft.title, '计划标题', 100),
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
  CustomerFilter build() => const CustomerFilter();

  void setKeyword(String value) => state = state.copyWith(keyword: value);

  void setStage(CustomerStage? value) => state = value == null
      ? state.copyWith(clearStage: true)
      : state.copyWith(stage: value);

  void setTag(int? value) => state = value == null
      ? state.copyWith(clearTag: true)
      : state.copyWith(tagId: value);

  void clear() => state = const CustomerFilter();
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
    stage: filter.stage,
    tagId: filter.tagId,
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
  return CustomerDetailData(
    customer: customer,
    tags: values[0] as List<TagRow>,
    contacts: values[1] as List<ContactRow>,
    opportunities: values[2] as List<OpportunityRow>,
    plans: values[3] as List<FollowPlanRow>,
    followups: values[4] as List<FollowupRow>,
    orders: values[5] as List<OrderRow>,
    completedAmountCents: values[6] as int,
  );
});

final homePlansProvider = FutureProvider<List<PlanWithCustomer>>((ref) {
  ref.watch(customerRevisionProvider);
  final now = DateTime.now();
  final endOfWeek = DateTime(
    now.year,
    now.month,
    now.day + (DateTime.sunday - now.weekday),
    23,
    59,
    59,
  );
  return ref.watch(databaseProvider).planDao.listOpenUntil(until: endOfWeek);
});
