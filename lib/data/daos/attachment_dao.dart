import 'package:drift/drift.dart';

import '../attachment_path.dart';
import '../database.dart';
import '../tables/attachments.dart';

part 'attachment_dao.g.dart';

/// 附件的业务归属。使用封闭类型层次，让调用方无法表达零归属或多重归属。
sealed class AttachmentOwner {
  const AttachmentOwner(this.id);

  final int id;
}

final class FollowupAttachmentOwner extends AttachmentOwner {
  const FollowupAttachmentOwner(super.id);
}

final class OrderAttachmentOwner extends AttachmentOwner {
  const OrderAttachmentOwner(super.id);
}

final class QuoteAttachmentOwner extends AttachmentOwner {
  const QuoteAttachmentOwner(super.id);
}

final class SampleAttachmentOwner extends AttachmentOwner {
  const SampleAttachmentOwner(super.id);
}

final class RegistrationAttachmentOwner extends AttachmentOwner {
  const RegistrationAttachmentOwner(super.id);
}

final class TenderAttachmentOwner extends AttachmentOwner {
  const TenderAttachmentOwner(super.id);
}

/// 附件数据访问。
///
/// 只管数据库记录，不碰文件本身。文件的写入与删除在阶段 4 由上层服务负责，
/// 这样 DAO 保持可用内存库测试、不依赖文件系统。
@DriftAccessor(tables: [Attachments])
class AttachmentDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentDaoMixin {
  AttachmentDao(super.db);

  /// 写入附件记录。[owner] 在类型层保证恰好一个归属。
  Future<int> insertAttachment({
    required AttachmentOwner owner,
    required String relativePath,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
    DateTime? now,
  }) {
    final normalizedPath = AttachmentPath.normalizeRelative(relativePath);

    final ts = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final ownerFields = switch (owner) {
      FollowupAttachmentOwner() => (followupId: Value(owner.id)),
      OrderAttachmentOwner() => (orderId: Value(owner.id)),
      QuoteAttachmentOwner() => (quoteId: Value(owner.id)),
      SampleAttachmentOwner() => (sampleId: Value(owner.id)),
      RegistrationAttachmentOwner() => (registrationId: Value(owner.id)),
      TenderAttachmentOwner() => (tenderId: Value(owner.id)),
    };
    return into(attachments).insert(
      AttachmentsCompanion.insert(
        followupId: ownerFields is ({Value<int> followupId})
            ? ownerFields.followupId
            : const Value.absent(),
        orderId: ownerFields is ({Value<int> orderId})
            ? ownerFields.orderId
            : const Value.absent(),
        quoteId: ownerFields is ({Value<int> quoteId})
            ? ownerFields.quoteId
            : const Value.absent(),
        sampleId: ownerFields is ({Value<int> sampleId})
            ? ownerFields.sampleId
            : const Value.absent(),
        registrationId: ownerFields is ({Value<int> registrationId})
            ? ownerFields.registrationId
            : const Value.absent(),
        tenderId: ownerFields is ({Value<int> tenderId})
            ? ownerFields.tenderId
            : const Value.absent(),
        relativePath: normalizedPath,
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

  Future<List<AttachmentRow>> listOf(AttachmentOwner owner) =>
      (select(attachments)
            ..where((t) => _ownerPredicate(t, owner))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<int> countOf(AttachmentOwner owner) async {
    final count = attachments.id.count();
    final query = selectOnly(attachments)
      ..addColumns([count])
      ..where(_ownerPredicate(attachments, owner));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// 全部附件记录。备份打包时遍历用。
  Future<List<AttachmentRow>> listAll() =>
      (select(attachments)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<AttachmentRow>> listOfCustomer(int customerId) => customSelect(
    '''
      SELECT attachment.*
      FROM attachments attachment
      WHERE attachment.followup_id IN (
        SELECT id FROM followups WHERE customer_id = ?
      ) OR attachment.order_id IN (
        SELECT id FROM orders WHERE customer_id = ?
      ) OR attachment.quote_id IN (
        SELECT quote.id
        FROM quotes quote
        JOIN opportunities opportunity ON opportunity.id = quote.opportunity_id
        WHERE opportunity.customer_id = ?
      ) OR attachment.sample_id IN (
        SELECT sample.id
        FROM samples sample
        JOIN opportunities opportunity ON opportunity.id = sample.opportunity_id
        WHERE opportunity.customer_id = ?
      ) OR attachment.registration_id IN (
        SELECT registration.id
        FROM registrations registration
        JOIN opportunities opportunity
          ON opportunity.id = registration.opportunity_id
        WHERE opportunity.customer_id = ?
      ) OR attachment.tender_id IN (
        SELECT tender.id
        FROM tenders tender
        JOIN opportunities opportunity ON opportunity.id = tender.opportunity_id
        WHERE opportunity.customer_id = ?
      )
      ORDER BY attachment.id
    ''',
    variables: List.generate(6, (_) => Variable.withInt(customerId)),
    readsFrom: {attachments},
  ).map((row) => attachments.map(row.data)).get();

  Future<List<AttachmentRow>> listOfOpportunity(int opportunityId) =>
      customSelect(
        '''
          SELECT attachment.*
          FROM attachments attachment
          WHERE attachment.followup_id IN (
            SELECT id FROM followups WHERE opportunity_id = ?
          ) OR attachment.order_id IN (
            SELECT id FROM orders WHERE opportunity_id = ?
          ) OR attachment.quote_id IN (
            SELECT id FROM quotes WHERE opportunity_id = ?
          ) OR attachment.sample_id IN (
            SELECT id FROM samples WHERE opportunity_id = ?
          ) OR attachment.registration_id IN (
            SELECT id FROM registrations WHERE opportunity_id = ?
          ) OR attachment.tender_id IN (
            SELECT id FROM tenders WHERE opportunity_id = ?
          )
          ORDER BY attachment.id
        ''',
        variables: List.generate(6, (_) => Variable.withInt(opportunityId)),
        readsFrom: {attachments},
      ).map((row) => attachments.map(row.data)).get();

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

  Expression<bool> _ownerPredicate(
    $AttachmentsTable table,
    AttachmentOwner owner,
  ) => switch (owner) {
    FollowupAttachmentOwner() => table.followupId.equals(owner.id),
    OrderAttachmentOwner() => table.orderId.equals(owner.id),
    QuoteAttachmentOwner() => table.quoteId.equals(owner.id),
    SampleAttachmentOwner() => table.sampleId.equals(owner.id),
    RegistrationAttachmentOwner() => table.registrationId.equals(owner.id),
    TenderAttachmentOwner() => table.tenderId.equals(owner.id),
  };
}
