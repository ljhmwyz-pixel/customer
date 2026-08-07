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
import '../../models/enums.dart';
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
            CustomerContactImportPreviewPanel(
              preview: preview,
              busy: _busy,
              onImport: _import,
              onCorrected: _correctRow,
              onRemoved: _removeRow,
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

  void _correctRow(CustomerContactImportRow correctedRow) {
    final preview = _preview;
    if (preview == null) return;
    final rows = [
      for (final row in preview.rows)
        if (row.line == correctedRow.line) correctedRow else row,
    ];
    final corrected = ref
        .read(customerContactImportServiceProvider)
        .revalidate(rows, headers: preview.headers);
    setState(() {
      _preview = corrected;
      _result = null;
      _error = null;
    });
  }

  void _removeRow(CustomerContactImportRow removedRow) {
    final preview = _preview;
    if (preview == null) return;
    final rows = preview.rows
        .where((row) => row.line != removedRow.line)
        .toList();
    final corrected = ref
        .read(customerContactImportServiceProvider)
        .revalidate(rows, headers: preview.headers);
    setState(() {
      _preview = corrected;
      _result = null;
      _error = null;
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

class CustomerContactImportPreviewPanel extends StatelessWidget {
  const CustomerContactImportPreviewPanel({
    required this.preview,
    required this.busy,
    required this.onImport,
    required this.onCorrected,
    required this.onRemoved,
    super.key,
  });

  final CustomerContactImportPreview preview;
  final bool busy;
  final VoidCallback onImport;
  final ValueChanged<CustomerContactImportRow> onCorrected;
  final ValueChanged<CustomerContactImportRow> onRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issuesByLine = <int, List<CustomerContactImportIssue>>{};
    for (final issue in preview.issues) {
      issuesByLine.putIfAbsent(issue.line, () => []).add(issue);
    }
    final rowsByLine = {for (final row in preview.rows) row.line: row};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('导入预览', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppTokens.s8),
        Text('共 ${preview.rows.length} 行，${preview.issues.length} 个问题'),
        if (issuesByLine.isNotEmpty) ...[
          const SizedBox(height: AppTokens.s12),
          for (final entry in issuesByLine.entries)
            if (rowsByLine[entry.key] case final row?)
              _ImportIssueRow(
                row: row,
                issues: entry.value,
                onCorrected: onCorrected,
                onRemoved: onRemoved,
              ),
        ],
        const SizedBox(height: AppTokens.s12),
        Row(
          children: [
            Icon(
              preview.canImport
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              size: 20,
              color: preview.canImport
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppTokens.s8),
            Expanded(
              child: Text(
                preview.canImport
                    ? '已通过校验，可导入 ${preview.rows.length} 行'
                    : preview.rows.isEmpty
                    ? '没有可导入的数据'
                    : '修正或排除问题行后可导入',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: preview.canImport
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        FilledButton.icon(
          onPressed: busy || !preview.canImport ? null : onImport,
          icon: const Icon(Icons.check),
          label: const Text('确认导入'),
        ),
      ],
    );
  }
}

class _ImportIssueRow extends StatelessWidget {
  const _ImportIssueRow({
    required this.row,
    required this.issues,
    required this.onCorrected,
    required this.onRemoved,
  });

  final CustomerContactImportRow row;
  final List<CustomerContactImportIssue> issues;
  final ValueChanged<CustomerContactImportRow> onCorrected;
  final ValueChanged<CustomerContactImportRow> onRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uniqueIssues = <String, CustomerContactImportIssue>{
      for (final issue in issues) issue.field: issue,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.s12),
      padding: const EdgeInsets.all(AppTokens.s12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: .5),
        ),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  '第 ${row.line} 行',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                '${issues.length} 个问题',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          for (final issue in uniqueIssues.values) ...[
            Text('${issue.field}：${_displayValue(row.values[issue.field])}'),
            Text(
              issue.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppTokens.s8),
          ],
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppTokens.s8,
            runSpacing: AppTokens.s4,
            children: [
              TextButton.icon(
                onPressed: () => _confirmRemove(context),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('不导入此行'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('修正本行'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final fields = <String>[];
    for (final issue in issues) {
      if (!fields.contains(issue.field)) fields.add(issue.field);
    }
    final updates = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          _ImportRowCorrectionDialog(row: row, fields: fields),
    );
    if (updates != null) onCorrected(row.withValues(updates));
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('排除第 ${row.line} 行？'),
        content: const Text('该行不会写入客户或联系人。其他保留行会重新校验。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认排除'),
          ),
        ],
      ),
    );
    if (confirmed == true) onRemoved(row);
  }

  static String _displayValue(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? '未填写' : trimmed;
  }
}

class _ImportRowCorrectionDialog extends StatefulWidget {
  const _ImportRowCorrectionDialog({required this.row, required this.fields});

  final CustomerContactImportRow row;
  final List<String> fields;

  @override
  State<_ImportRowCorrectionDialog> createState() =>
      _ImportRowCorrectionDialogState();
}

class _ImportRowCorrectionDialogState
    extends State<_ImportRowCorrectionDialog> {
  late final Map<String, TextEditingController> _controllers;
  CustomerStage? _stage;
  CustomerGrade? _grade;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.fields)
        if (field != '客户阶段' && field != '客户等级')
          field: TextEditingController(text: widget.row.values[field] ?? ''),
    };
    final rawStage = widget.row.values['客户阶段'];
    _stage = CustomerStage.values
        .where((value) => value.dbValue == rawStage || value.label == rawStage)
        .firstOrNull;
    final rawGrade = widget.row.values['客户等级'];
    _grade = CustomerGrade.values
        .where((value) => value.dbValue == rawGrade || value.label == rawGrade)
        .firstOrNull;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('修正第 ${widget.row.line} 行'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final field in widget.fields) ...[
            if (field == '客户阶段')
              DropdownButtonFormField<CustomerStage>(
                initialValue: _stage,
                decoration: const InputDecoration(labelText: '客户阶段'),
                items: [
                  for (final value in CustomerStage.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: (value) => setState(() => _stage = value),
              )
            else if (field == '客户等级')
              DropdownButtonFormField<CustomerGrade>(
                initialValue: _grade,
                decoration: const InputDecoration(labelText: '客户等级'),
                items: [
                  for (final value in CustomerGrade.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: (value) => setState(() => _grade = value),
              )
            else
              TextFormField(
                controller: _controllers[field],
                decoration: InputDecoration(labelText: field),
                keyboardType: field == '联系人邮箱'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
              ),
            const SizedBox(height: AppTokens.s12),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _updates()),
        child: const Text('应用修正'),
      ),
    ],
  );

  Map<String, String> _updates() => {
    for (final entry in _controllers.entries) entry.key: entry.value.text,
    if (widget.fields.contains('客户阶段'))
      '客户阶段': _stage?.label ?? widget.row.values['客户阶段'] ?? '',
    if (widget.fields.contains('客户等级'))
      '客户等级': _grade?.label ?? widget.row.values['客户等级'] ?? '',
  };
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
