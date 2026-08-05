import 'package:drift/drift.dart';

import 'opportunities.dart';

@DataClassName('QuoteRow')
class Quotes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get opportunityId =>
      integer().references(Opportunities, #id, onDelete: KeyAction.cascade)();

  TextColumn get quoteNo => text().withLength(min: 1, max: 50)();
  IntColumn get version => integer()();
  TextColumn get productModel => text().nullable()();
  IntColumn get quantity => integer()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  IntColumn get unitPriceMinor => integer().nullable()();
  IntColumn get totalAmountMinor => integer().nullable()();
  IntColumn get quotedAt => integer()();
  IntColumn get validUntil => integer().nullable()();
  BoolColumn get customerReceived =>
      boolean().withDefault(const Constant(false))();
  TextColumn get customerFeedback => text().nullable()();
  IntColumn get nextFollowAt => integer().nullable()();
  TextColumn get result => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  List<String> get customConstraints => [
    'CHECK (quantity >= 0)',
    'CHECK (unit_price_minor IS NULL OR unit_price_minor >= 0)',
    'CHECK (total_amount_minor IS NULL OR total_amount_minor >= 0)',
    'UNIQUE (opportunity_id, quote_no, version)',
  ];
}
