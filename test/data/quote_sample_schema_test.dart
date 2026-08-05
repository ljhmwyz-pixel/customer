import 'package:customer/data/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('quote version identity and amount constraints are enforced', () async {
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '报价项目',
    );
    final ts = DateTime(2026, 8, 5).millisecondsSinceEpoch;
    final quote = QuotesCompanion.insert(
      opportunityId: opportunityId,
      quoteNo: 'Q-1',
      version: 1,
      quantity: 10,
      quotedAt: ts,
      createdAt: ts,
      updatedAt: ts,
    );
    await db.into(db.quotes).insert(quote);
    await expectLater(db.into(db.quotes).insert(quote), throwsA(anything));
    await expectLater(
      db
          .into(db.quotes)
          .insert(
            QuotesCompanion.insert(
              opportunityId: opportunityId,
              quoteNo: 'Q-2',
              version: 1,
              quantity: -1,
              quotedAt: ts,
              createdAt: ts,
              updatedAt: ts,
            ),
          ),
      throwsA(anything),
    );
  });

  test('sample status and quantity constraints are enforced', () async {
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '样品项目',
    );
    final ts = DateTime(2026, 8, 5).millisecondsSinceEpoch;
    await db
        .into(db.samples)
        .insert(
          SamplesCompanion.insert(
            opportunityId: opportunityId,
            quantity: 1,
            createdAt: ts,
            updatedAt: ts,
          ),
        );
    await expectLater(
      db
          .into(db.samples)
          .insert(
            SamplesCompanion.insert(
              opportunityId: opportunityId,
              quantity: 1,
              status: const Value('unknown'),
              createdAt: ts,
              updatedAt: ts,
            ),
          ),
      throwsA(anything),
    );
  });
}
