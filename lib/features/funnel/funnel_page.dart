import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/daos/customer_dao.dart';
import '../../models/enums.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';
import '../customers/customer_providers.dart';
import '../customers/customer_widgets.dart';

class FunnelPage extends ConsumerWidget {
  const FunnelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('看板')),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => CustomerAsyncError(
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => _DashboardBody(data: data),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final m = data.metrics;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        AppTokens.s8,
        AppTokens.s16,
        AppTokens.s24,
      ),
      children: [
        _heading(context, '客户与项目'),
        _MetricSurface(
          children: [
            _metric(
              context,
              '客户总数',
              '${m.totalCustomers}',
              Icons.people_outline,
              '/customers',
            ),
            _metric(
              context,
              '客户等级',
              'A ${m.customerCountsByGrade[CustomerGrade.a] ?? 0} · B ${m.customerCountsByGrade[CustomerGrade.b] ?? 0} · C ${m.customerCountsByGrade[CustomerGrade.c] ?? 0} · D ${m.customerCountsByGrade[CustomerGrade.d] ?? 0}',
              Icons.grade_outlined,
              '/customers',
            ),
            _metric(
              context,
              '本周跟进',
              '${m.followupsThisWeek}',
              Icons.forum_outlined,
              '/customers',
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        _heading(context, '金额与活动'),
        _MetricSurface(
          children: [
            _metric(
              context,
              '未来三个月预计成交',
              _money(m.forecastByCurrency),
              Icons.trending_up,
              null,
            ),
            _metric(
              context,
              '未来三个月加权预计',
              _money(m.weightedForecastByCurrency),
              Icons.insights_outlined,
              null,
            ),
            _metric(
              context,
              '已成交金额',
              _money(m.wonByCurrency),
              Icons.check_circle_outline,
              '/customers',
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        _heading(context, '重点停滞'),
        _MetricSurface(
          children: [
            _metric(
              context,
              '报价停滞',
              '${m.stalledQuoteCount}',
              Icons.request_quote_outlined,
              '/customers?anomaly=stalledQuote',
            ),
            _metric(
              context,
              '样品停滞',
              '${m.stalledSampleCount}',
              Icons.science_outlined,
              '/customers?anomaly=stalledSample',
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        _heading(context, '异常入口'),
        if (data.anomalies.isEmpty)
          const _UnavailableRow(label: '当前没有需要处理的业务异常')
        else
          for (final anomaly in data.anomalies) _AnomalyRow(anomaly: anomaly),
      ],
    );
  }

  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );

  String _money(Map<String, int> values) {
    if (values.isEmpty) return '暂无';
    return values.entries
        .map((entry) => _formatMinor(entry.key, entry.value))
        .join('\n');
  }

  String _formatMinor(String currency, int amount) {
    const zeroDecimalCurrencies = {'JPY', 'KRW', 'VND'};
    if (zeroDecimalCurrencies.contains(currency)) return '$currency $amount';
    final sign = amount < 0 ? '-' : '';
    final absolute = amount.abs();
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '$currency $sign$whole.$fraction';
  }

  Widget _metric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    String? route,
  ) => InkWell(
    key: ValueKey('dashboard-metric-$label'),
    onTap: route == null ? null : () => context.go(route),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: AppTokens.s12),
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: AppTokens.wMedium),
            ),
          ),
          if (route != null) const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

class _MetricSurface extends StatelessWidget {
  const _MetricSurface({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
    borderRadius: BorderRadius.circular(AppTokens.r8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
      child: Column(children: children),
    ),
  );
}

class _AnomalyRow extends StatelessWidget {
  const _AnomalyRow({required this.anomaly});
  final DashboardAnomaly anomaly;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final (label, icon) = switch (anomaly.kind) {
      DashboardAnomalyKind.stalledQuote => (
        '报价停滞',
        Icons.request_quote_outlined,
      ),
      DashboardAnomalyKind.quoteExpiring => (
        '报价即将到期',
        Icons.event_busy_outlined,
      ),
      DashboardAnomalyKind.stalledSample => ('样品停滞', Icons.science_outlined),
      DashboardAnomalyKind.longSilence => ('长期沉默', Icons.hourglass_empty),
      DashboardAnomalyKind.internalSupport => ('需要内部支持', Icons.support_agent),
      DashboardAnomalyKind.registrationDue => (
        '注册节点到期',
        Icons.assignment_late_outlined,
      ),
      DashboardAnomalyKind.tenderImminent => ('招标临近截止', Icons.gavel_outlined),
      DashboardAnomalyKind.repurchaseDue => ('近期复购', Icons.autorenew),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8),
      child: Material(
        color: semantic.overdue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.r8),
        child: InkWell(
          key: ValueKey(
            'dashboard-anomaly-${anomaly.customerId}-${anomaly.kind.name}',
          ),
          onTap: () => context.go('/customers/${anomaly.customerId}'),
          child: ListTile(
            leading: Icon(icon, color: semantic.overdue),
            title: Text(
              '$label · ${anomaly.customerName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              anomaly.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

class _UnavailableRow extends StatelessWidget {
  const _UnavailableRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.hourglass_empty_outlined),
    title: Text(label),
    enabled: false,
  );
}
