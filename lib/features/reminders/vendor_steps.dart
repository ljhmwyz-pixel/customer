import 'package:flutter/material.dart';

import '../../services/oem_settings_channel.dart';
import '../../services/permission_service.dart';
import '../../theme/tokens.dart';

/// 厂商权限的操作步骤说明。
///
/// 这两项权限无法查询状态、也无法保证跳得中，所以必须给出可照做的文字步骤。
/// 文案按实际跳到了哪一层区分：跳中厂商页和退到应用详情页要找的位置完全不同，
/// 给一套通用说明只会让人更迷糊。
class VendorStepsSheet extends StatelessWidget {
  const VendorStepsSheet({
    required this.permission,
    required this.result,
    super.key,
  });

  final ReminderPermission permission;
  final OemJumpResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(permission.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.s4),
            Text(
              _resultNote(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            for (final (index, step) in _steps().indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: AppTokens.s24,
                      child: Text(
                        '${index + 1}.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(step, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppTokens.s8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('稍后再说'),
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('我已开启'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _resultNote() => switch (result) {
    OemJumpResult.oem => '已打开系统的设置页，按下面的步骤操作。',
    OemJumpResult.appDetails =>
      '这台设备上没找到对应的专用设置页，已打开系统的「应用详情」，'
          '需要你自己往里找一层。',
    OemJumpResult.failed => '设置页没能打开，请手动进入系统设置操作。',
  };

  List<String> _steps() {
    if (result == OemJumpResult.oem) {
      return switch (permission) {
        ReminderPermission.autoStart => const ['在应用列表里找到「客户跟进」', '把它的开关打开'],
        ReminderPermission.backgroundPopup => const [
          '找到「客户跟进」并进入',
          '允许「后台弹出界面」',
        ],
        _ => const ['按页面提示允许对应权限'],
      };
    }

    // 回退路径与手动路径的步骤一致：都得从应用详情或系统设置一层层找进去。
    return switch (permission) {
      ReminderPermission.autoStart => const [
        '在应用详情页找「自启动」或「允许自启动」并打开',
        '找不到的话回到系统设置，搜索「自启动」',
        '在自启动应用列表里打开「客户跟进」',
      ],
      ReminderPermission.backgroundPopup => const [
        '在应用详情页进入「权限」',
        '找到「后台弹出界面」并允许',
        '找不到的话回到系统设置，搜索「后台弹出」',
      ],
      _ => const ['在应用详情页的权限列表里允许对应权限'],
    };
  }
}
