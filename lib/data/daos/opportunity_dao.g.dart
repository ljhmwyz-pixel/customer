// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_dao.dart';

// ignore_for_file: type=lint
mixin _$OpportunityDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  OpportunityDaoManager get managers => OpportunityDaoManager(this);
}

class OpportunityDaoManager {
  final _$OpportunityDaoMixin _db;
  OpportunityDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
}
