import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'helpers.dart';

/// v10 数据库初始化与旧版本真库升级。
void main() {
  late AppDatabase db;

  group('v10 新库', () {
    setUp(() async => db = await openTestDb());
    tearDown(() async => db.close());

    test('schemaVersion 为 10', () {
      expect(db.schemaVersion, 10);
    });

    test('空库初始化后十三张表全部建成', () async {
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
        'quotes',
        'registrations',
        'samples',
        'tenders',
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
        'idx_attachments_quote',
        'idx_attachments_sample',
        'idx_attachments_registration',
        'idx_attachments_tender',
        'idx_customers_last_follow',
        'idx_customers_customer_no',
        'idx_customers_phone',
        'idx_customers_sample_batch',
        'idx_customers_stage',
        'idx_followups_customer',
        'idx_followups_contact',
        'idx_contacts_email',
        'idx_contacts_whatsapp',
        'idx_orders_customer',
        'idx_orders_opportunity',
        'idx_orders_estimated_repurchase',
        'idx_opportunities_customer',
        'idx_opportunities_legacy_default',
        'idx_opportunities_next_follow',
        'idx_opportunities_stage',
        'idx_plans_customer_status',
        'idx_plans_opportunity_status',
        'idx_plans_plan_at',
        'idx_plans_source_rule',
        'idx_followups_opportunity',
        'idx_quotes_opportunity_date',
        'idx_quotes_valid_until',
        'idx_samples_opportunity_status',
        'idx_samples_planned_test',
        'idx_registrations_opportunity',
        'idx_registrations_status_expected',
        'idx_registrations_document_due',
        'idx_tenders_opportunity',
        'idx_tenders_status_deadline',
      });
    });

    test('v3 跟进、v4 任务、v5 报价样品和 v6/v7 业务字段已建成', () async {
      expect(
        await _columnNames(db, 'followups'),
        containsAll({
          'feedback',
          'stage',
          'next_action',
          'next_follow_at',
          'pause_reason',
          'contact_name_snapshot',
        }),
      );
      expect(
        await _columnNames(db, 'opportunities'),
        containsAll({'last_follow_at', 'owner', 'importance'}),
      );
      expect(await _columnNames(db, 'customers'), contains('country'));
      expect(
        await _columnNames(db, 'follow_plans'),
        containsAll({
          'source_type',
          'source_id',
          'rule_key',
          'reason',
          'talking_direction',
          'next_action',
          'owner',
          'cancelled_at',
        }),
      );
      expect(
        await _columnNames(db, 'quotes'),
        containsAll({'quote_no', 'version', 'valid_until'}),
      );
      expect(
        await _columnNames(db, 'samples'),
        containsAll({'sent_at', 'delivered_at', 'planned_test_at', 'status'}),
      );
      expect(
        await _columnNames(db, 'orders'),
        containsAll({
          'pi_po_no',
          'currency',
          'payment_status',
          'production_status',
          'shipping_status',
          'estimated_arrival_at',
          'order_result',
          'estimated_repurchase_at',
        }),
      );
    });

    test('user_version 写入为 10', () async {
      // drift 用 SQLite 的 user_version 记录 schema 版本，
      // 这个值不对的话后续 onUpgrade 会走错分支。
      final row = await db.customSelect('PRAGMA user_version').getSingle();
      expect(row.data.values.first, 10);
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
      expect(sql, contains('quote_id'));
      expect(sql, contains('sample_id'));
      expect(sql, contains('registration_id'));
      expect(sql, contains('tender_id'));
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
      expect(rows.length, 36);
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
      expect(version.data.values.first, 10);

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

      final migratedFollowup = await migrated.customSelect('''
            SELECT feedback, stage, next_action, next_follow_at, pause_reason
            FROM followups
            WHERE id = 1
          ''').getSingle();
      expect(migratedFollowup.read<String>('feedback'), '旧跟进');
      expect(migratedFollowup.read<String>('stage'), 'new_lead');
      expect(migratedFollowup.read<String>('next_action'), '历史跟进（未记录下一步行动）');
      expect(migratedFollowup.read<int?>('next_follow_at'), isNull);
      expect(migratedFollowup.read<String?>('pause_reason'), isNull);

      final projectLastFollowAt = await migrated.customSelect('''
            SELECT last_follow_at, owner, importance
            FROM opportunities WHERE customer_id = 1
          ''').getSingle();
      expect(projectLastFollowAt.read<int>('last_follow_at'), 1785888000000);
      expect(projectLastFollowAt.read<String>('owner'), '本人');
      expect(projectLastFollowAt.read<String>('importance'), 'normal');

      await _expectLegacyTaskBackfill(migrated);

      final foreignKeyErrors = await migrated
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(foreignKeyErrors, isEmpty);
    } finally {
      await migrated.close();
      await directory.delete(recursive: true);
    }
  });

  test('v2 真库升级后无损回填快照与项目最后跟进时间', () async {
    final directory = await Directory.systemTemp.createTemp('customer-v2-');
    final file = File('${directory.path}/customer.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    try {
      _createV1Schema(raw);
      _seedV1Data(raw);
      _upgradeFixtureToV2(raw);
    } finally {
      raw.close();
    }

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await migrated.customSelect('SELECT 1').getSingle();

      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.first, 10);

      final followup = await migrated.customSelect('''
            SELECT opportunity_id, content, conclusion, feedback, stage,
                   next_action, next_follow_at, pause_reason
            FROM followups
            WHERE id = 1
          ''').getSingle();
      expect(followup.read<int>('opportunity_id'), 1);
      expect(followup.read<String>('content'), '旧跟进');
      expect(followup.read<String>('conclusion'), '旧结论');
      expect(followup.read<String>('feedback'), '旧结论');
      expect(followup.read<String>('stage'), 'quoted');
      expect(followup.read<String>('next_action'), '发送修订报价');
      expect(followup.read<int?>('next_follow_at'), isNull);
      expect(followup.read<String?>('pause_reason'), isNull);

      final opportunity = await migrated.customSelect('''
            SELECT stage, latest_feedback, next_action, next_follow_at,
                   last_follow_at
            FROM opportunities
            WHERE id = 1
          ''').getSingle();
      expect(opportunity.read<String>('stage'), 'quoted');
      expect(opportunity.read<String>('latest_feedback'), '原项目反馈');
      expect(opportunity.read<String>('next_action'), '发送修订报价');
      expect(opportunity.read<int>('next_follow_at'), 1786492800000);
      expect(opportunity.read<int>('last_follow_at'), 1785888000000);
      final taskFields = await migrated.customSelect('''
            SELECT owner, importance FROM opportunities WHERE id = 1
          ''').getSingle();
      expect(taskFields.read<String>('owner'), '本人');
      expect(taskFields.read<String>('importance'), 'normal');

      await _expectLegacyTaskBackfill(migrated);

      for (final table in [
        'customers',
        'opportunities',
        'followups',
        'follow_plans',
        'orders',
      ]) {
        final count = await migrated
            .customSelect('SELECT COUNT(*) AS count FROM $table')
            .getSingle();
        expect(count.read<int>('count'), isPositive, reason: table);
      }
      final attachments = await migrated
          .customSelect('SELECT COUNT(*) AS count FROM attachments')
          .getSingle();
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

  test('v3 真库升级只增加任务基础字段并保留原记录', () async {
    final directory = await Directory.systemTemp.createTemp('customer-v3-');
    final file = File('${directory.path}/customer.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    try {
      _createV1Schema(raw);
      _seedV1Data(raw);
      _upgradeFixtureToV2(raw);
      _upgradeFixtureToV3(raw);
    } finally {
      raw.close();
    }

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await migrated.customSelect('SELECT 1').getSingle();
      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.first, 10);
      await _expectLegacyTaskBackfill(migrated);

      final followup = await migrated.customSelect('''
            SELECT feedback, stage, next_action FROM followups WHERE id = 1
          ''').getSingle();
      expect(followup.read<String>('feedback'), '旧结论');
      expect(followup.read<String>('stage'), 'quoted');
      expect(followup.read<String>('next_action'), '发送修订报价');

      final foreignKeyErrors = await migrated
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(foreignKeyErrors, isEmpty);
    } finally {
      await migrated.close();
      await directory.delete(recursive: true);
    }
  });

  test('v5 真库升级到 v10 后无损保留订单和附件', () async {
    final directory = await Directory.systemTemp.createTemp('customer-v5-');
    final file = File('${directory.path}/customer.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    try {
      _createV5Fixture(raw);
    } finally {
      raw.close();
    }

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await migrated.customSelect('SELECT 1').getSingle();

      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.first, 10);

      final orders = await migrated.customSelect('''
            SELECT customer_id, opportunity_id, order_no, ordered_at,
                   amount_cents, description, status, currency,
                   payment_status, production_status, shipping_status,
                   order_result, created_at, updated_at
            FROM orders
            ORDER BY id
          ''').get();
      expect(orders, hasLength(5));

      const expectedStates = [
        ('pending', 'pending', 'pending', 'pending', 'inProgress'),
        ('shipped', 'pending', 'completed', 'shipped', 'inProgress'),
        ('paid', 'paid', 'completed', 'shipped', 'inProgress'),
        ('completed', 'paid', 'completed', 'delivered', 'completed'),
        ('cancelled', 'cancelled', 'cancelled', 'cancelled', 'cancelled'),
      ];
      for (var index = 0; index < orders.length; index++) {
        final row = orders[index];
        final expected = expectedStates[index];
        expect(row.read<int>('customer_id'), 1);
        expect(row.read<int>('opportunity_id'), 1);
        expect(row.read<String>('order_no'), 'V5-00${index + 1}');
        expect(row.read<int>('ordered_at'), 1785888000000 + index);
        expect(row.read<int>('amount_cents'), 10000 + index);
        expect(row.read<String>('description'), '旧订单${index + 1}');
        expect(row.read<String>('status'), expected.$1);
        expect(row.read<String>('currency'), 'CNY');
        expect(row.read<String>('payment_status'), expected.$2);
        expect(row.read<String>('production_status'), expected.$3);
        expect(row.read<String>('shipping_status'), expected.$4);
        expect(row.read<String>('order_result'), expected.$5);
        expect(row.read<int>('created_at'), 1785888000100 + index);
        expect(row.read<int>('updated_at'), 1785888000200 + index);
      }

      final attachments = await migrated.customSelect('''
            SELECT id, followup_id, order_id, quote_id, sample_id,
                   registration_id, tender_id, relative_path, original_name,
                   mime_type, size_bytes, created_at, updated_at
            FROM attachments
            ORDER BY id
          ''').get();
      expect(attachments, hasLength(2));

      final followupAttachment = attachments[0];
      expect(followupAttachment.read<int>('id'), 41);
      expect(followupAttachment.read<int>('followup_id'), 1);
      expect(followupAttachment.read<int?>('order_id'), isNull);
      expect(
        followupAttachment.read<String>('relative_path'),
        'attachments/2026/08/followup.jpg',
      );
      expect(followupAttachment.read<String>('original_name'), '客户现场.jpg');
      expect(followupAttachment.read<String>('mime_type'), 'image/jpeg');
      expect(followupAttachment.read<int>('size_bytes'), 123456);
      expect(followupAttachment.read<int>('created_at'), 1785888000101);
      expect(followupAttachment.read<int>('updated_at'), 1785888000201);

      final orderAttachment = attachments[1];
      expect(orderAttachment.read<int>('id'), 42);
      expect(orderAttachment.read<int?>('followup_id'), isNull);
      expect(orderAttachment.read<int>('order_id'), 1);
      expect(
        orderAttachment.read<String>('relative_path'),
        'attachments/2026/08/order.pdf',
      );
      expect(orderAttachment.read<String>('original_name'), 'PI-2026-001.pdf');
      expect(orderAttachment.read<String>('mime_type'), 'application/pdf');
      expect(orderAttachment.read<int>('size_bytes'), 654321);
      expect(orderAttachment.read<int>('created_at'), 1785888000102);
      expect(orderAttachment.read<int>('updated_at'), 1785888000202);

      for (final attachment in attachments) {
        expect(attachment.read<int?>('quote_id'), isNull);
        expect(attachment.read<int?>('sample_id'), isNull);
        expect(attachment.read<int?>('registration_id'), isNull);
        expect(attachment.read<int?>('tender_id'), isNull);
      }

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

Future<Set<String>> _columnNames(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info($table)').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<void> _expectLegacyTaskBackfill(AppDatabase db) async {
  final task = await db.customSelect('''
        SELECT id, customer_id, opportunity_id, title, plan_at, status,
               notified_at, completed_at, source_type, source_id, rule_key,
               reason, talking_direction, next_action, owner, cancelled_at
        FROM follow_plans WHERE id = 1
      ''').getSingle();
  expect(task.read<int>('id'), 1);
  expect(task.read<int>('customer_id'), 1);
  expect(task.read<int>('opportunity_id'), 1);
  expect(task.read<String>('title'), '旧计划');
  expect(task.read<int>('plan_at'), 1785888000000);
  expect(task.read<String>('status'), 'pending');
  expect(task.read<int?>('notified_at'), isNull);
  expect(task.read<int?>('completed_at'), isNull);
  expect(task.read<String>('source_type'), 'legacy');
  expect(task.read<int?>('source_id'), isNull);
  expect(task.read<String?>('rule_key'), isNull);
  expect(task.read<String?>('reason'), isNull);
  expect(task.read<String?>('talking_direction'), isNull);
  expect(task.read<String>('next_action'), '旧计划');
  expect(task.read<String>('owner'), '本人');
  expect(task.read<int?>('cancelled_at'), isNull);
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

void _upgradeFixtureToV2(sqlite.Database db) {
  db.execute('''
    CREATE TABLE opportunities (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      product_category TEXT,
      product_model TEXT,
      equipment_brand TEXT,
      equipment_model TEXT,
      estimated_annual_volume INTEGER,
      forecast_amount_minor INTEGER,
      currency TEXT NOT NULL DEFAULT 'USD',
      probability_percent INTEGER,
      expected_close_at INTEGER,
      current_supplier TEXT,
      current_purchase_brand TEXT,
      current_purchase_price_minor INTEGER,
      supplier_stability TEXT,
      supplier_problem TEXT,
      change_willingness TEXT,
      substitution_difficulty TEXT,
      latest_quote_minor INTEGER,
      target_price_minor INTEGER,
      entry_point TEXT,
      investment_advice TEXT,
      needs_sample INTEGER NOT NULL DEFAULT 0,
      needs_registration INTEGER NOT NULL DEFAULT 0,
      needs_authorization INTEGER NOT NULL DEFAULT 0,
      stage TEXT NOT NULL DEFAULT 'new_lead',
      status TEXT NOT NULL DEFAULT 'active',
      latest_feedback TEXT,
      current_obstacle TEXT,
      next_action TEXT,
      next_follow_at INTEGER,
      is_legacy_default INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('ALTER TABLE followups ADD COLUMN opportunity_id INTEGER');
  db.execute('ALTER TABLE follow_plans ADD COLUMN opportunity_id INTEGER');
  db.execute('ALTER TABLE orders ADD COLUMN opportunity_id INTEGER');
  db.execute('''
    INSERT INTO opportunities (
      customer_id, name, stage, status, latest_feedback, next_action,
      next_follow_at, is_legacy_default, created_at, updated_at
    ) VALUES (
      1, 'CT 注射器', 'quoted', 'active', '原项目反馈', '发送修订报价',
      1786492800000, 0, 1785888000000, 1785888000000
    )
  ''');
  db.execute("UPDATE followups SET opportunity_id = 1, conclusion = '旧结论'");
  db.execute('UPDATE follow_plans SET opportunity_id = 1');
  db.execute('UPDATE orders SET opportunity_id = 1');
  db.execute('PRAGMA user_version = 2');
}

void _upgradeFixtureToV3(sqlite.Database db) {
  db.execute('ALTER TABLE followups ADD COLUMN feedback TEXT');
  db.execute('ALTER TABLE followups ADD COLUMN stage TEXT');
  db.execute('ALTER TABLE followups ADD COLUMN next_action TEXT');
  db.execute('ALTER TABLE followups ADD COLUMN next_follow_at INTEGER');
  db.execute('ALTER TABLE followups ADD COLUMN pause_reason TEXT');
  db.execute('ALTER TABLE opportunities ADD COLUMN last_follow_at INTEGER');
  db.execute('''
    UPDATE followups
    SET feedback = '旧结论',
        stage = 'quoted',
        next_action = '发送修订报价'
  ''');
  db.execute('UPDATE opportunities SET last_follow_at = 1785888000000');
  db.execute('PRAGMA user_version = 3');
}

void _createV5Fixture(sqlite.Database db) {
  db.execute('PRAGMA foreign_keys = ON');
  db.execute('''
    CREATE TABLE customers (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE opportunities (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE followups (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      opportunity_id INTEGER REFERENCES opportunities(id) ON DELETE SET NULL,
      occurred_at INTEGER NOT NULL,
      method TEXT NOT NULL,
      content TEXT NOT NULL,
      conclusion TEXT,
      feedback TEXT,
      stage TEXT,
      next_action TEXT,
      next_follow_at INTEGER,
      pause_reason TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE orders (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      opportunity_id INTEGER REFERENCES opportunities(id) ON DELETE SET NULL,
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
    CREATE TABLE quotes (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      opportunity_id INTEGER NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
      quote_no TEXT NOT NULL,
      version INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      currency TEXT NOT NULL,
      quoted_at INTEGER NOT NULL,
      customer_received INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE samples (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      opportunity_id INTEGER NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
      quantity INTEGER NOT NULL,
      status TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
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

  db.execute('''
    INSERT INTO customers (id, name, created_at, updated_at)
    VALUES (1, 'v5 客户', 1785888000000, 1785888000000)
  ''');
  db.execute('''
    INSERT INTO opportunities (id, customer_id, name, created_at, updated_at)
    VALUES (1, 1, 'v5 项目', 1785888000000, 1785888000000)
  ''');
  db.execute('''
    INSERT INTO followups (
      id, customer_id, opportunity_id, occurred_at, method, content,
      created_at, updated_at
    ) VALUES (
      1, 1, 1, 1785888000000, 'email', 'v5 跟进',
      1785888000000, 1785888000000
    )
  ''');
  db.execute('''
    INSERT INTO quotes (
      id, opportunity_id, quote_no, version, quantity, currency, quoted_at,
      customer_received, created_at, updated_at
    ) VALUES (
      1, 1, 'V5-Q-001', 1, 100, 'USD', 1785888000000,
      1, 1785888000000, 1785888000000
    )
  ''');
  db.execute('''
    INSERT INTO samples (
      id, opportunity_id, quantity, status, created_at, updated_at
    ) VALUES (
      1, 1, 2, 'sent', 1785888000000, 1785888000000
    )
  ''');

  const statuses = ['pending', 'shipped', 'paid', 'completed', 'cancelled'];
  for (var index = 0; index < statuses.length; index++) {
    db.execute(
      '''
        INSERT INTO orders (
          customer_id, opportunity_id, order_no, ordered_at, amount_cents,
          description, status, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        1,
        1,
        'V5-00${index + 1}',
        1785888000000 + index,
        10000 + index,
        '旧订单${index + 1}',
        statuses[index],
        1785888000100 + index,
        1785888000200 + index,
      ],
    );
  }
  db.execute('''
    INSERT INTO attachments (
      id, followup_id, relative_path, original_name, mime_type, size_bytes,
      created_at, updated_at
    ) VALUES (
      41, 1, 'attachments/2026/08/followup.jpg', '客户现场.jpg', 'image/jpeg',
      123456, 1785888000101, 1785888000201
    )
  ''');
  db.execute('''
    INSERT INTO attachments (
      id, order_id, relative_path, original_name, mime_type, size_bytes,
      created_at, updated_at
    ) VALUES (
      42, 1, 'attachments/2026/08/order.pdf', 'PI-2026-001.pdf',
      'application/pdf', 654321, 1785888000102, 1785888000202
    )
  ''');
  db.execute('PRAGMA user_version = 5');
}
