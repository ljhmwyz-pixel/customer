import 'package:customer/features/business/business_providers.dart';
import 'package:customer/data/database.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  late AppDatabase db;
  late BusinessService service;
  setUp(() async {
    db = await openTestDb();
    service = BusinessService(db);
  });
  tearDown(() async => db.close());

  test('quote and sample service validates ownership and dates', () async {
    final customerId = await seedCustomer(db);
    final opportunityId = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '业务项目',
    );
    final quoteId = await service.createQuoteVersion(
      customerId: customerId,
      opportunityId: opportunityId,
      quoteNo: 'Q-1',
      quantity: 1,
      quotedAt: DateTime(2026, 8, 1),
      validUntil: DateTime(2026, 8, 10),
    );
    expect(quoteId, isPositive);
    await expectLater(
      service.createSample(
        customerId: customerId,
        opportunityId: opportunityId,
        quantity: 1,
        sentAt: DateTime(2026, 8, 10),
        deliveredAt: DateTime(2026, 8, 9),
      ),
      throwsA(isA<CustomerValidationException>()),
    );
    await expectLater(
      service.createQuoteVersion(
        customerId: 999,
        opportunityId: opportunityId,
        quoteNo: 'Q-2',
        quantity: 1,
        quotedAt: DateTime(2026, 8, 1),
      ),
      throwsA(isA<CustomerValidationException>()),
    );
  });
}
