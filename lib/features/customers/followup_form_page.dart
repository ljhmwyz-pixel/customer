import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_dropdown_form_field.dart';
import '../../widgets/app_form_fields.dart';
import '../../widgets/form_error_navigation.dart';
import '../../widgets/sticky_form_scaffold.dart';
import '../../widgets/unsaved_changes_guard.dart';
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
  final _feedbackController = TextEditingController();
  final _nextActionController = TextEditingController();
  final _contentController = TextEditingController();
  final _pauseReasonController = TextEditingController();
  final _feedbackTargetKey = GlobalKey();
  final _stageTargetKey = GlobalKey();
  final _nextActionTargetKey = GlobalKey();
  final _pauseReasonTargetKey = GlobalKey();
  final _feedbackFocusNode = FocusNode();
  final _nextActionFocusNode = FocusNode();
  final _pauseReasonFocusNode = FocusNode();

  int? _selectedOpportunityId;
  int? _selectedContactId;
  bool _contactInitialized = false;
  CustomerAttitude _attitude = CustomerAttitude.normal;
  OpportunityStage? _stage;
  FollowMethod _method = FollowMethod.phone;
  DateTime _occurredAt = DateTime.now();
  DateTime _planAt = DateTime.now().add(const Duration(days: 1));
  bool _skipNextPlan = false;
  bool _saving = false;
  bool _dirty = false;
  bool _allowLeave = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _feedbackController,
      _nextActionController,
      _contentController,
      _pauseReasonController,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  void _change(VoidCallback update) {
    _markDirty();
    setState(update);
  }

  @override
  void dispose() {
    for (final controller in [
      _feedbackController,
      _nextActionController,
      _contentController,
      _pauseReasonController,
    ]) {
      controller.removeListener(_markDirty);
    }
    _feedbackController.dispose();
    _nextActionController.dispose();
    _contentController.dispose();
    _pauseReasonController.dispose();
    _feedbackFocusNode.dispose();
    _nextActionFocusNode.dispose();
    _pauseReasonFocusNode.dispose();
    super.dispose();
  }

  void _initializeOpportunity(List<OpportunityRow> opportunities) {
    if (opportunities.isEmpty || _selectedOpportunityId != null) return;
    final opportunity = opportunities.first;
    _selectedOpportunityId = opportunity.id;
    _stage = OpportunityStage.fromDb(opportunity.stage);
  }

  void _initializeContact(List<ContactRow> contacts) {
    if (_contactInitialized) return;
    _contactInitialized = true;
    if (contacts.isNotEmpty) _selectedContactId = contacts.first.id;
  }

  void _selectOpportunity(
    int opportunityId,
    List<OpportunityRow> opportunities,
  ) {
    final opportunity = opportunities.firstWhere(
      (item) => item.id == opportunityId,
    );
    _change(() {
      _selectedOpportunityId = opportunity.id;
      _stage = OpportunityStage.fromDb(opportunity.stage);
    });
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
    _change(() {
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
    _change(() {
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
    if (_saving) return;
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      await _revealFirstError();
      return;
    }
    final opportunityId = _selectedOpportunityId;
    final stage = _stage;
    if (opportunityId == null || stage == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(customerServiceProvider)
          .addFollowup(
            widget.customerId,
            FollowupDraft(
              opportunityId: opportunityId,
              occurredAt: _occurredAt,
              method: _method,
              feedback: _feedbackController.text,
              stage: stage,
              nextAction: _nextActionController.text,
              content: _contentController.text,
              nextFollowAt: _skipNextPlan ? null : _planAt,
              pauseReason: _skipNextPlan ? _pauseReasonController.text : null,
              contactId: _selectedContactId,
              attitude: _attitude,
            ),
          );
      ref.read(customerRevisionProvider.notifier).refresh();
      if (!mounted) return;
      if (result.warning != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.warning!)));
      }
      setState(() {
        _allowLeave = true;
        _dirty = false;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) context.go('/customers/${widget.customerId}');
    } on CustomerValidationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _revealFirstError() {
    if (_feedbackController.text.trim().isEmpty) {
      return revealFormError(
        targetKey: _feedbackTargetKey,
        focusNode: _feedbackFocusNode,
      );
    }
    if (_stage == null) return revealFormError(targetKey: _stageTargetKey);
    if (_nextActionController.text.trim().isEmpty) {
      return revealFormError(
        targetKey: _nextActionTargetKey,
        focusNode: _nextActionFocusNode,
      );
    }
    return revealFormError(
      targetKey: _pauseReasonTargetKey,
      focusNode: _pauseReasonFocusNode,
    );
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
          _initializeOpportunity(value.opportunities);
          _initializeContact(value.contacts);
          final hasOpportunity = value.opportunities.isNotEmpty;
          return StickyFormScaffold(
            onSubmit: _save,
            enabled: hasOpportunity,
            submitting: _saving,
            submitLabel: '保存跟进',
            submitKey: const ValueKey('save-followup'),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s16,
                  AppTokens.s16,
                  AppTokens.s16,
                  AppTokens.s16 + AppTokens.minTouchTarget,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      value.customer.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTokens.s16),
                    if (!hasOpportunity) ...[
                      const _NoOpportunityMessage(),
                      const SizedBox(height: AppTokens.s16),
                    ] else if (value.opportunities.length == 1) ...[
                      Text(
                        '项目：${value.opportunities.single.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTokens.s16),
                    ] else ...[
                      AppDropdownFormField<int>(
                        fieldKey: const ValueKey('followup-opportunity'),
                        initialValue: _selectedOpportunityId,
                        decoration: const InputDecoration(labelText: '跟进项目'),
                        items: value.opportunities
                            .map(
                              (opportunity) => DropdownMenuItem(
                                value: opportunity.id,
                                child: Text(
                                  opportunity.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (opportunityId) {
                          if (opportunityId != null) {
                            _selectOpportunity(
                              opportunityId,
                              value.opportunities,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppTokens.s12),
                    ],
                    if (value.contacts.isNotEmpty) ...[
                      DropdownButtonFormField<int?>(
                        key: const ValueKey('followup-contact'),
                        initialValue: _selectedContactId,
                        decoration: const InputDecoration(labelText: '联系人'),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('未指定联系人'),
                          ),
                          ...value.contacts.map(
                            (contact) => DropdownMenuItem<int?>(
                              value: contact.id,
                              child: Text(contact.name),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            _change(() => _selectedContactId = value),
                      ),
                      const SizedBox(height: AppTokens.s12),
                    ],
                    DropdownButtonFormField<CustomerAttitude>(
                      key: const ValueKey('followup-attitude'),
                      initialValue: _attitude,
                      decoration: const InputDecoration(labelText: '客户态度'),
                      items: CustomerAttitude.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) _change(() => _attitude = value);
                      },
                    ),
                    const SizedBox(height: AppTokens.s12),
                    KeyedSubtree(
                      key: _feedbackTargetKey,
                      child: TextFormField(
                        key: const ValueKey('followup-feedback'),
                        controller: _feedbackController,
                        focusNode: _feedbackFocusNode,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 10000,
                        decoration: const InputDecoration(
                          labelText: '客户反馈',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? '客户反馈不能为空'
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s12),
                    KeyedSubtree(
                      key: _stageTargetKey,
                      child: AppDropdownFormField<OpportunityStage>(
                        fieldKey: const ValueKey('followup-stage'),
                        initialValue: _stage,
                        decoration: const InputDecoration(labelText: '项目阶段'),
                        items: OpportunityStage.values
                            .map(
                              (stage) => DropdownMenuItem(
                                value: stage,
                                child: Text(
                                  stage.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: hasOpportunity
                            ? (stage) {
                                if (stage != null) {
                                  _change(() => _stage = stage);
                                }
                              }
                            : null,
                        validator: (value) => value == null ? '请选择项目阶段' : null,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s12),
                    KeyedSubtree(
                      key: _nextActionTargetKey,
                      child: TextFormField(
                        key: const ValueKey('followup-next-action'),
                        controller: _nextActionController,
                        focusNode: _nextActionFocusNode,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: '下一步行动'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? '下一步行动不能为空'
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s24),
                    Text(
                      '补充信息',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.s12),
                    TextFormField(
                      key: const ValueKey('followup-content'),
                      controller: _contentController,
                      minLines: 2,
                      maxLines: 5,
                      maxLength: 10000,
                      decoration: const InputDecoration(
                        labelText: '跟进内容（选填）',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s16),
                    AppDropdownFormField<FollowMethod>(
                      fieldKey: const ValueKey('followup-method'),
                      initialValue: _method,
                      decoration: const InputDecoration(labelText: '跟进方式'),
                      items: FollowMethod.values
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(
                                method.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _change(() => _method = value);
                      },
                    ),
                    const SizedBox(height: AppTokens.s12),
                    AppDateFormField(
                      fieldKey: const ValueKey('followup-occurred-at'),
                      label: '发生时间',
                      value: _occurredAt,
                      valueText: formatDateTime(_occurredAt),
                      prefixIcon: Icons.schedule_outlined,
                      onTap: () => _pickDateTime(forPlan: false),
                    ),
                    const SizedBox(height: AppTokens.s24),
                    Text(
                      '后续安排',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                        _change(() => _skipNextPlan = selection.first);
                      },
                    ),
                    if (!_skipNextPlan) ...[
                      const SizedBox(height: AppTokens.s16),
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
                      AppDateFormField(
                        fieldKey: const ValueKey('followup-plan-at'),
                        label: '下次跟进时间',
                        value: _planAt,
                        valueText: formatDateTime(_planAt),
                        prefixIcon: Icons.schedule_outlined,
                        onTap: () => _pickDateTime(forPlan: true),
                      ),
                    ] else ...[
                      const SizedBox(height: AppTokens.s16),
                      KeyedSubtree(
                        key: _pauseReasonTargetKey,
                        child: TextFormField(
                          key: const ValueKey('followup-pause-reason'),
                          controller: _pauseReasonController,
                          focusNode: _pauseReasonFocusNode,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: '暂停原因',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (!_skipNextPlan) return null;
                            return value == null || value.trim().isEmpty
                                ? '暂停原因不能为空'
                                : null;
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTokens.s24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).protectUnsavedChanges(hasUnsavedChanges: _dirty && !_allowLeave);
  }
}

class _NoOpportunityMessage extends StatelessWidget {
  const _NoOpportunityMessage();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppTokens.s8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: AppTokens.s8),
          const Expanded(child: Text('当前客户暂无项目，请先创建项目后再记录跟进。')),
        ],
      ),
    ),
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
