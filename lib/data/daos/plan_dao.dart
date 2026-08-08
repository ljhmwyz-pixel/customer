import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/customers.dart';
import '../tables/follow_plans.dart';
import '../tables/opportunities.dart';
import '../tables/task_reconciliation_jobs.dart';

part 'plan_dao.g.dart';

/// 待办项，含所属客户名，避免列表页逐条再查客户。
class PlanWithCustomer {
  const PlanWithCustomer({required this.plan, required this.customerName});

  final FollowPlanRow plan;
  final String customerName;

  PlanStatus get status => PlanStatus.fromDb(plan.status);

  DateTime get planAt =>
      DateTime.fromMillisecondsSinceEpoch(plan.planAt, isUtc: true).toLocal();
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.plan,
    required this.customer,
    required this.opportunity,
  });

  final FollowPlanRow plan;
  final CustomerRow customer;
  final OpportunityRow opportunity;

  String get customerGrade => customer.grade.toUpperCase();
  String get opportunityImportance => opportunity.importance;
  String get projectLabel => opportunity.name;
  String get productLabel =>
      opportunity.productModel ?? opportunity.productCategory ?? '未填写产品';
  String get latestFeedback => opportunity.latestFeedback ?? '暂无反馈';
  String get reason => plan.reason ?? '历史任务';
  String get nextAction => plan.nextAction ?? plan.title;
  String get owner => plan.owner;

  int overdueDays(DateTime now) {
    final due = DateTime.fromMillisecondsSinceEpoch(
      plan.planAt,
      isUtc: true,
    ).toLocal();
    final start = DateTime(now.year, now.month, now.day);
    if (!due.isBefore(start)) return 0;
    return start.difference(DateTime(due.year, due.month, due.day)).inDays;
  }
}

/// 跟进计划数据访问。提醒链路的数据基础。
@DriftAccessor(
  tables: [FollowPlans, Customers, Opportunities, TaskReconciliationJobs],
)
class PlanDao extends DatabaseAccessor<AppDatabase> with _$PlanDaoMixin {
  PlanDao(super.db);

  static final _openStatusValues = [
    PlanStatus.pending.dbValue,
    PlanStatus.notified.dbValue,
    PlanStatus.overdue.dbValue,
  ];

