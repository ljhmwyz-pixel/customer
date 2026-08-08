import 'package:customer/data/database.dart';
import 'package:customer/features/opportunities/opportunity_providers.dart';
import 'package:customer/features/opportunities/supplier_substitution.dart';
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

  test('项目编辑只记录真正变化的关键字段', () async {
    final customerId = await seedCustomer(db);
    final id = await service.createOpportunity(
      customerId,
      const OpportunityDraft(
        name: '审计项目',
        owner: '甲',
        currency: 'USD',
        forecastAmountMinor: 10000,
        probabilityPercent: 20,
      ),
    );

    const changed = OpportunityDraft(
      name: '审计项目',
      owner: '乙',
      currency: 'EUR',
      forecastAmountMinor: 25000,
      probabilityPercent: 60,
      stage: OpportunityStage.quoted,
      nextAction: '确认报价反馈',
    );
    await service.updateOpportunity(customerId, id, changed);

    final rows = await db.opportunityChangeDao.listOfOpportunity(id);
    expect(rows.map((row) => row.fieldKey).toSet(), {
      'owner',
      'currency',
      'forecastAmountMinor',
      'probabilityPercent',
      'stage',
      'nextAction',
    });
    expect(rows.firstWhere((row) => row.fieldKey == 'owner').oldValue, '甲');
    expect(rows.firstWhere((row) => row.fieldKey == 'owner').newValue, '乙');

    await service.updateOpportunity(customerId, id, changed);
    expect(await db.opportunityChangeDao.listOfOpportunity(id), hasLength(6));
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

  test('供应商替代字段创建时只接受固定选项或空值', () async {
    final customerId = await seedCustomer(db);
    final id = await service.createOpportunity(
      customerId,
      OpportunityDraft(
        name: '标准替代项目',
        supplierProblem: supplierProblemOptions.first,
        changeWillingness: changeWillingnessOptions.first,
        substitutionDifficulty: substitutionDifficultyOptions.first,
        entryPoint: entryPointOptions.first,
        investmentAdvice: investmentAdviceOptions.first,
      ),
    );
    final created = await db.opportunityDao.findById(id);
    expect(created?.supplierProblem, supplierProblemOptions.first);
    expect(created?.entryPoint, entryPointOptions.first);

    await expectLater(
      service.createOpportunity(
        customerId,
        const OpportunityDraft(name: '非法替代项目', supplierProblem: '随便填写'),
      ),
      throwsA(
        isA<OpportunityValidationException>().having(
          (error) => error.message,
          'message',
          contains('供应商问题'),
        ),
      ),
    );
  });

  test('更新时可保留历史自由文本，但不能改成另一个自由文本', () async {
    final customerId = await seedCustomer(db);
    final id = await db.opportunityDao.insertOpportunity(
      customerId: customerId,
      name: '历史项目',
      supplierProblem: '旧系统问题描述',
      entryPoint: '旧系统切入方式',
    );

    await service.updateOpportunity(
      customerId,
      id,
      const OpportunityDraft(
        name: '历史项目',
        supplierProblem: '旧系统问题描述',
        entryPoint: '旧系统切入方式',
      ),
    );
    final preserved = await db.opportunityDao.findById(id);
    expect(preserved?.supplierProblem, '旧系统问题描述');
    expect(preserved?.entryPoint, '旧系统切入方式');

    await expectLater(
      service.updateOpportunity(
        customerId,
        id,
        const OpportunityDraft(
          name: '历史项目',
          supplierProblem: '另一个自由文本',
          entryPoint: '旧系统切入方式',
        ),
      ),
      throwsA(
        isA<OpportunityValidationException>().having(
          (error) => error.message,
          'message',
          contains('供应商问题'),
        ),
      ),
    );
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

  test('报价、样品、注册或招标任一存在时均拒绝删除项目', () async {
    final customerId = await seedCustomer(db);
    final seedLinkedRecord = <Future<void> Function(int)>[
      (opportunityId) async {
        await db.quoteDao.insertVersion(
          opportunityId: opportunityId,
          quoteNo: 'GUARD-Q-$opportunityId',
          quantity: 1,
          quotedAt: DateTime.utc(2026, 8, 6),
        );
      },
      (opportunityId) async {
        await db.sampleDao.insertSample(
          opportunityId: opportunityId,
          quantity: 1,
        );
      },
      (opportunityId) async {
        await db.registrationDao.insertRegistration(
          opportunityId: opportunityId,
        );
      },
      (opportunityId) async {
        await db.tenderDao.insertTender(opportunityId: opportunityId);
      },
    ];

    for (var index = 0; index < seedLinkedRecord.length; index++) {
      final opportunityId = await service.createOpportunity(
        customerId,
        OpportunityDraft(name: '守卫项目 $index'),
      );
      await seedLinkedRecord[index](opportunityId);

      await expectLater(
        service.deleteOpportunity(customerId, opportunityId),
        throwsA(isA<OpportunityValidationException>()),
      );
      expect(await db.opportunityDao.findById(opportunityId), isNotNull);
    }
  });
}
