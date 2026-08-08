import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'v9 upgrades backfill contact name snapshots without changing history',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'contact-snapshot-v9-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/customer.sqlite');
      final raw = sqlite.sqlite3.open(file.path);
      raw.execute('PRAGMA foreign_keys = ON');
      raw.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
      raw.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
      raw.execute('''
      CREATE TABLE opportunities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');
      raw.execute('''
      CREATE TABLE followups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
        opportunity_id INTEGER REFERENCES opportunities(id) ON DELETE SET NULL,
        contact_id INTEGER REFERENCES contacts(id) ON DELETE SET NULL,
        occurred_at INTEGER NOT NULL,
        method TEXT NOT NULL,
        content TEXT NOT NULL,
        conclusion TEXT,
        feedback TEXT,
        stage TEXT,
        next_action TEXT,
        next_follow_at INTEGER,
        pause_reason TEXT,
        attitude TEXT,
        owner TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
      raw.execute(
        "INSERT INTO customers(id, name, created_at, updated_at) VALUES (1, '旧客户', 10, 11)",
      );
      raw.execute(
        "INSERT INTO contacts(id, customer_id, name, created_at, updated_at) VALUES (7, 1, '李经理', 12, 13)",
      );
      raw.execute('''
      INSERT INTO followups (
        id, customer_id, contact_id, occurred_at, method, content,
        conclusion, feedback, stage, next_action, next_follow_at,
        attitude, owner, created_at, updated_at
      ) VALUES (
        21, 1, 7, 100, 'phone', '确认需求', '继续报价', '预算明确',
        'needs_confirmed', '发送报价', 200, 'positive', '何夕', 101, 102
      )
    ''');
      raw.execute('''
      INSERT INTO followups (
        id, customer_id, occurred_at, method, content,
        pause_reason, created_at, updated_at
      ) VALUES (22, 1, 110, 'email', '邮件跟进', '等待客户', 111, 112)
    ''');
      raw.execute('PRAGMA user_version = 9');
      raw.close();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      await db.customSelect('SELECT 1').getSingle();

      expect(db.schemaVersion, 10);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 10);

      final rows = await db.customSelect('''
      SELECT id, contact_id, contact_name_snapshot, content, feedback, stage,
             next_action, next_follow_at, pause_reason, attitude, owner,
             created_at, updated_at
      FROM followups
      ORDER BY id
    ''').get();
      expect(rows[0].data, {
        'id': 21,
        'contact_id': 7,
        'contact_name_snapshot': '李经理',
        'content': '确认需求',
        'feedback': '预算明确',
        'stage': 'needs_confirmed',
        'next_action': '发送报价',
        'next_follow_at': 200,
        'pause_reason': null,
        'attitude': 'positive',
        'owner': '何夕',
        'created_at': 101,
        'updated_at': 102,
      });
      expect(rows[1].read<String?>('contact_name_snapshot'), isNull);
      expect(rows[1].read<String>('content'), '邮件跟进');
      expect(rows[1].read<String>('pause_reason'), '等待客户');

      final foreignKeyErrors = await db
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(foreignKeyErrors, isEmpty);
    },
  );
}
