import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../services/attachment_service.dart';
import '../../services/attachment_service_providers.dart';
import '../../services/attachment_source_service.dart';
import '../../theme/tokens.dart';
import 'attachment_providers.dart';

class AttachmentPage extends ConsumerStatefulWidget {
  const AttachmentPage({super.key, required this.owner});

  final AttachmentOwnerRoute owner;

  @override
  ConsumerState<AttachmentPage> createState() => _AttachmentPageState();
}

class _AttachmentPageState extends ConsumerState<AttachmentPage> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final attachments = ref.watch(attachmentListProvider(widget.owner));
    final count = attachments.value?.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(count == null ? '附件' : '附件（$count）'),
        actions: [
          IconButton(
            tooltip: '添加附件',
            onPressed: _isBusy ? null : _showSourceMenu,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: attachments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _LoadError(
          onRetry: () => ref.invalidate(attachmentListProvider(widget.owner)),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('暂无附件'))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    enabled: !_isBusy,
                    onTap: _isBusy
                        ? null
                        : () => _openAttachment(item.row.id, item.row.mimeType),
                    leading: Icon(
                      item.row.mimeType.toLowerCase().startsWith('image/')
                          ? Icons.image_outlined
                          : Icons.insert_drive_file_outlined,
                    ),
                    title: Text(
                      item.row.originalName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.row.mimeType} · ${_formatBytes(item.row.sizeBytes)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!item.fileExists)
                          Text(
                            '文件已丢失',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: '删除附件',
                      onPressed: _isBusy
                          ? null
                          : () => _confirmDelete(item.row),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showSourceMenu() async {
    final action = await showModalBottomSheet<_AttachmentSourceAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('拍照'),
                onTap: () =>
                    Navigator.pop(context, _AttachmentSourceAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                onTap: () =>
                    Navigator.pop(context, _AttachmentSourceAction.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: const Text('从系统文件选择'),
                onTap: () =>
                    Navigator.pop(context, _AttachmentSourceAction.files),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null || !mounted || _isBusy) return;
    await _addFrom(action);
  }

  Future<void> _addFrom(_AttachmentSourceAction action) async {
    setState(() => _isBusy = true);
    try {
      final sourceService = ref.read(attachmentSourceServiceProvider);
      final result = await switch (action) {
        _AttachmentSourceAction.camera => sourceService.pickFromCamera(),
        _AttachmentSourceAction.gallery => sourceService.pickFromGallery(),
        _AttachmentSourceAction.files => sourceService.pickFromFiles(),
      };
      if (!mounted) return;

      switch (result.status) {
        case AttachmentSourceStatus.cancelled:
          return;
        case AttachmentSourceStatus.unavailable:
          _showMessage('当前设备不支持选择系统文件');
          return;
        case AttachmentSourceStatus.invalidData:
          _showMessage('无法读取所选文件');
          return;
        case AttachmentSourceStatus.failed:
          _showMessage('选择附件失败，请重试');
          return;
        case AttachmentSourceStatus.selected:
          final file = result.file;
          if (file == null) {
            _showMessage('无法读取所选文件');
            return;
          }
          try {
            await ref
                .read(attachmentServiceProvider)
                .add(
                  owner: widget.owner.owner,
                  source: File(file.sourcePath),
                  originalName: file.originalName,
                  mimeType: file.mimeType,
                );
          } catch (_) {
            if (mounted) _showMessage('附件保存失败，请重试');
            return;
          }
          if (mounted) {
            _refreshOwnerAttachments();
          }
      }
    } catch (_) {
      if (mounted) _showMessage('选择附件失败，请重试');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _openAttachment(int attachmentId, String mimeType) async {
    if (mimeType.toLowerCase().startsWith('image/')) {
      context.push('/attachments/preview/$attachmentId');
      return;
    }

    setState(() => _isBusy = true);
    try {
      final result = await ref
          .read(attachmentServiceProvider)
          .open(attachmentId);
      if (!mounted) return;
      final message = switch (result) {
        AttachmentOpenResult.opened => null,
        AttachmentOpenResult.recordNotFound => '附件记录不存在',
        AttachmentOpenResult.fileNotFound => '文件已丢失',
        AttachmentOpenResult.noAppToOpen => '未找到可打开此文件的应用',
        AttachmentOpenResult.permissionDenied => '没有权限打开此文件',
        AttachmentOpenResult.platformFailure ||
        AttachmentOpenResult.failed => '无法打开附件，请重试',
      };
      if (message != null) _showMessage(message);
    } catch (_) {
      if (mounted) _showMessage('无法打开附件，请重试');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmDelete(AttachmentRow row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除附件？'),
        content: Text(row.originalName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _isBusy) return;
    await _deleteAttachment(row.id);
  }

  Future<void> _deleteAttachment(int attachmentId) async {
    setState(() => _isBusy = true);
    try {
      final result = await ref
          .read(attachmentServiceProvider)
          .delete(attachmentId);
      if (!mounted) return;
      switch (result) {
        case AttachmentDeleteResult.deleted:
        case AttachmentDeleteResult.fileNotFound:
          _refreshOwnerAttachments();
        case AttachmentDeleteResult.cleanupFailed:
          _refreshOwnerAttachments();
          _showMessage('附件已删除，但文件清理失败');
        case AttachmentDeleteResult.recordNotFound:
          _refreshOwnerAttachments();
          _showMessage('附件记录不存在');
      }
    } catch (_) {
      if (mounted) _showMessage('删除附件失败，请重试');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _refreshOwnerAttachments() {
    ref.invalidate(attachmentListProvider(widget.owner));
    ref.invalidate(attachmentCountProvider(widget.owner));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('附件加载失败，请重试'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    ),
  );
}

enum _AttachmentSourceAction { camera, gallery, files }

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
