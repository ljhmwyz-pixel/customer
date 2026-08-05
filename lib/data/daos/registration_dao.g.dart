// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_dao.dart';

// ignore_for_file: type=lint
mixin _$RegistrationDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $RegistrationsTable get registrations => attachedDatabase.registrations;
  RegistrationDaoManager get managers => RegistrationDaoManager(this);
}

class RegistrationDaoManager {
  final _$RegistrationDaoMixin _db;
  RegistrationDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$RegistrationsTableTableManager get registrations =>
      $$RegistrationsTableTableManager(_db.attachedDatabase, _db.registrations);
}
