import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../theme/tokens.dart';
import 'customer_providers.dart';
import 'customer_widgets.dart';

class FollowupFormPage extends ConsumerStatefulWidget {
  const FollowupFormPage({required this.customerId, super.key});

  final int customerId;

  @override
  ConsumerState<FollowupFormPage> createState() => _FollowupFormPageState();
}

class _FollowupFormPageState extends ConsumerState<FollowupFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _conclusionController = TextEditingController();
  final _planTitleController = TextEditingController(text: '再次联系');

  FollowMethod _method = FollowMethod.phone;
  DateTime _occurredAt = DateTime.now();
  DateTime _planAt = DateTime.now().add(const Duration(days: 1));
  bool _skipNextPlan = false;
  bool _saving = false;

  @override
  void dispose() {
    _contentController.dispose();
    _conclusionController.dispose();
    _planTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool forPlan}) async {
    final initial = forPlan ? _planAt : _occurredAt;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: forPlan ? DateTime.now() : DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      final value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (forPlan) {
        _planAt = value;
      } else {
        _occurredAt = value;
      }
    });
  }

  void _setPlanOffset(int days) {
    final now = DateTime.now();
    setState(() {
      _planAt = DateTime(
        now.year,
        now.month,
        now.day + days,
        _planAt.hour,
        _planAt.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(customerServiceProvider)
          .addFollowup(
            widget.customerId,
            FollowupDraft(
              occurredAt: _occurredAt,
              method: _method,
              content: _contentController.text,
              conclusion: _conclusionController.text,
              nextPlan: _skipNextPlan
                  ? null
                  : PlanDraft(
                      title: _planTitleController.text,
                      planAt: _planAt,
                    ),
              skipNextPlan: _skipNextPlan,
            ),
          );
      ref.read(customerRevisionProvider.notifier).refresh();
      if (!mounted) return;
      if (result.warning != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.warning!)));
      }
      context.go('/customers/${widget.customerId}');
    } on CustomerValidationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(customerDetailProvider(widget.customerId));
    return Scaffold(
      appBar: AppBar(title: const Text('记录跟进')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => CustomerAsyncError(
          onRetry: () =>
              ref.invalidate(customerDetailProvider(widget.customerId)),
        ),
        data: (value) {
          if (value == null) {
            return _MissingCustomer(onBack: () => context.go('/customers'));
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppTokens.s16),
              children: [
                Text(
                  value.customer.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTokens.s16),
                TextFormField(
                  key: const ValueKey('followup-content'),
                  controller: _contentController,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 10000,
                  decoration: const InputDecoration(
                    labelText: '跟进内容',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '跟进内容不能为空' : null,
                ),
                const SizedBox(height: AppTokens.s12),
                TextFormField(
                  controller: _conclusionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '本次结论（选填）',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppTokens.s16),
                DropdownButtonFormField<FollowMethod>(
                  initialValue: _method,
                  decoration: const InputDecoration(labelText: '跟进方式'),
                  items: FollowMethod.values
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _method = value);
                  },
                ),
                const SizedBox(height: AppTokens.s12),
                _DateTimeTile(
                  label: '发生时间',
                  value: _occurredAt,
                  onTap: () => _pickDateTime(forPlan: false),
                ),
                const SizedBox(height: AppTokens.s24),
                Text('后续安排', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppTokens.s12),
                SegmentedButton<bool>(
                  key: const ValueKey('followup-next-choice'),
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.event_outlined),
                      label: Text('安排下次'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.event_busy_outlined),
                      label: Text('暂不跟进'),
                    ),
                  ],
                  selected: {_skipNextPlan},
                  onSelectionChanged: (selection) {
                    setState(() => _skipNextPlan = selection.first);
                  },
                ),
                if (!_skipNextPlan) ...[
                  const SizedBox(height: AppTokens.s16),
                  TextFormField(
                    key: const ValueKey('next-plan-title'),
                    controller: _planTitleController,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: '计划标题'),
                    validator: (value) {
                      if (_skipNextPlan) return null;
                      return value == null || value.trim().isEmpty
                          ? '计划标题不能为空'
                          : null;
                    },
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Wrap(
                    spacing: AppTokens.s8,
                    runSpacing: AppTokens.s8,
                    children: [
                      ActionChip(
                        label: const Text('明天'),
                        onPressed: () => _setPlanOffset(1),
                      ),
                      ActionChip(
                        label: const Text('三天后'),
                        onPressed: () => _setPlanOffset(3),
                      ),
                      ActionChip(
                        label: const Text('一周后'),
                        onPressed: () => _setPlanOffset(7),
                      ),
                      ActionChip(
                        label: const Text('一个月后'),
                        onPressed: () => _setPlanOffset(30),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.edit_calendar_outlined),
                        label: const Text('自定义'),
                        onPressed: () => _pickDateTime(forPlan: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s12),
                  _DateTimeTile(
                    label: '计划时间',
                    value: _planAt,
                    onTap: () => _pickDateTime(forPlan: true),
                  ),
                ],
                const SizedBox(height: AppTokens.s24),
                FilledButton.icon(
                  key: const ValueKey('save-followup'),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: AppTokens.s16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? '保存中' : '保存跟进'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.schedule_outlined),
    title: Text(label),
    subtitle: Text(formatDateTime(value)),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _MissingCustomer extends StatelessWidget {
  const _MissingCustomer({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_off_outlined, size: AppTokens.s32),
          const SizedBox(height: AppTokens.s12),
          const Text('客户不存在'),
          const SizedBox(height: AppTokens.s16),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回客户列表'),
          ),
        ],
      ),
    ),
  );
}
