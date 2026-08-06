import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/excel_export_providers.dart';
import '../../services/excel_file_export_service.dart';
import '../../theme/tokens.dart';

class ExcelExportPage extends ConsumerStatefulWidget {
  const ExcelExportPage({super.key});

  @override
  ConsumerState<ExcelExportPage> createState() => _ExcelExportPageState();
}

class _ExcelExportPageState extends ConsumerState<ExcelExportPage> {
  bool _isExporting = false;
  ExcelExportResult? _lastResult;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Excel 导出')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s16,
          AppTokens.s16,
          AppTokens.s24,
        ),
        children: [
          Text('导出业务数据', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTokens.s8),
          Text(
            '生成包含今日任务、客户及项目、跟进记录和报价样品订单追踪的 Excel 工作簿。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          FilledButton.icon(
            onPressed: _isExporting ? null : _export,
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.table_view_outlined),
            label: Text(_isExporting ? '正在生成…' : '生成并分享 Excel'),
          ),
          if (_lastResult case final result?) ...[
            const SizedBox(height: AppTokens.s24),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('已生成并打开分享面板'),
                subtitle: Text(
                  '${result.fileName}\n${_formatBytes(result.sizeBytes)}',
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppTokens.s16),
            Text('导出或分享失败，请重试。', style: TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Future<void> _export() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(excelExportServiceProvider)
          .exportAndShare();
      if (!mounted) return;
      setState(() => _lastResult = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
