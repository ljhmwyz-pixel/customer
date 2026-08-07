import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/attachment_source_service.dart';
import '../../services/backup_restore_providers.dart';
import '../../services/customer_contact_import_providers.dart';
import '../../services/customer_contact_import_service.dart';
import '../../theme/tokens.dart';

class CustomerContactImportPage extends ConsumerStatefulWidget {
  const CustomerContactImportPage({super.key});

  @override
  ConsumerState<CustomerContactImportPage> createState() =>
      _CustomerContactImportPageState();
}

class _CustomerContactImportPageState
    extends ConsumerState<CustomerContactImportPage> {
  CustomerContactImportPreview? _preview;
  CustomerContactImportResult? _result;
  String? _error;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;
    return Scaffold(
      appBar: AppBar(title: const Text('客户/联系人导入')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          Text('从 Excel 或 CSV 批量导入', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTokens.s8),
          Text(
            '本功能只导入客户和联系人。导入前建议先在“备份与恢复”中备份当前数据。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          const _StepLabel(
            number: '第 1 步',
            title: '下载并填写模板',
            detail: '保留第一行表头；客户名称必填，联系人可留空。',
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _shareTemplate,
            icon: const Icon(Icons.download_outlined),
            label: const Text('下载导入模板'),
          ),
          const SizedBox(height: AppTokens.s8),
          const _StepLabel(
            number: '第 2 步',
            title: '选择文件并预览',
            detail: '支持 UTF-8 CSV 或 Excel 第一张工作表。',
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _pick,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(_busy ? '正在处理…' : '选择 Excel / CSV 文件'),
          ),
          if (preview != null) ...[
            const SizedBox(height: AppTokens.s24),
            Text('导入预览', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.s8),
            Text('共 ${preview.rows.length} 行，${preview.issues.length} 个问题'),
            ...preview.issues
                .take(20)
                .map(
                  (issue) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    title: Text('第 ${issue.line} 行'),
                    subtitle: Text(issue.message),
                  ),
                ),
            FilledButton.icon(
              onPressed: _busy || !preview.canImport ? null : _import,
              icon: const Icon(Icons.check),
              label: const Text('确认导入'),
            ),
          ],
          if (_result case final result?) ...[
            const SizedBox(height: AppTokens.s16),
            Text(
              '导入完成：新增客户 ${result.createdCustomers}，更新客户 ${result.updatedCustomers}，新增联系人 ${result.createdContacts}，更新联系人 ${result.updatedContacts}',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppTokens.s8),
            OutlinedButton.icon(
              onPressed: () => context.go('/customers'),
              icon: const Icon(Icons.people_outline),
              label: const Text('查看客户列表'),
            ),
          ],
          if (_error case final error?) ...[
            const SizedBox(height: AppTokens.s16),
            Text(error, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }

  Future<void> _pick() async {
    await _run(() async {
      final picked = await ref
          .read(attachmentSourceServiceProvider)
          .pickFromFiles();
      if (picked.status == AttachmentSourceStatus.cancelled) {
        return;
      }
      if (picked.status != AttachmentSourceStatus.selected ||
          picked.file == null) {
        throw const FormatException('无法读取所选文件');
      }
      final name = picked.file!.originalName.toLowerCase();
      if (!name.endsWith('.csv') && !name.endsWith('.xlsx')) {
        throw const FormatException('仅支持 .csv 或 .xlsx 文件');
      }
      final bytes = await File(picked.file!.sourcePath).readAsBytes();
      final preview = ref
          .read(customerContactImportServiceProvider)
          .preview(
            Uint8List.fromList(bytes),
            fileName: picked.file!.originalName,
          );
      if (mounted) {
        setState(() {
          _preview = preview;
          _result = null;
        });
      }
    });
  }

  Future<void> _import() async {
    final preview = _preview;
    if (preview == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入？'),
        content: Text('将处理 ${preview.rows.length} 行客户和联系人数据。已有客户编号会更新。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _run(() async {
      final result = await ref
          .read(customerContactImportServiceProvider)
          .importPreview(preview);
      if (mounted) setState(() => _result = result);
    });
  }

  Future<void> _shareTemplate() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/客户联系人导入模板.csv');
    await file.writeAsString(
      '${CustomerContactImportService.headers.join(',')}\n',
      flush: true,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: '客户联系人导入模板',
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is FormatException
              ? error.message
              : '导入失败，请检查文件后重试。',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.number,
    required this.title,
    required this.detail,
  });

  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(number, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: AppTokens.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
