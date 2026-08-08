import 'package:customer/data/database.dart';
import 'package:customer/models/enums.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('招标授权类型保持固定数据库值和中文文案', () {
    expect(
      TenderAuthorizationType.values
          .map((type) => (type.dbValue, type.label))
          .toList(),
      [
        ('nonExclusiveProject', '非独家项目授权'),
        ('regional', '区域授权'),
        ('none', '暂不授权'),
      ],
    );
  });

  late AppDatabase db;

  setUp(() async => db = await openTestDb());
  tearDown(() async => db.close());

  test('schema v7 包含注册招标表、订单生命周期列和六个索引', () async {
    expect(db.schemaVersion, 10);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 10);

    final tables = await _objectNames(db, 'table');
    expect(tables, containsAll({'registrations', 'tenders'}));

    final orderColumns = await _columnNames(db, 'orders');
    expect(
      orderColumns,
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

    final indexes = await _objectNames(db, 'index');
    expect(
      indexes,
      containsAll({
        'idx_registrations_opportunity',
        'idx_registrations_status_expected',
        'idx_registrations_document_due',
        'idx_tenders_opportunity',
        'idx_tenders_status_deadline',
        'idx_orders_estimated_repurchase',
      }),
    );
  });

  test('注册与招标记录通过 CASCADE 外键归属项目', () async {
    expect(await _opportunityDeleteAction(db, 'registrations'), 'CASCADE');
    expect(await _opportunityDeleteAction(db, 'tenders'), 'CASCADE');
  });

  test('合法注册、招标和订单生命周期记录可写入', () async {
    final opportunityId = await _seedOpportunity(db);
    const now = 1785888000000;

    await db.customStatement(
      '''
      INSERT INTO registrations (
        opportunity_id, country, requirements, document_checklist,
        document_status, submitted_at, expected_completed_at,
        actual_completed_at, cost_bearer, status, current_obstacle,
        next_action, document_due_at, milestone_at, milestone_title,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        opportunityId,
        'CN',
        '注册要求',
        '营业执照,产品证书',
        'complete',
        now,
        now + 100,
        now + 90,
        '客户',
        'completed',
        '无',
        '归档',
        now + 20,
        now + 30,
        '资料复核',
        now,
        now,
      ],
    );
    await db.customStatement(
      '''
      INSERT INTO tenders (
        opportunity_id, project_no, name, deadline_at, document_status,
        qualification_status, bidder, deposit_minor, customer_experience,
        local_team_status, funding_status, risk_level, authorization_type,
        authorization_expires_at, exclusive_quote_scope,
        floor_price_support, status, next_action, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        opportunityId,
        'T-001',
        '医院项目',
        now + 100,
        'complete',
        'qualified',
        '本地伙伴',
        50000,
        '有同类经验',
        'confirmed',
        'confirmed',
        'mediumHigh',
        'nonExclusiveProject',
        now + 200,
        '本项目',
        '支持',
        'open',
        '准备投标',
        now,
        now,
      ],
    );
    await db.customStatement(
      '''
      INSERT INTO orders (
        customer_id, opportunity_id, order_no, ordered_at, amount_cents,
        pi_po_no, currency, payment_status, production_status,
        shipping_status, estimated_arrival_at, order_result,
        estimated_repurchase_at, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        1,
        opportunityId,
        'E-001',
        now,
        10000,
        'PI-001',
        'USD',
        'partial',
        'inProgress',
        'shipped',
        now + 100,
        'inProgress',
        now + 200,
        now,
        now,
      ],
    );

    for (final table in ['registrations', 'tenders', 'orders']) {
      final count = await db
          .customSelect('SELECT COUNT(*) AS count FROM $table')
          .getSingle();
      expect(count.read<int>('count'), 1, reason: table);
    }
  });

  test('注册资料状态和注册状态拒绝非法枚举', () async {
    final opportunityId = await _seedOpportunity(db);
    await _expectRegistrationRejected(
      db,
      opportunityId,
      documentStatus: 'invalid',
      status: 'preparing',
    );
    await _expectRegistrationRejected(
      db,
      opportunityId,
      documentStatus: 'pending',
      status: 'invalid',
    );
  });

  test('招标枚举与负保证金受 CHECK 约束', () async {
    final opportunityId = await _seedOpportunity(db);
    const validValues = <String, String>{
      'document_status': 'incomplete',
      'qualification_status': 'pending',
      'local_team_status': 'pending',
      'funding_status': 'pending',
      'risk_level': 'mediumHigh',
      'authorization_type': 'none',
      'status': 'preparing',
    };

    for (final entry in validValues.entries) {
      await _expectTenderRejected(
        db,
        opportunityId,
        values: {...validValues, entry.key: 'invalid'},
        depositMinor: 0,
      );
    }
    await _expectTenderRejected(
      db,
      opportunityId,
      values: validValues,
      depositMinor: -1,
    );
  });

  test('订单枚举与负金额受 CHECK 约束', () async {
    final opportunityId = await _seedOpportunity(db);
    const validValues = <String, String>{
      'payment_status': 'pending',
      'production_status': 'pending',
      'shipping_status': 'pending',
      'order_result': 'inProgress',
    };

    for (final entry in validValues.entries) {
      await _expectOrderRejected(
        db,
        opportunityId,
        values: {...validValues, entry.key: 'invalid'},
        amountCents: 0,
        suffix: entry.key,
      );
    }
    await _expectOrderRejected(
      db,
      opportunityId,
      values: validValues,
      amountCents: -1,
      suffix: 'negative',
    );
  });
}

Future<Set<String>> _objectNames(AppDatabase db, String type) async {
  final rows = await db
      .customSelect(
        'SELECT name FROM sqlite_master WHERE type = ? AND name NOT LIKE ?',
        variables: [Variable.withString(type), Variable.withString('sqlite_%')],
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<Set<String>> _columnNames(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info($table)').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<String?> _opportunityDeleteAction(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA foreign_key_list($table)').get();
  for (final row in rows) {
    if (row.read<String>('table') == 'opportunities' &&
        row.read<String>('from') == 'opportunity_id') {
      return row.read<String>('on_delete');
    }
  }
  return null;
}

Future<int> _seedOpportunity(AppDatabase db) async {
  await db.customStatement('''
    INSERT INTO customers (id, name, created_at, updated_at)
    VALUES (1, 'Phase E 客户', 1785888000000, 1785888000000)
  ''');
  await db.customStatement('''
    INSERT INTO opportunities (
      id, customer_id, name, created_at, updated_at
    ) VALUES (1, 1, 'Phase E 项目', 1785888000000, 1785888000000)
  ''');
  return 1;
}

Future<void> _expectRegistrationRejected(
  AppDatabase db,
  int opportunityId, {
  required String documentStatus,
  required String status,
}) async {
  await expectLater(
    db.customStatement(
      '''
        INSERT INTO registrations (
          opportunity_id, document_status, status, created_at, updated_at
        ) VALUES (?, ?, ?, 1785888000000, 1785888000000)
      ''',
      [opportunityId, documentStatus, status],
    ),
    throwsA(anything),
  );
}

Future<void> _expectTenderRejected(
  AppDatabase db,
  int opportunityId, {
  required Map<String, String> values,
  required int depositMinor,
}) async {
  await expectLater(
    db.customStatement(
      '''
        INSERT INTO tenders (
          opportunity_id, document_status, qualification_status,
          local_team_status, funding_status, risk_level, authorization_type,
          status, deposit_minor, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1785888000000, 1785888000000)
      ''',
      [
        opportunityId,
        values['document_status'],
        values['qualification_status'],
        values['local_team_status'],
        values['funding_status'],
        values['risk_level'],
        values['authorization_type'],
        values['status'],
        depositMinor,
      ],
    ),
    throwsA(anything),
  );
}

Future<void> _expectOrderRejected(
  AppDatabase db,
  int opportunityId, {
  required Map<String, String> values,
  required int amountCents,
  required String suffix,
}) async {
  await expectLater(
    db.customStatement(
      '''
        INSERT INTO orders (
          customer_id, opportunity_id, order_no, ordered_at, amount_cents,
          payment_status, production_status, shipping_status, order_result,
          created_at, updated_at
        ) VALUES (1, ?, ?, 1785888000000, ?, ?, ?, ?, ?,
                  1785888000000, 1785888000000)
      ''',
      [
        opportunityId,
        'INVALID-$suffix',
        amountCents,
        values['payment_status'],
        values['production_status'],
        values['shipping_status'],
        values['order_result'],
      ],
    ),
    throwsA(anything),
  );
}
