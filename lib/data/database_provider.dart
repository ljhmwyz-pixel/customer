import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// 全局唯一的数据库实例。
///
/// drift 的数据库对象不能重复创建：多个实例共用同一个文件会产生竞态，
/// 甚至损坏数据。整个应用只从这里取。
///
/// 注意后台 isolate（通知按钮回调）拿不到这个 provider，
/// 那边要自己新开连接，见 services/notification_actions.dart。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final customerDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).customerDao,
);

final contactDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).contactDao,
);

final followupDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).followupDao,
);

final planDaoProvider = Provider((ref) => ref.watch(databaseProvider).planDao);

final orderDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).orderDao,
);

final attachmentDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).attachmentDao,
);
