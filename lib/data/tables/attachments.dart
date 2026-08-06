import 'package:drift/drift.dart';

import 'followups.dart';
import 'orders.dart';
import 'quotes.dart';
import 'registrations.dart';
import 'samples.dart';
import 'tenders.dart';

/// 附件表。合同照片、报价单、样品照片、名片。
///
/// 附件可以挂在跟进、订单、报价、样品、注册或招标上，六个外键中恰好一个非空，
/// 由 CHECK 约束保证。
///
/// **只存相对路径**。绝对路径在应用重装或系统迁移后全部失效，
/// 拼接统一由 AttachmentPath 负责。
@DataClassName('AttachmentRow')
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get followupId => integer().nullable().references(
    Followups,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get orderId => integer().nullable().references(
    Orders,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get quoteId => integer().nullable().references(
    Quotes,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get sampleId => integer().nullable().references(
    Samples,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get registrationId => integer().nullable().references(
    Registrations,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get tenderId => integer().nullable().references(
    Tenders,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 相对应用文档目录的路径，形如 `attachments/2026/08/uuid.jpg`。
  TextColumn get relativePath => text()();

  /// 原始文件名，用于展示与导出时还原。
  TextColumn get originalName => text()();

  TextColumn get mimeType => text()();

  IntColumn get sizeBytes => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  /// 归属必须明确：恰好一个外键非空。
  ///
  /// 没有这条约束的话，孤儿附件会永远不被级联删除，
  /// 而多重归属附件会在删除任一父记录时产生歧义。
  @override
  List<String> get customConstraints => [
    'CHECK ((followup_id IS NOT NULL) + (order_id IS NOT NULL) + '
        '(quote_id IS NOT NULL) + (sample_id IS NOT NULL) + '
        '(registration_id IS NOT NULL) + (tender_id IS NOT NULL) = 1)',
  ];
}
