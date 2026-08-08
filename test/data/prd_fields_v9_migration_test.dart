import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('v8 upgrades add PRD fields without inventing business facts', () async {
    final dir = await Directory.systemTemp.createTemp('customer-v9-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/legacy.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('PRAGMA foreign_keys = ON');
    raw.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        company TEXT, country TEXT, phone TEXT, wechat TEXT, address TEXT,
        source TEXT, note TEXT, stage TEXT NOT NULL DEFAULT 'potential',
        grade TEXT NOT NULL DEFAULT 'c', sample_batch_id TEXT,
        last_follow_at INTEGER, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
        name TEXT NOT NULL, position TEXT, phone TEXT,
        is_decision_maker INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
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
        occurred_at INTEGER NOT NULL, method TEXT NOT NULL, content TEXT NOT NULL,
        conclusion TEXT, feedback TEXT, stage TEXT, next_action TEXT,
        next_follow_at INTEGER, pause_reason TEXT,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute(
      "INSERT INTO customers(name, created_at, updated_at) VALUES ('旧客户', 1, 1)",
    );
    raw.execute(
      "INSERT INTO contacts(customer_id, name, created_at, updated_at) VALUES (1, '旧联系人', 1, 1)",
    );
    raw.execute(
      "INSERT INTO followups(customer_id, occurred_at, method, content, created_at, updated_at) VALUES (1, 1, 'phone', '旧跟进', 1, 1)",
    );
    raw.execute('PRAGMA user_version = 8');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').getSingle();

    expect(db.schemaVersion, 10);
    expect((await db.customerDao.findById(1))!.owner, '本人');
    final contact = await db.contactDao.findById(1);
    expect(contact!.email, isNull);
    expect(contact.whatsapp, isNull);
    final followup = await db.followupDao.findById(1);
    expect(followup!.contactId, isNull);
    expect(followup.contactNameSnapshot, isNull);
    expect(followup.attitude, isNull);
    expect(followup.owner, isNull);
    final fkErrors = await db.customSelect('PRAGMA foreign_key_check').get();
    expect(fkErrors, isEmpty);
  });
}
