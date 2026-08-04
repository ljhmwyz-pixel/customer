import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/contacts.dart';

part 'contact_dao.g.dart';

/// 联系人数据访问。
@DriftAccessor(tables: [Contacts])
class ContactDao extends DatabaseAccessor<AppDatabase> with _$ContactDaoMixin {
  ContactDao(super.db);

  Future<int> insertContact({
    required int customerId,
    required String name,
    String? position,
    String? phone,
    bool isDecisionMaker = false,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(contacts).insert(
      ContactsCompanion.insert(
        customerId: customerId,
        name: name,
        position: Value(position),
        phone: Value(phone),
        isDecisionMaker: Value(isDecisionMaker),
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<ContactRow?> findById(int id) =>
      (select(contacts)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 某客户的联系人，决策人排在前面。
  Future<List<ContactRow>> listOf(int customerId) =>
      (select(contacts)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.isDecisionMaker),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

  Future<int> countOf(int customerId) async {
    final q = selectOnly(contacts)
      ..addColumns([contacts.id.count()])
      ..where(contacts.customerId.equals(customerId));
    final row = await q.getSingle();
    return row.read(contacts.id.count()) ?? 0;
  }

  Future<int> updateContact(
    int id, {
    String? name,
    String? position,
    String? phone,
    bool? isDecisionMaker,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (update(contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(
        name: name == null ? const Value.absent() : Value(name),
        position: position == null ? const Value.absent() : Value(position),
        phone: phone == null ? const Value.absent() : Value(phone),
        isDecisionMaker: isDecisionMaker == null
            ? const Value.absent()
            : Value(isDecisionMaker),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<int> deleteContact(int id) =>
      (delete(contacts)..where((t) => t.id.equals(id))).go();
}
