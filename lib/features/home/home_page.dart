import 'package:flutter/material.dart';

import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';

/// 今日待办首页。
///
/// 阶段 0 为占位实现，展示计数条与分组骨架。
/// 真实数据接入在阶段 3。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('今日')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
        children: [
          const SizedBox(height: AppTokens.s8),
          // 顶部紧凑计数，不做统计大卡片。
          Row(
            children: [
              _CountItem(label: '逾期', value: '0', color: semantic.overdue),
              const SizedBox(width: AppTokens.s16),
              _CountItem(label: '今日', value: '0', color: semantic.today),
              const SizedBox(width: AppTokens.s16),
              _CountItem(label: '本周', value: '0', color: semantic.upcoming),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          Text('待办', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTokens.s12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.s24),
            child: Text(
              '还没有待办，先去添加一个客户',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 计数项。数字用语义色，标签用次要色。
class _CountItem extends StatelessWidget {
  const _CountItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppTokens.s4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: AppTokens.wMedium,
          ),
        ),
      ],
    );
  }
}
