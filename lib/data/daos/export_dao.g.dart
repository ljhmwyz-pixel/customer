// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_dao.dart';

// ignore_for_file: type=lint
mixin _$ExportDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $FollowPlansTable get followPlans => attachedDatabase.followPlans;
  $FollowupsTable get followups => attachedDatabase.followups;
  $QuotesTable get quotes => attachedDatabase.quotes;
  $SamplesTable get samples => attachedDatabase.samples;
  $RegistrationsTable get registrations => attachedDatabase.registrations;
  $TendersTable get tenders => attachedDatabase.tenders;
  $OrdersTable get orders => attachedDatabase.orders;
  ExportDaoManager get managers => ExportDaoManager(this);
}

class ExportDaoManager {
  final _$ExportDaoMixin _db;
  ExportDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$FollowPlansTableTableManager get followPlans =>
      $$FollowPlansTableTableManager(_db.attachedDatabase, _db.followPlans);
  $$FollowupsTableTableManager get followups =>
      $$FollowupsTableTableManager(_db.attachedDatabase, _db.followups);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db.attachedDatabase, _db.quotes);
  $$SamplesTableTableManager get samples =>
      $$SamplesTableTableManager(_db.attachedDatabase, _db.samples);
  $$RegistrationsTableTableManager get registrations =>
      $$RegistrationsTableTableManager(_db.attachedDatabase, _db.registrations);
  $$TendersTableTableManager get tenders =>
      $$TendersTableTableManager(_db.attachedDatabase, _db.tenders);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
}
