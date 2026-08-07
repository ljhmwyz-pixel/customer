import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_dropdown_form_field.dart';
import '../../widgets/app_form_fields.dart';
import '../customers/customer_providers.dart';
import 'business_providers.dart';

class RegistrationFormPage extends ConsumerStatefulWidget {
  const RegistrationFormPage({
    required this.customerId,
    required this.opportunityId,
    this.registrationId,
    super.key,
  });

  final int customerId;
  final int opportunityId;
  final int? registrationId;

  @override
  ConsumerState<RegistrationFormPage> createState() =>
      _RegistrationFormPageState();
}

class _RegistrationFormPageState extends ConsumerState<RegistrationFormPage> {
  final _country = TextEditingController();
  final _requirements = TextEditingController();
  final _documentChecklist = TextEditingController();
  final _costBearer = TextEditingController();
  final _currentObstacle = TextEditingController();
  final _nextAction = TextEditingController();
  final _milestoneTitle = TextEditingController();

  RegistrationDocumentStatus _documentStatus =
      RegistrationDocumentStatus.pending;
  RegistrationStatus _status = RegistrationStatus.preparing;
  DateTime? _submittedAt;
  DateTime? _expectedCompletedAt;
  DateTime? _actualCompletedAt;
  DateTime? _documentDueAt;
  DateTime? _milestoneAt;
  bool _saving = false;

  bool get _editing => widget.registrationId != null;

  @override
  void initState() {
    super.initState();
    if (widget.registrationId != null) _load(widget.registrationId!);
  }

  Future<void> _load(int id) async {
    final row = await ref.read(databaseProvider).registrationDao.findById(id);
    if (!mounted || row == null || row.opportunityId != widget.opportunityId) {
      return;
    }
    _country.text = row.country ?? '';
    _requirements.text = row.requirements ?? '';
    _documentChecklist.text = row.documentChecklist ?? '';
    _costBearer.text = row.costBearer ?? '';
    _currentObstacle.text = row.currentObstacle ?? '';
    _nextAction.text = row.nextAction ?? '';
    _milestoneTitle.text = row.milestoneTitle ?? '';
    DateTime? date(int? value) => value == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    setState(() {
      _documentStatus = RegistrationDocumentStatus.fromDb(row.documentStatus);
      _status = RegistrationStatus.fromDb(row.status);
      _submittedAt = date(row.submittedAt);
      _expectedCompletedAt = date(row.expectedCompletedAt);
      _actualCompletedAt = date(row.actualCompletedAt);
      _documentDueAt = date(row.documentDueAt);
      _milestoneAt = date(row.milestoneAt);
    });
  }

