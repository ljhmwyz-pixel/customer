import 'package:drift/drift.dart';

import 'followups.dart';
import 'orders.dart';

/// 附件表。合同照片、报价单、样品照片、名片。
///
/// 附件可以挂在跟进记录上或订单上，两个外键同一时刻只有一个非空，
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
  /// 没有这条约束的话，孤儿附件（两个都空）会永远不被级联删除，
  /// 而双挂附件（两个都有值）在删除任一父记录后会留下悬空引用。
  @override
  List<String> get customConstraints => [
    'CHECK ((followup_id IS NOT NULL AND order_id IS NULL) '
        'OR (followup_id IS NULL AND order_id IS NOT NULL))',
  ];
}
