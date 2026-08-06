import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database_provider.dart';
import 'attachment_file_service.dart';
import 'attachment_service.dart';

final attachmentImageProcessorProvider = Provider<AttachmentImageProcessor>(
  (ref) => const FlutterAttachmentImageProcessor(),
);

final attachmentFileStoreProvider = Provider<AttachmentFileStore>(
  (ref) => AttachmentFileService(
    appDirectoryLoader: getApplicationDocumentsDirectory,
    imageProcessor: ref.watch(attachmentImageProcessorProvider),
  ),
);

final attachmentOpenerProvider = Provider<AttachmentOpener>(
  (ref) => const OpenFileAttachmentOpener(),
);

final attachmentServiceProvider = Provider<AttachmentService>(
  (ref) => AttachmentService(
    dao: ref.watch(attachmentDaoProvider),
    fileStore: ref.watch(attachmentFileStoreProvider),
    opener: ref.watch(attachmentOpenerProvider),
  ),
);

class FlutterAttachmentImageProcessor implements AttachmentImageProcessor {
  const FlutterAttachmentImageProcessor();

  @override
  Future<void> process(AttachmentImageRequest request) async {
    final output = await FlutterImageCompress.compressAndGetFile(
      request.sourcePath,
      request.targetPath,
      minWidth: request.minWidth,
      minHeight: request.minHeight,
      quality: request.quality,
      autoCorrectionAngle: request.autoCorrectionAngle,
      format: switch (request.format) {
        AttachmentImageFormat.jpeg => CompressFormat.jpeg,
        AttachmentImageFormat.png => CompressFormat.png,
        AttachmentImageFormat.webp => CompressFormat.webp,
      },
    );
    if (output == null) throw StateError('图片压缩未返回输出文件');
    if (output.path != request.targetPath) {
      await File(output.path).copy(request.targetPath);
    }
  }
}

class OpenFileAttachmentOpener implements AttachmentOpener {
  const OpenFileAttachmentOpener();

  @override
  Future<AttachmentOpenAdapterResult> open(String absolutePath) async {
    try {
      final result = await OpenFilex.open(absolutePath);
      return switch (result.type) {
        ResultType.done => AttachmentOpenAdapterResult.opened,
        ResultType.fileNotFound => AttachmentOpenAdapterResult.fileNotFound,
        ResultType.noAppToOpen => AttachmentOpenAdapterResult.noAppToOpen,
        ResultType.permissionDenied =>
          AttachmentOpenAdapterResult.permissionDenied,
        ResultType.error => AttachmentOpenAdapterResult.platformFailure,
      };
    } catch (_) {
      return AttachmentOpenAdapterResult.failed;
    }
  }
}
