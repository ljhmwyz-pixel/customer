// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_dao.dart';

// ignore_for_file: type=lint
mixin _$PlanDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $FollowPlansTable get followPlans => attachedDatabase.followPlans;
  PlanDaoManager get managers => PlanDaoManager(this);
}

class PlanDaoManager {
  final _$PlanDaoMixin _db;
  PlanDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$FollowPlansTableTableManager get followPlans =>
      $$FollowPlansTableTableManager(_db.attachedDatabase, _db.followPlans);
}
