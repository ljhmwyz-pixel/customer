// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $TagsTable get tags => attachedDatabase.tags;
  $CustomerTagsTable get customerTags => attachedDatabase.customerTags;
  CustomerDaoManager get managers => CustomerDaoManager(this);
}

class CustomerDaoManager {
  final _$CustomerDaoMixin _db;
  CustomerDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$CustomerTagsTableTableManager get customerTags =>
      $$CustomerTagsTableTableManager(_db.attachedDatabase, _db.customerTags);
}