  Future<int> insertPlan({
    required int customerId,
    int? opportunityId,
    TaskSourceType sourceType = TaskSourceType.legacy,
    int? sourceId,
    String? ruleKey,
    String? reason,
    String? talkingDirection,
    String? nextAction,
    String? owner,
    String? title,
    required DateTime planAt,
    DateTime? now,
  }) {
    final normalizedNextAction = nextAction ?? title;
    if (normalizedNextAction == null || normalizedNextAction.trim().isEmpty) {
      throw ArgumentError('nextAction or title is required');
    }
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(followPlans).insert(
      FollowPlansCompanion.insert(
        customerId: customerId,
        opportunityId: Value(opportunityId),
        sourceType: Value(sourceType.dbValue),
        sourceId: Value(sourceId),
        ruleKey: Value(ruleKey),
        title: title ?? normalizedNextAction,
        reason: Value(reason),
        talkingDirection: Value(talkingDirection),
        nextAction: Value(normalizedNextAction),
        owner: Value(owner ?? '本人'),
        planAt: planAt.toUtc().millisecondsSinceEpoch,
        status: Value(PlanStatus.pending.dbValue),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<FollowPlanRow?> findById(int id) =>
      (select(followPlans)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<FollowPlanRow?> findBySourceRule(
    TaskSourceType sourceType,
    int sourceId,
    String ruleKey,
  ) =>
      (select(followPlans)..where(
            (t) =>
                t.sourceType.equals(sourceType.dbValue) &
                t.sourceId.equals(sourceId) &
                t.ruleKey.equals(ruleKey),
          ))
          .getSingleOrNull();

  Future<List<FollowPlanRow>> listOf(int customerId) =>
      (select(followPlans)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.asc(t.planAt)]))
          .get();

  /// 某客户所有未完成计划，按时间和主键稳定排序。
  Future<List<FollowPlanRow>> listOpenOf(int customerId) =>
      (select(followPlans)
            ..where(
              (t) =>
                  t.customerId.equals(customerId) &
                  t.status.isIn(_openStatusValues),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(t.planAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

  Future<List<FollowPlanRow>> listOpenAutomaticOfOpportunity(
    int opportunityId,
  ) =>
      (select(followPlans)
            ..where(
              (t) =>
                  t.opportunityId.equals(opportunityId) &
                  t.status.isIn(_openStatusValues) &
                  t.sourceType.isIn([
                    TaskSourceType.quote.dbValue,
                    TaskSourceType.sample.dbValue,
                    TaskSourceType.registration.dbValue,
                    TaskSourceType.tender.dbValue,
                    TaskSourceType.repurchase.dbValue,
                  ]) &
                  t.ruleKey.isNotNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<int> countOf(int customerId) async {
    final q = selectOnly(followPlans)
      ..addColumns([followPlans.id.count()])
      ..where(followPlans.customerId.equals(customerId));
    final row = await q.getSingle();
    return row.read(followPlans.id.count()) ?? 0;
  }

  /// 到期待提醒的计划。阶段 2 的闹钟回调用它决定发哪些通知。
  ///
  /// 只取 pending：已提醒过的不重复推送，已完成的不再打扰。
  Future<List<PlanWithCustomer>> listDue({required DateTime now}) {
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    final q =
        select(followPlans).join([
            innerJoin(
              customers,
              customers.id.equalsExp(followPlans.customerId),
            ),
          ])
          ..where(
            followPlans.status.equals(PlanStatus.pending.dbValue) &
                followPlans.planAt.isSmallerOrEqualValue(nowMs),
          )
          ..orderBy([OrderingTerm.asc(followPlans.planAt)]);

    return q
        .map(
          (row) => PlanWithCustomer(
            plan: row.readTable(followPlans),
            customerName: row.readTable(customers).name,
          ),
        )
        .get();
  }

  /// 未来待排期的计划。设备重启后靠它重建全部闹钟。
  Future<List<FollowPlanRow>> listUpcoming({required DateTime now}) {
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    return (select(followPlans)
          ..where(
            (t) =>
                t.status.equals(PlanStatus.pending.dbValue) &
                t.planAt.isBiggerThanValue(nowMs),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.planAt)]))
        .get();
  }

  /// 已实际触发过提醒的计划，按触发时间倒序。触发日志页用。
  ///
  /// 判据是 notifiedAt 非空而不是 status，因为提醒触发后用户可能马上点了
  /// 「已完成」，状态就不再是 notified 了，但那条提醒确实响过。
  /// 状态过滤会漏掉这类记录，让日志显得比实际触发得少。
  Future<List<PlanWithCustomer>> listNotified({int limit = 100}) {
    final q =
        select(followPlans).join([
            innerJoin(
              customers,
              customers.id.equalsExp(followPlans.customerId),
            ),
          ])
          ..where(followPlans.notifiedAt.isNotNull())
          ..orderBy([OrderingTerm.desc(followPlans.notifiedAt)])
          ..limit(limit);

    return q
        .map(
          (row) => PlanWithCustomer(
            plan: row.readTable(followPlans),
            customerName: row.readTable(customers).name,
          ),
        )
        .get();
  }

  /// 今日待办与逾期项，首页用。
  Future<List<PlanWithCustomer>> listOpenUntil({required DateTime until}) {
    final untilMs = until.toUtc().millisecondsSinceEpoch;
    final q =
        select(followPlans).join([
            innerJoin(
              customers,
              customers.id.equalsExp(followPlans.customerId),
            ),
          ])
          ..where(
            followPlans.status.isIn(_openStatusValues) &
                followPlans.planAt.isSmallerOrEqualValue(untilMs),
          )
          ..orderBy([OrderingTerm.asc(followPlans.planAt)]);

    return q
        .map(
          (row) => PlanWithCustomer(
            plan: row.readTable(followPlans),
            customerName: row.readTable(customers).name,
          ),
        )
        .get();
  }

  /// Project-aware Today dashboard query. Boundaries are local calendar days,
  /// while stored timestamps remain UTC milliseconds.
  Future<List<TodayPlanItem>> listToday({required DateTime now}) {
    final localNow = now.toLocal();
    final start = DateTime(localNow.year, localNow.month, localNow.day);
    final end = start.add(const Duration(days: 1));
    final startMs = start.toUtc().millisecondsSinceEpoch;
    final endMs = end.toUtc().millisecondsSinceEpoch;
    final q =
        select(followPlans).join([
            innerJoin(
              customers,
              customers.id.equalsExp(followPlans.customerId),
            ),
            innerJoin(
              opportunities,
              opportunities.id.equalsExp(followPlans.opportunityId),
            ),
          ])
          ..where(
            followPlans.status.isIn(_openStatusValues) &
                followPlans.planAt.isSmallerThanValue(endMs) &
                opportunities.status.isNotIn(['paused', 'won', 'closed']) &
                opportunities.stage.isNotIn(['lost', 'paused']),
          )
          ..orderBy([
            OrderingTerm(
              expression: CaseWhenExpression<int>(
                cases: [
                  CaseWhen(
                    followPlans.planAt.isSmallerThanValue(startMs),
                    then: const Constant(0),
                  ),
                ],
                orElse: const Constant(1),
              ),
              mode: OrderingMode.asc,
            ),
            OrderingTerm(
              expression: CaseWhenExpression<int>(
                cases: [
                  CaseWhen(
                    followPlans.planAt.isSmallerThanValue(startMs),
                    then: Constant(startMs) - followPlans.planAt,
                  ),
                ],
                orElse: const Constant(0),
              ),
              mode: OrderingMode.desc,
            ),
            OrderingTerm(expression: customers.grade, mode: OrderingMode.desc),
            OrderingTerm(
              expression: opportunities.importance,
              mode: OrderingMode.desc,
            ),
            OrderingTerm(
              expression: followPlans.planAt,
              mode: OrderingMode.asc,
            ),
            OrderingTerm(expression: followPlans.id, mode: OrderingMode.asc),
          ]);
    return q
        .map(
          (row) => TodayPlanItem(
            plan: row.readTable(followPlans),
            customer: row.readTable(customers),
            opportunity: row.readTable(opportunities),
          ),
        )
        .get();
  }

  /// 标记提醒已触发，记下实际触发时间。
  ///
  /// notifiedAt 与 planAt 的偏差是阶段 2 判断 ColorOS 有没有掐掉闹钟的依据，
  /// 所以这里存的是真实触发时刻，不是计划时刻。
  Future<int> markNotified(int id, {DateTime? at}) {
    final ts = (at ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(followPlans)..where(
          (t) => t.id.equals(id) & t.status.equals(PlanStatus.pending.dbValue),
        ))
        .write(
          FollowPlansCompanion(
            status: Value(PlanStatus.notified.dbValue),
            notifiedAt: Value(ts),
            updatedAt: Value(ts),
          ),
        );
  }

  /// 标记完成。通知上的「已完成」按钮走这里。
  Future<int> markCompleted(int id, {DateTime? at}) {
    final ts = (at ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(
      followPlans,
    )..where((t) => t.id.equals(id) & t.status.isIn(_openStatusValues))).write(
      FollowPlansCompanion(
        status: Value(PlanStatus.completed.dbValue),
        completedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }

  /// 推迟。通知上的「推迟一天」按钮走这里。
  ///
  /// 状态回到 pending，这样闹钟会被重新排期。
  Future<int> postpone(
    int id, {
    Duration by = const Duration(days: 1),
    DateTime? now,
  }) async {
    final plan = await findById(id);
    if (plan == null || !PlanStatus.fromDb(plan.status).isOpen) return 0;

    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final base = DateTime.fromMillisecondsSinceEpoch(plan.planAt, isUtc: true);
    final next = base.add(by).millisecondsSinceEpoch;

    return (update(
      followPlans,
    )..where((t) => t.id.equals(id) & t.status.isIn(_openStatusValues))).write(
      FollowPlansCompanion(
        planAt: Value(next),
        status: Value(PlanStatus.pending.dbValue),
        notifiedAt: const Value(null),
        updatedAt: Value(ts),
      ),
    );
  }

  /// 取消开放任务并保留历史行。已完成或已取消任务不可逆转。
  Future<int> markCancelled(int id, {DateTime? at}) {
    final ts = (at ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(
      followPlans,
    )..where((t) => t.id.equals(id) & t.status.isIn(_openStatusValues))).write(
      FollowPlansCompanion(
        status: Value(PlanStatus.cancelled.dbValue),
        cancelledAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }

  /// 把超过计划时间 24 小时仍未完成的计划标为逾期。
  ///
  /// 逾期是派生状态，由这个方法在应用启动与每日首次打开时批量刷新，
  /// 而不是查询时实时计算，否则每次列表查询都要额外算一遍。
  Future<int> markOverdue({required DateTime now}) {
    final cutoff = now
        .subtract(const Duration(hours: 24))
        .toUtc()
        .millisecondsSinceEpoch;
    final ts = now.toUtc().millisecondsSinceEpoch;

    return (update(followPlans)..where(
          (t) =>
              t.status.isIn([
                PlanStatus.pending.dbValue,
                PlanStatus.notified.dbValue,
              ]) &
              t.planAt.isSmallerThanValue(cutoff),
        ))
        .write(
          FollowPlansCompanion(
            status: Value(PlanStatus.overdue.dbValue),
            updatedAt: Value(ts),
          ),
        );
  }

  Future<int> updateManualPlan(
    int id, {
    required int opportunityId,
    required String reason,
    required String talkingDirection,
    required String nextAction,
    required String owner,
    required DateTime planAt,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(followPlans)..where(
          (t) =>
              t.id.equals(id) &
              t.sourceType.equals(TaskSourceType.manual.dbValue) &
              t.status.isIn(_openStatusValues),
        ))
        .write(
          FollowPlansCompanion(
            opportunityId: Value(opportunityId),
            title: Value(nextAction),
            reason: Value(reason),
            talkingDirection: Value(talkingDirection),
            nextAction: Value(nextAction),
            owner: Value(owner),
            planAt: Value(planAt.toUtc().millisecondsSinceEpoch),
            status: Value(PlanStatus.pending.dbValue),
            notifiedAt: const Value(null),
            updatedAt: Value(ts),
          ),
        );
  }

  Future<int> updatePlan(
    int id, {
    String? title,
    DateTime? planAt,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(followPlans)..where((t) => t.id.equals(id))).write(
      FollowPlansCompanion(
        title: title == null ? const Value.absent() : Value(title),
        planAt: planAt == null
            ? const Value.absent()
            : Value(planAt.toUtc().millisecondsSinceEpoch),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> deletePlan(int id) =>
      (delete(followPlans)..where((t) => t.id.equals(id))).go();

  Future<void> enqueueTaskReconciliation(
    int opportunityId, {
    required Object error,
    DateTime? now,
  }) async {
    final existing =
        await (select(taskReconciliationJobs)
              ..where((row) => row.opportunityId.equals(opportunityId)))
            .getSingleOrNull();
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final message = error.toString();
    final safeMessage = message.length <= 500
        ? message
        : message.substring(0, 500);
    await into(taskReconciliationJobs).insertOnConflictUpdate(
      TaskReconciliationJobsCompanion.insert(
        opportunityId: Value(opportunityId),
        attemptCount: Value((existing?.attemptCount ?? 0) + 1),
        lastError: Value(safeMessage),
        updatedAt: ts,
      ),
    );
  }

  Future<int> clearTaskReconciliation(int opportunityId) => (delete(
    taskReconciliationJobs,
  )..where((row) => row.opportunityId.equals(opportunityId))).go();

  Future<List<TaskReconciliationJobRow>> listTaskReconciliationJobs() =>
      (select(taskReconciliationJobs)..orderBy([
            (row) => OrderingTerm.asc(row.updatedAt),
            (row) => OrderingTerm.asc(row.opportunityId),
          ]))
          .get();

  Future<int> countTaskReconciliationJobs() async {
    final count = taskReconciliationJobs.opportunityId.count();
    final row = await (selectOnly(
      taskReconciliationJobs,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }
}
