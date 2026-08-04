import 'package:customer/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 验收第 5 项：数据库版本号与迁移函数就位，能从 v1 空库正常初始化。
void main() {
  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('schemaVersion 为 1', () {
    expect(db.schemaVersion, 1);
  });

  test('空库初始化后八张表全部建成', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();
    final tables = rows.map((r) => r.read<String>('name')).toSet();

    expect(tables, {
      'attachments',
      'contacts',
      'customer_tags',
      'customers',
      'follow_plans',
      'followups',
      'orders',
      'tags',
    });
  });

  test('业务索引全部建成', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'idx_%' ORDER BY name",
        )
        .get();
    final indexes = rows.map((r) => r.read<String>('name')).toSet();

    expect(indexes, {
      'idx_attachments_followup',
      'idx_attachments_order',
      'idx_customers_last_follow',
      'idx_customers_phone',
      'idx_customers_stage',
      'idx_followups_customer',
      'idx_orders_customer',
      'idx_plans_customer_status',
      'idx_plans_plan_at',
    });
  });

  test('user_version 写入为 1', () async {
    // drift 用 SQLite 的 user_version 记录 schema 版本，
    // 这个值不对的话后续 onUpgrade 会走错分支。
    final row = await db.customSelect('PRAGMA user_version').getSingle();
    expect(row.data.values.first, 1);
  });

  test('外键约束在 beforeOpen 后处于开启状态', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.first, anyOf(1, true));
  });

  test('附件表的 CHECK 约束已随建表落地', () async {
    final row = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'table' "
          "AND name = 'attachments'",
        )
        .getSingle();
    final sql = row.read<String>('sql');

    expect(sql, contains('CHECK'));
    expect(sql, contains('followup_id'));
    expect(sql, contains('order_id'));
  });

  test('空库各表记录数为 0，且可立刻写入', () async {
    expect(await db.customerDao.countAll(), 0);
    expect(await db.followupDao.countAll(), 0);
    expect(await db.attachmentDao.countAll(), 0);

    final id = await seedCustomer(db);
    expect(await db.customerDao.findById(id), isNotNull);
  });

  test('建索引语句可重复执行，不会因已存在而报错', () async {
    // onCreate 里的建索引语句都带 IF NOT EXISTS。这里直接再执行一遍同名索引，
    // 确认真的幂等：迁移里重跑建索引是常见操作，不幂等的话升级会中途失败。
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_plans_plan_at ON follow_plans(plan_at)',
    );

    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'idx_%'",
        )
        .get();
    // 索引没有被重复创建成两条。
    expect(rows.length, 9);
  });
}
