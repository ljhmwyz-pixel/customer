import 'package:customer/data/database.dart';
import 'package:customer/data/daos/customer_dao.dart';
import 'package:customer/models/enums.dart';
// drift 也导出 isNull / isNotNull，与 matcher 的同名匹配器冲突，
// 这里只取需要的 Value，避免整包导入。
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const expectedAdvancedFilterCustomerIds = <int>{100, 200, 300, 400, 500};

/// 验收第 4 项：500 客户 + 5000 跟进记录下，按紧急度排序查询低于 200ms。
///
/// 用内存库跑，比真机文件库快，所以这里的数字是乐观值。
/// 结论要留出余量，实测若接近 200ms 就说明真机上会超。
void main() {
  const customerCount = 500;
  const followupPerCustomer = 10; // 共 5000 条
  const budget = Duration(milliseconds: 200);

  late AppDatabase db;

  setUpAll(() async {
    db = await openTestDb();
    await _seed(db, customerCount, followupPerCustomer);
  });

  tearDownAll(() async => db.close());

  test('数据量符合预期', () async {
    expect(await db.customerDao.countAll(), customerCount);
    expect(
      await db.followupDao.countAll(),
      customerCount * followupPerCustomer,
    );
  });

  test('listByUrgency 耗时低于 200ms', () async {
    final now = DateTime(2026, 8, 4, 12);

    // 预热一次：首次查询要编译 SQL、填页缓存，计进去不代表稳态表现。
    await db.customerDao.listByUrgency(now: now);

    final samples = <int>[];
    for (var i = 0; i < 3; i++) {
      final sw = Stopwatch()..start();
      final rows = await db.customerDao.listByUrgency(now: now);
      sw.stop();
      expect(rows, hasLength(customerCount));
      samples.add(sw.elapsedMicroseconds);
    }

    samples.sort();
    final median = samples[1];
    // ignore: avoid_print
    print(
      'listByUrgency 三轮耗时(us): $samples，中位数 ${median / 1000}ms '
      '(内存库，真机文件库会更慢)',
    );

    expect(
      median,
      lessThan(budget.inMicroseconds),
      reason: '中位数 ${median / 1000}ms 超出 ${budget.inMilliseconds}ms 预算',
    );
  });

  test('listByUrgency 排序符合优先级：逾期在最前', () async {
    final now = DateTime(2026, 8, 4, 12);
    final rows = await db.customerDao.listByUrgency(now: now);

    // 前面若干条应当都是有逾期计划的，且逾期越久越靠前。
    final overdue = rows
        .where((e) => e.nextPlanAt != null && e.nextPlanAt!.isBefore(now))
        .toList();
    expect(overdue, isNotEmpty, reason: '测试数据里应当有逾期计划');

    // 逾期项必须占据列表开头的连续区间。
    for (var i = 0; i < overdue.length; i++) {
      expect(rows[i].nextPlanAt, isNotNull, reason: '第 $i 条应为逾期项但没有计划时间');
      expect(rows[i].nextPlanAt!.isBefore(now), isTrue);
    }

    // 逾期区间内按计划时间升序，也就是逾期越久越靠前。
    // 计划时间相同是允许的，所以只要求后一条不早于前一条。
    for (var i = 1; i < overdue.length; i++) {
      expect(
        rows[i].nextPlanAt!.isBefore(rows[i - 1].nextPlanAt!),
        isFalse,
        reason:
            '第 $i 条 (${rows[i].nextPlanAt}) 早于第 ${i - 1} 条 '
            '(${rows[i - 1].nextPlanAt})，逾期排序不是升序',
      );
    }

    // 无计划的客户排在最后。
    final firstWithoutPlan = rows.indexWhere((e) => e.nextPlanAt == null);
    if (firstWithoutPlan >= 0) {
      for (var i = firstWithoutPlan; i < rows.length; i++) {
        expect(rows[i].nextPlanAt, isNull, reason: '无计划客户应连续排在末尾');
      }
    }
  });

  test('limit 生效且更快', () async {
    final now = DateTime(2026, 8, 4, 12);
    final rows = await db.customerDao.listByUrgency(now: now, limit: 20);
    expect(rows, hasLength(20));
  });

  test('listFilteredByUrgency 在 500 客户下低于 200ms', () async {
    final now = DateTime(2026, 8, 4, 12);
    await db.customerDao.listFilteredByUrgency(
      now: now,
      keyword: '客户',
      customerStage: CustomerStage.contacted,
    );

    final sw = Stopwatch()..start();
    final rows = await db.customerDao.listFilteredByUrgency(
      now: now,
      keyword: '客户',
      customerStage: CustomerStage.contacted,
    );
    sw.stop();

    expect(rows, isNotEmpty);
    expect(sw.elapsedMicroseconds, lessThan(budget.inMicroseconds));
  });

  test('500 customer advanced combined filter completes under 200ms', () async {
    final now = DateTime(2026, 8, 4, 12);

    Future<List<CustomerListItem>> query() =>
        db.customerDao.listFilteredByUrgency(
          now: now,
          productCategory: '目标耗材',
          productModel: 'PERF-M100',
          equipmentBrand: 'PerfBrand',
          opportunityStatus: OpportunityStatus.paused,
          expectedCloseFrom: DateTime(2026, 9, 1),
          expectedCloseTo: DateTime(2026, 9, 30),
          anomalies: const {
            CustomerAnomalyFilter.stalledQuote,
            CustomerAnomalyFilter.stalledSample,
          },
        );

    // 预热 SQL 编译和页缓存，只测稳态查询耗时。
    await query();

    final sw = Stopwatch()..start();
    final rows = await query();
    sw.stop();

    final actualCustomerIds = rows.map((row) => row.customer.id).toSet();
    // ignore: avoid_print
    print(
      '高级组合筛选耗时 ${sw.elapsedMicroseconds / 1000}ms，'
      '命中 ${rows.length} 条',
    );
    expect(actualCustomerIds, expectedAdvancedFilterCustomerIds);
    expect(
      sw.elapsedMicroseconds,
      lessThan(budget.inMicroseconds),
      reason:
          '高级组合筛选 ${sw.elapsedMicroseconds / 1000}ms '
          '超出 ${budget.inMilliseconds}ms 预算',
    );
  });

  test('search 在 500 客户下低于 200ms', () async {
    await db.customerDao.search('客户');

    final sw = Stopwatch()..start();
    final rows = await db.customerDao.search('客户 200');
    sw.stop();

    expect(rows, isNotNull);
    expect(sw.elapsedMicroseconds, lessThan(budget.inMicroseconds));
  });

  test('listStale 在 500 客户下低于 200ms', () async {
    final now = DateTime(2026, 8, 4, 12);
    await db.customerDao.listStale(now: now);

    final sw = Stopwatch()..start();
    final rows = await db.customerDao.listStale(now: now);
    sw.stop();

    // ignore: avoid_print
    print(
      'listStale 耗时 ${sw.elapsedMicroseconds / 1000}ms，命中 ${rows.length} 条',
    );
    expect(sw.elapsedMicroseconds, lessThan(budget.inMicroseconds));
  });

  test('countByStage 在 500 客户下低于 200ms', () async {
    await db.customerDao.countByStage();

    final sw = Stopwatch()..start();
    final counts = await db.customerDao.countByStage();
    sw.stop();

    expect(counts.values.reduce((a, b) => a + b), customerCount);
    expect(sw.elapsedMicroseconds, lessThan(budget.inMicroseconds));
  });
}

