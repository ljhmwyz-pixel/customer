import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daos/attachment_dao.dart';
import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../services/attachment_service_providers.dart';
import '../../services/attachment_source_service.dart';

enum AttachmentOwnerType {
  followup,
  order,
  quote,
  sample,
  registration,
  tender,
}

class AttachmentOwnerRoute {
  const AttachmentOwnerRoute({required this.type, required this.id});

  final AttachmentOwnerType type;
  final int id;

  static AttachmentOwnerRoute? tryParse(String ownerType, String ownerId) {
    final id = int.tryParse(ownerId);
    if (id == null || id <= 0) return null;

    final type = switch (ownerType) {
      'followup' => AttachmentOwnerType.followup,
      'order' => AttachmentOwnerType.order,
      'quote' => AttachmentOwnerType.quote,
      'sample' => AttachmentOwnerType.sample,
      'registration' => AttachmentOwnerType.registration,
      'tender' => AttachmentOwnerType.tender,
      _ => null,
    };
    if (type == null) return null;
    return AttachmentOwnerRoute(type: type, id: id);
  }

  AttachmentOwner get owner => switch (type) {
    AttachmentOwnerType.followup => FollowupAttachmentOwner(id),
    AttachmentOwnerType.order => OrderAttachmentOwner(id),
    AttachmentOwnerType.quote => QuoteAttachmentOwner(id),
    AttachmentOwnerType.sample => SampleAttachmentOwner(id),
    AttachmentOwnerType.registration => RegistrationAttachmentOwner(id),
    AttachmentOwnerType.tender => TenderAttachmentOwner(id),
  };

  String get segment => switch (type) {
    AttachmentOwnerType.followup => 'followup',
    AttachmentOwnerType.order => 'order',
    AttachmentOwnerType.quote => 'quote',
    AttachmentOwnerType.sample => 'sample',
    AttachmentOwnerType.registration => 'registration',
    AttachmentOwnerType.tender => 'tender',
  };

  String get location => '/attachments/$segment/$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentOwnerRoute && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

class AttachmentListItem {
  const AttachmentListItem({required this.row, required this.fileExists});

  final AttachmentRow row;
  final bool fileExists;
}

enum AttachmentPreviewStatus {
  ready,
  recordNotFound,
  fileNotFound,
  notImage,
  failed,
}

class AttachmentPreviewState {
  const AttachmentPreviewState({
    required this.status,
    this.row,
    this.absolutePath,
  });

  final AttachmentPreviewStatus status;
  final AttachmentRow? row;
  final String? absolutePath;
}

final attachmentSourceServiceProvider = Provider<AttachmentSourceService>(
  (ref) => AttachmentSourceService(),
);

final attachmentListProvider =
    FutureProvider.family<List<AttachmentListItem>, AttachmentOwnerRoute>((
      ref,
      route,
    ) async {
      final rows = await ref.watch(attachmentDaoProvider).listOf(route.owner);
      final fileStore = ref.watch(attachmentFileStoreProvider);
      return Future.wait(
        rows.map(
          (row) async => AttachmentListItem(
            row: row,
            fileExists: await fileStore.exists(row.relativePath),
          ),
        ),
      );
    });

final attachmentCountProvider =
    FutureProvider.family<int, AttachmentOwnerRoute>(
      (ref, route) => ref.watch(attachmentDaoProvider).countOf(route.owner),
    );

final attachmentPreviewProvider =
    FutureProvider.family<AttachmentPreviewState, int>((ref, id) async {
      final row = await ref.watch(attachmentDaoProvider).findById(id);
      if (row == null) {
        return const AttachmentPreviewState(
          status: AttachmentPreviewStatus.recordNotFound,
        );
      }

      final fileStore = ref.watch(attachmentFileStoreProvider);
      try {
        if (!await fileStore.exists(row.relativePath)) {
          return AttachmentPreviewState(
            status: AttachmentPreviewStatus.fileNotFound,
            row: row,
          );
        }
        if (!row.mimeType.toLowerCase().startsWith('image/')) {
          return AttachmentPreviewState(
            status: AttachmentPreviewStatus.notImage,
            row: row,
          );
        }
        return AttachmentPreviewState(
          status: AttachmentPreviewStatus.ready,
          row: row,
          absolutePath: await fileStore.absolutePath(row.relativePath),
        );
      } catch (_) {
        return AttachmentPreviewState(
          status: AttachmentPreviewStatus.failed,
          row: row,
        );
      }
    });
