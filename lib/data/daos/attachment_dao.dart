import 'package:drift/drift.dart';

import '../attachment_path.dart';
import '../database.dart';
import '../tables/attachments.dart';

part 'attachment_dao.g.dart';

/// 附件数据访问。
///
/// 只管数据库记录，不碰文件本身。文件的写入与删除在阶段 4 由上层服务负责，
/// 这样 DAO 保持可用内存库测试、不依赖文件系统。
@DriftAccessor(tables: [Attachments])
class AttachmentDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentDaoMixin {
  AttachmentDao(super.db);

  /// 写入附件记录。[followupId] 与 [orderId] 必须恰好一个非空。
  ///
  /// 在 Dart 层先挡一道，是为了报出能看懂的错误信息；
  /// 表上的 CHECK 约束仍然保留作为兜底，防止绕过 DAO 的写入路径。
  Future<int> insertAttachment({
    int? followupId,
    int? orderId,
    required String relativePath,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
    DateTime? now,
  }) {
    if ((followupId == null) == (orderId == null)) {
      throw ArgumentError(
        '附件归属必须明确：followupId 与 orderId 恰好一个非空，'
        '当前 followupId=$followupId, orderId=$orderId',
      );
    }
    if (relativePath.startsWith('/')) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        '附件表只存相对路径，请用 AttachmentPath.relativeFor 生成',
      );
    }

    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return into(attachments).insert(
      AttachmentsCompanion.insert(
        followupId: Value(followupId),
        orderId: Value(orderId),
        relativePath: relativePath,
        originalName: originalName,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
        createdAt: ts,
        updatedAt: ts,
      ),
    );
  }

  Future<AttachmentRow?> findById(int id) =>
      (select(attachments)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<AttachmentRow>> listOfFollowup(int followupId) =>
      (select(attachments)
            ..where((t) => t.followupId.equals(followupId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<List<AttachmentRow>> listOfOrder(int orderId) =>
      (select(attachments)
            ..where((t) => t.orderId.equals(orderId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  /// 全部附件记录。备份打包时遍历用。
  Future<List<AttachmentRow>> listAll() =>
      (select(attachments)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<int> countAll() async {
    final q = selectOnly(attachments)..addColumns([attachments.id.count()]);
    final row = await q.getSingle();
    return row.read(attachments.id.count()) ?? 0;
  }

  /// 附件占用的总字节数。设置页展示存储占用用它。
  Future<int> totalSizeBytes() async {
    final sum = attachments.sizeBytes.sum();
    final q = selectOnly(attachments)..addColumns([sum]);
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// 解析出当前设备上的绝对路径。
  ///
  /// [appDir] 由调用方在运行时取得，DAO 自己不去调 path_provider，
  /// 这样换目录后同一条记录仍能正确解析。
  String absolutePathOf(AttachmentRow row, {required String appDir}) =>
      AttachmentPath.resolve(appDir: appDir, relativePath: row.relativePath);

  Future<int> deleteAttachment(int id) =>
      (delete(attachments)..where((t) => t.id.equals(id))).go();
}
