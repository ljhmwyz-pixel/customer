import 'package:customer/data/database.dart';
import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:customer/services/sample_data_service.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 6, 9);
  late AppDatabase db;
  late _FakeReminderScheduler scheduler;
  late _FakeAttachmentCleaner cleaner;
  late SampleDataService service;

  setUp(() {
    db = AppDatabase.memory();
    scheduler = _FakeReminderScheduler();
    cleaner = _FakeAttachmentCleaner();
    service = SampleDataService(
      db: db,
      reminderScheduler: scheduler,
      attachmentCleaner: cleaner,
      clock: () => now,
    );
  });

  tearDown(() async => db.close());

  test('空库未导入，首次导入创建九个确定性场景', () async {
    expect(await service.inspect(), const SampleDataState(customerCount: 0));

    expect(await service.importAll(), SampleImportResult.imported);

    final state = await service.inspect();
    expect(state, const SampleDataState(customerCount: 9));
    expect(scheduler.rescheduleCount, 1);

    final customers = await db.customerDao.listBySampleBatch(
      SampleDataService.batchId,
    );
    expect(customers, hasLength(9));
    expect(customers.every((row) => row.name.startsWith('示例｜')), isTrue);
    expect(
      customers.every((row) => row.createdAt == now.millisecondsSinceEpoch),
      isTrue,
    );

    expect(
      await _count(db, 'opportunities', where: _sampleOpportunityWhere),
      9,
    );
    expect(await _count(db, 'followups', where: _sampleCustomerWhere), 9);
    expect(await _count(db, 'follow_plans', where: _sampleCustomerWhere), 9);

    final medtron = await _opportunityFor(db, '示例｜Medtron 合作商');
    expect(medtron.equipmentBrand, 'Medtron');
    expect(medtron.productCategory, '连接管及配件');
    expect(medtron.entryPoint, contains('连接管'));

    final antmed = await _opportunityFor(db, '示例｜Antmed 成熟客户');
    expect(antmed.currentSupplier, 'Antmed');
    expect(antmed.supplierStability, '关系稳定');

    final ulrich = await _opportunityFor(db, '示例｜Ulrich 价格敏感客户');
    expect(ulrich.equipmentBrand, 'Ulrich');
    expect(ulrich.estimatedAnnualVolume, lessThan(2000));
    expect(ulrich.currentObstacle, contains('价格'));

    final tube = await _opportunityFor(db, '示例｜高压连接管潜客');
    expect(tube.productCategory, '连接管及配件');
    expect(tube.stage, OpportunityStage.needsConfirmed.dbValue);

    final tenders = await db
        .customSelect(
          '''
      SELECT customer.name AS customer_name, tender.*
      FROM tenders tender
      JOIN opportunities opportunity ON opportunity.id = tender.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
      WHERE customer.sample_batch_id = ?
      ORDER BY tender.id
    ''',
          variables: [Variable.withString(SampleDataService.batchId)],
        )
        .get();
    expect(tenders, hasLength(2));
    expect(tenders[0].read<String>('customer_name'), '示例｜普通注射器招标客户');
    expect(tenders[1].read<String>('customer_name'), '示例｜首次招标新客户');
    expect(
      tenders[1].read<String>('risk_level'),
      TenderRiskLevel.mediumHigh.dbValue,
    );
    expect(
      tenders[1].read<String>('authorization_type'),
      TenderAuthorizationType.nonExclusiveProject.dbValue,
    );

    final sample = await db.customSelect('''
      SELECT sample.* FROM samples sample
      JOIN opportunities opportunity ON opportunity.id = sample.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
      WHERE customer.name = '示例｜样品测试客户'
    ''').getSingle();
    expect(sample.read<String>('status'), SampleStatus.testing.dbValue);

    final quote = await db.customSelect('''
      SELECT quote.* FROM quotes quote
      JOIN opportunities opportunity ON opportunity.id = quote.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
      WHERE customer.name = '示例｜报价未回复客户'
    ''').getSingle();
    expect(
      quote.read<int>('quoted_at'),
      now.subtract(const Duration(days: 45)).millisecondsSinceEpoch,
    );
    expect(quote.read<String?>('customer_feedback'), contains('未回复'));

    final order = await db.customSelect('''
      SELECT orders.* FROM orders
      JOIN customers customer ON customer.id = orders.customer_id
      WHERE customer.name = '示例｜成交待复购客户'
    ''').getSingle();
    expect(order.read<String>('order_result'), OrderResult.completed.dbValue);
    expect(
      order.read<int>('estimated_repurchase_at'),
      now.add(const Duration(days: 45)).millisecondsSinceEpoch,
    );
  });

  test('重复导入不写入任何表也不重复重排提醒', () async {
    expect(await service.importAll(), SampleImportResult.imported);
    final counts = await _businessCounts(db);

    expect(await service.importAll(), SampleImportResult.alreadyImported);
    expect(await _businessCounts(db), counts);
    expect(scheduler.rescheduleCount, 1);
  });

  test('第九个场景唯一约束失败时回滚整个批次', () async {
    final formalCustomer = await db.customerDao.insertCustomer(
      name: '正式客户',
      now: now,
    );
    final formalOpportunity = await db.opportunityDao.insertOpportunity(
      customerId: formalCustomer,
      name: '正式项目',
      now: now,
    );
    await db.orderDao.insertOrder(
      customerId: formalCustomer,
      opportunityId: formalOpportunity,
      orderNo: SampleDataService.sampleOrderNo,
      orderedAt: now,
      amountCents: 100,
      now: now,
    );

    await expectLater(service.importAll(), throwsA(anything));

    expect(
      await db.customerDao.countBySampleBatch(SampleDataService.batchId),
      0,
    );
    expect(await db.customerDao.countAll(), 1);
    expect(scheduler.rescheduleCount, 0);
  });

  test('撤销按内部标记删除编辑后的完整图且保留正式数据', () async {
    final formalId = await db.customerDao.insertCustomer(
      name: '必须保留的正式客户',
      now: now,
    );
    await service.importAll();
    final sampleCustomers = await db.customerDao.listBySampleBatch(
      SampleDataService.batchId,
    );
    final edited = sampleCustomers.first;
    await db.customerDao.updateCustomer(edited.id, name: '已被用户改名', now: now);
    await db.followupDao.insertAndTouchCustomer(
      customerId: edited.id,
      occurredAt: now,
      method: FollowMethod.other,
      content: '用户新增记录',
      now: now,
    );
    final attachmentFollowup = (await db.followupDao.listOf(edited.id)).first;
    await db.attachmentDao.insertAttachment(
      owner: FollowupAttachmentOwner(attachmentFollowup.id),
      relativePath: 'attachments/sample-proof.txt',
      originalName: 'sample-proof.txt',
      mimeType: 'text/plain',
      sizeBytes: 12,
      now: now,
    );

    final openPlanIds = <int>[];
    for (final customer in sampleCustomers) {
      openPlanIds.addAll(
        (await db.planDao.listOpenOf(customer.id)).map((p) => p.id),
      );
    }

    final result = await service.undoAll();

    expect(result.deletedCustomerCount, 9);
    expect(result.cleanupReport.hasFailures, isFalse);
    expect(scheduler.cancelledIds, unorderedEquals(openPlanIds));
    expect(
      await db.customerDao.countBySampleBatch(SampleDataService.batchId),
      0,
    );
    expect(await db.customerDao.findById(formalId), isNotNull);
    expect(await _count(db, 'opportunities'), 0);
    expect(await _count(db, 'followups'), 0);
    expect(await _count(db, 'follow_plans'), 0);
    expect(cleaner.databaseDeletedBeforeCleanup, isTrue);
    expect(cleaner.loadedPaths, ['attachments/sample-proof.txt']);
  });

  test('附件清理失败会报告，但数据库删除保持提交', () async {
    await service.importAll();
    cleaner.report = const AttachmentCleanupReport(
      failedPaths: ['attachments/sample.pdf'],
    );

    final result = await service.undoAll();

    expect(result.cleanupReport.failedPaths, ['attachments/sample.pdf']);
    expect(await service.inspect(), const SampleDataState(customerCount: 0));
  });

  test('取消提醒失败时中止数据库删除，允许完整重试', () async {
    await service.importAll();
    scheduler.throwOnCancel = true;

    await expectLater(service.undoAll(), throwsA(isA<StateError>()));

    expect(await service.inspect(), const SampleDataState(customerCount: 9));
    expect(cleaner.calls, 0);
  });
}

