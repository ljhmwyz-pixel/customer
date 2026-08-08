import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/contacts.dart';
import '../tables/customers.dart';
import '../tables/follow_plans.dart';
import '../tables/followups.dart';
import '../tables/opportunities.dart';
import '../tables/orders.dart';
import '../tables/quotes.dart';
import '../tables/samples.dart';
import '../tables/tags.dart';

part 'customer_dao.g.dart';

/// 客户列表的一行，含排序与展示所需的聚合信息。
class CustomerListItem {
  const CustomerListItem({
    required this.customer,
    required this.nextPlanAt,
    required this.openPlanCount,
  });

  final CustomerRow customer;

  /// 最近一条未完成计划的时间，无计划时为 null。
  final DateTime? nextPlanAt;

  /// 未完成计划条数。
  final int openPlanCount;

  CustomerStage get stage => CustomerStage.fromDb(customer.stage);

  CustomerGrade get grade => CustomerGrade.fromDb(customer.grade);

  /// 逾期天数。未逾期或无计划时为 0。
  int overdueDays(DateTime now) {
    final at = nextPlanAt;
    if (at == null || !at.isBefore(now)) return 0;
    return now.difference(at).inDays;
  }
}

/// 客户列表筛选器中从现有业务数据提取的动态选项。
class CustomerFilterOptions {
  const CustomerFilterOptions({
    required this.countries,
    required this.currentSuppliers,
    required this.entryPoints,
    required this.owners,
    required this.productCategories,
    required this.productModels,
    required this.equipmentBrands,
  });

  final List<String> countries;
  final List<String> currentSuppliers;
  final List<String> entryPoints;
  final List<String> owners;
  final List<String> productCategories;
  final List<String> productModels;
  final List<String> equipmentBrands;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.totalCustomers,
    required this.customerCountsByGrade,
    required this.projectCountsByStage,
    required this.followupsThisWeek,
    required this.stalledQuoteCount,
    required this.stalledSampleCount,
    required this.forecastByCurrency,
    required this.weightedForecastByCurrency,
    required this.wonByCurrency,
  });

  final int totalCustomers;
  final Map<CustomerGrade, int> customerCountsByGrade;
  final Map<OpportunityStage, int> projectCountsByStage;
  final int followupsThisWeek;
  final int stalledQuoteCount;
  final int stalledSampleCount;
  final Map<String, int> forecastByCurrency;
  final Map<String, int> weightedForecastByCurrency;
  final Map<String, int> wonByCurrency;
}

enum DashboardAmountType { forecast, weighted, won }

class DashboardAmountItem {
  const DashboardAmountItem({
    required this.customerId,
    required this.customerName,
    required this.currency,
    required this.amountMinor,
    required this.weightedAmountMinor,
    this.opportunityId,
    this.opportunityName,
    this.orderId,
    this.orderNo,
    this.probabilityPercent,
  });

  final int customerId;
  final String customerName;
  final int? opportunityId;
  final String? opportunityName;
  final int? orderId;
  final String? orderNo;
  final String currency;
  final int amountMinor;
  final int? probabilityPercent;
  final int weightedAmountMinor;
}

class DashboardAmountDetails {
  const DashboardAmountDetails({
    required this.type,
    required this.items,
    required this.totalsByCurrency,
  });

  final DashboardAmountType type;
  final List<DashboardAmountItem> items;
  final Map<String, int> totalsByCurrency;
}

enum DashboardAnomalyKind {
  stalledQuote,
  quoteExpiring,
  stalledSample,
  longSilence,
  internalSupport,
  registrationDue,
  tenderImminent,
  repurchaseDue,
}

/// 客户高级筛选中可组合的异常类型。
enum CustomerAnomalyFilter { stalledQuote, stalledSample, longSilence }

class DashboardAnomaly {
  const DashboardAnomaly({
    required this.customerId,
    required this.customerName,
    required this.opportunityId,
    required this.opportunityName,
    required this.kind,
    required this.severity,
    required this.detail,
  });

  final int customerId;
  final String customerName;
  final int? opportunityId;
  final String? opportunityName;
  final DashboardAnomalyKind kind;
  final int severity;
  final String detail;
}

