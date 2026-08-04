import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// 设置页。阶段 0 仅展示版本信息骨架，备份功能在阶段 5。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          const SizedBox(height: AppTokens.s8),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('备份与恢复'),
            subtitle: Text(
              '阶段 5 实现',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('提醒权限'),
            subtitle: Text(
              '阶段 2 实现',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
