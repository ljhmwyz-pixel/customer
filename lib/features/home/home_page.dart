import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/daos/plan_dao.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../customers/customer_providers.dart';
import '../customers/customer_widgets.dart';

/// 今日待办首页。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(homePlansProvider);
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
        ),
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({required this.values, required this.onRefresh});

  final List<PlanWithCustomer> values;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final groups = _PlanGroups.from(values, DateTime.now());
    if (groups.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.event_available_outlined,
                message: '还没有待办',
                actionLabel: '添加客户',
                onAction: () => context.go('/customers/new'),
              ),
            ),
          ],
        ),
      );
    }

    final semantic = AppSemanticColors.of(context);
    final visibleGroups = <_VisiblePlanGroup>[
      if (groups.overdue.isNotEmpty)
        _VisiblePlanGroup(
          label: '逾期',
          color: semantic.overdue,
          plans: groups.overdue,
        ),
      if (groups.today.isNotEmpty)
        _VisiblePlanGroup(
          label: '今天',
          color: semantic.today,
          plans: groups.today,
        ),
      if (groups.thisWeek.isNotEmpty)
        _VisiblePlanGroup(
          label: '本周',
          color: semantic.upcoming,
          plans: groups.thisWeek,
        ),
    ];

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
          Wrap(
            spacing: AppTokens.s16,
            runSpacing: AppTokens.s4,
            children: visibleGroups
                .map(
                  (group) => _CountItem(
                    label: group.label,
                    value: group.plans.length,
                    color: group.color,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppTokens.s24),
          for (var index = 0; index < visibleGroups.length; index++) ...[
            _PlanSection(group: visibleGroups[index]),
            if (index != visibleGroups.length - 1)
              const SizedBox(height: AppTokens.s24),
          ],
        ],
      ),
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.group});

  final _VisiblePlanGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTokens.s8),
        for (final item in group.plans)
          _PlanTile(item: item, color: group.color),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.item, required this.color});

  final PlanWithCustomer item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: AppTokens.minTouchTarget + AppTokens.s24,
      child: Material(
        color: scheme.surface,
        child: InkWell(
          key: ValueKey('home-plan-${item.plan.id}'),
          onTap: () => context.go(
            '/customers/${item.plan.customerId}?planId=${item.plan.id}',
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppTokens.accentBarWidth,
                height: double.infinity,
                child: ColoredBox(color: color),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: AppTokens.wMedium,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      '${item.plan.title} · ${formatDateTime(item.planAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: AppTokens.f12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountItem extends StatelessWidget {
  const _CountItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppTokens.s4),
        Text(
          '$value',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: AppTokens.wMedium,
          ),
        ),
      ],
    );
  }
}

class _VisiblePlanGroup {
  const _VisiblePlanGroup({
    required this.label,
    required this.color,
    required this.plans,
  });

  final String label;
  final Color color;
  final List<PlanWithCustomer> plans;
}

class _PlanGroups {
  const _PlanGroups({
    required this.overdue,
    required this.today,
    required this.thisWeek,
  });

  final List<PlanWithCustomer> overdue;
  final List<PlanWithCustomer> today;
  final List<PlanWithCustomer> thisWeek;

  bool get isEmpty => overdue.isEmpty && today.isEmpty && thisWeek.isEmpty;

  factory _PlanGroups.from(List<PlanWithCustomer> values, DateTime now) {
    final localNow = now.toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextMonday = today.add(Duration(days: 8 - today.weekday));
    final overdue = <PlanWithCustomer>[];
    final todayPlans = <PlanWithCustomer>[];
    final thisWeek = <PlanWithCustomer>[];

    for (final item in values) {
      final planAt = item.planAt;
      if (planAt.isBefore(today)) {
        overdue.add(item);
      } else if (planAt.isBefore(tomorrow)) {
        todayPlans.add(item);
      } else if (planAt.isBefore(nextMonday)) {
        thisWeek.add(item);
      }
    }

    return _PlanGroups(overdue: overdue, today: todayPlans, thisWeek: thisWeek);
  }
}
