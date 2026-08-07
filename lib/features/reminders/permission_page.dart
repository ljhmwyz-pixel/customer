import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/oem_settings_channel.dart';
import '../../services/permission_service.dart';
import '../../services/service_providers.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';
import 'vendor_steps.dart';

/// 提醒权限引导页。
///
/// 每项权限独立一行、独立重试，而不是做成必须一路走完的向导：
/// 权限申请多数要跳出应用，跳回来时向导的进度状态很容易和实际状态不一致。
/// 逐项呈现真实状态，用户想开哪项点哪项，跳回来刷新即可。
class PermissionPage extends ConsumerStatefulWidget {
  const PermissionPage({super.key});

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 权限跳转没有回调，只能靠生命周期感知「用户从设置页回来了」。
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatesProvider);
    }
  }

  Future<void> _request(ReminderPermission permission) async {
    final service = ref.read(permissionServiceProvider);

    if (permission.isVendorSpecific) {
      final result = await service.openVendorSettings(permission);
      if (!mounted) return;
      await _showVendorGuide(permission, result);
      return;
    }

    await service.request(permission);
    if (!mounted) return;
    ref.invalidate(permissionStatesProvider);
  }

  /// 厂商权限跳转后的说明。
  ///
  /// 无论跳到哪一层都要展示：这两项权限的状态查不到，
  /// 系统页面上的选项名称也和我们的叫法不一致，不给步骤说明用户会找不到。
  Future<void> _showVendorGuide(
    ReminderPermission permission,
    OemJumpResult result,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          VendorStepsSheet(permission: permission, result: result),
    );

    if (confirmed == true) {
      await ref.read(permissionServiceProvider).markVendorConfirmed(permission);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = ref.watch(permissionStatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('提醒权限')),
      body: states.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('读取权限状态失败：$e')),
        data: (data) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
          children: [
            const _Intro(),
            for (final permission in ReminderPermission.values)
              _PermissionTile(
                permission: permission,
                state: data[permission] ?? ReminderPermissionState.unknown,
                onTap: () => _request(permission),
              ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        AppTokens.s8,
        AppTokens.s16,
        AppTokens.s16,
      ),
      child: Text(
        '提醒能否准时响，取决于下面这些开关。前三项能读到真实状态，'
        '后两项是手机厂商自己的开关，系统不提供查询接口，只能你自己确认。',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PermissionTile extends ConsumerWidget {
  const _PermissionTile({
    required this.permission,
    required this.state,
    required this.onTap,
  });

  final ReminderPermission permission;
  final ReminderPermissionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = AppSemanticColors.of(context);
    final theme = Theme.of(context);

    return ListTile(
      leading: _StatusIcon(
        permission: permission,
        state: state,
        semantic: semantic,
      ),
      title: Text(permission.title),
      subtitle: Text(
        permission.why,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: TextButton(onPressed: onTap, child: Text(_actionLabel(state))),
      onTap: onTap,
    );
  }

  String _actionLabel(ReminderPermissionState state) => switch (state) {
    ReminderPermissionState.granted => '已开启',
    ReminderPermissionState.permanentlyDenied => '去设置',
    _ => '开启',
  };
}

class _StatusIcon extends ConsumerWidget {
  const _StatusIcon({
    required this.permission,
    required this.state,
    required this.semantic,
  });

  final ReminderPermission permission;
  final ReminderPermissionState state;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 厂商权限查不到状态，用「用户自己确认过」代替，图标也要和已授予有区别，
    // 免得看起来像真的验证过了。
    if (permission.isVendorSpecific) {
      return FutureBuilder<bool>(
        future: ref
            .read(permissionServiceProvider)
            .isVendorConfirmed(permission),
        builder: (context, snapshot) => Icon(
          snapshot.data == true
              ? Icons.check_circle_outline
              : Icons.help_outline,
          color: snapshot.data == true
              ? semantic.upcoming
              : Theme.of(context).colorScheme.outline,
        ),
      );
    }

    return switch (state) {
      ReminderPermissionState.granted => Icon(
        Icons.check_circle,
        color: semantic.done,
      ),
      ReminderPermissionState.permanentlyDenied => Icon(
        Icons.error_outline,
        color: semantic.overdue,
      ),
      _ => Icon(
        Icons.radio_button_unchecked,
        color: Theme.of(context).colorScheme.outline,
      ),
    };
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Text(
        '权限齐了也不能百分百保证准时。真正能证明提醒可靠的只有实际触发记录，'
        '在「提醒记录」里可以看到每条提醒的计划时间与实际触发时间。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
