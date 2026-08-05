import 'package:customer/data/database.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

const _defaultNextFollowAt = Object();

Future<int> _seedOpportunity(
  AppDatabase db,
  int customerId, {
  required String name,
  OpportunityStage stage = OpportunityStage.newLead,
}) => db.opportunityDao.insertOpportunity(
  customerId: customerId,
  name: name,
  stage: stage,
);

FollowupDraft _followupDraft({
  required int opportunityId,
  DateTime? occurredAt,
  FollowMethod method = FollowMethod.phone,
  String feedback = '认可技术方案',
  OpportunityStage stage = OpportunityStage.needsConfirmed,
  String nextAction = '发送正式报价',
  String? content,
  Object? nextFollowAt = _defaultNextFollowAt,
  String? pauseReason,
}) => FollowupDraft(
  opportunityId: opportunityId,
  occurredAt: occurredAt ?? DateTime.utc(2026, 8, 5, 10),
  method: method,
  feedback: feedback,
  stage: stage,
  nextAction: nextAction,
  content: content,
  nextFollowAt: identical(nextFollowAt, _defaultNextFollowAt)
      ? DateTime.utc(2026, 8, 8, 10)
      : nextFollowAt as DateTime?,
  pauseReason: pauseReason,
);

void main() {
  late AppDatabase db;
  late _FakeReminderScheduler scheduler;
  late CustomerService service;

  setUp(() async {
    db = await openTestDb();
    scheduler = _FakeReminderScheduler();
    service = CustomerService(db, scheduler);
  });

  tearDown(() => db.close());

  group('客户', () {
    test('仅名称即可创建，并清理首尾空格', () async {
      final id = await service.createCustomer(
        const CustomerDraft(name: '  星河科技  '),
      );

      final customer = await db.customerDao.findById(id);
      expect(customer?.name, '星河科技');
      expect(customer?.company, isNull);
      expect(customer?.stage, CustomerStage.potential.dbValue);
      final opportunity = await db.opportunityDao.findLegacyDefaultOfCustomer(
        id,
      );
      expect(opportunity?.name, '待确认项目');
      expect(opportunity?.stage, OpportunityStage.newLead.dbValue);
    });

    test('空名称和超过 50 字符的名称会被拒绝', () async {
      expect(
        () => service.createCustomer(const CustomerDraft(name: '   ')),
        throwsA(
          isA<CustomerValidationException>().having(
            (error) => error.message,
            'message',
            '客户名称不能为空',
          ),
        ),
      );
      expect(
        () => service.createCustomer(CustomerDraft(name: '客' * 51)),
        throwsA(isA<CustomerValidationException>()),
      );
    });

    test('编辑时可显式清空可选字段', () async {
      final id = await service.createCustomer(
        const CustomerDraft(
          name: '原客户',
          company: '原公司',
          phone: '13800000000',
          note: '原备注',
        ),
      );

      await service.updateCustomer(
        id,
        const CustomerDraft(name: '新客户', company: ' ', phone: '', note: '\n'),
      );

      final customer = await db.customerDao.findById(id);
      expect(customer?.name, '新客户');
      expect(customer?.company, isNull);
      expect(customer?.phone, isNull);
      expect(customer?.note, isNull);
    });

    test('旧客户编辑页修改阶段时同步兼容项目阶段', () async {
      final id = await service.createCustomer(
        const CustomerDraft(name: '推进中的客户'),
      );

      await service.updateCustomer(
        id,
        const CustomerDraft(name: '推进中的客户', stage: CustomerStage.deal),
      );

      final opportunity = await db.opportunityDao.findLegacyDefaultOfCustomer(
        id,
      );
      expect(opportunity?.stage, OpportunityStage.won.dbValue);
      expect(opportunity?.status, OpportunityStatus.won.dbValue);
    });

    test('标签会清理空格、去重并在编辑时同步', () async {
      final id = await service.createCustomer(
        const CustomerDraft(name: '客户', tagNames: [' 重点 ', '同行推荐', '重点']),
      );

      expect((await db.customerDao.tagsOf(id)).map((tag) => tag.name).toSet(), {
        '重点',
        '同行推荐',
      });

      await service.updateCustomer(
        id,
        const CustomerDraft(name: '客户', tagNames: [' 重点 ', '复购']),
      );
      expect((await db.customerDao.tagsOf(id)).map((tag) => tag.name).toSet(), {
        '重点',
        '复购',
      });
    });
  });

  group('联系人', () {
    test('创建会清理输入，编辑可清空可选字段', () async {
      final customerId = await seedCustomer(db);
      final contactId = await service.createContact(
        customerId,
        const ContactDraft(
          name: '  李经理 ',
          position: ' 采购 ',
          phone: ' 13900000000 ',
          isDecisionMaker: true,
        ),
      );

      var contact = await db.contactDao.findById(contactId);
      expect(contact?.name, '李经理');
      expect(contact?.position, '采购');
      expect(contact?.phone, '13900000000');
      expect(contact?.isDecisionMaker, isTrue);

      await service.updateContact(
        contactId,
        const ContactDraft(name: ' 李经理 ', position: ' ', phone: ''),
      );
      contact = await db.contactDao.findById(contactId);
      expect(contact?.position, isNull);
      expect(contact?.phone, isNull);
      expect(contact?.isDecisionMaker, isFalse);
    });

    test('空联系人名称会被拒绝', () async {
      final customerId = await seedCustomer(db);
      expect(
        () => service.createContact(customerId, const ContactDraft(name: ' ')),
        throwsA(isA<CustomerValidationException>()),
      );
    });
  });

  group('跟进与提醒', () {
    test('项目必须存在且属于当前客户', () async {
      final customerId = await seedCustomer(db);
      final otherCustomerId = await seedCustomer(db, name: '其他客户');
      final otherOpportunityId = await _seedOpportunity(
        db,
        otherCustomerId,
        name: '其他项目',
      );

      expect(
        () => service.addFollowup(
          customerId,
          _followupDraft(opportunityId: 999999),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      expect(
        () => service.addFollowup(
          customerId,
          _followupDraft(opportunityId: otherOpportunityId),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      expect(await db.followupDao.listOf(customerId), isEmpty);
    });

    test('反馈、下一步行动和后续方式必须填写完整', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '密封件项目',
      );

      for (final draft in [
        _followupDraft(opportunityId: opportunityId, feedback: '  '),
        _followupDraft(opportunityId: opportunityId, nextAction: '\n'),
        _followupDraft(
          opportunityId: opportunityId,
          nextFollowAt: null,
          pauseReason: null,
        ),
        _followupDraft(opportunityId: opportunityId, pauseReason: '暂缓采购'),
        _followupDraft(
          opportunityId: opportunityId,
          nextFollowAt: null,
          pauseReason: '   ',
        ),
      ]) {
        await expectLater(
          service.addFollowup(customerId, draft),
          throwsA(isA<CustomerValidationException>()),
        );
      }
      expect(await db.followupDao.listOf(customerId), isEmpty);
    });

    test('保存不可变五字段快照，并同步所选项目和下一计划', () async {
      final customerId = await seedCustomer(db, name: '远山公司');
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '密封件项目',
        stage: OpportunityStage.contactEstablished,
      );
      final occurredAt = DateTime.utc(2026, 8, 5, 10);
      final nextFollowAt = DateTime.utc(2026, 8, 8, 10);

      final result = await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          occurredAt: occurredAt,
          feedback: '  认可技术方案  ',
          stage: OpportunityStage.needsConfirmed,
          nextAction: '  发送正式报价  ',
          nextFollowAt: nextFollowAt,
        ),
      );

      expect(result.hasWarning, isFalse);
      final followup = (await db.followupDao.listOf(customerId)).single;
      expect(followup.opportunityId, opportunityId);
      expect(followup.feedback, '认可技术方案');
      expect(followup.content, '认可技术方案');
      expect(followup.stage, OpportunityStage.needsConfirmed.dbValue);
      expect(followup.nextAction, '发送正式报价');
      expect(followup.nextFollowAt, nextFollowAt.millisecondsSinceEpoch);
      expect(followup.pauseReason, isNull);

      final opportunity = await db.opportunityDao.findById(opportunityId);
      expect(opportunity?.lastFollowAt, occurredAt.millisecondsSinceEpoch);
      expect(opportunity?.latestFeedback, '认可技术方案');
      expect(opportunity?.stage, OpportunityStage.needsConfirmed.dbValue);
      expect(opportunity?.nextAction, '发送正式报价');
      expect(opportunity?.nextFollowAt, nextFollowAt.millisecondsSinceEpoch);
      expect(opportunity?.status, OpportunityStatus.active.dbValue);

      final plan = (await db.planDao.listOf(customerId)).single;
      expect(plan.opportunityId, opportunityId);
      expect(TaskSourceType.fromDb(plan.sourceType), TaskSourceType.followup);
      expect(plan.sourceId, followup.id);
      expect(plan.ruleKey, 'next_followup');
      expect(plan.reason, '按计划继续跟进');
      expect(plan.talkingDirection, '确认年用量、具体型号、采购时间和注册要求');
      expect(plan.nextAction, '发送正式报价');
      expect(plan.owner, '本人');
      expect(plan.title, '发送正式报价');
      expect(plan.planAt, nextFollowAt.millisecondsSinceEpoch);
      expect(scheduler.scheduledPlanIds, [plan.id]);
      expect(scheduler.scheduledCustomerNames, ['远山公司']);
    });

    test('自定义沟通内容会清理空格并独立于客户反馈保存', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '过滤器项目',
      );

      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          feedback: '需要内部评估',
          content: '  讨论了安装空间和交期  ',
        ),
      );

      final followup = (await db.followupDao.listOf(customerId)).single;
      expect(followup.feedback, '需要内部评估');
      expect(followup.content, '讨论了安装空间和交期');
    });

    test('同一客户的多个项目互不污染', () async {
      final customerId = await seedCustomer(db);
      final firstId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
        stage: OpportunityStage.contactEstablished,
      );
      final secondId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 B',
        stage: OpportunityStage.quoted,
      );

      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: secondId,
          feedback: 'B 项目反馈',
          stage: OpportunityStage.priceNegotiation,
          nextAction: 'B 项目行动',
        ),
      );

      final first = await db.opportunityDao.findById(firstId);
      final second = await db.opportunityDao.findById(secondId);
      expect(first?.stage, OpportunityStage.contactEstablished.dbValue);
      expect(first?.latestFeedback, isNull);
      expect(first?.nextAction, isNull);
      expect(first?.lastFollowAt, isNull);
      expect(second?.stage, OpportunityStage.priceNegotiation.dbValue);
      expect(second?.latestFeedback, 'B 项目反馈');
      expect(second?.nextAction, 'B 项目行动');
      expect(
        (await db.followupDao.listOf(customerId)).single.opportunityId,
        secondId,
      );
    });

    test('旧补录不倒退客户时间，也不覆盖项目较新状态', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      final recentAt = DateTime.utc(2026, 8, 5, 10);
      final oldAt = DateTime.utc(2026, 8, 4, 10);

      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          occurredAt: recentAt,
          feedback: '较新反馈',
          stage: OpportunityStage.quoted,
          nextAction: '较新行动',
        ),
      );
      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          occurredAt: oldAt,
          feedback: '补录旧反馈',
          stage: OpportunityStage.newLead,
          nextAction: '补录旧行动',
          nextFollowAt: null,
          pauseReason: '历史记录',
        ),
      );

      final customer = await db.customerDao.findById(customerId);
      final opportunity = await db.opportunityDao.findById(opportunityId);
      expect(customer?.lastFollowAt, recentAt.millisecondsSinceEpoch);
      expect(opportunity?.lastFollowAt, recentAt.millisecondsSinceEpoch);
      expect(opportunity?.latestFeedback, '较新反馈');
      expect(opportunity?.stage, OpportunityStage.quoted.dbValue);
      expect(opportunity?.nextAction, '较新行动');
      expect(await db.followupDao.listOf(customerId), hasLength(2));
    });

    test('发生时间相同时也不覆盖已经同步的项目状态', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      final occurredAt = DateTime.utc(2026, 8, 5, 10);

      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          occurredAt: occurredAt,
          feedback: '第一次反馈',
          nextAction: '第一次行动',
        ),
      );
      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          occurredAt: occurredAt,
          feedback: '第二次反馈',
          stage: OpportunityStage.lost,
          nextAction: '第二次行动',
          nextFollowAt: null,
          pauseReason: '同时间补录',
        ),
      );

      final opportunity = await db.opportunityDao.findById(opportunityId);
      expect(opportunity?.latestFeedback, '第一次反馈');
      expect(opportunity?.stage, OpportunityStage.needsConfirmed.dbValue);
      expect(opportunity?.nextAction, '第一次行动');
      expect(opportunity?.status, OpportunityStatus.active.dbValue);
    });

    test('暂不跟进会保存原因且不创建计划', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );

      await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          nextFollowAt: null,
          pauseReason: '  等待客户预算释放  ',
        ),
      );

      final followup = (await db.followupDao.listOf(customerId)).single;
      final opportunity = await db.opportunityDao.findById(opportunityId);
      expect(followup.pauseReason, '等待客户预算释放');
      expect(followup.nextFollowAt, isNull);
      expect(opportunity?.nextFollowAt, isNull);
      expect(await db.planDao.listOf(customerId), isEmpty);
      expect(scheduler.scheduleAttempts, isEmpty);
    });

    test('提醒排期失败不回滚跟进、项目同步和下一计划', () async {
      final customerId = await seedCustomer(db, name: '远山公司');
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      scheduler.throwOnSchedule = true;

      final result = await service.addFollowup(
        customerId,
        _followupDraft(
          opportunityId: opportunityId,
          feedback: '确认需求',
          nextAction: '提交方案',
        ),
      );

      expect(result.warning, contains('计划已保存'));
      expect(await db.followupDao.listOf(customerId), hasLength(1));
      final opportunity = await db.opportunityDao.findById(opportunityId);
      expect(opportunity?.latestFeedback, '确认需求');
      final plans = await db.planDao.listOf(customerId);
      expect(plans.single.title, '提交方案');
      expect(plans.single.opportunityId, opportunityId);
      expect(scheduler.scheduleAttempts, [plans.single.id]);
    });

    test('创建独立计划成功后会调度提醒', () async {
      final customerId = await seedCustomer(db, name: '远山公司');
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );

      final result = await service.createPlan(
        customerId,
        PlanDraft(
          opportunityId: opportunityId,
          reason: ' 回访确认 ',
          talkingDirection: '确认采购时间和数量',
          nextAction: ' 回访 ',
          planAt: DateTime(2026, 8, 8, 10),
        ),
      );

      expect(result.hasWarning, isFalse);
      expect(scheduler.scheduledPlanIds, [result.value]);
      expect(scheduler.scheduledCustomerNames, ['远山公司']);
      final plan = await db.planDao.findById(result.value);
      expect(plan?.opportunityId, isNotNull);
    });

    test('独立计划必须绑定当前客户的项目并保存任务快照', () async {
      final customerId = await seedCustomer(db);
      final otherCustomerId = await seedCustomer(db, name: '其他客户');
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      final otherOpportunityId = await _seedOpportunity(
        db,
        otherCustomerId,
        name: '其他项目',
      );

      expect(
        () => service.createPlan(
          customerId,
          PlanDraft(
            opportunityId: otherOpportunityId,
            reason: '原因',
            talkingDirection: '方向',
            nextAction: '行动',
            planAt: DateTime(2026, 8, 8),
          ),
        ),
        throwsA(isA<CustomerValidationException>()),
      );

      final result = await service.createPlan(
        customerId,
        PlanDraft(
          opportunityId: opportunityId,
          reason: '  确认采购计划 ',
          talkingDirection: '确认采购时间和数量',
          nextAction: '  电话确认 ',
          owner: '  本人 ',
          planAt: DateTime(2026, 8, 8),
        ),
      );
      final plan = await db.planDao.findById(result.value);
      expect(plan?.reason, '确认采购计划');
      expect(plan?.nextAction, '电话确认');
      expect(plan?.title, '电话确认');
      expect(TaskSourceType.fromDb(plan!.sourceType), TaskSourceType.manual);
    });

    test('取消计划先持久化，提醒清理失败时返回警告', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      final created = await service.createPlan(
        customerId,
        PlanDraft(
          opportunityId: opportunityId,
          reason: '确认采购计划',
          talkingDirection: '确认采购时间和数量',
          nextAction: '电话确认',
          planAt: DateTime(2026, 8, 8),
        ),
      );
      scheduler.throwOnCancel = true;

      final warning = await service.cancelPlan(customerId, created.value);
      expect(warning, contains('计划已取消'));
      final plan = await db.planDao.findById(created.value);
      expect(PlanStatus.fromDb(plan!.status), PlanStatus.cancelled);
      expect(scheduler.cancelledPlanIds, isEmpty);
    });
  });

  group('删除客户', () {
    test('删除前取消全部开放计划提醒', () async {
      final customerId = await seedCustomer(db);
      final first = await db.planDao.insertPlan(
        customerId: customerId,
        title: '计划一',
        planAt: DateTime(2026, 8, 5),
      );
      final second = await db.planDao.insertPlan(
        customerId: customerId,
        title: '计划二',
        planAt: DateTime(2026, 8, 6),
      );
      final completed = await db.planDao.insertPlan(
        customerId: customerId,
        title: '已完成',
        planAt: DateTime(2026, 8, 3),
      );
      await db.planDao.markCompleted(completed);

      await service.deleteCustomer(customerId);

      expect(scheduler.cancelledPlanIds, [first, second]);
      expect(await db.customerDao.findById(customerId), isNull);
    });

    test('取消提醒失败时保留客户和业务数据', () async {
      final customerId = await seedCustomer(db);
      await db.planDao.insertPlan(
        customerId: customerId,
        title: '待处理',
        planAt: DateTime(2026, 8, 5),
      );
      scheduler.throwOnCancel = true;

      await expectLater(
        service.deleteCustomer(customerId),
        throwsA(isA<StateError>()),
      );

      expect(await db.customerDao.findById(customerId), isNotNull);
      expect(await db.planDao.listOf(customerId), hasLength(1));
    });
  });
}

class _FakeReminderScheduler implements ReminderScheduler {
  final List<int> scheduledPlanIds = [];
  final List<int> scheduleAttempts = [];
  final List<String> scheduledCustomerNames = [];
  final List<int> cancelledPlanIds = [];
  bool throwOnSchedule = false;
  bool throwOnCancel = false;

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async {
    scheduleAttempts.add(plan.id);
    if (throwOnSchedule) throw StateError('schedule failed');
    scheduledPlanIds.add(plan.id);
    scheduledCustomerNames.add(customerName);
  }

  @override
  Future<void> cancelForPlan(int planId) async {
    if (throwOnCancel) throw StateError('cancel failed');
    cancelledPlanIds.add(planId);
  }

  @override
  Future<void> init() async {}

  @override
  Future<List<int>> pendingIds() async => List.of(scheduledPlanIds);

  @override
  Future<int> rescheduleAll() async => 0;
}
