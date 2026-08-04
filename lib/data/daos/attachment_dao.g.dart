// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_dao.dart';

// ignore_for_file: type=lint
mixin _$AttachmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $FollowupsTable get followups => attachedDatabase.followups;
  $OrdersTable get orders => attachedDatabase.orders;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  AttachmentDaoManager get managers => AttachmentDaoManager(this);
}

class AttachmentDaoManager {
  final _$AttachmentDaoMixin _db;
  AttachmentDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$FollowupsTableTableManager get followups =>
      $$FollowupsTableTableManager(_db.attachedDatabase, _db.followups);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
}
