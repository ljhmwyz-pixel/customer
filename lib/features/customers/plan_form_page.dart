import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class PlanFormPage extends ConsumerStatefulWidget {
  const PlanFormPage({required this.customerId, this.planId, super.key});

  final int customerId;
  final int? planId;

  @override
  ConsumerState<PlanFormPage> createState() => _PlanFormPageState();
}

class _PlanFormPageState extends ConsumerState<PlanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _directionController = TextEditingController();
  final _nextActionController = TextEditingController();
  final _ownerController = TextEditingController();
  final _reasonTargetKey = GlobalKey();
  final _directionTargetKey = GlobalKey();
  final _nextActionTargetKey = GlobalKey();
  final _ownerTargetKey = GlobalKey();
  final _reasonFocusNode = FocusNode();
  final _directionFocusNode = FocusNode();
  final _nextActionFocusNode = FocusNode();
  final _ownerFocusNode = FocusNode();

  int? _selectedOpportunityId;
  DateTime _planAt = DateTime.now().add(const Duration(days: 1));
  bool _initialized = false;
  bool _dirty = false;
  bool _saving = false;
  bool _allowLeave = false;

  bool get _isEditing => widget.planId != null;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_markDirty);
    }
  }

  List<TextEditingController> get _controllers => [
    _reasonController,
    _directionController,
    _nextActionController,
    _ownerController,
  ];

  void _markDirty() {
    if (_initialized && !_dirty && mounted) setState(() => _dirty = true);
  }

  void _initialize(
    List<OpportunityRow> opportunities,
    List<FollowPlanRow> plans,
  ) {
    if (_initialized) return;
    _initialized = true;
    if (opportunities.isEmpty) return;
    final plan = _isEditing
        ? plans.where((item) => item.id == widget.planId).firstOrNull
        : null;
    final opportunity = plan?.opportunityId == null
        ? opportunities.first
        : opportunities
                  .where((item) => item.id == plan!.opportunityId)
                  .firstOrNull ??
              opportunities.first;
    _selectedOpportunityId = opportunity.id;
    _reasonController.text = plan?.reason ?? '';
    _directionController.text =
        plan?.talkingDirection ??
        talkingDirectionForStage(OpportunityStage.fromDb(opportunity.stage));
    _nextActionController.text = plan?.nextAction ?? plan?.title ?? '';
    _ownerController.text = plan?.owner ?? opportunity.owner;
    if (plan != null) _planAt = localDateTime(plan.planAt);
    _dirty = false;
  }

  void _selectOpportunity(
    int opportunityId,
    List<OpportunityRow> opportunities,
  ) {
    final opportunity = opportunities.firstWhere(
      (item) => item.id == opportunityId,
    );
    setState(() {
      _selectedOpportunityId = opportunity.id;
      _directionController.text = talkingDirectionForStage(
        OpportunityStage.fromDb(opportunity.stage),
      );
      _ownerController.text = opportunity.owner;
      _dirty = true;
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _planAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_planAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _planAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _dirty = true;
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
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      await _revealFirstError();
      return;
    }
    final opportunityId = _selectedOpportunityId;
    if (opportunityId == null) return;
    setState(() => _saving = true);
    try {
      final draft = PlanDraft(
        opportunityId: opportunityId,
        reason: _reasonController.text,
        talkingDirection: _directionController.text,
        nextAction: _nextActionController.text,
        owner: _ownerController.text,
        planAt: _planAt,
      );
      final warning = _isEditing
          ? await ref
                .read(customerServiceProvider)
                .updatePlan(widget.customerId, widget.planId!, draft)
          : (await ref
                    .read(customerServiceProvider)
                    .createPlan(widget.customerId, draft))
                .warning;
      ref.read(customerRevisionProvider.notifier).refresh();
      ref.invalidate(homePlansProvider);
      ref.invalidate(customerDetailProvider(widget.customerId));
      if (!mounted) return;
      if (warning != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(warning)));
      }
      setState(() {
        _dirty = false;
        _allowLeave = true;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop();
    } on CustomerValidationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _revealFirstError() {
    if (_reasonController.text.trim().isEmpty) {
      return revealFormError(
        targetKey: _reasonTargetKey,
        focusNode: _reasonFocusNode,
      );
    }
    if (_directionController.text.trim().isEmpty) {
      return revealFormError(
        targetKey: _directionTargetKey,
        focusNode: _directionFocusNode,
      );
    }
    if (_nextActionController.text.trim().isEmpty) {
      return revealFormError(
        targetKey: _nextActionTargetKey,
        focusNode: _nextActionFocusNode,
      );
    }
    return revealFormError(
      targetKey: _ownerTargetKey,
      focusNode: _ownerFocusNode,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_markDirty);
      controller.dispose();
    }
    _reasonFocusNode.dispose();
    _directionFocusNode.dispose();
    _nextActionFocusNode.dispose();
    _ownerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(customerDetailProvider(widget.customerId));
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑任务' : '新建任务')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => CustomerAsyncError(
          onRetry: () =>
              ref.invalidate(customerDetailProvider(widget.customerId)),
        ),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('客户不存在'));
          }
          _initialize(value.opportunities, value.plans);
          if (_isEditing &&
              !value.plans.any((item) => item.id == widget.planId)) {
            return const Center(child: Text('任务不存在'));
          }
          final hasOpportunity = value.opportunities.isNotEmpty;
          return StickyFormScaffold(
            onSubmit: _save,
            enabled: hasOpportunity,
            submitting: _saving,
            submitLabel: _isEditing ? '保存修改' : '保存任务',
            submitKey: const ValueKey('save-plan'),
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
                    if (!hasOpportunity)
                      const Text('请先新建项目，再安排跟进任务。')
                    else if (value.opportunities.length == 1)
                      Text(
                        '项目：${value.opportunities.single.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    else
                      AppDropdownFormField<int>(
                        fieldKey: const ValueKey('plan-opportunity'),
                        initialValue: _selectedOpportunityId,
                        decoration: const InputDecoration(labelText: '项目'),
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
                            .toList(growable: false),
                        onChanged: (id) {
                          if (id != null) {
                            _selectOpportunity(id, value.opportunities);
                          }
                        },
                      ),
                    const SizedBox(height: AppTokens.s16),
                    KeyedSubtree(
                      key: _reasonTargetKey,
                      child: TextFormField(
                        key: const ValueKey('plan-reason'),
                        controller: _reasonController,
                        focusNode: _reasonFocusNode,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: '跟进原因'),
                        validator: _required('跟进原因'),
                      ),
                    ),
                    const SizedBox(height: AppTokens.s12),
                    KeyedSubtree(
                      key: _directionTargetKey,
                      child: TextFormField(
                        key: const ValueKey('plan-direction'),
                        controller: _directionController,
                        focusNode: _directionFocusNode,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: '建议话术方向',
                          alignLabelWithHint: true,
                        ),
                        validator: _required('建议话术方向'),
                      ),
                    ),
                    const SizedBox(height: AppTokens.s12),
                    KeyedSubtree(
                      key: _nextActionTargetKey,
                      child: TextFormField(
                        key: const ValueKey('plan-next-action'),
                        controller: _nextActionController,
                        focusNode: _nextActionFocusNode,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: '下一步行动'),
                        validator: _required('下一步行动'),
                      ),
                    ),
                    const SizedBox(height: AppTokens.s12),
                    KeyedSubtree(
                      key: _ownerTargetKey,
                      child: TextFormField(
                        key: const ValueKey('plan-owner'),
                        controller: _ownerController,
                        focusNode: _ownerFocusNode,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: '负责人'),
                        validator: _required('负责人'),
                      ),
                    ),
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
                          label: const Text('3 天后'),
                          onPressed: () => _setPlanOffset(3),
                        ),
                        ActionChip(
                          label: const Text('7 天后'),
                          onPressed: () => _setPlanOffset(7),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s12),
                    AppDateFormField(
                      fieldKey: const ValueKey('plan-at'),
                      label: '计划时间',
                      value: _planAt,
                      valueText: formatDateTime(_planAt),
                      prefixIcon: Icons.event_outlined,
                      onTap: _pickDateTime,
                    ),
                  ],
                ),
              ),
            ),
          ).protectUnsavedChanges(hasUnsavedChanges: _dirty && !_allowLeave);
        },
      ),
    );
  }
}

String? Function(String?) _required(String label) =>
    (value) => value == null || value.trim().isEmpty ? '$label不能为空' : null;
