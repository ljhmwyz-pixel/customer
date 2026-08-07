import 'package:drift/drift.dart';

import 'customers.dart';

/// 联系人表。一个客户可挂多个联系人。
///
/// 与客户表分开而不是塞几个字段，因为对公客户经常要同时记采购、技术、决策人，
/// 且需要标出谁能拍板。
@DataClassName('ContactRow')
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get position => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get whatsapp => text().nullable()();

  TextColumn get communicationPreference => text().nullable()();

  TextColumn get note => text().nullable()();

  /// 是否决策人。能拍板的那个人要能一眼看出来。
  BoolColumn get isDecisionMaker =>
      boolean().withDefault(const Constant(false))();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
