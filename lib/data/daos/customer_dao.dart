import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/contacts.dart';
import '../tables/customers.dart';
import '../tables/follow_plans.dart';
import '../tables/followups.dart';
import '../tables/opportunities.dart';
import '../tables/orders.dart';
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
  });

  final List<String> countries;
  final List<String> currentSuppliers;
  final List<String> entryPoints;
  final List<String> owners;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.totalCustomers,
    required this.customerCountsByGrade,
    required this.projectCountsByStage,
    required this.followupsThisWeek,
    required this.stalledQuoteCount,
    required this.stalledSampleCount,
    required this.forecastAmountMinor,
    required this.weightedForecastAmountMinor,
    required this.wonAmountMinor,
  });

  final int totalCustomers;
  final Map<CustomerGrade, int> customerCountsByGrade;
  final Map<OpportunityStage, int> projectCountsByStage;
  final int followupsThisWeek;
  final int? stalledQuoteCount;
  final int? stalledSampleCount;
  final int forecastAmountMinor;
  final int weightedForecastAmountMinor;
  final int wonAmountMinor;
}

enum DashboardAnomalyKind {
  longSilence,
  internalSupport,
  registrationDue,
  tenderImminent,
  repurchaseDue,
}

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
  ],
)
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<int> insertCustomer({
    required String name,
    String? company,
    String? country,
    String? phone,
    String? wechat,
    String? address,
    String? source,
    String? note,
    CustomerStage stage = CustomerStage.potential,
    CustomerGrade grade = CustomerGrade.c,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(customers).insert(
      CustomersCompanion.insert(
        name: name,
        company: Value(company),
        country: Value(country),
        phone: Value(phone),
        wechat: Value(wechat),
        address: Value(address),
        source: Value(source),
        note: Value(note),
        stage: Value(stage.dbValue),
        grade: Value(grade.dbValue),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<CustomerRow?> findById(int id) =>
      (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CustomerRow>> allCustomers() => select(customers).get();

  Future<int> countAll() async {
    final q = selectOnly(customers)..addColumns([customers.id.count()]);
    final row = await q.getSingle();
    return row.read(customers.id.count()) ?? 0;
  }

  /// 更新客户。只改传入的字段，未传的保持原值。
  Future<int> updateCustomer(
    int id, {
    String? name,
    Value<String?> company = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> wechat = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> note = const Value.absent(),
    CustomerStage? stage,
    CustomerGrade? grade,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        name: name == null ? const Value.absent() : Value(name),
        company: company,
        phone: phone,
        wechat: wechat,
        address: address,
        source: source,
        note: note,
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

    if (trimmedKeyword.isNotEmpty) {
      final escaped = trimmedKeyword
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      final pattern = '%$escaped%';
      conditions.add('''
        (c.name LIKE ? ESCAPE '\\'
         OR c.phone LIKE ? ESCAPE '\\'
         OR EXISTS (
           SELECT 1
           FROM contacts contact
           WHERE contact.customer_id = c.id
             AND contact.phone LIKE ? ESCAPE '\\'
         ))
      ''');
      filterVariables.addAll([
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
        SELECT 'country' AS kind, TRIM(country) AS value FROM customers
        UNION ALL
        SELECT 'supplier', TRIM(current_supplier) FROM opportunities
        UNION ALL
        SELECT 'entry_point', TRIM(entry_point) FROM opportunities
        UNION ALL
        SELECT 'owner', TRIM(owner) FROM opportunities
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
      }
    }
    return CustomerFilterOptions(
      countries: countries,
      currentSuppliers: currentSuppliers,
      entryPoints: entryPoints,
      owners: owners,
    );
  }

  /// 按名称或电话模糊搜索。
  Future<List<CustomerRow>> search(String keyword) {
    final pattern = '%${keyword.trim()}%';
    return (select(customers)
          ..where((t) => t.name.like(pattern) | t.phone.like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
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
    final threeMonths = now
        .toUtc()
        .add(const Duration(days: 90))
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
    final forecast = await customSelect(
      '''SELECT COALESCE(SUM(forecast_amount_minor), 0) AS total,
                COALESCE(SUM(forecast_amount_minor * probability_percent / 100), 0) AS weighted
         FROM opportunities
         WHERE expected_close_at IS NOT NULL AND expected_close_at <= ?
           AND status NOT IN ('paused', 'won', 'closed')
           AND stage NOT IN ('lost', 'paused')''',
      variables: [Variable.withInt(threeMonths)],
      readsFrom: {db.opportunities},
    ).getSingle();
    final won = await customSelect(
      "SELECT COALESCE(SUM(amount_cents), 0) AS value FROM orders WHERE status = 'completed'",
      readsFrom: {db.orders},
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
      stalledQuoteCount: null,
      stalledSampleCount: null,
      forecastAmountMinor: forecast.read<int>('total'),
      weightedForecastAmountMinor: forecast.read<int>('weighted'),
      wonAmountMinor: won.read<int>('value'),
    );
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
      ],
      readsFrom: {customers, db.opportunities, followPlans},
    ).get();
    return rows.map((row) {
      return DashboardAnomaly(
        customerId: row.read<int>('customer_id'),
        customerName: row.read<String>('customer_name'),
        opportunityId: row.readNullable<int>('opportunity_id'),
        opportunityName: row.readNullable<String>('opportunity_name'),
        kind: switch (row.read<String>('kind')) {
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
