import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/attachment_source_service.dart';
import '../../services/backup_restore_providers.dart';
import '../../services/backup_restore_service.dart';
import '../../theme/tokens.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({super.key});

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  bool _busy = false;
  BackupResult? _backup;
  String? _message;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          Text('保护本机业务数据', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTokens.s8),
          Text(
            '备份包含客户、项目、跟进和业务记录。恢复会在下次启动时替换当前数据库。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          FilledButton.icon(
            onPressed: _busy ? null : _backupAndShare,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup_outlined),
            label: Text(_busy ? '正在处理…' : '备份并分享'),
          ),
          const SizedBox(height: AppTokens.s8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickAndRestore,
            icon: const Icon(Icons.restore),
            label: const Text('选择备份并恢复'),
          ),
          if (_backup case final result?) ...[
            const SizedBox(height: AppTokens.s16),
            Text('已生成 ${result.fileName}（${_formatBytes(result.sizeBytes)}）'),
          ],
          if (_message case final message?) ...[
            const SizedBox(height: AppTokens.s16),
            Text(
              message,
              style: TextStyle(
                color: _error
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _backupAndShare() async {
    await _run(() async {
      final result = await ref
          .read(backupRestoreServiceProvider)
          .backupAndShare();
      if (!mounted) return;
      setState(() {
        _backup = result;
        _message = '备份已准备好，可在分享面板中保存。';
        _error = false;
      });
    });
  }

  Future<void> _pickAndRestore() async {
    await _run(() async {
      final result = await ref
          .read(attachmentSourceServiceProvider)
          .pickFromFiles();
      if (result.status == AttachmentSourceStatus.cancelled || !mounted) return;
      if (result.status != AttachmentSourceStatus.selected ||
          result.file == null) {
        throw StateError('无法读取所选备份');
      }
      await ref
          .read(backupRestoreServiceProvider)
          .stageRestore(File(result.file!.sourcePath));
      if (!mounted) return;
      setState(() {
        _message = '恢复文件已校验，将在下次启动时生效。';
        _error = false;
      });
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = '操作失败，请重试。';
          _error = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _formatBytes(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).toStringAsFixed(1)} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