  @override
  void dispose() {
    _country.dispose();
    _requirements.dispose();
    _documentChecklist.dispose();
    _costBearer.dispose();
    _currentObstacle.dispose();
    _nextAction.dispose();
    _milestoneTitle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final service = ref.read(businessServiceProvider);
      if (_editing) {
        await service.updateRegistration(
          widget.customerId,
          widget.registrationId!,
          country: Value(_country.text),
          requirements: Value(_requirements.text),
          documentChecklist: Value(_documentChecklist.text),
          documentStatus: _documentStatus,
          submittedAt: Value(_submittedAt),
          expectedCompletedAt: Value(_expectedCompletedAt),
          actualCompletedAt: Value(_actualCompletedAt),
          costBearer: Value(_costBearer.text),
          status: _status,
          currentObstacle: Value(_currentObstacle.text),
          nextAction: Value(_nextAction.text),
          documentDueAt: Value(_documentDueAt),
          milestoneAt: Value(_milestoneAt),
          milestoneTitle: Value(_milestoneTitle.text),
        );
      } else {
        await service.createRegistration(
          customerId: widget.customerId,
          opportunityId: widget.opportunityId,
          country: _country.text,
          requirements: _requirements.text,
          documentChecklist: _documentChecklist.text,
          documentStatus: _documentStatus,
          submittedAt: _submittedAt,
          expectedCompletedAt: _expectedCompletedAt,
          actualCompletedAt: _actualCompletedAt,
          costBearer: _costBearer.text,
          status: _status,
          currentObstacle: _currentObstacle.text,
          nextAction: _nextAction.text,
          documentDueAt: _documentDueAt,
          milestoneAt: _milestoneAt,
          milestoneTitle: _milestoneTitle.text,
        );
      }
      ref.read(customerRevisionProvider.notifier).refresh();
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_editing ? '编辑注册' : '新增注册')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textField(
            key: 'registration-country',
            controller: _country,
            label: '注册国家/地区',
          ),
          _textField(
            key: 'registration-requirements',
            controller: _requirements,
            label: '注册要求',
            maxLines: 3,
          ),
          _textField(
            key: 'registration-document-checklist',
            controller: _documentChecklist,
            label: '资料清单',
            maxLines: 3,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s12),
            child: AppDropdownFormField<RegistrationDocumentStatus>(
              fieldKey: const ValueKey('registration-document-status'),
              initialValue: _documentStatus,
              decoration: const InputDecoration(labelText: '资料状态'),
              items: RegistrationDocumentStatus.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _documentStatus = value);
              },
            ),
          ),
          _dateField(
            fieldKey: const ValueKey('registration-submitted-at'),
            label: '提交日期',
            value: _submittedAt,
            onChanged: (value) => setState(() => _submittedAt = value),
          ),
          _dateField(
            fieldKey: const ValueKey('registration-expected-completed-at'),
            label: '预计完成日期',
            value: _expectedCompletedAt,
            onChanged: (value) => setState(() => _expectedCompletedAt = value),
          ),
          _dateField(
            fieldKey: const ValueKey('registration-actual-completed-at'),
            label: '实际完成日期',
            value: _actualCompletedAt,
            onChanged: (value) => setState(() => _actualCompletedAt = value),
          ),
          _textField(
            key: 'registration-cost-bearer',
            controller: _costBearer,
            label: '费用承担方',
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s12),
            child: AppDropdownFormField<RegistrationStatus>(
              fieldKey: const ValueKey('registration-status'),
              initialValue: _status,
              decoration: const InputDecoration(labelText: '注册状态'),
              items: RegistrationStatus.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
          ),
          _textField(
            key: 'registration-current-obstacle',
            controller: _currentObstacle,
            label: '当前障碍',
            maxLines: 2,
          ),
          _textField(
            key: 'registration-next-action',
            controller: _nextAction,
            label: '下一步行动',
            maxLines: 2,
          ),
          _dateField(
            fieldKey: const ValueKey('registration-document-due-at'),
            label: '资料截止日期',
            value: _documentDueAt,
            onChanged: (value) => setState(() => _documentDueAt = value),
          ),
          _dateField(
            fieldKey: const ValueKey('registration-milestone-at'),
            label: '里程碑日期',
            value: _milestoneAt,
            onChanged: (value) => setState(() => _milestoneAt = value),
          ),
          _textField(
            key: 'registration-milestone-title',
            controller: _milestoneTitle,
            label: '里程碑标题',
          ),
          const SizedBox(height: AppTokens.s24),
          FilledButton(
            key: const ValueKey('registration-save'),
            onPressed: _saving ? null : _save,
            child: const Text('保存注册'),
          ),
        ],
      ),
    ),
  );

  Widget _textField({
    required String key,
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: TextField(
      key: ValueKey(key),
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget _dateField({
    required Key fieldKey,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: AppDateFormField(
      fieldKey: fieldKey,
      label: label,
      value: value,
      onTap: () => _pickDate(value, onChanged),
      onClear: value == null ? null : () => onChanged(null),
    ),
  );

  Future<void> _pickDate(
    DateTime? value,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) onChanged(selected);
  }
}
