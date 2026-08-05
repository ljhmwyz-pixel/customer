// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tender_dao.dart';

// ignore_for_file: type=lint
mixin _$TenderDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $TendersTable get tenders => attachedDatabase.tenders;
  TenderDaoManager get managers => TenderDaoManager(this);
}

class TenderDaoManager {
  final _$TenderDaoMixin _db;
  TenderDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$TendersTableTableManager get tenders =>
      $$TendersTableTableManager(_db.attachedDatabase, _db.tenders);
}
