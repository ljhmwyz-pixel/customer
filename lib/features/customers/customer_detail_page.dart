import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../models/enums.dart';
import '../../theme/semantic_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../orders/order_form_page.dart';
import '../orders/order_providers.dart';
import 'contact_actions.dart';
import 'customer_providers.dart';
import 'customer_widgets.dart';

class CustomerDetailPage extends ConsumerWidget {
  const CustomerDetailPage({
    required this.customerId,
    this.highlightedPlanId,
    this.invalidPlanId = false,
    super.key,
  });

  final int? customerId;
  final int? highlightedPlanId;
  final bool invalidPlanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = customerId;
    if (id == null) {
      return _MissingCustomer(message: '客户编号无效');
    }

    final detail = ref.watch(customerDetailProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('客户详情'),
        actions: [
          IconButton(
            tooltip: '编辑客户',
            onPressed: () => context.push('/customers/$id/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<_CustomerAction>(
            tooltip: '更多操作',
            onSelected: (action) {
              if (action == _CustomerAction.delete) {
                _deleteCustomer(context, ref, id);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _CustomerAction.delete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('删除客户'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/$id/followups/new'),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('记录跟进'),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => CustomerAsyncError(
          onRetry: () => ref.invalidate(customerDetailProvider(id)),
        ),
        data: (value) {
          if (value == null) return const _MissingCustomerBody();
          final hasHighlightedPlan =
              highlightedPlanId != null &&
              value.plans.any((plan) => plan.id == highlightedPlanId);
          final showPlanWarning =
              invalidPlanId ||
              (highlightedPlanId != null && !hasHighlightedPlan);
          return RefreshIndicator(
            onRefresh: () async {
              ref.read(customerRevisionProvider.notifier).refresh();
              await ref.read(customerDetailProvider(id).future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s8,
                AppTokens.s16,
                AppTokens.s32 + AppTokens.minTouchTarget,
              ),
              children: [
                if (showPlanWarning) ...[
                  const _InlineMessage(
                    icon: Icons.info_outline,
                    message: '指定的跟进计划不存在',
                  ),
                  const SizedBox(height: AppTokens.s16),
                ],
                _CustomerOverview(
                  customer: value.customer,
                  tags: value.tags,
                  completedAmountCents: value.completedAmountCents,
                  onCall: () => _call(context, ref, value.customer.phone),
                ),
                const SizedBox(height: AppTokens.s24),
                _SectionHeader(
                  title: '联系人',
                  count: value.contacts.length,
                  actions: [
                    IconButton(
                      tooltip: '从通讯录导入',
                      onPressed: () => _importContact(context, ref, id),
                      icon: const Icon(Icons.contact_page_outlined),
                    ),
                    IconButton(
                      tooltip: '新增联系人',
                      onPressed: () => _editContact(context, ref, id),
                      icon: const Icon(Icons.person_add_outlined),
                    ),
                  ],
                ),
                if (value.contacts.isEmpty)
                  const _SectionEmpty(message: '暂无联系人')
                else
                  ...value.contacts.map(
                    (contact) => _ContactTile(
                      contact: contact,
                      onCall: () => _call(context, ref, contact.phone),
                      onEdit: () =>
                          _editContact(context, ref, id, contact: contact),
                      onDelete: () => _deleteContact(context, ref, contact),
                    ),
                  ),
                const SizedBox(height: AppTokens.s24),
                _SectionHeader(
                  title: '订单',
                  count: value.orders.length,
                  actions: [
                    IconButton(
                      tooltip: '新增订单',
                      onPressed: () =>
                          context.push('/customers/$id/orders/new'),
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                    ),
                  ],
                ),
                if (value.orders.isEmpty)
                  const _SectionEmpty(message: '暂无订单')
                else
                  ...value.orders.map((order) {
                    final status = OrderStatus.fromDb(order.status);
                    final nextStatus = status.nextStatus;
                    final canCancel =
                        status != OrderStatus.completed &&
                        status != OrderStatus.cancelled;
                    return _OrderTile(
                      order: order,
                      status: status,
                      onEdit: () => context.push(
                        '/customers/$id/orders/${order.id}/edit',
                      ),
                      onAdvance: nextStatus == null
                          ? null
                          : () => _transitionOrder(
                              context,
                              ref,
                              id,
                              order,
                              nextStatus,
                            ),
                      onCancel: canCancel
                          ? () => _cancelOrder(context, ref, id, order)
                          : null,
                      onDelete: () => _deleteOrder(context, ref, id, order),
                    );
                  }),
                const SizedBox(height: AppTokens.s24),
                _SectionHeader(title: '跟进计划', count: value.plans.length),
                if (value.plans.isEmpty)
                  const _SectionEmpty(message: '暂无跟进计划')
                else
                  ...value.plans.map(
                    (plan) => _PlanTile(
                      plan: plan,
                      highlighted:
                          hasHighlightedPlan && plan.id == highlightedPlanId,
                    ),
                  ),
                const SizedBox(height: AppTokens.s24),
                _SectionHeader(title: '跟进记录', count: value.followups.length),
                if (value.followups.isEmpty)
                  const _SectionEmpty(message: '暂无跟进记录')
                else
                  _FollowupTimeline(followups: value.followups),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _call(BuildContext context, WidgetRef ref, String? phone) async {
    try {
      await ref.read(contactActionsProvider).call(phone ?? '');
    } on ContactActionException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } catch (_) {
      if (context.mounted) _showMessage(context, '当前设备无法拨打电话');
    }
  }

  Future<void> _importContact(
    BuildContext context,
    WidgetRef ref,
    int customerId,
  ) async {
    try {
      final imported = await ref.read(contactActionsProvider).pickContact();
      if (imported == null || !context.mounted) return;
      await _editContact(
        context,
        ref,
        customerId,
        initial: ContactDraft(
          name: imported.name,
          position: imported.position,
          phone: imported.phone,
        ),
      );
    } on ContactActionException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, '无法读取通讯录，请在系统设置中允许通讯录权限');
      }
    }
  }

  Future<void> _editContact(
    BuildContext context,
    WidgetRef ref,
    int customerId, {
    ContactRow? contact,
    ContactDraft? initial,
  }) async {
    final draft = await showDialog<ContactDraft>(
      context: context,
      builder: (context) => _ContactDialog(
        initial:
            initial ??
            (contact == null
                ? null
                : ContactDraft(
                    name: contact.name,
                    position: contact.position,
                    phone: contact.phone,
                    isDecisionMaker: contact.isDecisionMaker,
                  )),
      ),
    );
    if (draft == null || !context.mounted) return;
    try {
      final service = ref.read(customerServiceProvider);
      if (contact == null) {
        await service.createContact(customerId, draft);
      } else {
        await service.updateContact(contact.id, draft);
      }
      ref.read(customerRevisionProvider.notifier).refresh();
    } on CustomerValidationException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } catch (_) {
      if (context.mounted) _showMessage(context, '联系人保存失败，请重试');
    }
  }

  Future<void> _deleteContact(
    BuildContext context,
    WidgetRef ref,
    ContactRow contact,
  ) async {
    final confirmed = await _confirm(
      context,
      title: '删除联系人',
      message: '确定删除联系人“${contact.name}”吗？',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(customerServiceProvider).deleteContact(contact.id);
      ref.read(customerRevisionProvider.notifier).refresh();
    } catch (_) {
      if (context.mounted) _showMessage(context, '删除失败，请重试');
    }
  }

  Future<void> _deleteCustomer(
    BuildContext context,
    WidgetRef ref,
    int customerId,
  ) async {
    final confirmed = await _confirm(
      context,
      title: '删除客户',
      message: '客户资料、联系人、计划和跟进记录将一并删除，此操作无法撤销。',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(customerServiceProvider).deleteCustomer(customerId);
      ref.read(customerRevisionProvider.notifier).refresh();
      if (context.mounted) context.go('/customers');
    } catch (_) {
      if (context.mounted) _showMessage(context, '删除失败，请重试');
    }
  }

  Future<void> _transitionOrder(
    BuildContext context,
    WidgetRef ref,
    int customerId,
    OrderRow order,
    OrderStatus target,
  ) async {
    try {
      await ref
          .read(orderServiceProvider)
          .transitionOrder(customerId, order.id, target);
      ref.read(customerRevisionProvider.notifier).refresh();
    } on OrderValidationException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } catch (_) {
      if (context.mounted) _showMessage(context, '订单状态更新失败，请重试');
    }
  }

  Future<void> _cancelOrder(
    BuildContext context,
    WidgetRef ref,
    int customerId,
    OrderRow order,
  ) async {
    final confirmed = await _confirm(
      context,
      title: '取消订单',
      message: '确定取消订单“${order.orderNo}”吗？',
      confirmLabel: '确认取消',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(orderServiceProvider).cancelOrder(customerId, order.id);
      ref.read(customerRevisionProvider.notifier).refresh();
    } on OrderValidationException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } catch (_) {
      if (context.mounted) _showMessage(context, '取消订单失败，请重试');
    }
  }

  Future<void> _deleteOrder(
    BuildContext context,
    WidgetRef ref,
    int customerId,
    OrderRow order,
  ) async {
    final confirmed = await _confirm(
      context,
      title: '删除订单',
      message: '确定删除订单“${order.orderNo}”吗？此操作无法撤销。',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(orderServiceProvider).deleteOrder(customerId, order.id);
      ref.read(customerRevisionProvider.notifier).refresh();
    } on OrderValidationException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } catch (_) {
      if (context.mounted) _showMessage(context, '删除订单失败，请重试');
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = '删除',
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CustomerOverview extends StatelessWidget {
  const _CustomerOverview({
    required this.customer,
    required this.tags,
    required this.completedAmountCents,
    required this.onCall,
  });

  final CustomerRow customer;
  final List<TagRow> tags;
  final int completedAmountCents;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final company = customer.company?.trim();
    final phone = customer.phone?.trim();
    final fields = <(IconData, String, String?)>[
      (Icons.business_outlined, '公司', company),
      (Icons.phone_outlined, '电话', phone),
      (Icons.chat_outlined, '微信', customer.wechat),
      (Icons.location_on_outlined, '地址', customer.address),
      (Icons.input_outlined, '来源', customer.source),
      (Icons.notes_outlined, '备注', customer.note),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerGradeBadge(grade: CustomerGrade.fromDb(customer.grade)),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Text(
                customer.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: AppTokens.f24,
                  fontWeight: AppTokens.wSemibold,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s8),
            CustomerStageBadge(stage: CustomerStage.fromDb(customer.stage)),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: AppTokens.s12),
          Wrap(
            spacing: AppTokens.s8,
            runSpacing: AppTokens.s8,
            children: tags
                .map(
                  (tag) => Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(tag.name),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: AppTokens.s16),
        const Divider(height: 1),
        _InfoRow(
          icon: Icons.account_balance_wallet_outlined,
          label: '累计成交金额',
          value: formatAmountCents(completedAmountCents),
        ),
        ...fields
            .where((field) => field.$3?.trim().isNotEmpty ?? false)
            .map(
              (field) => _InfoRow(
                icon: field.$1,
                label: field.$2,
                value: field.$3!.trim(),
                trailing: field.$2 == '电话'
                    ? IconButton(
                        tooltip: '拨打电话',
                        onPressed: onCall,
                        icon: const Icon(Icons.call_outlined),
                      )
                    : null,
              ),
            ),
        if (!fields.any((field) => field.$3?.trim().isNotEmpty ?? false))
          const _SectionEmpty(message: '暂无更多资料'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppTokens.s4),
          child: Icon(
            icon,
            size: AppTokens.s24,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppTokens.s12),
        SizedBox(
          width: AppTokens.minTouchTarget,
          child: Padding(
            padding: const EdgeInsets.only(top: AppTokens.s4),
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Expanded(child: Text(value)),
        ?trailing,
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.actions,
  });

  final String title;
  final int count;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '$title  $count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: AppTokens.f20,
              fontWeight: AppTokens.wSemibold,
            ),
          ),
        ),
        ...?actions,
      ],
    ),
  );
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.onCall,
    required this.onEdit,
    required this.onDelete,
  });

  final ContactRow contact;
  final VoidCallback onCall;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final position = contact.position?.trim();
    final phone = contact.phone?.trim();
    final subtitle = [
      if (position != null && position.isNotEmpty) position,
      if (phone != null && phone.isNotEmpty) phone,
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Row(
        children: [
          Flexible(
            child: Text(
              contact.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (contact.isDecisionMaker) ...[
            const SizedBox(width: AppTokens.s8),
            const Chip(
              visualDensity: VisualDensity.compact,
              label: Text('决策人'),
            ),
          ],
        ],
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '拨打电话',
            onPressed: onCall,
            icon: const Icon(Icons.call_outlined),
          ),
          PopupMenuButton<_ContactAction>(
            tooltip: '联系人操作',
            onSelected: (action) {
              switch (action) {
                case _ContactAction.edit:
                  onEdit();
                case _ContactAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: _ContactAction.edit, child: Text('编辑')),
              PopupMenuItem(value: _ContactAction.delete, child: Text('删除')),
            ],
          ),
        ],
      ),
    );
  }
}

