import 'dart:io';

import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'helpers.dart';

const _ownerColumns = <String>[
  'followup_id',
  'order_id',
  'quote_id',
  'sample_id',
  'registration_id',
  'tender_id',
];

const _ownerIndexes = <String>{
  'idx_attachments_followup',
  'idx_attachments_order',
  'idx_attachments_quote',
  'idx_attachments_sample',
  'idx_attachments_registration',
  'idx_attachments_tender',
};

void main() {
  group('v7 新库附件结构', () {
    late AppDatabase db;

    setUp(() async {
      db = await openTestDb();
      await _seedAllOwners(db);
    });

    tearDown(() async => db.close());

    test('版本、六个归属列、六个索引和 CHECK 均已落地', () async {
      expect(db.schemaVersion, 9);

      final columns = await db
          .customSelect('PRAGMA table_info(attachments)')
          .get();
      expect(
        columns.map((row) => row.read<String>('name')).toSet(),
        containsAll(_ownerColumns),
      );

      final indexes = await db.customSelect('''
        SELECT name FROM sqlite_master
        WHERE type = 'index' AND name LIKE 'idx_attachments_%'
      ''').get();
      expect(
        indexes.map((row) => row.read<String>('name')).toSet(),
        _ownerIndexes,
      );

      final table = await db.customSelect('''
        SELECT sql FROM sqlite_master
        WHERE type = 'table' AND name = 'attachments'
      ''').getSingle();
      final sql = table.read<String>('sql');
      expect(sql, contains('CHECK'));
      for (final column in _ownerColumns) {
        expect(sql, contains(column), reason: '$column 必须参与六选一约束');
      }
    });

    test('六种单一归属均可写入', () async {
      for (final column in _ownerColumns) {
        await _insertAttachment(db, ownerColumn: column, suffix: column);
      }

      final count = await db
          .customSelect('SELECT COUNT(*) AS count FROM attachments')
          .getSingle();
      expect(count.read<int>('count'), 6);
    });

    test('DAO 可按六种类型安全归属写入、查询和计数', () async {
      const owners = <AttachmentOwner>[
        FollowupAttachmentOwner(1),
        OrderAttachmentOwner(1),
        QuoteAttachmentOwner(1),
        SampleAttachmentOwner(1),
        RegistrationAttachmentOwner(1),
        TenderAttachmentOwner(1),
      ];

      for (var index = 0; index < owners.length; index++) {
        final owner = owners[index];
        await db.attachmentDao.insertAttachment(
          owner: owner,
          relativePath: 'attachments/dao-$index',
          originalName: 'dao-$index',
          mimeType: 'text/plain',
          sizeBytes: index + 1,
        );

        expect(await db.attachmentDao.listOf(owner), hasLength(1));
        expect(await db.attachmentDao.countOf(owner), 1);
      }
    });

    test('零归属和双归属均被 CHECK 拒绝', () async {
      expect(
        () => db.customStatement('''
          INSERT INTO attachments (
            relative_path, original_name, mime_type, size_bytes,
            created_at, updated_at
          ) VALUES ('attachments/none', 'none', 'text/plain', 1, 10, 11)
        '''),
        throwsA(anything),
      );
      expect(
        () => db.customStatement('''
          INSERT INTO attachments (
            followup_id, order_id, relative_path, original_name,
            mime_type, size_bytes, created_at, updated_at
          ) VALUES (
            1, 1, 'attachments/double', 'double',
            'text/plain', 2, 12, 13
          )
        '''),
        throwsA(anything),
      );
    });
  });

  for (final entry in const <String, String>{
    'followup_id': 'followups',
    'order_id': 'orders',
    'quote_id': 'quotes',
    'sample_id': 'samples',
    'registration_id': 'registrations',
    'tender_id': 'tenders',
  }.entries) {
    test('删除 ${entry.value} 会级联删除对应附件', () async {
      final db = await openTestDb();
      try {
        await _seedAllOwners(db);
        await _insertAttachment(
          db,
          ownerColumn: entry.key,
          suffix: entry.value,
        );

        await db.customStatement('DELETE FROM ${entry.value} WHERE id = 1');

        final count = await db
            .customSelect('SELECT COUNT(*) AS count FROM attachments')
            .getSingle();
        expect(count.read<int>('count'), 0);
      } finally {
        await db.close();
      }
    });
  }

  test('v6 升级到 v7 无损保留跟进和订单附件', () async {
    final directory = await Directory.systemTemp.createTemp('attachment-v6-');
    final file = File('${directory.path}/customer.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    try {
      _createV6Fixture(raw);
    } finally {
      raw.close();
    }

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await migrated.customSelect('SELECT 1').getSingle();

      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.first, 9);

      final rows = await migrated.customSelect('''
        SELECT id, followup_id, order_id, quote_id, sample_id,
               registration_id, tender_id, relative_path, original_name,
               mime_type, size_bytes, created_at, updated_at
        FROM attachments ORDER BY id
      ''').get();
      expect(rows, hasLength(2));

      expect(rows[0].data, {
        'id': 41,
        'followup_id': 11,
        'order_id': null,
        'quote_id': null,
        'sample_id': null,
        'registration_id': null,
        'tender_id': null,
        'relative_path': 'attachments/2026/08/followup.jpg',
        'original_name': '客户现场.jpg',
        'mime_type': 'image/jpeg',
        'size_bytes': 123456,
        'created_at': 1785888000101,
        'updated_at': 1785888000201,
      });
      expect(rows[1].data, {
        'id': 42,
        'followup_id': null,
        'order_id': 21,
        'quote_id': null,
        'sample_id': null,
        'registration_id': null,
        'tender_id': null,
        'relative_path': 'attachments/2026/08/order.pdf',
        'original_name': 'PI-2026-001.pdf',
        'mime_type': 'application/pdf',
        'size_bytes': 654321,
        'created_at': 1785888000102,
        'updated_at': 1785888000202,
      });

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

Future<void> _seedAllOwners(AppDatabase db) async {
  const now = 1785888000000;
  await db.customStatement('''
    INSERT INTO customers (id, name, created_at, updated_at)
    VALUES (1, '附件客户', $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO opportunities (id, customer_id, name, created_at, updated_at)
    VALUES (1, 1, '附件项目', $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO followups (
      id, customer_id, opportunity_id, occurred_at, method, content,
      created_at, updated_at
    ) VALUES (1, 1, 1, $now, 'phone', '附件测试', $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO orders (
      id, customer_id, opportunity_id, order_no, ordered_at, amount_cents,
      created_at, updated_at
    ) VALUES (1, 1, 1, 'ATT-001', $now, 100, $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO quotes (
      id, opportunity_id, quote_no, version, quantity, quoted_at,
      created_at, updated_at
    ) VALUES (1, 1, 'Q-001', 1, 1, $now, $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO samples (id, opportunity_id, quantity, created_at, updated_at)
    VALUES (1, 1, 1, $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO registrations (id, opportunity_id, created_at, updated_at)
    VALUES (1, 1, $now, $now)
  ''');
  await db.customStatement('''
    INSERT INTO tenders (id, opportunity_id, created_at, updated_at)
    VALUES (1, 1, $now, $now)
  ''');
}

Future<void> _insertAttachment(
  AppDatabase db, {
  required String ownerColumn,
  required String suffix,
}) => db.customStatement('''
  INSERT INTO attachments (
    $ownerColumn, relative_path, original_name, mime_type, size_bytes,
    created_at, updated_at
  ) VALUES (1, 'attachments/$suffix', '$suffix', 'text/plain', 1, 10, 11)
''');

void _createV6Fixture(sqlite.Database db) {
  db.execute('PRAGMA foreign_keys = ON');
  db.execute('''
    CREATE TABLE followups (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
    )
  ''');
  db.execute('''
    CREATE TABLE orders (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
    )
  ''');
  for (final table in ['quotes', 'samples', 'registrations', 'tenders']) {
    db.execute('''
      CREATE TABLE $table (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
      )
    ''');
  }
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
  db.execute('INSERT INTO followups (id) VALUES (11)');
  db.execute('INSERT INTO orders (id) VALUES (21)');
  db.execute('''
    INSERT INTO attachments (
      id, followup_id, relative_path, original_name, mime_type, size_bytes,
      created_at, updated_at
    ) VALUES (
      41, 11, 'attachments/2026/08/followup.jpg', '客户现场.jpg',
      'image/jpeg', 123456, 1785888000101, 1785888000201
    )
  ''');
  db.execute('''
    INSERT INTO attachments (
      id, order_id, relative_path, original_name, mime_type, size_bytes,
      created_at, updated_at
    ) VALUES (
      42, 21, 'attachments/2026/08/order.pdf', 'PI-2026-001.pdf',
      'application/pdf', 654321, 1785888000102, 1785888000202
    )
  ''');
  db.execute('PRAGMA user_version = 6');
}