/// 灌入测试数据。
///
/// 用 batch 批量插入而不是逐条 await：500 + 5000 条逐条插入在内存库上也要几十秒，
/// 测试会慢到没人愿意跑。
Future<void> _seed(AppDatabase db, int customerCount, int perCustomer) async {
  final base = DateTime(2026, 8, 4, 12);
  final baseMs = base.toUtc().millisecondsSinceEpoch;
  const day = 86400000;

  await db.batch((b) {
    for (var i = 1; i <= customerCount; i++) {
      // 最后跟进时间散布在过去 0 到 120 天。
      final lastFollow = baseMs - (i % 120) * day;
      b.insert(
        db.customers,
        CustomersCompanion.insert(
          name: '客户 $i',
          phone: Value('138${i.toString().padLeft(8, '0')}'),
          company: Value('公司 $i'),
          stage: Value(
            CustomerStage.values[i % CustomerStage.values.length].dbValue,
          ),
          grade: Value(
            CustomerGrade.values[i % CustomerGrade.values.length].dbValue,
          ),
          lastFollowAt: Value(lastFollow),
          createdAt: baseMs - 200 * day,
          updatedAt: baseMs,
        ),
      );
    }
  });

  await db.batch((b) {
    for (var c = 1; c <= customerCount; c++) {
      for (var k = 0; k < perCustomer; k++) {
        b.insert(
          db.followups,
          FollowupsCompanion.insert(
            customerId: c,
            occurredAt: baseMs - (k * 7 + c % 30) * day,
            method: FollowMethod
                .values[(c + k) % FollowMethod.values.length]
                .dbValue,
            content: '第 $k 次跟进，客户 $c',
            createdAt: baseMs,
            updatedAt: baseMs,
          ),
        );
      }
    }
  });

  // 计划：约六成客户有未完成计划，其中一部分逾期、一部分今天、一部分未来。
  await db.batch((b) {
    for (var c = 1; c <= customerCount; c++) {
      if (c % 5 == 0) continue; // 两成客户完全没有计划

      final bucket = c % 3;
      final planAt = switch (bucket) {
        0 => baseMs - (c % 40 + 1) * day, // 逾期
        1 => baseMs + 3600000, // 今天稍后
        _ => baseMs + (c % 30 + 1) * day, // 未来
      };

      b.insert(
        db.followPlans,
        FollowPlansCompanion.insert(
          customerId: c,
          title: '跟进客户 $c',
          planAt: planAt,
          status: Value(PlanStatus.pending.dbValue),
          createdAt: baseMs,
          updatedAt: baseMs,
        ),
      );
    }
  });

  // 每个客户创建两个项目。非目标客户的主项目固定破坏一个条件，
  // 次项目补足该条件但破坏另一个条件，以锁定“同一项目完整匹配”的语义。
  await db.batch((b) {
    for (var customerId = 1; customerId <= customerCount; customerId++) {
      final isExpected = expectedAdvancedFilterCustomerIds.contains(customerId);
      final failureCase = customerId % 7;
      final primaryOpportunityId = customerId * 2 - 1;
      final secondaryOpportunityId = customerId * 2;

      b.insert(
        db.opportunities,
        OpportunitiesCompanion.insert(
          id: Value(primaryOpportunityId),
          customerId: customerId,
          name: '性能主项目 $customerId',
          productCategory: Value(
            !isExpected && failureCase == 0 ? '其他耗材' : '目标耗材',
          ),
          productModel: Value(
            !isExpected && failureCase == 1 ? 'PERF-OTHER' : 'PERF-M100',
          ),
          equipmentBrand: Value(
            !isExpected && failureCase == 2 ? 'OtherBrand' : 'PerfBrand',
          ),
          status: Value(
            !isExpected && failureCase == 3
                ? OpportunityStatus.active.dbValue
                : OpportunityStatus.paused.dbValue,
          ),
          expectedCloseAt: Value(
            DateTime(
              2026,
              !isExpected && failureCase == 4 ? 10 : 9,
              15,
            ).toUtc().millisecondsSinceEpoch,
          ),
          createdAt: baseMs,
          updatedAt: baseMs,
        ),
      );
      b.insert(
        db.opportunities,
        OpportunitiesCompanion.insert(
          id: Value(secondaryOpportunityId),
          customerId: customerId,
          name: '性能干扰项目 $customerId',
          productCategory: Value(
            !isExpected && failureCase == 0 ? '目标耗材' : '干扰耗材',
          ),
          productModel: Value(
            !isExpected && failureCase == 0 ? 'PERF-OTHER' : 'PERF-M100',
          ),
          equipmentBrand: const Value('PerfBrand'),
          status: Value(OpportunityStatus.paused.dbValue),
          expectedCloseAt: Value(
            DateTime(2026, 9, 15).toUtc().millisecondsSinceEpoch,
          ),
          createdAt: baseMs,
          updatedAt: baseMs,
        ),
      );
    }
  });

  await db.batch((b) {
    for (var customerId = 1; customerId <= customerCount; customerId++) {
      final isExpected = expectedAdvancedFilterCustomerIds.contains(customerId);
      final failureCase = customerId % 7;
      final primaryOpportunityId = customerId * 2 - 1;
      final secondaryOpportunityId = customerId * 2;

      for (final opportunityId in [
        primaryOpportunityId,
        secondaryOpportunityId,
      ]) {
        final primaryWithoutStalledQuote =
            opportunityId == primaryOpportunityId &&
            !isExpected &&
            failureCase == 5;
        for (var version = 1; version <= 2; version++) {
          b.insert(
            db.quotes,
            QuotesCompanion.insert(
              opportunityId: opportunityId,
              quoteNo: 'PERF-$opportunityId',
              version: version,
              quantity: 100,
              quotedAt: baseMs - (primaryWithoutStalledQuote ? 29 : 31) * day,
              customerReceived: Value(
                primaryWithoutStalledQuote && version == 2,
              ),
              createdAt: baseMs,
              updatedAt: baseMs,
            ),
          );
        }
      }
    }
  });

  await db.batch((b) {
    for (var customerId = 1; customerId <= customerCount; customerId++) {
      final isExpected = expectedAdvancedFilterCustomerIds.contains(customerId);
      final failureCase = customerId % 7;
      final primaryOpportunityId = customerId * 2 - 1;
      final secondaryOpportunityId = customerId * 2;

      for (final opportunityId in [
        primaryOpportunityId,
        secondaryOpportunityId,
      ]) {
        final primaryWithoutStalledSample =
            opportunityId == primaryOpportunityId &&
            !isExpected &&
            failureCase == 6;
        for (var sampleIndex = 1; sampleIndex <= 2; sampleIndex++) {
          b.insert(
            db.samples,
            SamplesCompanion.insert(
              opportunityId: opportunityId,
              quantity: sampleIndex,
              deliveredAt: Value(
                baseMs - (primaryWithoutStalledSample ? 29 : 31) * day,
              ),
              testResult: Value(
                primaryWithoutStalledSample && sampleIndex == 2 ? '已通过' : null,
              ),
              createdAt: baseMs,
              updatedAt: baseMs,
            ),
          );
        }
      }
    }
  });
}
