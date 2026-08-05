import 'package:customer/data/database.dart';
import 'package:customer/features/opportunities/opportunity_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

void main() {
  late AppDatabase db;
  late OpportunityService service;

  setUp(() async {
    db = await openTestDb();
    service = OpportunityService(db);
  });
  tearDown(() => db.close());

  test('创建和更新时规范名称与币种', () async {
    final customerId = await seedCustomer(db);
    final id = await service.createOpportunity(
      customerId,
      const OpportunityDraft(
        name: '  CT 注射器  ',
        currency: ' usd ',
        probabilityPercent: 40,
      ),
    );
    expect((await db.opportunityDao.findById(id))?.name, 'CT 注射器');
    expect((await db.opportunityDao.findById(id))?.currency, 'USD');

    await service.updateOpportunity(
      customerId,
      id,
      const OpportunityDraft(
        name: '连接管',
        currency: 'eur',
        stage: OpportunityStage.quoted,
      ),
    );
    final updated = await db.opportunityDao.findById(id);
    expect(updated?.name, '连接管');
    expect(updated?.currency, 'EUR');
    expect(updated?.stage, OpportunityStage.quoted.dbValue);
  });

  test('拒绝空名称、负数、非法币种和越界概率', () async {
    final customerId = await seedCustomer(db);
    for (final draft in [
      const OpportunityDraft(name: '  '),
      const OpportunityDraft(name: '项目', forecastAmountMinor: -1),
      const OpportunityDraft(name: '项目', currency: 'US'),
      const OpportunityDraft(name: '项目', probabilityPercent: 101),
    ]) {
      expect(
        () => service.createOpportunity(customerId, draft),
        throwsA(isA<OpportunityValidationException>()),
      );
    }
  });

  test('拒绝跨客户编辑和删除有关联记录的项目', () async {
    final first = await seedCustomer(db, name: '客户一');
    final second = await seedCustomer(db, name: '客户二');
    final id = await service.createOpportunity(
      first,
      const OpportunityDraft(name: '项目'),
    );
    expect(
      () => service.updateOpportunity(
        second,
        id,
        const OpportunityDraft(name: '越权'),
      ),
      throwsA(isA<OpportunityValidationException>()),
    );
    await db.orderDao.insertOrder(
      customerId: first,
      opportunityId: id,
      orderNo: 'SO-1',
      orderedAt: DateTime.utc(2026, 8, 5),
      amountCents: 100,
    );
    expect(
      () => service.deleteOpportunity(first, id),
      throwsA(isA<OpportunityValidationException>()),
    );
  });
}
