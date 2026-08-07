import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/attachments/attachment_providers.dart';
import '../services/attachment_service.dart';
import '../theme/tokens.dart';

class BusinessRecordActions extends ConsumerStatefulWidget {
  const BusinessRecordActions({
    required this.title,
    required this.statusLabel,
    required this.contextLabel,
    required this.attachmentOwner,
    required this.onDelete,
    required this.onDeleted,
    this.enabled = true,
    this.onDeletingChanged,
    super.key,
  });

  final String title;
  final String statusLabel;
  final String contextLabel;
  final AttachmentOwnerRoute attachmentOwner;
  final Future<AttachmentCleanupReport> Function() onDelete;
  final FutureOr<void> Function(AttachmentCleanupReport report) onDeleted;
  final bool enabled;
  final ValueChanged<bool>? onDeletingChanged;

  @override
  ConsumerState<BusinessRecordActions> createState() =>
      _BusinessRecordActionsState();
}

class _BusinessRecordActionsState extends ConsumerState<BusinessRecordActions> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认删除${widget.contextLabel}？'),
            content: const Text('该记录及其关联附件将一并删除，此操作无法撤销。'),
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
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    widget.onDeletingChanged?.call(true);
    try {
      final report = await widget.onDelete();
      await widget.onDeleted(report);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
        widget.onDeletingChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.attachmentOwner;
    final count = ref.watch(attachmentCountProvider(owner)).value ?? 0;
    final enabled = widget.enabled && !_deleting;
    final segment = owner.segment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.fact_check_outlined),
          title: Text(
            widget.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${widget.contextLabel} · 当前状态：${widget.statusLabel}'),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: ValueKey(
                  'business-record-attachments-$segment-${owner.id}',
                ),
                onPressed: enabled ? () => context.push(owner.location) : null,
                icon: const Icon(Icons.attach_file),
                label: Text('附件（$count）'),
              ),
            ),
            const SizedBox(width: AppTokens.s8),
            Expanded(
              child: TextButton.icon(
                key: ValueKey('business-record-delete-$segment-${owner.id}'),
                onPressed: enabled ? _confirmDelete : null,
                icon: _deleting
                    ? const SizedBox.square(
                        dimension: AppTokens.s16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(_deleting ? '删除中' : '删除记录'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
      ],
    );
  }
}
