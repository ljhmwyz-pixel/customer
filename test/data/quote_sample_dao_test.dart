import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('quote DAO creates immutable versions and returns latest', () async {
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '报价项目',
    );
    final first = await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-1',
      quantity: 10,
      quotedAt: DateTime(2026, 8, 1),
    );
    final second = await db.quoteDao.insertVersion(
      opportunityId: opportunityId,
      quoteNo: 'Q-1',
      quantity: 12,
      quotedAt: DateTime(2026, 8, 2),
    );
    expect(first, isNot(second));
    expect(
      (await db.quoteDao.listVersions(opportunityId)).map((e) => e.version),
      [2, 1],
    );
    expect((await db.quoteDao.latest(opportunityId))!.id, second);
  });

  test('sample DAO preserves timeline and updates milestones', () async {
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '样品项目',
    );
    final id = await db.sampleDao.insertSample(
      opportunityId: opportunityId,
      quantity: 2,
      sentAt: DateTime(2026, 8, 1),
    );
    await db.sampleDao.updateMilestone(
      id,
      deliveredAt: Value(DateTime(2026, 8, 3)),
      status: SampleStatus.delivered,
    );
    final row = await db.sampleDao.findById(id);
    expect(row!.deliveredAt, DateTime(2026, 8, 3).millisecondsSinceEpoch);
    expect(row.status, SampleStatus.delivered.dbValue);
  });
}
