// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_dao.dart';

// ignore_for_file: type=lint
mixin _$AttachmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $OpportunitiesTable get opportunities => attachedDatabase.opportunities;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $FollowupsTable get followups => attachedDatabase.followups;
  $OrdersTable get orders => attachedDatabase.orders;
  $QuotesTable get quotes => attachedDatabase.quotes;
  $SamplesTable get samples => attachedDatabase.samples;
  $RegistrationsTable get registrations => attachedDatabase.registrations;
  $TendersTable get tenders => attachedDatabase.tenders;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  AttachmentDaoManager get managers => AttachmentDaoManager(this);
}

class AttachmentDaoManager {
  final _$AttachmentDaoMixin _db;
  AttachmentDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db.attachedDatabase, _db.opportunities);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$FollowupsTableTableManager get followups =>
      $$FollowupsTableTableManager(_db.attachedDatabase, _db.followups);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db.attachedDatabase, _db.quotes);
  $$SamplesTableTableManager get samples =>
      $$SamplesTableTableManager(_db.attachedDatabase, _db.samples);
  $$RegistrationsTableTableManager get registrations =>
      $$RegistrationsTableTableManager(_db.attachedDatabase, _db.registrations);
  $$TendersTableTableManager get tenders =>
      $$TendersTableTableManager(_db.attachedDatabase, _db.tenders);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
}
