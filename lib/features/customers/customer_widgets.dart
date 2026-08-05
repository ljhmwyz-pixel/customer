import 'package:flutter/material.dart';

import '../../data/daos/customer_dao.dart';
import '../../data/database.dart';
import '../../models/enums.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';

DateTime localDateTime(int utcMilliseconds) =>
    DateTime.fromMillisecondsSinceEpoch(utcMilliseconds, isUtc: true).toLocal();

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

String planTimingLabel(DateTime value, {DateTime? now}) {
  final local = value.toLocal();
  final current = (now ?? DateTime.now()).toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(current.year, current.month, current.day);
  final difference = day.difference(today).inDays;
  final time = formatDateTime(local).split(' ').last;
  if (difference < 0) return '逾期 ${-difference} 天 · $time';
  if (difference == 0) return '今天 $time';
  if (difference == 1) return '明天 $time';
  return formatDateTime(local);
}

class CustomerStageBadge extends StatelessWidget {
  const CustomerStageBadge({required this.stage, super.key});

  final CustomerStage stage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final color = stage == CustomerStage.lost
        ? semantic.inactive
        : stage == CustomerStage.deal
        ? semantic.done
        : scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s4,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.r4),
      ),
      child: Text(
        stage.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: AppTokens.f10,
          fontWeight: AppTokens.wMedium,
        ),
      ),
    );
  }
}

class CustomerGradeBadge extends StatelessWidget {
  const CustomerGradeBadge({required this.grade, super.key});

  final CustomerGrade grade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: AppTokens.s24,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppTokens.r4),
        ),
        child: Center(
          child: Text(
            grade.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
              fontSize: AppTokens.f12,
              fontWeight: AppTokens.wSemibold,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerRowTile extends StatelessWidget {
  const CustomerRowTile({
    required this.item,
    required this.tags,
    required this.onTap,
    this.now,
    super.key,
  });

  final CustomerListItem item;
  final List<TagRow> tags;
  final VoidCallback onTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final current = now ?? DateTime.now();
    final overdue = item.overdueDays(current) > 0;
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final company = item.customer.company?.trim();
    final planAt = item.nextPlanAt;
    final supporting = planAt == null
        ? company == null || company.isEmpty
              ? '暂无跟进计划'
              : company
        : planTimingLabel(planAt, now: current);

    return SizedBox(
      height: AppTokens.minTouchTarget + AppTokens.s32,
      child: Material(
        color: scheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: AppTokens.accentBarWidth,
                height: double.infinity,
                child: ColoredBox(
                  color: overdue ? semantic.overdue : Colors.transparent,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s12,
                    vertical: AppTokens.s8,
                  ),
                  child: Row(
                    children: [
                      CustomerGradeBadge(grade: item.grade),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontSize: AppTokens.f16,
                                    fontWeight: AppTokens.wMedium,
                                  ),
                            ),
                            const SizedBox(height: AppTokens.s4),
                            Text(
                              supporting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: overdue
                                        ? semantic.overdue
                                        : scheme.onSurfaceVariant,
                                    fontSize: AppTokens.f12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTokens.s8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppTokens.minTouchTarget + AppTokens.s24,
                        ),
                        child: CustomerStageBadge(stage: item.stage),
                      ),
                      const SizedBox(width: AppTokens.s4),
                      Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerAsyncError extends StatelessWidget {
  const CustomerAsyncError({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: AppTokens.s32),
          const SizedBox(height: AppTokens.s12),
          const Text('加载失败，请重试'),
          const SizedBox(height: AppTokens.s16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    ),
  );
}
