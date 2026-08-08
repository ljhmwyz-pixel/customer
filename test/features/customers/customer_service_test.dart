import 'package:customer/data/database.dart';
import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:customer/features/opportunities/supplier_substitution.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

const _defaultNextFollowAt = Object();

Future<int> _seedOpportunity(
  AppDatabase db,
  int customerId, {
  required String name,
  OpportunityStage stage = OpportunityStage.newLead,
  String? supplierProblem,
  int? estimatedAnnualVolume,
}) => db.opportunityDao.insertOpportunity(
  customerId: customerId,
  name: name,
  stage: stage,
  supplierProblem: supplierProblem,
  estimatedAnnualVolume: estimatedAnnualVolume,
);

FollowupDraft _followupDraft({
  required int opportunityId,
  int? contactId,
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
  contactId: contactId,
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
  late _RecordingAttachmentCleaner attachmentCleaner;
  late CustomerService service;

  setUp(() async {
    db = await openTestDb();
    scheduler = _FakeReminderScheduler();
    attachmentCleaner = _RecordingAttachmentCleaner();
    service = CustomerService(
      db,
      scheduler,
      attachmentCleaner: attachmentCleaner,
    );
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
    test('沟通方向可追加简短供应商替代建议', () {
      expect(
        talkingDirectionForStage(OpportunityStage.needsConfirmed),
        '确认年用量、具体型号、采购时间和注册要求',
      );
      expect(
        talkingDirectionForStage(
          OpportunityStage.needsConfirmed,
          const SupplierSubstitutionRecommendation(
            entryPoint: '价格替代',
            investmentAdvice: '继续投入',
            summary: '测试建议',
            reasons: [],
          ),
        ),
        '确认年用量、具体型号、采购时间和注册要求；替代建议：价格替代，继续投入',
      );
    });

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

    test('联系人姓名按跟进发生时保存，并校验联系人属于当前客户', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '密封件项目',
      );
      final contactId = await service.createContact(
        customerId,
        const ContactDraft(name: '李经理'),
      );

      final result = await service.addFollowup(
        customerId,
        _followupDraft(opportunityId: opportunityId, contactId: contactId),
      );
      var followup = await db.followupDao.findById(result.value);
      expect(followup?.contactNameSnapshot, '李经理');

      await service.updateContact(contactId, const ContactDraft(name: '王经理'));
      followup = await db.followupDao.findById(result.value);
      expect(followup?.contactNameSnapshot, '李经理');

      await service.deleteContact(contactId);
      followup = await db.followupDao.findById(result.value);
      expect(followup?.contactId, isNull);
      expect(followup?.contactNameSnapshot, '李经理');

      final otherCustomerId = await seedCustomer(db, name: '其他客户');
      final otherContactId = await service.createContact(
        otherCustomerId,
        const ContactDraft(name: '其他联系人'),
      );
      expect(
        () => service.addFollowup(
          customerId,
          _followupDraft(opportunityId: opportunityId, contactId: 999999),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
      expect(
        () => service.addFollowup(
          customerId,
          _followupDraft(
            opportunityId: opportunityId,
            contactId: otherContactId,
          ),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
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
        supplierProblem: '价格高',
        estimatedAnnualVolume: 1200,
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
      expect(plan.talkingDirection, '确认年用量、具体型号、采购时间和注册要求；替代建议：价格替代，继续投入');
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

    test('完成计划记录时间并清理提醒', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      final planId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        title: '完成我',
        planAt: DateTime(2026, 8, 5),
      );
      final warning = await service.completePlan(customerId, planId);
      final row = await db.planDao.findById(planId);
      expect(warning, isNull);
      expect(PlanStatus.fromDb(row!.status), PlanStatus.completed);
      expect(row.completedAt, isNotNull);
      expect(scheduler.cancelledPlanIds, [planId]);
    });

    test('完成计划提醒清理失败返回警告但保留完成状态', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '项目 A',
      );
      final planId = await db.planDao.insertPlan(
        customerId: customerId,
        opportunityId: opportunityId,
        title: '完成我',
        planAt: DateTime(2026, 8, 5),
      );
      scheduler.throwOnCancel = true;
      final warning = await service.completePlan(customerId, planId);
      expect(warning, contains('计划已完成'));
      expect(
        PlanStatus.fromDb((await db.planDao.findById(planId))!.status),
        PlanStatus.completed,
      );
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

    test('提交客户树删除后清理六类业务附件', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '完整附件树',
      );
      final followupId = await db.followupDao.insertAndTouchCustomer(
        customerId: customerId,
        opportunityId: opportunityId,
        occurredAt: DateTime.utc(2026, 8, 6),
        method: FollowMethod.phone,
        content: '跟进',
      );
      final orderId = await db.orderDao.insertOrder(
        customerId: customerId,
        opportunityId: opportunityId,
        orderNo: 'TREE-ORDER',
        orderedAt: DateTime.utc(2026, 8, 6),
        amountCents: 100,
      );
      final quoteId = await db.quoteDao.insertVersion(
        opportunityId: opportunityId,
        quoteNo: 'TREE-QUOTE',
        quantity: 1,
        quotedAt: DateTime.utc(2026, 8, 6),
      );
      final sampleId = await db.sampleDao.insertSample(
        opportunityId: opportunityId,
        quantity: 1,
      );
      final registrationId = await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
      );
      final tenderId = await db.tenderDao.insertTender(
        opportunityId: opportunityId,
      );
      final owners = <AttachmentOwner>[
        FollowupAttachmentOwner(followupId),
        OrderAttachmentOwner(orderId),
        QuoteAttachmentOwner(quoteId),
        SampleAttachmentOwner(sampleId),
        RegistrationAttachmentOwner(registrationId),
        TenderAttachmentOwner(tenderId),
      ];
      for (var index = 0; index < owners.length; index++) {
        await db.attachmentDao.insertAttachment(
          owner: owners[index],
          relativePath: 'attachments/2026/08/tree-$index.bin',
          originalName: 'tree-$index.bin',
          mimeType: 'application/octet-stream',
          sizeBytes: 1,
        );
      }
      attachmentCleaner.afterDatabaseDelete = () async {
        expect(await db.customerDao.findById(customerId), isNull);
        expect(await db.attachmentDao.countAll(), 0);
      };

      await service.deleteCustomer(customerId);

      expect(attachmentCleaner.databaseCommitted, isTrue);
      expect(attachmentCleaner.loadedPaths, [
        for (var index = 0; index < owners.length; index++)
          'attachments/2026/08/tree-$index.bin',
      ]);
    });

    test('客户数据库删除失败时保留数据且不进入文件清理', () async {
      final customerId = await seedCustomer(db);
      final opportunityId = await _seedOpportunity(
        db,
        customerId,
        name: '删除失败项目',
      );
      final orderId = await db.orderDao.insertOrder(
        customerId: customerId,
        opportunityId: opportunityId,
        orderNo: 'FAIL-DELETE',
        orderedAt: DateTime.utc(2026, 8, 6),
        amountCents: 100,
      );
      await db.attachmentDao.insertAttachment(
        owner: OrderAttachmentOwner(orderId),
        relativePath: 'attachments/2026/08/keep.pdf',
        originalName: 'keep.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 1,
      );
      await db.customStatement('''
        CREATE TRIGGER fail_customer_delete
        BEFORE DELETE ON customers
        BEGIN
          SELECT RAISE(ABORT, 'forced customer delete failure');
        END
      ''');

      await expectLater(service.deleteCustomer(customerId), throwsA(anything));

      expect(await db.customerDao.findById(customerId), isNotNull);
      expect(await db.attachmentDao.countAll(), 1);
      expect(attachmentCleaner.databaseCommitted, isFalse);
    });
  });

  test('删除跟进记录时按正确归属清理附件', () async {
    final customerId = await seedCustomer(db);
    final otherCustomerId = await seedCustomer(
      db,
      name: '其他客户',
      phone: '13900000000',
    );
    final opportunityId = await _seedOpportunity(db, customerId, name: '项目 A');
    final followupId = await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      opportunityId: opportunityId,
      occurredAt: DateTime.utc(2026, 8, 6),
      method: FollowMethod.phone,
      content: '待删除跟进',
    );
    await db.attachmentDao.insertAttachment(
      owner: FollowupAttachmentOwner(followupId),
      relativePath: 'attachments/2026/08/followup.pdf',
      originalName: 'followup.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 1,
    );

    await expectLater(
      service.deleteFollowup(otherCustomerId, followupId),
      throwsA(isA<CustomerValidationException>()),
    );
    final report = await service.deleteFollowup(customerId, followupId);

    expect(report.hasFailures, isFalse);
    expect(await db.followupDao.findById(followupId), isNull);
    expect(attachmentCleaner.loadedPaths, ['attachments/2026/08/followup.pdf']);
  });
}

class _RecordingAttachmentCleaner implements AttachmentGraphCleaner {
  final loadedPaths = <String>[];
  Future<void> Function()? afterDatabaseDelete;
  bool databaseCommitted = false;

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async {
    loadedPaths.addAll(
      (await loadAttachments()).map((row) => row.relativePath),
    );
    await deleteDatabaseGraph();
    databaseCommitted = true;
    await afterDatabaseDelete?.call();
    return const AttachmentCleanupReport();
  }

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async =>
      const AttachmentCleanupReport();
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
