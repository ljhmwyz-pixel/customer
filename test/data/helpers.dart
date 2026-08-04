import 'package:customer/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

/// 建一个开好外键约束的内存数据库。
///
/// drift 的 `beforeOpen` 只在真正打开连接时执行，所以这里先跑一次查询把连接
/// 逼开，避免测试里第一条语句在外键仍关闭的状态下执行。
Future<AppDatabase> openTestDb() async {
  final db = AppDatabase.memory();
  final on = await db
      .customSelect('PRAGMA foreign_keys')
      .map((r) => r.data.values.first)
      .getSingle();
  // 外键没开的话级联删除会静默失效，整组级联测试会假通过，所以这里直接卡住。
  expect(on, anyOf(1, true), reason: 'PRAGMA foreign_keys 未生效');
  return db;
}

/// 建一个客户，返回 id。测试里大量用到，省掉重复的必填参数。
Future<int> seedCustomer(
  AppDatabase db, {
  String name = '张三',
  String? phone = '13800000000',
}) => db.customerDao.insertCustomer(name: name, phone: phone);
