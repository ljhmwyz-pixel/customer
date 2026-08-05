import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/contacts.dart';
import '../tables/customers.dart';
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

/// 客户数据访问。标签的读写也归这里，因为标签只在客户上下文中使用。
@DriftAccessor(tables: [Customers, Contacts, Tags, CustomerTags])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<int> insertCustomer({
    required String name,
    String? company,
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

  /// 按紧急度排序，并组合关键字、阶段、标签筛选。
  Future<List<CustomerListItem>> listFilteredByUrgency({
    required DateTime now,
    String keyword = '',
    CustomerStage? stage,
    int? tagId,
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
    if (stage != null) {
      conditions.add('c.stage = ?');
      filterVariables.add(Variable.withString(stage.dbValue));
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
      readsFrom: {customers, db.followPlans, contacts, customerTags},
    ).get();

    return rows.map(_mapListItem).toList();
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