/// 客户数据访问。标签的读写也归这里，因为标签只在客户上下文中使用。
@DriftAccessor(
  tables: [
    Customers,
    Contacts,
    Tags,
    CustomerTags,
    FollowPlans,
    Followups,
    Opportunities,
    Orders,
    Quotes,
    Samples,
  ],
)
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<int> insertCustomer({
    required String name,
    String? customerNo,
    String? customerType,
    String owner = '本人',
    String? company,
    String? country,
    String? phone,
    String? wechat,
    String? address,
    String? source,
    String? note,
    String? tenderExperience,
    String? tenderQualification,
    String? tenderBidder,
    String? localTeamStatus,
    String? fundingStatus,
    CustomerStage stage = CustomerStage.potential,
    CustomerGrade grade = CustomerGrade.c,
    String? sampleBatchId,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(customers).insert(
      CustomersCompanion.insert(
        name: name,
        customerNo: Value(customerNo),
        customerType: Value(customerType),
        owner: Value(owner),
        company: Value(company),
        country: Value(country),
        phone: Value(phone),
        wechat: Value(wechat),
        address: Value(address),
        source: Value(source),
        note: Value(note),
        tenderExperience: Value(tenderExperience),
        tenderQualification: Value(tenderQualification),
        tenderBidder: Value(tenderBidder),
        localTeamStatus: Value(localTeamStatus),
        fundingStatus: Value(fundingStatus),
        stage: Value(stage.dbValue),
        grade: Value(grade.dbValue),
        sampleBatchId: Value(sampleBatchId),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<CustomerRow?> findById(int id) =>
      (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CustomerRow>> allCustomers() => select(customers).get();

  Future<List<CustomerRow>> listBySampleBatch(String batchId) =>
      (select(customers)..where((t) => t.sampleBatchId.equals(batchId))).get();

  Future<int> countBySampleBatch(String batchId) async {
    final count = customers.id.count();
    final query = selectOnly(customers)
      ..addColumns([count])
      ..where(customers.sampleBatchId.equals(batchId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// 删除一个示例批次的客户根；所有业务子记录由外键级联删除。
  Future<int> deleteSampleBatchRoots(String batchId) =>
      (delete(customers)..where((t) => t.sampleBatchId.equals(batchId))).go();

  Future<int> countAll() async {
    final q = selectOnly(customers)..addColumns([customers.id.count()]);
    final row = await q.getSingle();
    return row.read(customers.id.count()) ?? 0;
  }

  /// 更新客户。只改传入的字段，未传的保持原值。
  Future<int> updateCustomer(
    int id, {
    String? name,
    Value<String?> customerNo = const Value.absent(),
    Value<String?> customerType = const Value.absent(),
    String? owner,
    Value<String?> company = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> wechat = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> tenderExperience = const Value.absent(),
    Value<String?> tenderQualification = const Value.absent(),
    Value<String?> tenderBidder = const Value.absent(),
    Value<String?> localTeamStatus = const Value.absent(),
    Value<String?> fundingStatus = const Value.absent(),
    CustomerStage? stage,
    CustomerGrade? grade,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        name: name == null ? const Value.absent() : Value(name),
        customerNo: customerNo,
        customerType: customerType,
        owner: owner == null ? const Value.absent() : Value(owner),
        company: company,
        country: country,
        phone: phone,
        wechat: wechat,
        address: address,
        source: source,
        note: note,
        tenderExperience: tenderExperience,
        tenderQualification: tenderQualification,
        tenderBidder: tenderBidder,
        localTeamStatus: localTeamStatus,
        fundingStatus: fundingStatus,
        stage: stage == null ? const Value.absent() : Value(stage.dbValue),
        grade: grade == null ? const Value.absent() : Value(grade.dbValue),
        updatedAt: Value(ts),
      ),
    );
  }

  /// 更新客户阶段。
  Future<int> updateStage(int id, CustomerStage stage, {DateTime? now}) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(stage: Value(stage.dbValue), updatedAt: Value(ts)),
    );
  }

  /// 删除客户。其联系人、跟进记录、计划、订单、附件由外键级联删除。
  Future<int> deleteCustomer(int id) =>
      (delete(customers)..where((t) => t.id.equals(id))).go();

  /// 按紧急度排序的客户列表。这是客户页的默认排序。
  ///
  /// 排序优先级：
  /// 1. 有逾期计划的最前，逾期越久越靠前
  /// 2. 有今日计划的次之
  /// 3. 有未来计划的，按计划时间升序
  /// 4. 无计划的最后，按分级 A > B > C，同级按最后跟进时间升序
  ///
  /// 写成单条 SQL 而非在 Dart 层排序：500 客户下要求低于 200ms，
  /// 把数据全捞到内存再排会明显超时。
  Future<List<CustomerListItem>> listByUrgency({
    required DateTime now,
    int? limit,
  }) => listFilteredByUrgency(now: now, limit: limit);

  /// 按紧急度排序，并组合客户与项目维度筛选。
  Future<List<CustomerListItem>> listFilteredByUrgency({
    required DateTime now,
    String keyword = '',
    CustomerStage? customerStage,
    int? tagId,
    String? country,
    CustomerGrade? customerGrade,
    String? currentSupplier,
    String? entryPoint,
    OpportunityStage? opportunityStage,
    String? owner,
    String? productCategory,
    String? productModel,
    String? equipmentBrand,
    OpportunityStatus? opportunityStatus,
    DateTime? expectedCloseFrom,
    DateTime? expectedCloseTo,
    bool overdueOnly = false,
    Set<CustomerAnomalyFilter> anomalies = const {},
    int? limit,
  }) async {
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    // 今日结束时刻，用于区分「今日待办」与「未来待办」。
    final endOfToday = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    ).toUtc().millisecondsSinceEpoch;
    final conditions = <String>[];
    final filterVariables = <Variable<Object>>[];
    final trimmedKeyword = keyword.trim();
    final trimmedCountry = country?.trim() ?? '';
    final trimmedCurrentSupplier = currentSupplier?.trim() ?? '';
    final trimmedEntryPoint = entryPoint?.trim() ?? '';
    final trimmedOwner = owner?.trim() ?? '';
    final trimmedProductCategory = productCategory?.trim() ?? '';
    final trimmedProductModel = productModel?.trim() ?? '';
    final trimmedEquipmentBrand = equipmentBrand?.trim() ?? '';

    if (overdueOnly) {
      conditions.add('p.next_plan_at < ?');
      filterVariables.add(Variable.withInt(nowMs));
    }

    if (trimmedKeyword.isNotEmpty) {
      final escaped = trimmedKeyword
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      final pattern = '%$escaped%';
      conditions.add('''
        (c.name LIKE ? ESCAPE '\\'
         OR c.phone LIKE ? ESCAPE '\\'
         OR c.customer_no LIKE ? ESCAPE '\\'
         OR EXISTS (
           SELECT 1
           FROM contacts contact
           WHERE contact.customer_id = c.id
             AND (contact.name LIKE ? ESCAPE '\\'
                  OR contact.phone LIKE ? ESCAPE '\\'
                  OR contact.email LIKE ? ESCAPE '\\'
                  OR contact.whatsapp LIKE ? ESCAPE '\\')
         ))
      ''');
      filterVariables.addAll([
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
      ]);
    }
    if (customerStage != null) {
      conditions.add('c.stage = ?');
      filterVariables.add(Variable.withString(customerStage.dbValue));
    }
    if (tagId != null) {
      conditions.add('''
        EXISTS (
          SELECT 1
          FROM customer_tags customer_tag
          WHERE customer_tag.customer_id = c.id
            AND customer_tag.tag_id = ?
        )
      ''');
      filterVariables.add(Variable.withInt(tagId));
    }
    if (trimmedCountry.isNotEmpty) {
      conditions.add('TRIM(c.country) = ?');
      filterVariables.add(Variable.withString(trimmedCountry));
    }
    if (customerGrade != null) {
      conditions.add('c.grade = ?');
      filterVariables.add(Variable.withString(customerGrade.dbValue));
    }
    if (anomalies.contains(CustomerAnomalyFilter.longSilence)) {
      conditions.add('''
        c.stage NOT IN ('deal', 'lost')
        AND (? - COALESCE(c.last_follow_at, c.created_at)) >=
          CASE c.grade
            WHEN 'a' THEN 14 * 86400000
            WHEN 'b' THEN 30 * 86400000
            ELSE 60 * 86400000
          END
      ''');
      filterVariables.add(Variable.withInt(nowMs));
    }

    final opportunityConditions = <String>[];
    final opportunityVariables = <Variable<Object>>[];
    if (trimmedCurrentSupplier.isNotEmpty) {
      opportunityConditions.add('TRIM(o.current_supplier) = ?');
      opportunityVariables.add(Variable.withString(trimmedCurrentSupplier));
    }
    if (trimmedEntryPoint.isNotEmpty) {
      opportunityConditions.add('TRIM(o.entry_point) = ?');
      opportunityVariables.add(Variable.withString(trimmedEntryPoint));
    }
    if (opportunityStage != null) {
      opportunityConditions.add('o.stage = ?');
      opportunityVariables.add(Variable.withString(opportunityStage.dbValue));
    }
    if (trimmedOwner.isNotEmpty) {
      opportunityConditions.add('TRIM(o.owner) = ?');
      opportunityVariables.add(Variable.withString(trimmedOwner));
    }
    if (trimmedProductCategory.isNotEmpty) {
      opportunityConditions.add('TRIM(o.product_category) = ?');
      opportunityVariables.add(Variable.withString(trimmedProductCategory));
    }
    if (trimmedProductModel.isNotEmpty) {
      opportunityConditions.add('TRIM(o.product_model) = ?');
      opportunityVariables.add(Variable.withString(trimmedProductModel));
    }
    if (trimmedEquipmentBrand.isNotEmpty) {
      opportunityConditions.add('TRIM(o.equipment_brand) = ?');
      opportunityVariables.add(Variable.withString(trimmedEquipmentBrand));
    }
    if (opportunityStatus != null) {
      opportunityConditions.add('o.status = ?');
      opportunityVariables.add(Variable.withString(opportunityStatus.dbValue));
    }
    if (expectedCloseFrom != null) {
      final fromMs = DateTime(
        expectedCloseFrom.year,
        expectedCloseFrom.month,
        expectedCloseFrom.day,
      ).toUtc().millisecondsSinceEpoch;
      opportunityConditions.add('o.expected_close_at >= ?');
      opportunityVariables.add(Variable.withInt(fromMs));
    }
    if (expectedCloseTo != null) {
      final toExclusiveMs = DateTime(
        expectedCloseTo.year,
        expectedCloseTo.month,
        expectedCloseTo.day + 1,
      ).toUtc().millisecondsSinceEpoch;
      opportunityConditions.add('o.expected_close_at < ?');
      opportunityVariables.add(Variable.withInt(toExclusiveMs));
    }
    final stalledCutoffMs = now
        .subtract(const Duration(days: 30))
        .toUtc()
        .millisecondsSinceEpoch;
    if (anomalies.contains(CustomerAnomalyFilter.stalledQuote)) {
      opportunityConditions.add('''
        EXISTS (
          SELECT 1
          FROM quotes q
          WHERE q.opportunity_id = o.id
            AND q.customer_received = 0
            AND q.quoted_at <= ?
        )
      ''');
      opportunityVariables.add(Variable.withInt(stalledCutoffMs));
    }
    if (anomalies.contains(CustomerAnomalyFilter.stalledSample)) {
      opportunityConditions.add('''
        EXISTS (
          SELECT 1
          FROM samples s
          WHERE s.opportunity_id = o.id
            AND s.delivered_at IS NOT NULL
            AND s.delivered_at <= ?
            AND (s.test_result IS NULL OR TRIM(s.test_result) = '')
        )
      ''');
      opportunityVariables.add(Variable.withInt(stalledCutoffMs));
    }
    if (opportunityConditions.isNotEmpty) {
      conditions.add('''
        EXISTS (
          SELECT 1
          FROM opportunities o
          WHERE o.customer_id = c.id
            AND ${opportunityConditions.join(' AND ')}
        )
      ''');
      filterVariables.addAll(opportunityVariables);
    }
    final whereSql = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';

    final rows = await customSelect(
      '''
      SELECT c.*,
             p.next_plan_at        AS next_plan_at,
             COALESCE(p.open_count, 0) AS open_count,
             CASE
               WHEN p.next_plan_at IS NULL           THEN 3
               WHEN p.next_plan_at < ?1              THEN 0
               WHEN p.next_plan_at <= ?2             THEN 1
               ELSE 2
             END AS urgency_bucket,
             CASE c.grade
               WHEN 'a' THEN 3
               WHEN 'b' THEN 2
               WHEN 'c' THEN 1
               ELSE 0
             END AS grade_weight
      FROM customers c
      LEFT JOIN (
        SELECT customer_id,
               MIN(plan_at) AS next_plan_at,
               COUNT(*)     AS open_count
        FROM follow_plans
        WHERE status != 'completed'
        GROUP BY customer_id
      ) p ON p.customer_id = c.id
      $whereSql
      ORDER BY urgency_bucket ASC,
               CASE WHEN p.next_plan_at IS NULL THEN 0 ELSE p.next_plan_at END ASC,
               grade_weight DESC,
               CASE WHEN c.last_follow_at IS NULL THEN 0 ELSE c.last_follow_at END ASC,
               c.id ASC
      ${limit == null ? '' : 'LIMIT ?'}
      ''',
      variables: [
        Variable.withInt(nowMs),
        Variable.withInt(endOfToday),
        ...filterVariables,
        if (limit != null) Variable.withInt(limit),
      ],
      readsFrom: {
        customers,
        db.followPlans,
        contacts,
        customerTags,
        db.opportunities,
        db.quotes,
        db.samples,
      },
    ).get();

    return rows.map(_mapListItem).toList();
  }

  /// 从已有客户和项目中生成文本筛选选项。
  Future<CustomerFilterOptions> listFilterOptions() async {
    final rows = await customSelect(
      '''
      SELECT kind, value
      FROM (
        SELECT 'country' AS kind,
               TRIM(country, char(9) || char(10) || char(11) || char(12) || char(13) || ' ') AS value
        FROM customers
        UNION ALL
        SELECT 'supplier',
               TRIM(current_supplier, char(9) || char(10) || char(11) || char(12) || char(13) || ' ')
        FROM opportunities
        UNION ALL
        SELECT 'entry_point',
               TRIM(entry_point, char(9) || char(10) || char(11) || char(12) || char(13) || ' ')
        FROM opportunities
        UNION ALL
        SELECT 'owner',
               TRIM(owner, char(9) || char(10) || char(11) || char(12) || char(13) || ' ')
        FROM opportunities
        UNION ALL
        SELECT 'product_category',
               TRIM(product_category, char(9) || char(10) || char(11) || char(12) || char(13) || ' ')
        FROM opportunities
        UNION ALL
        SELECT 'product_model',
               TRIM(product_model, char(9) || char(10) || char(11) || char(12) || char(13) || ' ')
        FROM opportunities
        UNION ALL
        SELECT 'equipment_brand',
               TRIM(equipment_brand, char(9) || char(10) || char(11) || char(12) || char(13) || ' ')
        FROM opportunities
      )
      WHERE value IS NOT NULL AND value != ''
      GROUP BY kind, value
      ORDER BY kind ASC, value ASC
      ''',
      readsFrom: {customers, db.opportunities},
    ).get();

    final countries = <String>[];
    final currentSuppliers = <String>[];
    final entryPoints = <String>[];
    final owners = <String>[];
    final productCategories = <String>[];
    final productModels = <String>[];
    final equipmentBrands = <String>[];
    for (final row in rows) {
      final kind = row.read<String>('kind');
      final value = row.read<String>('value');
      switch (kind) {
        case 'country':
          countries.add(value);
        case 'supplier':
          currentSuppliers.add(value);
        case 'entry_point':
          entryPoints.add(value);
        case 'owner':
          owners.add(value);
        case 'product_category':
          productCategories.add(value);
        case 'product_model':
          productModels.add(value);
        case 'equipment_brand':
          equipmentBrands.add(value);
      }
    }
    return CustomerFilterOptions(
      countries: countries,
      currentSuppliers: currentSuppliers,
      entryPoints: entryPoints,
      owners: owners,
      productCategories: productCategories,
      productModels: productModels,
      equipmentBrands: equipmentBrands,
    );
  }

  /// 按名称或电话模糊搜索。
  Future<List<CustomerRow>> search(String keyword) async {
    final pattern = '%${keyword.trim()}%';
    final rows = await customSelect(
      '''SELECT DISTINCT c.* FROM customers c
         LEFT JOIN contacts contact ON contact.customer_id = c.id
         WHERE c.name LIKE ? OR c.phone LIKE ? OR c.customer_no LIKE ?
            OR contact.name LIKE ? OR contact.phone LIKE ?
            OR contact.email LIKE ? OR contact.whatsapp LIKE ?
         ORDER BY c.name''',
      variables: List.generate(7, (_) => Variable.withString(pattern)),
      readsFrom: {customers, contacts},
    ).get();
    return Future.wait(rows.map(customers.mapFromRow));
  }

  /// 按阶段筛选。
  Future<List<CustomerRow>> listByStage(CustomerStage stage) =>
      (select(customers)..where((t) => t.stage.equals(stage.dbValue))).get();

  /// 久未联系的客户。
  ///
  /// 定义：超过 [days] 天无跟进记录，且阶段非已成交、已流失。
  /// 从未跟进过的客户按创建时间判断，否则新建客户永远不会出现在这里。
  Future<List<CustomerRow>> listStale({required DateTime now, int days = 30}) {
    final cutoff = now
        .subtract(Duration(days: days))
        .toUtc()
        .millisecondsSinceEpoch;
    final closed = [CustomerStage.deal.dbValue, CustomerStage.lost.dbValue];

    // 「最后活跃时间」= lastFollowAt，没跟进过则退回 createdAt。
    // 用 coalesce 交给 SQL 算，而不是在 Dart 里分支：where 的条件是
    // Expression<bool> 而非 Dart bool，三元运算符在这里不成立。
    Expression<int> lastActiveOf(Customers t) =>
        coalesce([t.lastFollowAt, t.createdAt]);

    return (select(customers)
          ..where(
            (t) =>
                t.stage.isNotIn(closed) &
                lastActiveOf(t).isSmallerThanValue(cutoff),
          )
          ..orderBy([(t) => OrderingTerm.asc(lastActiveOf(t))]))
        .get();
  }

  /// 各阶段客户数，用于漏斗视图。未出现的阶段计数为 0。
  Future<Map<CustomerStage, int>> countByStage() async {
    final count = customers.id.count();
    final q = selectOnly(customers)
      ..addColumns([customers.stage, count])
      ..groupBy([customers.stage]);

    final result = {for (final s in CustomerStage.values) s: 0};
    for (final row in await q.get()) {
      final stage = CustomerStage.fromDb(row.read(customers.stage)!);
      result[stage] = row.read(count) ?? 0;
    }
    return result;
  }

  Future<DashboardMetrics> dashboardMetrics({required DateTime now}) async {
    final local = now.toLocal();
    final weekStart = DateTime(local.year, local.month, local.day)
        .subtract(Duration(days: local.weekday - DateTime.monday))
        .toUtc()
        .millisecondsSinceEpoch;
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    final stalledCutoff = now
        .toUtc()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    final customersCount = await customSelect(
      'SELECT COUNT(*) AS value FROM customers',
      readsFrom: {customers},
    ).getSingle();
    final grades = await customSelect(
      'SELECT grade, COUNT(*) AS value FROM customers GROUP BY grade',
      readsFrom: {customers},
    ).get();
    final stages = await customSelect(
      '''SELECT stage, COUNT(*) AS value FROM opportunities
         WHERE status NOT IN ('paused', 'won', 'closed')
           AND stage NOT IN ('lost', 'paused') GROUP BY stage''',
      readsFrom: {db.opportunities},
    ).get();
    final followupResult = await customSelect(
      'SELECT COUNT(*) AS value FROM followups WHERE occurred_at >= ? AND occurred_at <= ?',
      variables: [Variable.withInt(weekStart), Variable.withInt(nowMs)],
      readsFrom: {db.followups},
    ).getSingle();
    final amountItems = await Future.wait([
      _dashboardForecastItems(now: now),
      _dashboardWonItems(),
    ]);
    final forecastItems = amountItems[0];
    final wonItems = amountItems[1];
    final stalled = await customSelect(
      '''SELECT
           (SELECT COUNT(*) FROM quotes
            WHERE customer_received = 0 AND quoted_at <= ?) AS quote_count,
           (SELECT COUNT(*) FROM samples
            WHERE delivered_at IS NOT NULL AND delivered_at <= ?
              AND status NOT IN ('passed', 'failed', 'cancelled')
              AND (test_result IS NULL OR TRIM(test_result) = '')) AS sample_count''',
      variables: [
        Variable.withInt(stalledCutoff),
        Variable.withInt(stalledCutoff),
      ],
      readsFrom: {db.quotes, db.samples},
    ).getSingle();
    return DashboardMetrics(
      totalCustomers: customersCount.read<int>('value'),
      customerCountsByGrade: {
        for (final grade in CustomerGrade.values)
          grade:
              grades
                  .where((row) => row.read<String>('grade') == grade.dbValue)
                  .map((row) => row.read<int>('value'))
                  .firstOrNull ??
              0,
      },
      projectCountsByStage: {
        for (final stage in OpportunityStage.values)
          stage:
              stages
                  .where((row) => row.read<String>('stage') == stage.dbValue)
                  .map((row) => row.read<int>('value'))
                  .firstOrNull ??
              0,
      },
      followupsThisWeek: followupResult.read<int>('value'),
      stalledQuoteCount: stalled.read<int>('quote_count'),
      stalledSampleCount: stalled.read<int>('sample_count'),
      forecastByCurrency: _amountTotals(
        forecastItems,
        type: DashboardAmountType.forecast,
      ),
      weightedForecastByCurrency: _amountTotals(
        forecastItems,
        type: DashboardAmountType.weighted,
      ),
      wonByCurrency: _amountTotals(wonItems, type: DashboardAmountType.won),
    );
  }

  Future<DashboardAmountDetails> dashboardAmountDetails({
    required DashboardAmountType type,
    required DateTime now,
  }) async {
    final items = switch (type) {
      DashboardAmountType.forecast ||
      DashboardAmountType.weighted => await _dashboardForecastItems(now: now),
      DashboardAmountType.won => await _dashboardWonItems(),
    };
    return DashboardAmountDetails(
      type: type,
      items: List.unmodifiable(items),
      totalsByCurrency: Map.unmodifiable(_amountTotals(items, type: type)),
    );
  }

  Future<List<DashboardAmountItem>> _dashboardForecastItems({
    required DateTime now,
  }) async {
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    final threeMonths = now
        .toUtc()
        .add(const Duration(days: 90))
        .millisecondsSinceEpoch;
    final rows = await customSelect(
      '''SELECT c.id AS customer_id, c.name AS customer_name,
                o.id AS opportunity_id, o.name AS opportunity_name,
                UPPER(o.currency) AS currency,
                o.forecast_amount_minor AS amount_minor,
                o.probability_percent AS probability_percent
         FROM opportunities o
         INNER JOIN customers c ON c.id = o.customer_id
         WHERE o.expected_close_at IS NOT NULL
           AND o.expected_close_at >= ? AND o.expected_close_at <= ?
           AND o.forecast_amount_minor IS NOT NULL
           AND o.status NOT IN ('paused', 'won', 'closed')
           AND o.stage NOT IN ('lost', 'paused')
         ORDER BY UPPER(o.currency), o.expected_close_at, o.id''',
      variables: [Variable.withInt(nowMs), Variable.withInt(threeMonths)],
      readsFrom: {customers, db.opportunities},
    ).get();
    return [
      for (final row in rows)
        DashboardAmountItem(
          customerId: row.read<int>('customer_id'),
          customerName: row.read<String>('customer_name'),
          opportunityId: row.read<int>('opportunity_id'),
          opportunityName: row.read<String>('opportunity_name'),
          currency: row.read<String>('currency'),
          amountMinor: row.read<int>('amount_minor'),
          probabilityPercent: row.readNullable<int>('probability_percent'),
          weightedAmountMinor:
              row.read<int>('amount_minor') *
              (row.readNullable<int>('probability_percent') ?? 0) ~/
              100,
        ),
    ];
  }

  Future<List<DashboardAmountItem>> _dashboardWonItems() async {
    final rows = await customSelect(
      '''SELECT c.id AS customer_id, c.name AS customer_name,
                o.id AS opportunity_id, o.name AS opportunity_name,
                r.id AS order_id, r.order_no AS order_no,
                UPPER(r.currency) AS currency, r.amount_cents AS amount_minor
         FROM orders r
         INNER JOIN customers c ON c.id = r.customer_id
         LEFT JOIN opportunities o ON o.id = r.opportunity_id
         WHERE r.order_result = 'completed'
         ORDER BY UPPER(r.currency), r.ordered_at DESC, r.id DESC''',
      readsFrom: {customers, db.opportunities, db.orders},
    ).get();
    return [
      for (final row in rows)
        DashboardAmountItem(
          customerId: row.read<int>('customer_id'),
          customerName: row.read<String>('customer_name'),
          opportunityId: row.readNullable<int>('opportunity_id'),
          opportunityName: row.readNullable<String>('opportunity_name'),
          orderId: row.read<int>('order_id'),
          orderNo: row.read<String>('order_no'),
          currency: row.read<String>('currency'),
          amountMinor: row.read<int>('amount_minor'),
          weightedAmountMinor: row.read<int>('amount_minor'),
        ),
    ];
  }

  Map<String, int> _amountTotals(
    List<DashboardAmountItem> items, {
    required DashboardAmountType type,
  }) {
    final totals = <String, int>{};
    for (final item in items) {
      final amount = type == DashboardAmountType.weighted
          ? item.weightedAmountMinor
          : item.amountMinor;
      totals.update(
        item.currency,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }
    return totals;
  }

  Future<List<DashboardAnomaly>> dashboardAnomalies({
    required DateTime now,
  }) async {
    final rows = await customSelect(
      '''SELECT customer_id, customer_name, opportunity_id, opportunity_name,
                kind, severity, detail
         FROM (
           SELECT c.id AS customer_id, c.name AS customer_name,
                  NULL AS opportunity_id, NULL AS opportunity_name,
                  'long_silence' AS kind,
                  CAST((? - COALESCE(c.last_follow_at, c.created_at)) / 86400000 AS INTEGER) AS severity,
                  CAST((? - COALESCE(c.last_follow_at, c.created_at)) / 86400000 AS TEXT) || ' 天未联系' AS detail,
                  0 AS sort_group, 0 AS sort_time, c.id AS sort_id
           FROM customers c
           WHERE c.stage NOT IN ('deal', 'lost')
             AND (? - COALESCE(c.last_follow_at, c.created_at)) >=
               CASE c.grade WHEN 'a' THEN 14 * 86400000
                            WHEN 'b' THEN 30 * 86400000
                            ELSE 60 * 86400000 END
           UNION ALL
           SELECT c.id, c.name, o.id, o.name, 'stalled_quote',
                  CAST((? - MIN(q.quoted_at)) / 86400000 AS INTEGER),
                  '报价后 ' || CAST((? - MIN(q.quoted_at)) / 86400000 AS TEXT) || ' 天未确认收到',
                  0, MIN(q.quoted_at), o.id
           FROM customers c
           JOIN opportunities o ON o.customer_id = c.id
           JOIN quotes q ON q.opportunity_id = o.id
           WHERE q.customer_received = 0 AND q.quoted_at <= ?
             AND o.status NOT IN ('paused', 'won', 'closed')
             AND o.stage NOT IN ('lost', 'paused')
           GROUP BY c.id, c.name, o.id, o.name
           UNION ALL
           SELECT c.id, c.name, o.id, o.name, 'quote_expiring', 0,
                  '报价将在 ' || CAST((MIN(q.valid_until) - ?) / 86400000 AS TEXT) || ' 天内到期',
                  0, MIN(q.valid_until), o.id
           FROM customers c
           JOIN opportunities o ON o.customer_id = c.id
           JOIN quotes q ON q.opportunity_id = o.id
           WHERE q.valid_until IS NOT NULL AND q.valid_until >= ?
             AND q.valid_until <= ?
             AND o.status NOT IN ('paused', 'won', 'closed')
             AND o.stage NOT IN ('lost', 'paused')
           GROUP BY c.id, c.name, o.id, o.name
           UNION ALL
           SELECT c.id, c.name, o.id, o.name, 'stalled_sample',
                  CAST((? - MIN(s.delivered_at)) / 86400000 AS INTEGER),
                  '样品签收后 ' || CAST((? - MIN(s.delivered_at)) / 86400000 AS TEXT) || ' 天无测试结果',
                  0, MIN(s.delivered_at), o.id
           FROM customers c
           JOIN opportunities o ON o.customer_id = c.id
           JOIN samples s ON s.opportunity_id = o.id
           WHERE s.delivered_at IS NOT NULL AND s.delivered_at <= ?
             AND s.status NOT IN ('passed', 'failed', 'cancelled')
             AND (s.test_result IS NULL OR TRIM(s.test_result) = '')
             AND o.status NOT IN ('paused', 'won', 'closed')
             AND o.stage NOT IN ('lost', 'paused')
           GROUP BY c.id, c.name, o.id, o.name
           UNION ALL
           SELECT c.id, c.name, o.id, o.name, 'internal_support', 1000,
                  o.current_obstacle, 0, 0, c.id
           FROM customers c JOIN opportunities o ON o.customer_id = c.id
           WHERE o.current_obstacle IS NOT NULL AND TRIM(o.current_obstacle) <> ''
             AND o.status NOT IN ('paused', 'won', 'closed')
             AND o.stage NOT IN ('lost', 'paused')
           UNION ALL
           SELECT c.id, c.name, o.id, o.name,
                  CASE fp.source_type
                    WHEN 'registration' THEN 'registration_due'
                    WHEN 'tender' THEN 'tender_imminent'
                    WHEN 'repurchase' THEN 'repurchase_due'
                  END,
                  0,
                  COALESCE(NULLIF(TRIM(fp.next_action), ''), fp.title),
                  1, fp.plan_at, fp.id
           FROM follow_plans fp
           JOIN customers c ON c.id = fp.customer_id
           LEFT JOIN opportunities o ON o.id = fp.opportunity_id
           WHERE fp.source_type IN ('registration', 'tender', 'repurchase')
             AND fp.status IN ('pending', 'notified', 'overdue')
             AND fp.plan_at <= ?
         ) anomalies
         ORDER BY sort_group ASC, severity DESC, sort_time ASC,
                  sort_id ASC, customer_id ASC''',
      variables: [
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(
          now.toUtc().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
        ),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(
          now.toUtc().add(const Duration(days: 7)).millisecondsSinceEpoch,
        ),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
        Variable.withInt(
          now.toUtc().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
        ),
        Variable.withInt(now.toUtc().millisecondsSinceEpoch),
      ],
      readsFrom: {
        customers,
        db.opportunities,
        db.quotes,
        db.samples,
        followPlans,
      },
    ).get();
    return rows.map((row) {
      return DashboardAnomaly(
        customerId: row.read<int>('customer_id'),
        customerName: row.read<String>('customer_name'),
        opportunityId: row.readNullable<int>('opportunity_id'),
        opportunityName: row.readNullable<String>('opportunity_name'),
        kind: switch (row.read<String>('kind')) {
          'stalled_quote' => DashboardAnomalyKind.stalledQuote,
          'quote_expiring' => DashboardAnomalyKind.quoteExpiring,
          'stalled_sample' => DashboardAnomalyKind.stalledSample,
          'long_silence' => DashboardAnomalyKind.longSilence,
          'internal_support' => DashboardAnomalyKind.internalSupport,
          'registration_due' => DashboardAnomalyKind.registrationDue,
          'tender_imminent' => DashboardAnomalyKind.tenderImminent,
          'repurchase_due' => DashboardAnomalyKind.repurchaseDue,
          final value => throw StateError(
            'Unknown dashboard anomaly kind: $value',
          ),
        },
        severity: row.read<int>('severity'),
        detail: row.read<String>('detail'),
      );
    }).toList();
  }

  // ── 标签 ──

  /// 按名称取标签，不存在则创建。标签名唯一，重复调用不会产生副本。
  Future<int> ensureTag(String name, {DateTime? now}) async {
    final trimmed = name.trim();
    final existing = await (select(
      tags,
    )..where((t) => t.name.equals(trimmed))).getSingleOrNull();
    if (existing != null) return existing.id;

    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(
      tags,
    ).insert(TagsCompanion.insert(name: trimmed, createdAt: ts, updatedAt: ts));
  }

  Future<List<TagRow>> allTags() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  /// 给客户打标签。重复打同一标签不报错，靠联合主键去重。
  Future<void> attachTag(int customerId, int tagId, {DateTime? now}) async {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    await into(customerTags).insert(
      CustomerTagsCompanion.insert(
        customerId: customerId,
        tagId: tagId,
        createdAt: ts,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<int> detachTag(int customerId, int tagId) =>
      (delete(customerTags)..where(
            (t) => t.customerId.equals(customerId) & t.tagId.equals(tagId),
          ))
          .go();

  /// 某客户的全部标签。
  Future<List<TagRow>> tagsOf(int customerId) {
    final q = select(customerTags).join([
      innerJoin(tags, tags.id.equalsExp(customerTags.tagId)),
    ])..where(customerTags.customerId.equals(customerId));
    return q.map((row) => row.readTable(tags)).get();
  }

  /// 批量读取多个客户的标签，避免列表页逐客户查询。
  Future<Map<int, List<TagRow>>> tagsForCustomers(
    Iterable<int> customerIds,
  ) async {
    final ids = customerIds.toSet().toList();
    final result = <int, List<TagRow>>{for (final id in ids) id: <TagRow>[]};
    if (ids.isEmpty) return result;

    final q =
        select(
            customerTags,
          ).join([innerJoin(tags, tags.id.equalsExp(customerTags.tagId))])
          ..where(customerTags.customerId.isIn(ids))
          ..orderBy([OrderingTerm.asc(tags.name), OrderingTerm.asc(tags.id)]);
    for (final row in await q.get()) {
      result[row.readTable(customerTags).customerId]!.add(row.readTable(tags));
    }
    return result;
  }

  /// 按标签筛选客户。
  Future<List<CustomerRow>> listByTag(int tagId) {
    final q = select(customerTags).join([
      innerJoin(customers, customers.id.equalsExp(customerTags.customerId)),
    ])..where(customerTags.tagId.equals(tagId));
    return q.map((row) => row.readTable(customers)).get();
  }

  CustomerListItem _mapListItem(QueryRow row) {
    final nextAt = row.data['next_plan_at'] as int?;
    return CustomerListItem(
      customer: customers.map(row.data),
      nextPlanAt: nextAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(nextAt, isUtc: true).toLocal(),
      openPlanCount: (row.data['open_count'] as int?) ?? 0,
    );
  }
}
