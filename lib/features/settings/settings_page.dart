import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';

/// 设置页。提醒、示例数据和导出入口集中在这里。
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
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('提醒权限'),
            subtitle: Text(
              '提醒不响时先来这里检查',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/reminder-permissions'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('提醒记录'),
            subtitle: Text(
              '每条提醒的计划时间与实际触发时间',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/reminder-log'),
          ),
          ListTile(
            leading: const Icon(Icons.alarm_add_outlined),
            title: const Text('提醒自检'),
            subtitle: Text(
              '排一条测试提醒，确认能准时响',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/reminder-test'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('示例数据'),
            subtitle: Text(
              '导入或整体撤销业务示例',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/sample-data'),
          ),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: const Text('Excel 导出'),
            subtitle: Text(
              '生成并分享四张业务工作表',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/excel-export'),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('备份与恢复'),
            subtitle: Text(
              '保存或恢复本机业务数据',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/backup-restore'),
          ),
        ],
      ),
    );
  }
}
