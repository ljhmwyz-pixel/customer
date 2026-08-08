import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('v10 upgrades add change history and task repair queue', () async {
    final directory = await Directory.systemTemp.createTemp('customer-v11-');
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
      CREATE TABLE opportunities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    raw.execute(
      "INSERT INTO customers(id, name, created_at, updated_at) VALUES (1, '旧客户', 10, 11)",
    );
    raw.execute(
      "INSERT INTO opportunities(id, customer_id, name, created_at, updated_at) VALUES (2, 1, '旧项目', 12, 13)",
    );
    raw.execute('PRAGMA user_version = 10');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').getSingle();

    expect(db.schemaVersion, 11);
    final tables = await db.customSelect('''
      SELECT name FROM sqlite_master
      WHERE type = 'table'
        AND name IN ('opportunity_changes', 'task_reconciliation_jobs')
      ORDER BY name
    ''').get();
    expect(tables.map((row) => row.read<String>('name')).toList(), [
      'opportunity_changes',
      'task_reconciliation_jobs',
    ]);
    final opportunity = await db
        .customSelect(
          'SELECT name, created_at, updated_at FROM opportunities WHERE id = 2',
        )
        .getSingle();
    expect(opportunity.data, {
      'name': '旧项目',
      'created_at': 12,
      'updated_at': 13,
    });
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}
