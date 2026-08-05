// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_dao.dart';

// ignore_for_file: type=lint
mixin _$QuoteDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $QuotesTable get quotes => attachedDatabase.quotes;
  QuoteDaoManager get managers => QuoteDaoManager(this);
}

class QuoteDaoManager {
  final _$QuoteDaoMixin _db;
  QuoteDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db.attachedDatabase, _db.quotes);
}
