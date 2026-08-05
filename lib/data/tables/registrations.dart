import 'package:drift/drift.dart';

import 'opportunities.dart';

@DataClassName('RegistrationRow')
class Registrations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get opportunityId =>
      integer().references(Opportunities, #id, onDelete: KeyAction.cascade)();

  TextColumn get country => text().nullable()();
  TextColumn get requirements => text().nullable()();
  TextColumn get documentChecklist => text().nullable()();
  TextColumn get documentStatus =>
      text().withDefault(const Constant('pending'))();
  IntColumn get submittedAt => integer().nullable()();
  IntColumn get expectedCompletedAt => integer().nullable()();
  IntColumn get actualCompletedAt => integer().nullable()();
  TextColumn get costBearer => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('preparing'))();
  TextColumn get currentObstacle => text().nullable()();
  TextColumn get nextAction => text().nullable()();
  IntColumn get documentDueAt => integer().nullable()();
  IntColumn get milestoneAt => integer().nullable()();
  TextColumn get milestoneTitle => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  List<String> get customConstraints => [
    "CHECK (document_status IN ('pending', 'incomplete', 'complete'))",
    "CHECK (status IN ('preparing', 'submitted', 'inProgress', 'completed', 'blocked', 'cancelled'))",
  ];
}
