import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'helpers.dart';

/// v2 数据库初始化与 v1 真库升级。
void main() {
  late AppDatabase db;

  group('v2 新库', () {
    setUp(() async => db = await openTestDb());
    tearDown(() async => db.close());

    test('schemaVersion 为 2', () {
      expect(db.schemaVersion, 2);
    });

    test('空库初始化后九张表全部建成', () async {
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
        'opportunities',
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
        'idx_orders_opportunity',
        'idx_opportunities_customer',
        'idx_opportunities_legacy_default',
        'idx_opportunities_next_follow',
        'idx_opportunities_stage',
        'idx_plans_customer_status',
        'idx_plans_opportunity_status',
        'idx_plans_plan_at',
        'idx_followups_opportunity',
      });
    });

    test('user_version 写入为 2', () async {
      // drift 用 SQLite 的 user_version 记录 schema 版本，
      // 这个值不对的话后续 onUpgrade 会走错分支。
      final row = await db.customSelect('PRAGMA user_version').getSingle();
      expect(row.data.values.first, 2);
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
      expect(rows.length, 16);
    });
  });

  test('v1 真库升级后创建历史项目并回填全部业务记录', () async {
    final directory = await Directory.systemTemp.createTemp('customer-v1-');
    final file = File('${directory.path}/customer.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    try {
      _createV1Schema(raw);
      _seedV1Data(raw);
    } finally {
      raw.close();
    }

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    try {
      // 首次查询触发 Drift 的 onUpgrade。
      await migrated.customSelect('SELECT 1').getSingle();

      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.first, 2);

      final opportunities = await migrated.customSelect('''
            SELECT customer_id, name, stage, status, is_legacy_default
            FROM opportunities
            ORDER BY customer_id
          ''').get();
      expect(opportunities, hasLength(5));
      expect(opportunities.map((row) => row.read<String>('stage')).toList(), [
        'new_lead',
        'contact_established',
        'needs_confirmed',
        'won',
        'lost',
      ]);
      expect(opportunities.map((row) => row.read<String>('status')).toList(), [
        'active',
        'active',
        'active',
        'won',
        'closed',
      ]);
      for (final row in opportunities) {
        expect(row.read<String>('name'), '历史项目');
        expect(row.read<int>('is_legacy_default'), 1);
      }

      for (final table in ['followups', 'follow_plans', 'orders']) {
        final row = await migrated.customSelect('''
              SELECT child.customer_id, child.opportunity_id,
                     opportunity.customer_id AS opportunity_customer_id
              FROM $table child
              JOIN opportunities opportunity
                ON opportunity.id = child.opportunity_id
            ''').getSingle();
        expect(row.read<int>('opportunity_id'), isPositive);
        expect(
          row.read<int>('opportunity_customer_id'),
          row.read<int>('customer_id'),
        );
      }

      final customers = await migrated
          .customSelect('SELECT COUNT(*) AS count FROM customers')
          .getSingle();
      final attachments = await migrated
          .customSelect('SELECT COUNT(*) AS count FROM attachments')
          .getSingle();
      expect(customers.read<int>('count'), 5);
      expect(attachments.read<int>('count'), 2);

      final foreignKeyErrors = await migrated
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(foreignKeyErrors, isEmpty);
    } finally {
      await migrated.close();
      await directory.delete(recursive: true);
    }
  });
}

void _createV1Schema(sqlite.Database db) {
  db.execute('PRAGMA foreign_keys = ON');
  db.execute('''
    CREATE TABLE customers (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      company TEXT,
      phone TEXT,
      wechat TEXT,
      address TEXT,
      source TEXT,
      note TEXT,
      stage TEXT NOT NULL DEFAULT 'potential',
      grade TEXT NOT NULL DEFAULT 'c',
      last_follow_at INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE contacts (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      position TEXT,
      phone TEXT,
      is_decision_maker INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE followups (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      occurred_at INTEGER NOT NULL,
      method TEXT NOT NULL,
      content TEXT NOT NULL,
      conclusion TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE follow_plans (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      title TEXT NOT NULL,
      plan_at INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      notified_at INTEGER,
      completed_at INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE orders (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      order_no TEXT NOT NULL UNIQUE,
      ordered_at INTEGER NOT NULL,
      amount_cents INTEGER NOT NULL,
      description TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE tags (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE customer_tags (
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
      created_at INTEGER NOT NULL,
      PRIMARY KEY (customer_id, tag_id)
    )
  ''');
  db.execute('''
    CREATE TABLE attachments (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      followup_id INTEGER REFERENCES followups(id) ON DELETE CASCADE,
      order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
      relative_path TEXT NOT NULL,
      original_name TEXT NOT NULL,
      mime_type TEXT NOT NULL,
      size_bytes INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      CHECK ((followup_id IS NOT NULL AND order_id IS NULL)
        OR (followup_id IS NULL AND order_id IS NOT NULL))
    )
  ''');
  db.execute('PRAGMA user_version = 1');
}

void _seedV1Data(sqlite.Database db) {
  const now = 1785888000000;
  for (final entry in <String, String>{
    '潜客': 'potential',
    '已联系': 'contacted',
    '有意向': 'intent',
    '已成交': 'deal',
    '已流失': 'lost',
  }.entries) {
    db.execute(
      'INSERT INTO customers '
      '(name, stage, grade, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
      [entry.key, entry.value, 'c', now, now],
    );
  }
  db.execute('''
    INSERT INTO followups
      (customer_id, occurred_at, method, content, created_at, updated_at)
    VALUES (1, $now, 'phone', '旧跟进', $now, $now)
  ''');
  db.execute('''
    INSERT INTO follow_plans
      (customer_id, title, plan_at, status, created_at, updated_at)
    VALUES (1, '旧计划', $now, 'pending', $now, $now)
  ''');
  db.execute('''
    INSERT INTO orders
      (customer_id, order_no, ordered_at, amount_cents, status, created_at, updated_at)
    VALUES (1, 'V1-001', $now, 10000, 'completed', $now, $now)
  ''');
  db.execute('''
    INSERT INTO attachments
      (followup_id, relative_path, original_name, mime_type, size_bytes,
       created_at, updated_at)
    VALUES (1, 'attachments/f.jpg', 'f.jpg', 'image/jpeg', 100, $now, $now)
  ''');
  db.execute('''
    INSERT INTO attachments
      (order_id, relative_path, original_name, mime_type, size_bytes,
       created_at, updated_at)
    VALUES (1, 'attachments/o.pdf', 'o.pdf', 'application/pdf', 200, $now, $now)
  ''');
}
