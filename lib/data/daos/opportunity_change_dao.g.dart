// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_change_dao.dart';

// ignore_for_file: type=lint
mixin _$OpportunityChangeDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $OpportunityChangesTable get opportunityChanges =>
      attachedDatabase.opportunityChanges;
  OpportunityChangeDaoManager get managers => OpportunityChangeDaoManager(this);
}

class OpportunityChangeDaoManager {
  final _$OpportunityChangeDaoMixin _db;
  OpportunityChangeDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$OpportunityChangesTableTableManager get opportunityChanges =>
      $$OpportunityChangesTableTableManager(
        _db.attachedDatabase,
        _db.opportunityChanges,
      );
}
