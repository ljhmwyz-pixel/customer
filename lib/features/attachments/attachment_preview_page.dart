import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import 'attachment_providers.dart';

class AttachmentPreviewPage extends ConsumerWidget {
  const AttachmentPreviewPage({super.key, required this.attachmentId});

  final int attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(attachmentPreviewProvider(attachmentId));
    final title = preview.value?.row?.originalName ?? '图片预览';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: preview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const _PreviewMessage(message: '图片预览失败，请重试'),
        data: (state) {
          final absolutePath = state.absolutePath;
          if (state.status == AttachmentPreviewStatus.ready &&
              absolutePath != null) {
            return PhotoView(
              imageProvider: FileImage(File(absolutePath)),
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
            );
          }
          return _PreviewMessage(message: _previewMessage(state.status));
        },
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

String _previewMessage(AttachmentPreviewStatus status) => switch (status) {
  AttachmentPreviewStatus.recordNotFound => '附件记录不存在',
  AttachmentPreviewStatus.fileNotFound => '文件已丢失',
  AttachmentPreviewStatus.notImage => '此附件不是图片',
  AttachmentPreviewStatus.failed ||
  AttachmentPreviewStatus.ready => '图片预览失败，请重试',
};
