import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/daos/plan_dao.dart';
import '../../models/enums.dart';
import '../../services/service_providers.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../customers/customer_providers.dart';
import '../customers/customer_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(homePlansProvider);
    final pendingSyncs = ref.watch(pendingTaskSyncCountProvider);
    final pendingSyncCount = switch (pendingSyncs) {
      AsyncData(:final value) => value,
      _ => 0,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('今日')),
      body: plans.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => CustomerAsyncError(
          onRetry: () => ref.invalidate(homePlansProvider),
        ),
        data: (values) => _PlanList(
          values: values,
          onRefresh: () => ref.refresh(homePlansProvider.future),
          pendingSyncCount: pendingSyncCount,
          onRetrySync: () => _retryTaskSync(context, ref),
        ),
      ),
    );
  }

  Future<void> _retryTaskSync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final rules = ref.read(businessTaskRulesProvider);
    final report = await rules.retryPending(now: DateTime.now());
    ref.read(customerRevisionProvider.notifier).refresh();
    ref.invalidate(pendingTaskSyncCountProvider);
    ref.invalidate(homePlansProvider);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          report.remainingCount == 0
              ? '自动任务已同步'
              : '仍有 ${report.remainingCount} 个项目待同步，请稍后重试',
        ),
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.values,
    required this.onRefresh,
    required this.pendingSyncCount,
    required this.onRetrySync,
  });

  final List<TodayPlanItem> values;
  final Future<void> Function() onRefresh;
  final int pendingSyncCount;
  final Future<void> Function() onRetrySync;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = values.where((e) => e.overdueDays(now) > 0).toList();
    final today = values.where((e) => e.overdueDays(now) == 0).toList();
    if (values.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _QuickActions()),
            if (pendingSyncCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.s16,
                    AppTokens.s16,
                    AppTokens.s16,
                    0,
                  ),
                  child: _TaskSyncNotice(
                    count: pendingSyncCount,
                    onRetry: onRetrySync,
                  ),
                ),
              ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.event_available_outlined,
                message: '没有逾期或今日任务',
                actionLabel: '添加客户',
                onAction: () => context.go('/customers/new'),
              ),
            ),
          ],
        ),
      );
    }
    final semantic = AppSemanticColors.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey('home-plan-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s24,
        ),
        children: [
          const _QuickActions(),
          if (pendingSyncCount > 0) ...[
            const SizedBox(height: AppTokens.s16),
            _TaskSyncNotice(count: pendingSyncCount, onRetry: onRetrySync),
          ],
          const SizedBox(height: AppTokens.s16),
          Text(
            '逾期 ${overdue.length} · 今天 ${today.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.s16),
          if (overdue.isNotEmpty) ...[
            _section(context, '逾期', semantic.overdue, overdue),
            if (today.isNotEmpty) const SizedBox(height: AppTokens.s24),
          ],
          if (today.isNotEmpty) _section(context, '今天', semantic.today, today),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    Color color,
    List<TodayPlanItem> items,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
      const SizedBox(height: AppTokens.s8),
      for (final item in items) _PlanTile(item: item, color: color),
    ],
  );
}

class _TaskSyncNotice extends StatelessWidget {
  const _TaskSyncNotice({required this.count, required this.onRetry});

  final int count;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(AppTokens.r8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s12,
          AppTokens.s8,
          AppTokens.s8,
          AppTokens.s8,
        ),
        child: Row(
          children: [
            Icon(Icons.sync_problem_outlined, color: scheme.onErrorContainer),
            const SizedBox(width: AppTokens.s8),
            Expanded(
              child: Text(
                '$count 个项目的自动任务待同步',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              key: const ValueKey('retry-task-sync'),
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppTokens.s16,
      AppTokens.s12,
      AppTokens.s16,
      0,
    ),
    child: Wrap(
      spacing: AppTokens.s8,
      runSpacing: AppTokens.s8,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go('/customers/new'),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('新建客户'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/customers'),
          icon: const Icon(Icons.people_outline),
          label: const Text('客户列表'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/settings/customer-contact-import'),
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('导入客户'),
        ),
      ],
    ),
  );
}

class _PlanTile extends ConsumerStatefulWidget {
  const _PlanTile({required this.item, required this.color});
  final TodayPlanItem item;
  final Color color;

  @override
  ConsumerState<_PlanTile> createState() => _PlanTileState();
}

class _PlanTileState extends ConsumerState<_PlanTile> {
  String? warning;
  bool busy = false;

  Future<void> _complete() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      warning = await ref
          .read(customerServiceProvider)
          .completePlan(widget.item.customer.id, widget.item.plan.id);
      ref.read(customerRevisionProvider.notifier).refresh();
      ref.invalidate(homePlansProvider);
      ref.invalidate(customerDetailProvider(widget.item.customer.id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _cancel() async {
    if (busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消任务？'),
        content: const Text('任务会保留在历史记录中。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('返回'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('取消任务'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    try {
      warning = await ref
          .read(customerServiceProvider)
          .cancelPlan(widget.item.customer.id, widget.item.plan.id);
      ref.read(customerRevisionProvider.notifier).refresh();
      ref.invalidate(homePlansProvider);
      ref.invalidate(customerDetailProvider(widget.item.customer.id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final country = item.customer.country == null
        ? ''
        : ' · ${item.customer.country}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTokens.r8),
        child: InkWell(
          key: ValueKey('home-plan-${item.plan.id}'),
          borderRadius: BorderRadius.circular(AppTokens.r8),
          onTap: () => context.go(
            '/customers/${item.customer.id}?planId=${item.plan.id}',
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: AppTokens.accentBarWidth,
                    color: widget.color,
                  ),
                  const SizedBox(width: AppTokens.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.customer.name}$country',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: AppTokens.wMedium),
                        ),
                        const SizedBox(height: AppTokens.s4),
                        Text(
                          '${item.projectLabel} · ${item.productLabel}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '反馈：${item.latestFeedback}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '原因：${item.reason}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '方向：${item.plan.talkingDirection ?? '待确认'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '下一步：${item.nextAction} · 负责人：${item.owner}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          item.overdueDays(DateTime.now()) > 0
                              ? '逾期 ${item.overdueDays(DateTime.now())} 天'
                              : '今天 ${formatDateTime(localDateTime(item.plan.planAt)).split(' ').last}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: widget.color),
                        ),
                        if (warning != null)
                          Text(
                            warning!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppSemanticColors.of(context).overdue,
                                ),
                          ),
                        const SizedBox(height: AppTokens.s4),
                        Row(
                          key: ValueKey('home-plan-actions-${item.plan.id}'),
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomerGradeBadge(
                              grade: CustomerGrade.fromDb(item.customer.grade),
                            ),
                            const Spacer(),
                            IconButton(
                              key: ValueKey(
                                'home-plan-complete-${item.plan.id}',
                              ),
                              tooltip: '完成任务',
                              onPressed: busy ? null : _complete,
                              icon: const Icon(Icons.check_circle_outline),
                            ),
                            PopupMenuButton<String>(
                              key: ValueKey('home-plan-menu-${item.plan.id}'),
                              tooltip: '更多操作',
                              onSelected: (_) => _cancel(),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'cancel',
                                  child: Text('取消任务'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
