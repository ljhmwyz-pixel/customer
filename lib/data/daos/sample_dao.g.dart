// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_dao.dart';

// ignore_for_file: type=lint
mixin _$SampleDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $SamplesTable get samples => attachedDatabase.samples;
  SampleDaoManager get managers => SampleDaoManager(this);
}

class SampleDaoManager {
  final _$SampleDaoMixin _db;
  SampleDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$SamplesTableTableManager get samples =>
      $$SamplesTableTableManager(_db.attachedDatabase, _db.samples);
}
