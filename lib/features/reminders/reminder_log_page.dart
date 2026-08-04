import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/daos/plan_dao.dart';
import '../../data/database_provider.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';

/// 已触发提醒的记录。
///
/// 这一页存在的唯一目的是回答「提醒到底准不准」。计划时间与实际触发时间的差值
/// 就是系统延迟，也是判断 ColorOS 有没有压制闹钟的直接证据
/// （见 docs/phase2/PLAN.md 第 3.5 节）。所以不做美化，把数字露出来即可。
final reminderLogProvider = FutureProvider<List<PlanWithCustomer>>((ref) {
  return ref.watch(planDaoProvider).listNotified();
});

class ReminderLogPage extends ConsumerWidget {
  const ReminderLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(reminderLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () => ref.invalidate(reminderLogProvider),
          ),
        ],
      ),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('读取记录失败：$e')),
        data: (data) => data.isEmpty
            ? const EmptyState(
                icon: Icons.history,
                message: '还没有提醒触发过。\n设一个几分钟后的跟进计划就能在这里看到记录。',
              )
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => _LogTile(item: data[index]),
              ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.item});

  final PlanWithCustomer item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final format = DateFormat('MM-dd HH:mm:ss');

    final planAt = item.planAt;
    final notifiedAtMs = item.plan.notifiedAt;
    final notifiedAt = notifiedAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            notifiedAtMs,
            isUtc: true,
          ).toLocal();
    final delay = notifiedAt?.difference(planAt);

    return ListTile(
      title: Text('${item.customerName}　${item.plan.title}'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppTokens.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '计划　${format.format(planAt)}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '实际　${notifiedAt == null ? '未记录' : format.format(notifiedAt)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      trailing: delay == null
          ? null
          : Text(
              _formatDelay(delay),
              style: theme.textTheme.bodyMedium?.copyWith(
                // 60 秒是 PRD 验收第 2 项的误差上限，超了就该注意。
                color: delay.inSeconds.abs() <= 60
                    ? semantic.done
                    : semantic.overdue,
                fontWeight: AppTokens.wMedium,
              ),
            ),
    );
  }

  /// 延迟的可读形式。负值意味着提前触发，理论上不该出现，但也要显示出来
  /// 而不是当成 0，否则真出问题会被掩盖。
  String _formatDelay(Duration delay) {
    final seconds = delay.inSeconds;
    if (seconds.abs() < 60) return '${seconds}s';

    final minutes = delay.inMinutes;
    if (minutes.abs() < 60) return '${minutes}m${(seconds % 60).abs()}s';

    return '${delay.inHours}h${(minutes % 60).abs()}m';
  }
}