const _sampleCustomerWhere = '''
customer_id IN (SELECT id FROM customers WHERE sample_batch_id = 'phase-f-samples-v1')
''';
const _sampleOpportunityWhere = '''
customer_id IN (SELECT id FROM customers WHERE sample_batch_id = 'phase-f-samples-v1')
''';

Future<int> _count(AppDatabase db, String table, {String? where}) async {
  final row = await db
      .customSelect(
        'SELECT COUNT(*) AS count FROM $table${where == null ? '' : ' WHERE $where'}',
      )
      .getSingle();
  return row.read<int>('count');
}

Future<OpportunityRow> _opportunityFor(AppDatabase db, String name) async {
  final row = await db
      .customSelect(
        '''
    SELECT opportunity.* FROM opportunities opportunity
    JOIN customers customer ON customer.id = opportunity.customer_id
    WHERE customer.name = ?
  ''',
        variables: [Variable.withString(name)],
      )
      .getSingle();
  return db.opportunities.map(row.data);
}

Future<Map<String, int>> _businessCounts(AppDatabase db) async => {
  for (final table in const [
    'customers',
    'opportunities',
    'followups',
    'follow_plans',
    'quotes',
    'samples',
    'tenders',
    'orders',
  ])
    table: await _count(db, table),
};

class _FakeReminderScheduler implements ReminderScheduler {
  int rescheduleCount = 0;
  bool throwOnCancel = false;
  final cancelledIds = <int>[];

  @override
  Future<void> cancelForPlan(int planId) async {
    if (throwOnCancel) throw StateError('cancel failed');
    cancelledIds.add(planId);
  }

  @override
  Future<void> init() async {}

  @override
  Future<List<int>> pendingIds() async => [];

  @override
  Future<int> rescheduleAll() async {
    rescheduleCount++;
    return 0;
  }

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async {}
}

class _FakeAttachmentCleaner implements AttachmentGraphCleaner {
  int calls = 0;
  bool databaseDeletedBeforeCleanup = false;
  final loadedPaths = <String>[];
  AttachmentCleanupReport report = const AttachmentCleanupReport();

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async {
    calls++;
    loadedPaths.addAll(
      (await loadAttachments()).map((attachment) => attachment.relativePath),
    );
    await deleteDatabaseGraph();
    databaseDeletedBeforeCleanup = true;
    return report;
  }

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async => report;
}
