import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/sample_data_providers.dart';
import '../../services/sample_data_service.dart';
import '../../theme/tokens.dart';

class SampleDataPage extends ConsumerStatefulWidget {
  const SampleDataPage({super.key});

  @override
  ConsumerState<SampleDataPage> createState() => _SampleDataPageState();
}

class _SampleDataPageState extends ConsumerState<SampleDataPage> {
  bool _isMutating = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sampleDataStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('示例数据')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s16,
          AppTokens.s16,
          AppTokens.s24,
        ),
        children: [
          Text('当前状态', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTokens.s8),
          state.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => _ErrorState(
              onRetry: () => ref.invalidate(sampleDataStateProvider),
            ),
            data: (value) => _LoadedState(
              state: value,
              isMutating: _isMutating,
              onImport: _confirmImport,
              onUndo: _confirmUndo,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入示例数据？'),
        content: const Text('将新增 9 条可编辑的业务示例，不会修改现有客户。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认导入'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runMutation(
      action: () => ref.read(sampleDataServiceProvider).importAll(),
      successMessage: (_) => '9 条示例数据已导入',
      errorMessage: '导入失败，请重试',
    );
  }

  Future<void> _confirmUndo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤销全部示例数据？'),
        content: const Text('示例客户及其业务记录将全部删除，正式客户不会受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认撤销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runMutation(
      action: () => ref.read(sampleDataServiceProvider).undoAll(),
      successMessage: (result) {
        final failures = result.cleanupReport.failedPaths.length;
        if (failures > 0) return '已撤销；$failures 个附件文件待下次启动重试';
        return '已撤销 ${result.deletedCustomerCount} 条示例数据';
      },
      errorMessage: '撤销失败，请重试',
    );
  }

  Future<void> _runMutation<T>({
    required Future<T> Function() action,
    required String Function(T result) successMessage,
    required String errorMessage,
  }) async {
    if (_isMutating) return;
    setState(() => _isMutating = true);
    try {
      final result = await action();
      ref.invalidate(sampleDataStateProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage(result))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }
}

class _LoadedState extends StatelessWidget {
  const _LoadedState({
    required this.state,
    required this.isMutating,
    required this.onImport,
    required this.onUndo,
  });

  final SampleDataState state;
  final bool isMutating;
  final VoidCallback onImport;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              state.isImported
                  ? Icons.check_circle_outline
                  : Icons.remove_circle_outline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Text(
                state.isImported ? '已导入 ${state.customerCount} 条' : '尚未导入',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s24),
        FilledButton.icon(
          onPressed: isMutating
              ? null
              : state.isImported
              ? onUndo
              : onImport,
          icon: isMutating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  state.isImported
                      ? Icons.delete_sweep_outlined
                      : Icons.download_outlined,
                ),
          label: Text(state.isImported ? '撤销全部示例数据' : '导入 9 条示例数据'),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Text('状态读取失败')),
      IconButton(
        onPressed: onRetry,
        tooltip: '重试',
        icon: const Icon(Icons.refresh),
      ),
    ],
  );
}
