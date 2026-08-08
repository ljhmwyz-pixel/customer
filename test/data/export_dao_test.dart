import 'package:customer/data/daos/export_dao.dart';
import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 8, 6, 9);

  setUp(() => db = AppDatabase.memory());
  tearDown(() async => db.close());

  test('导出快照完整联结四个工作区并保持确定顺序', () async {
    final customerId = await db.customerDao.insertCustomer(
      name: '上海医械',
      company: '上海医械有限公司',
      country: '中国',
      stage: CustomerStage.intent,
      grade: CustomerGrade.a,
      now: now,
    );
    await db.customerDao.insertCustomer(name: '无项目客户', now: now);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: 'CT 双筒项目',
      productCategory: '高压注射器耗材',
      forecastAmountMinor: 123456,
      currency: 'USD',
      probabilityPercent: 60,
      stage: OpportunityStage.quoted,
      nextAction: '确认报价反馈',
      now: now,
    );
    final contactId = await db.contactDao.insertContact(
      customerId: customerId,
      name: '李经理',
      now: now,
    );
    await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: opportunityId,
      contactId: contactId,
      contactNameSnapshot: '李经理',
      occurredAt: now.subtract(const Duration(days: 1)),
      method: FollowMethod.wechat,
      content: '已发送报价',
      feedback: '等待采购确认',
      stage: OpportunityStage.quoted,
      nextAction: '周五再次联系',
      now: now,
    );
    await db.contactDao.deleteContact(contactId);
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      reason: '报价跟进',
      nextAction: '确认报价反馈',
      planAt: now.subtract(const Duration(hours: 1)),
      now: now,
    );
    await db.planDao.insertPlan(
      customerId: customerId,
      opportunityId: opportunityId,
      nextAction: '未来任务不应导出到今日表',
      planAt: now.add(const Duration(days: 2)),
      now: now,
    );
    await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-2026-001',
      quantity: 100,
      currency: 'USD',
      totalAmountMinor: 123456,
      quotedAt: now,
      now: now,
    );
    await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      sampleModel: 'CT-200',
      quantity: 2,
      status: SampleStatus.testing,
      now: now,
    );
    await db.registrationDao.insertRegistration(
      opportunityId: opportunityId,
      country: '中国',
      status: RegistrationStatus.inProgress,
      now: now,
    );
    await db.tenderDao.insertTender(
      opportunityId: opportunityId,
      projectNo: 'T-001',
      status: TenderStatus.open,
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: customerId,
      opportunityId: opportunityId,
      orderNo: 'O-001',
      orderedAt: now,
      amountCents: 88800,
      currency: 'USD',
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: customerId,
      orderNo: 'O-LEGACY',
      orderedAt: now.add(const Duration(minutes: 1)),
      amountCents: 100,
      now: now,
    );

    final snapshot = await db.exportDao.loadExcelSnapshot(now: now);

    expect(snapshot.todayTasks, hasLength(1));
    expect(snapshot.todayTasks.single.customerName, '上海医械');
    expect(snapshot.todayTasks.single.opportunityName, 'CT 双筒项目');
    expect(snapshot.todayTasks.single.statusLabel, '待提醒');

    expect(snapshot.customerProjects, hasLength(2));
    expect(snapshot.customerProjects.first.customerName, '上海医械');
    expect(snapshot.customerProjects.first.customerStageLabel, '意向明确');
    expect(snapshot.customerProjects.first.opportunityStageLabel, '已报价');
    expect(snapshot.customerProjects.first.forecastAmountMinor, 123456);
    expect(snapshot.customerProjects.last.customerName, '无项目客户');
    expect(snapshot.customerProjects.last.opportunityId, isNull);

    expect(snapshot.followups, hasLength(1));
    expect(snapshot.followups.single.methodLabel, '微信');
    expect(snapshot.followups.single.feedback, '等待采购确认');
    expect(snapshot.followups.single.contactName, '李经理');

    expect(snapshot.businessEvents, hasLength(6));
    expect(
      snapshot.businessEvents.take(5).map((row) => row.type),
      BusinessExportType.values,
    );
    expect(snapshot.businessEvents.first.reference, 'Q-2026-001 v1');
    expect(snapshot.businessEvents.first.amountMinor, 123456);
    expect(snapshot.businessEvents[4].reference, 'O-001');
    expect(snapshot.businessEvents[4].amountMinor, 88800);
    expect(snapshot.businessEvents.last.reference, 'O-LEGACY');
    expect(snapshot.businessEvents.last.opportunityName, '未关联项目');
  });

  test('空库产生四个空列表', () async {
    final snapshot = await db.exportDao.loadExcelSnapshot(now: now);
    expect(snapshot.todayTasks, isEmpty);
    expect(snapshot.customerProjects, isEmpty);
    expect(snapshot.followups, isEmpty);
    expect(snapshot.businessEvents, isEmpty);
  });
}
