// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_dao.dart';

// ignore_for_file: type=lint
mixin _$ContactDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $ContactsTable get contacts => attachedDatabase.contacts;
  ContactDaoManager get managers => ContactDaoManager(this);
}

class ContactDaoManager {
  final _$ContactDaoMixin _db;
  ContactDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
}
