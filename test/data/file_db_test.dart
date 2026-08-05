import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// 落盘数据库的验证。
///
/// 其余测试都用内存库，跑得快但和真机不完全一样：文件库要经过真实的 VFS，
/// 外键 PRAGMA、WAL、页缓存的行为都可能不同。性能预算也是按真机文件库定的，
/// 所以这里补一组文件库的实测。
void main() {
  late Directory tmpDir;
  late File dbFile;
  late AppDatabase db;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('customer_db_test');
    dbFile = File(p.join(tmpDir.path, 'customer.sqlite'));
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
  });

  tearDown(() async {
    await db.close();
    if (await tmpDir.exists()) {
      await tmpDir.delete(recursive: true);
    }
  });

  test('落盘库初始化后文件真实存在且十一张表建成', () async {
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();

    expect(await dbFile.exists(), isTrue);
    expect(tables, hasLength(11));
    expect(await dbFile.length(), greaterThan(0));
  });

  test('落盘库的外键约束同样生效', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.first, anyOf(1, true));

    final customerId = await db.customerDao.insertCustomer(name: '落盘客户');
    await db.contactDao.insertContact(customerId: customerId, name: '联系人');
    await db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      occurredAt: DateTime(2026, 8, 1),
      method: FollowMethod.phone,
      content: 'x',
    );

    await db.customerDao.deleteCustomer(customerId);

    expect(await db.contactDao.countOf(customerId), 0);
    expect(await db.followupDao.countOf(customerId), 0);
  });

  test('数据在重开连接后仍然存在', () async {
    await db.customerDao.insertCustomer(name: '持久化客户', phone: '13800000000');
    await db.close();

    // 换一个连接重新打开同一个文件。
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final rows = await db.customerDao.allCustomers();

    expect(rows, hasLength(1));
    expect(rows.single.name, '持久化客户');
    // 重开后 user_version 仍是 5，不会重跑 onCreate。
    final v = await db.customSelect('PRAGMA user_version').getSingle();
    expect(v.data.values.first, 5);
  });

  test('落盘库在 500 客户 + 5000 跟进下排序仍低于 200ms', () async {
    const customerCount = 500;
    const perCustomer = 10;
    final base = DateTime(2026, 8, 4, 12);
    final baseMs = base.toUtc().millisecondsSinceEpoch;
    const day = 86400000;

    await db.batch((b) {
      for (var i = 1; i <= customerCount; i++) {
        b.insert(
          db.customers,
          CustomersCompanion.insert(
            name: '客户 $i',
            phone: Value('138${i.toString().padLeft(8, '0')}'),
            stage: Value(
              CustomerStage.values[i % CustomerStage.values.length].dbValue,
            ),
            grade: Value(
              CustomerGrade.values[i % CustomerGrade.values.length].dbValue,
            ),
            lastFollowAt: Value(baseMs - (i % 120) * day),
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
              content: '第 $k 次跟进',
              createdAt: baseMs,
              updatedAt: baseMs,
            ),
          );
        }
      }
    });

    await db.batch((b) {
      for (var c = 1; c <= customerCount; c++) {
        if (c % 5 == 0) continue;
        b.insert(
          db.followPlans,
          FollowPlansCompanion.insert(
            customerId: c,
            title: '跟进 $c',
            planAt: switch (c % 3) {
              0 => baseMs - (c % 40 + 1) * day,
              1 => baseMs + 3600000,
              _ => baseMs + (c % 30 + 1) * day,
            },
            status: Value(PlanStatus.pending.dbValue),
            createdAt: baseMs,
            updatedAt: baseMs,
          ),
        );
      }
    });

    expect(await db.customerDao.countAll(), customerCount);
    expect(await db.followupDao.countAll(), customerCount * perCustomer);

    await db.customerDao.listByUrgency(now: base);

    final samples = <int>[];
    for (var i = 0; i < 3; i++) {
      final sw = Stopwatch()..start();
      final rows = await db.customerDao.listByUrgency(now: base);
      sw.stop();
      expect(rows, hasLength(customerCount));
      samples.add(sw.elapsedMicroseconds);
    }
    samples.sort();

    // ignore: avoid_print
    print(
      '落盘库 listByUrgency 三轮耗时(us): $samples，'
      '中位数 ${samples[1] / 1000}ms，库文件 ${await dbFile.length()} 字节',
    );

    expect(
      samples[1],
      lessThan(const Duration(milliseconds: 200).inMicroseconds),
    );
  });
}
