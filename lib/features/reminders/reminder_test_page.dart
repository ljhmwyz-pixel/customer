import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database_provider.dart';
import '../../services/service_providers.dart';
import '../../theme/tokens.dart';

/// 提醒自检页。
///
/// 阶段 2 要验证的十五项里，第 5 到 13 项都需要「真的排一条提醒然后等它响」，
/// 而客户与计划的录入界面到阶段 3 才有。没有这个入口，2A 根本没法验证。
///
/// 它不是临时脚手架：提醒可靠性依赖系统行为，换设备、系统升级、改省电策略之后
/// 都需要重新确认一遍，这个能力长期有用。位置放在设置页里，不占主导航。
class ReminderTestPage extends ConsumerStatefulWidget {
  const ReminderTestPage({super.key});

  @override
  ConsumerState<ReminderTestPage> createState() => _ReminderTestPageState();
}

class _ReminderTestPageState extends ConsumerState<ReminderTestPage> {
  List<int> _pending = const [];
  String? _lastAction;

  @override
  void initState() {
    super.initState();
    _refreshPending();
  }

  Future<void> _refreshPending() async {
    final ids = await ref.read(reminderSchedulerProvider).pendingIds();
    if (!mounted) return;
    setState(() => _pending = ids);
  }

  /// 排一条测试提醒。
  ///
  /// 走完整的真实链路：建客户、建计划、再调调度器。不直接调 zonedSchedule，
  /// 否则通知按钮回调找不到对应的数据库记录，第 11、12 项就验不了。
  Future<void> _schedule(Duration delay) async {
    final db = ref.read(databaseProvider);
    final at = DateTime.now().add(delay);

    final customerId = await db.customerDao.insertCustomer(
      name: '提醒自检 ${DateFormat('HH:mm:ss').format(at)}',
    );
    final planId = await db.planDao.insertPlan(
      customerId: customerId,
      title: '${delay.inMinutes} 分钟后的测试提醒',
      planAt: at,
    );

    final plan = await db.planDao.findById(planId);
    if (plan == null) return;

    await ref
        .read(reminderSchedulerProvider)
        .scheduleForPlan(plan, customerName: '提醒自检');

    if (!mounted) return;
    setState(
      () => _lastAction =
          '已排期：计划 $planId，触发时间 ${DateFormat('HH:mm:ss').format(at)}',
    );
    await _refreshPending();
  }

  Future<void> _rescheduleAll() async {
    final count = await ref.read(reminderSchedulerProvider).rescheduleAll();
    if (!mounted) return;
    setState(() => _lastAction = '已重建 $count 条提醒');
    await _refreshPending();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('提醒自检')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          Text(
            '排一条测试提醒，然后锁屏等它响。响了之后到「提醒记录」看实际触发时间'
            '与计划时间的差值。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          Wrap(
            spacing: AppTokens.s8,
            runSpacing: AppTokens.s8,
            children: [
              for (final minutes in const [1, 2, 5, 30])
                OutlinedButton(
                  onPressed: () => _schedule(Duration(minutes: minutes)),
                  child: Text('$minutes 分钟后'),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          FilledButton.tonal(
            onPressed: _rescheduleAll,
            child: const Text('按数据库全量重建提醒'),
          ),
          const SizedBox(height: AppTokens.s24),
          Text('当前已排期的通知 id', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.s4),
          Text(
            _pending.isEmpty ? '（无）' : _pending.join('、'),
            style: theme.textTheme.bodyMedium,
          ),
          if (_lastAction != null) ...[
            const SizedBox(height: AppTokens.s16),
            Text(
              _lastAction!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
