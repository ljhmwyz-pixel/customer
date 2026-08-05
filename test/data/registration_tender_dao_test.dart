import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('registration DAO normalizes data and isolates opportunities', () async {
    final customerId = await seedCustomer(db);
    final firstOpportunity = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '注册项目 A',
    );
    final secondOpportunity = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '注册项目 B',
    );
    final changes = <List<RegistrationRow>>[];
    final subscription = db.registrationDao
        .watchOf(firstOpportunity)
        .listen(changes.add);

    final id = await db.registrationDao.insertRegistration(
      opportunityId: firstOpportunity,
      country: '  越南  ',
      requirements: '  认证资料  ',
      submittedAt: DateTime.parse('2026-08-01T10:00:00+08:00'),
      expectedCompletedAt: DateTime.parse('2026-08-20T18:00:00+08:00'),
      now: DateTime.utc(2026, 8, 1),
    );
    await db.registrationDao.insertRegistration(
      opportunityId: secondOpportunity,
      country: '泰国',
      now: DateTime.utc(2026, 8, 2),
    );
    await Future<void>.delayed(Duration.zero);

    final row = await db.registrationDao.findById(id);
    expect(row!.country, '越南');
    expect(row.requirements, '认证资料');
    expect(row.submittedAt, DateTime.utc(2026, 8, 1, 2).millisecondsSinceEpoch);
    expect(
      (await db.registrationDao.listOf(firstOpportunity)).map((e) => e.id),
      [id],
    );
    expect(changes.last.map((e) => e.id), [id]);

    await db.registrationDao.updateRegistration(
      id,
      country: const Value('  马来西亚  '),
      status: RegistrationStatus.inProgress,
      nextAction: const Value('  补资料  '),
      now: DateTime.utc(2026, 8, 3),
    );
    final updated = await db.registrationDao.findById(id);
    expect(updated!.country, '马来西亚');
    expect(updated.status, RegistrationStatus.inProgress.dbValue);
    expect(updated.nextAction, '补资料');
    await subscription.cancel();
  });

  test(
    'registration due query uses all due fields and excludes terminal rows',
    () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '注册提醒项目',
      );
      final expectedId = await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        country: '预计完成',
        expectedCompletedAt: DateTime.utc(2026, 8, 12),
      );
      final documentId = await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        country: '资料待补',
        documentDueAt: DateTime.utc(2026, 8, 11),
      );
      final milestoneId = await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        country: '关键节点',
        milestoneAt: DateTime.utc(2026, 8, 13),
      );
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        country: '已完成',
        expectedCompletedAt: DateTime.utc(2026, 8, 10),
        status: RegistrationStatus.completed,
      );
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        country: '已取消',
        documentDueAt: DateTime.utc(2026, 8, 10),
        status: RegistrationStatus.cancelled,
      );

      final due = await db.registrationDao.listDue(
        from: DateTime.utc(2026, 8, 10),
        to: DateTime.utc(2026, 8, 14),
      );
      expect(due.map((e) => e.id), [documentId, expectedId, milestoneId]);
    },
  );

  test(
    'tender DAO normalizes data, watches updates and filters open deadlines',
    () async {
      final customerId = await seedCustomer(db);
      final firstOpportunity = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '招标项目 A',
      );
      final secondOpportunity = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '招标项目 B',
      );
      final changes = <List<TenderRow>>[];
      final subscription = db.tenderDao
          .watchOf(firstOpportunity)
          .listen(changes.add);

      final laterId = await db.tenderDao.insertTender(
        opportunityId: firstOpportunity,
        projectNo: '  T-002  ',
        name: '  二号标  ',
        deadlineAt: DateTime.parse('2026-08-20T18:00:00+08:00'),
        status: TenderStatus.open,
        now: DateTime.utc(2026, 8, 1),
      );
      final earlierId = await db.tenderDao.insertTender(
        opportunityId: firstOpportunity,
        projectNo: 'T-001',
        name: '一号标',
        deadlineAt: DateTime.utc(2026, 8, 15),
        status: TenderStatus.open,
        now: DateTime.utc(2026, 8, 2),
      );
      await db.tenderDao.insertTender(
        opportunityId: firstOpportunity,
        projectNo: 'T-CLOSED',
        deadlineAt: DateTime.utc(2026, 8, 14),
        status: TenderStatus.closed,
      );
      final otherOpportunityId = await db.tenderDao.insertTender(
        opportunityId: secondOpportunity,
        projectNo: 'T-OTHER',
        deadlineAt: DateTime.utc(2026, 8, 16),
        status: TenderStatus.open,
      );
      await Future<void>.delayed(Duration.zero);

      final row = await db.tenderDao.findById(laterId);
      expect(row!.projectNo, 'T-002');
      expect(row.name, '二号标');
      expect(
        row.deadlineAt,
        DateTime.utc(2026, 8, 20, 10).millisecondsSinceEpoch,
      );
      expect((await db.tenderDao.listOf(firstOpportunity)).map((e) => e.id), [
        earlierId,
        laterId,
      ]);
      expect(changes.last.map((e) => e.id), [earlierId, laterId]);

      await db.tenderDao.updateTender(
        laterId,
        name: const Value('  二号标更新  '),
        nextAction: const Value('  准备保证金  '),
        riskLevel: TenderRiskLevel.high,
        now: DateTime.utc(2026, 8, 3),
      );
      final updated = await db.tenderDao.findById(laterId);
      expect(updated!.name, '二号标更新');
      expect(updated.nextAction, '准备保证金');
      expect(updated.riskLevel, TenderRiskLevel.high.dbValue);

      final deadlines = await db.tenderDao.listOpenDeadlines(
        from: DateTime.utc(2026, 8, 14),
        to: DateTime.utc(2026, 8, 21),
      );
      expect(deadlines.map((e) => e.id), [
        earlierId,
        otherOpportunityId,
        laterId,
      ]);
      await subscription.cancel();
    },
  );
}
