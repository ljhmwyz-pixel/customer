import 'package:customer/data/database.dart';
import 'package:customer/data/daos/customer_dao.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('dashboardMetrics aggregates supported SPRD metrics', () async {
    final now = DateTime(2026, 8, 5, 12);
    final a = await db.customerDao.insertCustomer(
      name: 'A 客户',
      grade: CustomerGrade.a,
      now: now,
    );
    final b = await db.customerDao.insertCustomer(
      name: 'B 客户',
      grade: CustomerGrade.b,
      now: now,
    );
    final opportunity = await db.opportunityDao.insertOpportunity(
      customerId: a,
      name: '未来项目',
      forecastAmountMinor: 120000,
      probabilityPercent: 50,
      expectedCloseAt: now.add(const Duration(days: 30)),
      now: now,
    );
    await db.opportunityDao.insertOpportunity(
      customerId: b,
      name: '已暂停',
      forecastAmountMinor: 999999,
      probabilityPercent: 100,
      status: OpportunityStatus.paused,
      now: now,
    );
    await db.followupDao.insertAndTouchCustomer(
      customerId: a,
      opportunityId: opportunity,
      occurredAt: now,
      method: FollowMethod.phone,
      content: '本周跟进',
      now: now,
    );
    final completedOrderId = await db.orderDao.insertOrder(
      customerId: a,
      opportunityId: opportunity,
      orderNo: 'D-1',
      orderedAt: now,
      amountCents: 88000,
      orderResult: OrderResult.completed,
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: a,
      opportunityId: opportunity,
      orderNo: 'D-PAID',
      orderedAt: now,
      amountCents: 77000,
      paymentStatus: PaymentStatus.paid,
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: a,
      opportunityId: opportunity,
      orderNo: 'D-SHIPPED',
      orderedAt: now,
      amountCents: 66000,
      shippingStatus: ShippingStatus.shipped,
      now: now,
    );
    expect(
      (await db.orderDao.findById(completedOrderId))?.status,
      OrderStatus.completed.dbValue,
    );

    final metrics = await db.customerDao.dashboardMetrics(now: now);
    expect(metrics.totalCustomers, 2);
    expect(metrics.customerCountsByGrade[CustomerGrade.a], 1);
    expect(metrics.projectCountsByStage[OpportunityStage.newLead], 1);
    expect(metrics.followupsThisWeek, 1);
    expect(metrics.forecastAmountMinor, 120000);
    expect(metrics.weightedForecastAmountMinor, 60000);
    expect(metrics.wonAmountMinor, 88000);
    expect(metrics.stalledQuoteCount, isNull);
  });

  test(
    'dashboardAnomalies reports long silence and internal support',
    () async {
      final now = DateTime(2026, 8, 5, 12);
      final stale = await db.customerDao.insertCustomer(
        name: '长期沉默',
        grade: CustomerGrade.a,
        now: now.subtract(const Duration(days: 30)),
      );
      final active = await db.customerDao.insertCustomer(
        name: '需要支持',
        now: now,
      );
      await db.opportunityDao.insertOpportunity(
        customerId: active,
        name: '支持项目',
        currentObstacle: '需要内部确认授权文件',
        now: now,
      );

      final anomalies = await db.customerDao.dashboardAnomalies(now: now);
      expect(anomalies.map((item) => item.customerId), contains(stale));
      expect(
        anomalies.any(
          (item) => item.kind == DashboardAnomalyKind.internalSupport,
        ),
        isTrue,
      );
    },
  );

  test(
    'dashboardAnomalies reports only due open registration tender and repurchase tasks',
    () async {
      final now = DateTime(2026, 8, 5, 12);
      final customerId = await db.customerDao.insertCustomer(
        name: '业务任务客户',
        now: now,
      );
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '海外项目',
        now: now,
      );
      final sameDueAt = now.subtract(const Duration(hours: 3));
      await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.registration,
        title: '注册标题',
        nextAction: '补齐注册资料',
        planAt: sameDueAt,
        now: now,
      );
      final tenderId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.tender,
        title: '招标标题',
        nextAction: '确认投标文件',
        planAt: sameDueAt,
        now: now,
      );
      await db.planDao.markNotified(tenderId, at: now);
      final repurchaseId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        title: '联系客户确认复购',
        planAt: now.subtract(const Duration(hours: 1)),
        now: now,
      );
      await (db.update(
        db.followPlans,
      )..where((table) => table.id.equals(repurchaseId))).write(
        FollowPlansCompanion(
          nextAction: const Value(null),
          status: Value(PlanStatus.overdue.dbValue),
        ),
      );

      final completedId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.registration,
        title: '已完成注册',
        planAt: now.subtract(const Duration(days: 1)),
        now: now,
      );
      await db.planDao.markCompleted(completedId, at: now);
      final cancelledId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.tender,
        title: '已取消招标',
        planAt: now.subtract(const Duration(days: 1)),
        now: now,
      );
      await db.planDao.markCancelled(cancelledId, at: now);
      await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.repurchase,
        title: '未来复购',
        planAt: now.add(const Duration(days: 1)),
        now: now,
      );
      await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        sourceType: TaskSourceType.manual,
        title: '手工到期任务',
        planAt: now.subtract(const Duration(hours: 2)),
        now: now,
      );

      final anomalies = await db.customerDao.dashboardAnomalies(now: now);
      final businessAnomalies = anomalies
          .where(
            (item) => {
              DashboardAnomalyKind.registrationDue,
              DashboardAnomalyKind.tenderImminent,
              DashboardAnomalyKind.repurchaseDue,
            }.contains(item.kind),
          )
          .toList();

      expect(businessAnomalies.map((item) => item.kind), [
        DashboardAnomalyKind.registrationDue,
        DashboardAnomalyKind.tenderImminent,
        DashboardAnomalyKind.repurchaseDue,
      ]);
      expect(
        businessAnomalies.map((item) => item.customerId),
        everyElement(customerId),
      );
      expect(
        businessAnomalies.map((item) => item.opportunityId),
        everyElement(opportunityId),
      );
      expect(
        businessAnomalies.map((item) => item.opportunityName),
        everyElement('海外项目'),
      );
      expect(businessAnomalies.map((item) => item.detail), [
        '补齐注册资料',
        '确认投标文件',
        '联系客户确认复购',
      ]);
    },
  );
}
