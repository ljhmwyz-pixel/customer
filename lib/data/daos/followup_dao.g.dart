// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followup_dao.dart';

// ignore_for_file: type=lint
mixin _$FollowupDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $FollowupsTable get followups => attachedDatabase.followups;
  FollowupDaoManager get managers => FollowupDaoManager(this);
}

class FollowupDaoManager {
  final _$FollowupDaoMixin _db;
  FollowupDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$FollowupsTableTableManager get followups =>
      $$FollowupsTableTableManager(_db.attachedDatabase, _db.followups);
}
