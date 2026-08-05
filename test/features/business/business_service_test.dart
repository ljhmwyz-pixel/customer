import 'package:customer/features/business/business_providers.dart';
import 'package:customer/data/database.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart' show Value;
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

  test(
    'registration service normalizes input and validates ownership, state and dates',
    () async {
      final customerId = await seedCustomer(db);
      final otherCustomerId = await seedCustomer(
        db,
        name: '其他客户',
        phone: '13900000000',
      );
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '注册项目',
      );
      final closedOpportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '关闭项目',
        status: OpportunityStatus.closed,
      );

      final id = await service.createRegistration(
        customerId: customerId,
        opportunityId: opportunityId,
        country: '  越南  ',
        requirements: '  资料要求  ',
        submittedAt: DateTime.utc(2026, 8, 1),
        expectedCompletedAt: DateTime.utc(2026, 8, 10),
      );
      expect((await db.registrationDao.findById(id))!.country, '越南');
      await expectLater(
        service.createRegistration(
          customerId: otherCustomerId,
          opportunityId: opportunityId,
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      await expectLater(
        service.createRegistration(
          customerId: customerId,
          opportunityId: closedOpportunityId,
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      await expectLater(
        service.createRegistration(
          customerId: customerId,
          opportunityId: opportunityId,
          submittedAt: DateTime.utc(2026, 8, 10),
          expectedCompletedAt: DateTime.utc(2026, 8, 9),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      await expectLater(
        service.createRegistration(
          customerId: customerId,
          opportunityId: opportunityId,
          submittedAt: DateTime.utc(2026, 8, 10),
          actualCompletedAt: DateTime.utc(2026, 8, 9),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      await expectLater(
        service.createRegistration(
          customerId: customerId,
          opportunityId: opportunityId,
          status: RegistrationStatus.blocked,
          nextAction: '   ',
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      await expectLater(
        service.updateRegistration(
          customerId,
          id,
          submittedAt: Value(DateTime.utc(2026, 8, 20)),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
    },
  );

  test(
    'tender service applies risk defaults and qualification controls',
    () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '招标项目',
      );
      final firstId = await service.createTender(
        customerId: customerId,
        opportunityId: opportunityId,
        projectNo: ' T-1 ',
        name: ' 第一标 ',
      );
      final secondId = await service.createTender(
        customerId: customerId,
        opportunityId: opportunityId,
        projectNo: 'T-2',
      );
      expect(
        (await db.tenderDao.findById(firstId))!.riskLevel,
        TenderRiskLevel.mediumHigh.dbValue,
      );
      expect(
        (await db.tenderDao.findById(secondId))!.riskLevel,
        TenderRiskLevel.low.dbValue,
      );
      expect((await db.tenderDao.findById(firstId))!.name, '第一标');

      await expectLater(
        service.createTender(
          customerId: customerId,
          opportunityId: opportunityId,
          documentStatus: TenderDocumentStatus.incomplete,
          qualificationStatus: TenderQualificationStatus.qualified,
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      await expectLater(
        service.createTender(
          customerId: customerId,
          opportunityId: opportunityId,
          documentStatus: TenderDocumentStatus.complete,
          qualificationStatus: TenderQualificationStatus.qualified,
          bidder: '投标主体',
          depositMinor: 100,
          localTeamStatus: TenderVerificationStatus.confirmed,
          fundingStatus: TenderVerificationStatus.confirmed,
          authorizationType: TenderAuthorizationType.regional,
        ),
        throwsA(isA<CustomerValidationException>()),
      );
    },
  );

  test(
    'tender authorization and floor-price support require complete evidence and risk acknowledgement',
    () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '授权项目',
      );

      Future<int> createReadyTender({
        TenderRiskLevel riskLevel = TenderRiskLevel.low,
        bool riskAcknowledged = false,
        String? bidder = '投标主体',
        int? depositMinor = 100,
        TenderVerificationStatus localTeamStatus =
            TenderVerificationStatus.confirmed,
        TenderVerificationStatus fundingStatus =
            TenderVerificationStatus.confirmed,
        TenderAuthorizationType authorizationType =
            TenderAuthorizationType.none,
        DateTime? authorizationExpiresAt,
        String? floorPriceSupport,
      }) => service.createTender(
        customerId: customerId,
        opportunityId: opportunityId,
        documentStatus: TenderDocumentStatus.complete,
        qualificationStatus: TenderQualificationStatus.qualified,
        bidder: bidder,
        depositMinor: depositMinor,
        localTeamStatus: localTeamStatus,
        fundingStatus: fundingStatus,
        riskLevel: riskLevel,
        riskAcknowledged: riskAcknowledged,
        authorizationType: authorizationType,
        authorizationExpiresAt: authorizationExpiresAt,
        floorPriceSupport: floorPriceSupport,
      );

      for (final invalid in <Future<int>>[
        createReadyTender(bidder: ' ', floorPriceSupport: '支持'),
        createReadyTender(depositMinor: null, floorPriceSupport: '支持'),
        createReadyTender(
          localTeamStatus: TenderVerificationStatus.pending,
          floorPriceSupport: '支持',
        ),
        createReadyTender(
          fundingStatus: TenderVerificationStatus.pending,
          floorPriceSupport: '支持',
        ),
        createReadyTender(
          authorizationType: TenderAuthorizationType.regional,
          authorizationExpiresAt: DateTime.utc(2026, 9, 1),
          riskLevel: TenderRiskLevel.high,
        ),
      ]) {
        await expectLater(invalid, throwsA(isA<CustomerValidationException>()));
      }
      final authorizedId = await createReadyTender(
        authorizationType: TenderAuthorizationType.regional,
        authorizationExpiresAt: DateTime.utc(2026, 9, 1),
        riskLevel: TenderRiskLevel.high,
        riskAcknowledged: true,
      );
      expect(authorizedId, isPositive);

      await expectLater(
        service.updateTender(
          customerId,
          authorizedId,
          bidder: const Value('   '),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
    },
  );
}
