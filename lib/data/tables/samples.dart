import 'package:drift/drift.dart';

import 'opportunities.dart';

@DataClassName('SampleRow')
class Samples extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get opportunityId =>
      integer().references(Opportunities, #id, onDelete: KeyAction.cascade)();

  TextColumn get sampleModel => text().nullable()();
  IntColumn get quantity => integer()();
  IntColumn get feeMinor => integer().nullable()();
  IntColumn get sentAt => integer().nullable()();
  TextColumn get carrier => text().nullable()();
  TextColumn get trackingNo => text().nullable()();
  IntColumn get deliveredAt => integer().nullable()();
  TextColumn get recipient => text().nullable()();
  TextColumn get tester => text().nullable()();
  IntColumn get plannedTestAt => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('preparing'))();
  TextColumn get testResult => text().nullable()();
  TextColumn get nextAction => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  List<String> get customConstraints => [
    'CHECK (quantity >= 0)',
    'CHECK (fee_minor IS NULL OR fee_minor >= 0)',
    "CHECK (status IN ('preparing', 'sent', 'delivered', 'testing', 'passed', 'failed', 'cancelled'))",
  ];
}
