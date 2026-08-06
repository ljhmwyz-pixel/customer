// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $TagsTable get tags => attachedDatabase.tags;
  $CustomerTagsTable get customerTags => attachedDatabase.customerTags;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $FollowPlansTable get followPlans => attachedDatabase.followPlans;
  $FollowupsTable get followups => attachedDatabase.followups;
  $OrdersTable get orders => attachedDatabase.orders;
  $QuotesTable get quotes => attachedDatabase.quotes;
  $SamplesTable get samples => attachedDatabase.samples;
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
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$FollowPlansTableTableManager get followPlans =>
      $$FollowPlansTableTableManager(_db.attachedDatabase, _db.followPlans);
  $$FollowupsTableTableManager get followups =>
      $$FollowupsTableTableManager(_db.attachedDatabase, _db.followups);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db.attachedDatabase, _db.quotes);
  $$SamplesTableTableManager get samples =>
      $$SamplesTableTableManager(_db.attachedDatabase, _db.samples);
}
