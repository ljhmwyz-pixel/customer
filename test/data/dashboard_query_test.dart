import 'package:customer/data/database.dart';
import 'package:customer/data/daos/customer_dao.dart';
import 'package:customer/models/enums.dart';
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
}
