import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'helpers.dart';

void main() {
  test('v8 新库包含可空示例批次列和局部索引', () async {
    final db = await openTestDb();
    try {
      expect(db.schemaVersion, 11);

      final columns = await db
          .customSelect('PRAGMA table_info(customers)')
          .get();
      final sampleColumn = columns.singleWhere(
        (row) => row.read<String>('name') == 'sample_batch_id',
      );
      expect(sampleColumn.read<int>('notnull'), 0);

      final index = await db.customSelect('''
        SELECT sql FROM sqlite_master
        WHERE type = 'index' AND name = 'idx_customers_sample_batch'
      ''').getSingle();
      expect(index.read<String>('sql'), contains('sample_batch_id'));
      expect(index.read<String>('sql'), contains('IS NOT NULL'));
    } finally {
      await db.close();
    }
  });

  test('v7 升级到 v8 保留正式客户且批次标记为空', () async {
    final directory = await Directory.systemTemp.createTemp('sample-v7-');
    final file = File('${directory.path}/customer.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    try {
      raw.execute('''
        CREATE TABLE customers (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 50),
          company TEXT NULL,
          country TEXT NULL,
          phone TEXT NULL,
          wechat TEXT NULL,
          address TEXT NULL,
          source TEXT NULL,
          note TEXT NULL,
          stage TEXT NOT NULL DEFAULT 'potential',
          grade TEXT NOT NULL DEFAULT 'c',
          last_follow_at INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      raw.execute('''
        INSERT INTO customers (
          id, name, company, country, phone, stage, grade,
          created_at, updated_at
        ) VALUES (
          7, '正式客户', 'Formal Medical', 'DE', '+49-123', 'contacted', 'b',
          1785888000101, 1785888000202
        )
      ''');
      raw.execute('PRAGMA user_version = 7');
    } finally {
      raw.close();
    }

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await migrated.customSelect('SELECT 1').getSingle();

      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.single, 11);

      final row = await migrated.customSelect('''
        SELECT id, name, company, country, phone, stage, grade,
               sample_batch_id, created_at, updated_at
        FROM customers
      ''').getSingle();
      expect(row.data, {
        'id': 7,
        'name': '正式客户',
        'company': 'Formal Medical',
        'country': 'DE',
        'phone': '+49-123',
        'stage': 'contacted',
        'grade': 'b',
        'sample_batch_id': null,
        'created_at': 1785888000101,
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
