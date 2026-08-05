import 'package:drift/drift.dart';

import 'opportunities.dart';

@DataClassName('TenderRow')
class Tenders extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get opportunityId =>
      integer().references(Opportunities, #id, onDelete: KeyAction.cascade)();

  TextColumn get projectNo => text().nullable()();
  TextColumn get name => text().nullable()();
  IntColumn get deadlineAt => integer().nullable()();
  TextColumn get documentStatus =>
      text().withDefault(const Constant('incomplete'))();
  TextColumn get qualificationStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get bidder => text().nullable()();
  IntColumn get depositMinor => integer().nullable()();
  TextColumn get customerExperience => text().nullable()();
  TextColumn get localTeamStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get fundingStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get riskLevel => text().withDefault(const Constant('low'))();
  TextColumn get authorizationType =>
      text().withDefault(const Constant('none'))();
  IntColumn get authorizationExpiresAt => integer().nullable()();
  TextColumn get exclusiveQuoteScope => text().nullable()();
  TextColumn get floorPriceSupport => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('preparing'))();
  TextColumn get nextAction => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  List<String> get customConstraints => [
    "CHECK (document_status IN ('incomplete', 'complete'))",
    "CHECK (qualification_status IN ('pending', 'qualified', 'disqualified'))",
    "CHECK (local_team_status IN ('pending', 'confirmed', 'failed'))",
    "CHECK (funding_status IN ('pending', 'confirmed', 'failed'))",
    "CHECK (risk_level IN ('low', 'medium', 'mediumHigh', 'high'))",
    "CHECK (authorization_type IN ('nonExclusiveProject', 'regional', 'none'))",
    "CHECK (status IN ('preparing', 'open', 'won', 'lost', 'closed', 'abandoned', 'disqualified'))",
    'CHECK (deposit_minor IS NULL OR deposit_minor >= 0)',
  ];
}
