import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('同一客户可创建多个项目并按更新时间倒序读取', () async {
    final customerId = await seedCustomer(db);
    final older = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '注射器项目',
      stage: OpportunityStage.needsConfirmed,
      now: DateTime.utc(2026, 8, 1),
    );
    final newer = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '连接管项目',
      productCategory: '连接管及配件',
      stage: OpportunityStage.quoted,
      forecastAmountMinor: 500000,
      probabilityPercent: 40,
      now: DateTime.utc(2026, 8, 2),
    );

    final values = await db.opportunityDao.listOfCustomer(customerId);
    expect(values.map((value) => value.id), [newer, older]);
    expect(values.first.productCategory, '连接管及配件');
    expect(values.first.forecastAmountMinor, 500000);
    expect(values.first.probabilityPercent, 40);
    expect(await db.opportunityDao.countAll(), 2);
  });

  test('每个客户只能有一个兼容默认项目', () async {
    final customerId = await seedCustomer(db);
    final id = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '历史项目',
      isLegacyDefault: true,
    );

    final value = await db.opportunityDao.findLegacyDefaultOfCustomer(
      customerId,
    );
    expect(value?.id, id);

    expect(
      () => db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '重复默认项目',
        isLegacyDefault: true,
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('删除客户级联删除项目', () async {
    final customerId = await seedCustomer(db);
    await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '待删除项目',
    );

    await db.customerDao.deleteCustomer(customerId);
    expect(await db.opportunityDao.countAll(), 0);
  });

  test('可更新项目并检测关联业务记录', () async {
    final customerId = await seedCustomer(db);
    final id = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '旧项目名',
    );

    await db.opportunityDao.updateOpportunity(
      id,
      name: '新项目名',
      currency: 'EUR',
      stage: OpportunityStage.quoted,
      status: OpportunityStatus.active,
      probabilityPercent: const Value(60),
      now: DateTime.utc(2026, 8, 5),
    );
    final updated = await db.opportunityDao.findById(id);
    expect(updated?.name, '新项目名');
    expect(updated?.currency, 'EUR');
    expect(updated?.stage, OpportunityStage.quoted.dbValue);
    expect(updated?.probabilityPercent, 60);
    expect(await db.opportunityDao.hasLinkedBusinessRecords(id), isFalse);

    await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: id,
      method: FollowMethod.other,
      content: '已发送报价',
      occurredAt: DateTime.utc(2026, 8, 5),
    );
    expect(await db.opportunityDao.hasLinkedBusinessRecords(id), isTrue);
  });
}