enum _OrderAction { edit, advance, cancel, delete }

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.status,
    required this.onEdit,
    required this.onAdvance,
    required this.onCancel,
    required this.onDelete,
  });

  final OrderRow order;
  final OrderStatus status;
  final VoidCallback onEdit;
  final VoidCallback? onAdvance;
  final VoidCallback? onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final description = order.description?.trim();
    return ListTile(
      key: ValueKey('order-${order.id}'),
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
      title: Text(order.orderNo, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatDateTime(localDateTime(order.orderedAt))} · '
            '${formatAmountCents(order.amountCents)} · ${status.label}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null && description.isNotEmpty)
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: PopupMenuButton<_OrderAction>(
        tooltip: '订单操作',
        onSelected: (action) {
          switch (action) {
            case _OrderAction.edit:
              onEdit();
            case _OrderAction.advance:
              onAdvance?.call();
            case _OrderAction.cancel:
              onCancel?.call();
            case _OrderAction.delete:
              onDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: _OrderAction.edit, child: Text('编辑')),
          if (onAdvance != null)
            PopupMenuItem(
              value: _OrderAction.advance,
              child: Text('推进至${status.nextStatus!.label}'),
            ),
          if (onCancel != null)
            const PopupMenuItem(
              value: _OrderAction.cancel,
              child: Text('取消订单'),
            ),
          const PopupMenuItem(value: _OrderAction.delete, child: Text('删除')),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.highlighted});

  final FollowPlanRow plan;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final status = PlanStatus.fromDb(plan.status);
    final semantic = AppSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      PlanStatus.completed => semantic.done,
      PlanStatus.overdue => semantic.overdue,
      PlanStatus.notified => semantic.today,
      PlanStatus.pending => semantic.upcoming,
    };
    return Container(
      key: ValueKey('plan-${plan.id}'),
      margin: const EdgeInsets.only(bottom: AppTokens.s8),
      padding: const EdgeInsets.all(AppTokens.s12),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer : scheme.surface,
        border: Border.all(
          color: highlighted ? scheme.primary : scheme.outlineVariant,
          width: highlighted ? AppTokens.timelineLineWidth : 1,
        ),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_outlined, color: color),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTokens.wMedium,
                  ),
                ),
                const SizedBox(height: AppTokens.s4),
                Text(
                  planTimingLabel(localDateTime(plan.planAt)),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: AppTokens.wMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowupTimeline extends StatelessWidget {
  const _FollowupTimeline({required this.followups});

  final List<FollowupRow> followups;

  @override
  Widget build(BuildContext context) {
    final ordered = [...followups]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return Column(
      children: [
        for (var index = 0; index < ordered.length; index++)
          _TimelineEntry(
            followup: ordered[index],
            isLast: index == ordered.length - 1,
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.followup, required this.isLast});

  final FollowupRow followup;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final conclusion = followup.conclusion?.trim();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: AppTokens.s24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: AppTokens.timelineDotSize,
                    bottom: 0,
                    child: SizedBox(
                      width: AppTokens.timelineLineWidth,
                      child: ColoredBox(color: scheme.outlineVariant),
                    ),
                  ),
                Positioned(
                  top: AppTokens.s8,
                  child: SizedBox.square(
                    dimension: AppTokens.timelineDotSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          FollowMethod.fromDb(followup.method).label,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: AppTokens.wMedium),
                        ),
                      ),
                      Text(
                        formatDateTime(localDateTime(followup.occurredAt)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Text(followup.content),
                  if (conclusion != null && conclusion.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.s8),
                    Text(
                      '结论：$conclusion',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog({this.initial});

  final ContactDraft? initial;

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _positionController;
  late final TextEditingController _phoneController;
  late bool _isDecisionMaker;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _positionController = TextEditingController(
      text: widget.initial?.position ?? '',
    );
    _phoneController = TextEditingController(text: widget.initial?.phone ?? '');
    _isDecisionMaker = widget.initial?.isDecisionMaker ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ContactDraft(
        name: _nameController.text,
        position: _positionController.text,
        phone: _phoneController.text,
        isDecisionMaker: _isDecisionMaker,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.initial == null ? '新增联系人' : '编辑联系人'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const ValueKey('contact-name'),
              controller: _nameController,
              autofocus: true,
              maxLength: 50,
              decoration: const InputDecoration(labelText: '名称'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '联系人名称不能为空' : null,
            ),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(labelText: '职位'),
            ),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '电话'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('决策人'),
              value: _isDecisionMaker,
              onChanged: (value) {
                setState(() => _isDecisionMaker = value);
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _submit, child: const Text('保存')),
    ],
  );
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTokens.s16),
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppTokens.s12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppTokens.r8),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: AppTokens.s12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _MissingCustomer extends StatelessWidget {
  const _MissingCustomer({this.message = '客户不存在'});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('客户详情')),
    body: _MissingCustomerBody(message: message),
  );
}

class _MissingCustomerBody extends StatelessWidget {
  const _MissingCustomerBody({this.message = '客户不存在'});

  final String message;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.person_off_outlined,
    message: message,
    actionLabel: '返回客户列表',
    onAction: () => context.go('/customers'),
  );
}

enum _CustomerAction { delete }

enum _ContactAction { edit, delete }
