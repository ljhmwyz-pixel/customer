import 'package:customer/data/database.dart';
import 'package:customer/features/customers/customer_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';

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
    test('必须创建下一计划或明确暂不跟进', () async {
      final customerId = await seedCustomer(db);
      final base = FollowupDraft(
        occurredAt: DateTime(2026, 8, 4),
        method: FollowMethod.phone,
        content: '沟通报价',
      );

      expect(
        () => service.addFollowup(customerId, base),
        throwsA(isA<CustomerValidationException>()),
      );
      expect(
        () => service.addFollowup(
          customerId,
          FollowupDraft(
            occurredAt: base.occurredAt,
            method: base.method,
            content: base.content,
            nextPlan: PlanDraft(title: '再次联系', planAt: DateTime(2026, 8, 5)),
            skipNextPlan: true,
          ),
        ),
        throwsA(isA<CustomerValidationException>()),
      );
    });

    test('明确暂不跟进时只写入跟进记录', () async {
      final customerId = await seedCustomer(db);

      final result = await service.addFollowup(
        customerId,
        FollowupDraft(
          occurredAt: DateTime(2026, 8, 4),
          method: FollowMethod.wechat,
          content: '  已发送产品资料  ',
          skipNextPlan: true,
        ),
      );

      expect(result.hasWarning, isFalse);
      expect(
        (await db.followupDao.listOf(customerId)).single.content,
        '已发送产品资料',
      );
      expect(await db.planDao.listOf(customerId), isEmpty);
      expect(scheduler.scheduledPlanIds, isEmpty);
    });

    test('提醒排期失败不回滚跟进和下一计划', () async {
      final customerId = await seedCustomer(db, name: '远山公司');
      scheduler.throwOnSchedule = true;

      final result = await service.addFollowup(
        customerId,
        FollowupDraft(
          occurredAt: DateTime(2026, 8, 4),
          method: FollowMethod.meeting,
          content: '确认需求',
          nextPlan: PlanDraft(title: ' 提交方案 ', planAt: DateTime(2026, 8, 7, 9)),
        ),
      );

      expect(result.warning, contains('计划已保存'));
      expect(await db.followupDao.listOf(customerId), hasLength(1));
      final plans = await db.planDao.listOf(customerId);
      expect(plans.single.title, '提交方案');
      expect(scheduler.scheduleAttempts, [plans.single.id]);
    });

    test('创建独立计划成功后会调度提醒', () async {
      final customerId = await seedCustomer(db, name: '远山公司');

      final result = await service.createPlan(
        customerId,
        PlanDraft(title: ' 回访 ', planAt: DateTime(2026, 8, 8, 10)),
      );

      expect(result.hasWarning, isFalse);
      expect(scheduler.scheduledPlanIds, [result.value]);
      expect(scheduler.scheduledCustomerNames, ['远山公司']);
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
