import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_dropdown_form_field.dart';
import '../../widgets/app_form_fields.dart';
import '../../widgets/business_record_actions.dart';
import '../../widgets/form_section.dart';
import '../../widgets/sticky_form_scaffold.dart';
import '../attachments/attachment_providers.dart';
import '../customers/customer_providers.dart';
import 'business_providers.dart';

class TenderFormPage extends ConsumerStatefulWidget {
  const TenderFormPage({
    required this.customerId,
    required this.opportunityId,
    this.tenderId,
    super.key,
  });

  final int customerId;
  final int opportunityId;
  final int? tenderId;

  @override
  ConsumerState<TenderFormPage> createState() => _TenderFormPageState();
}

class _TenderFormPageState extends ConsumerState<TenderFormPage> {
  final _projectNo = TextEditingController();
  final _name = TextEditingController();
  final _bidder = TextEditingController();
  final _depositMinor = TextEditingController();
  final _customerExperience = TextEditingController();
  final _exclusiveQuoteScope = TextEditingController();
  final _floorPriceSupport = TextEditingController();
  final _nextAction = TextEditingController();

  DateTime? _deadlineAt;
  TenderDocumentStatus _documentStatus = TenderDocumentStatus.incomplete;
  TenderQualificationStatus _qualificationStatus =
      TenderQualificationStatus.pending;
  TenderVerificationStatus _localTeamStatus = TenderVerificationStatus.pending;
  TenderVerificationStatus _fundingStatus = TenderVerificationStatus.pending;
  TenderRiskLevel _riskLevel = TenderRiskLevel.mediumHigh;
  TenderAuthorizationType _authorizationType = TenderAuthorizationType.none;
  DateTime? _authorizationExpiresAt;
  TenderStatus _status = TenderStatus.preparing;
  bool _riskAcknowledged = false;
  bool _saving = false;
  bool _deleting = false;
  bool _riskExpanded = false;

  bool get _editing => widget.tenderId != null;

  @override
  void initState() {
    super.initState();
    _floorPriceSupport.addListener(_handleRiskInputChanged);
    if (widget.tenderId != null) _load(widget.tenderId!);
  }

  Future<void> _load(int id) async {
    final row = await ref.read(databaseProvider).tenderDao.findById(id);
    if (!mounted || row == null || row.opportunityId != widget.opportunityId) {
      return;
    }
    DateTime? date(int? value) => value == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    _projectNo.text = row.projectNo ?? '';
    _name.text = row.name ?? '';
    _bidder.text = row.bidder ?? '';
    _depositMinor.text = row.depositMinor?.toString() ?? '';
    _customerExperience.text = row.customerExperience ?? '';
    _exclusiveQuoteScope.text = row.exclusiveQuoteScope ?? '';
    _floorPriceSupport.text = row.floorPriceSupport ?? '';
    _nextAction.text = row.nextAction ?? '';
    setState(() {
      _deadlineAt = date(row.deadlineAt);
      _documentStatus = TenderDocumentStatus.fromDb(row.documentStatus);
      _qualificationStatus = TenderQualificationStatus.fromDb(
        row.qualificationStatus,
      );
      _localTeamStatus = TenderVerificationStatus.fromDb(row.localTeamStatus);
      _fundingStatus = TenderVerificationStatus.fromDb(row.fundingStatus);
      _riskLevel = TenderRiskLevel.fromDb(row.riskLevel);
      _authorizationType = TenderAuthorizationType.fromDb(
        row.authorizationType,
      );
      _authorizationExpiresAt = date(row.authorizationExpiresAt);
      _status = TenderStatus.fromDb(row.status);
      _riskExpanded =
          row.riskLevel == TenderRiskLevel.high.dbValue ||
          (row.floorPriceSupport?.trim().isNotEmpty ?? false) ||
          row.authorizationType != TenderAuthorizationType.none.dbValue;
    });
  }

  bool get _requiresRiskAcknowledgement =>
      _riskLevel == TenderRiskLevel.high &&
      (_authorizationType != TenderAuthorizationType.none ||
          _floorPriceSupport.text.trim().isNotEmpty);

  void _handleRiskInputChanged() {
    final required = _requiresRiskAcknowledgement;
    if (!required && _riskAcknowledged) _riskAcknowledged = false;
    if (required && !_riskExpanded) _riskExpanded = true;
    setState(() {});
  }

  void _setRiskLevel(TenderRiskLevel value) {
    setState(() {
      _riskLevel = value;
      _riskExpanded = true;
      if (!_requiresRiskAcknowledgement) _riskAcknowledged = false;
    });
  }

  void _setAuthorizationType(TenderAuthorizationType value) {
    setState(() {
      _authorizationType = value;
      _riskExpanded = true;
      if (!_requiresRiskAcknowledgement) _riskAcknowledged = false;
    });
  }

  @override
  void dispose() {
    _floorPriceSupport.removeListener(_handleRiskInputChanged);
    _projectNo.dispose();
    _name.dispose();
    _bidder.dispose();
    _depositMinor.dispose();
    _customerExperience.dispose();
    _exclusiveQuoteScope.dispose();
    _floorPriceSupport.dispose();
    _nextAction.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final depositText = _depositMinor.text.trim();
    final deposit = depositText.isEmpty ? null : int.tryParse(depositText);
    if (depositText.isNotEmpty && (deposit == null || deposit < 0)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写有效的保证金')));
      return;
    }

    setState(() => _saving = true);
    try {
      final service = ref.read(businessServiceProvider);
      if (_editing) {
        await service.updateTender(
          widget.customerId,
          widget.tenderId!,
          projectNo: Value(_projectNo.text),
          name: Value(_name.text),
          deadlineAt: Value(_deadlineAt),
          documentStatus: _documentStatus,
          qualificationStatus: _qualificationStatus,
          bidder: Value(_bidder.text),
          depositMinor: Value(deposit),
          customerExperience: Value(_customerExperience.text),
          localTeamStatus: _localTeamStatus,
          fundingStatus: _fundingStatus,
          riskLevel: _riskLevel,
          authorizationType: _authorizationType,
          authorizationExpiresAt: Value(_authorizationExpiresAt),
          exclusiveQuoteScope: Value(_exclusiveQuoteScope.text),
          floorPriceSupport: Value(_floorPriceSupport.text),
          status: _status,
          nextAction: Value(_nextAction.text),
          riskAcknowledged: _riskAcknowledged,
        );
      } else {
        await service.createTender(
          customerId: widget.customerId,
          opportunityId: widget.opportunityId,
          projectNo: _projectNo.text,
          name: _name.text,
          deadlineAt: _deadlineAt,
          documentStatus: _documentStatus,
          qualificationStatus: _qualificationStatus,
          bidder: _bidder.text,
          depositMinor: deposit,
          customerExperience: _customerExperience.text,
          localTeamStatus: _localTeamStatus,
          fundingStatus: _fundingStatus,
          riskLevel: _riskLevel,
          authorizationType: _authorizationType,
          authorizationExpiresAt: _authorizationExpiresAt,
          exclusiveQuoteScope: _exclusiveQuoteScope.text,
          floorPriceSupport: _floorPriceSupport.text,
          status: _status,
          nextAction: _nextAction.text,
          riskAcknowledged: _riskAcknowledged,
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
    appBar: AppBar(title: Text(_editing ? '编辑招标' : '新增招标')),
    body: StickyFormScaffold(
      submitting: _saving,
      enabled: !_deleting,
      submitKey: const ValueKey('tender-save'),
      submitLabel: '保存招标',
      onSubmit: _save,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_editing)
              BusinessRecordActions(
                title: _name.text.trim().isNotEmpty
                    ? _name.text
                    : _projectNo.text.trim().isNotEmpty
                    ? _projectNo.text
                    : '未命名招标',
                statusLabel: _status.label,
                contextLabel: '招标记录',
                attachmentOwner: AttachmentOwnerRoute(
                  type: AttachmentOwnerType.tender,
                  id: widget.tenderId!,
                ),
                enabled: !_saving,
                onDeletingChanged: (value) => setState(() => _deleting = value),
                onDelete: () => ref
                    .read(businessServiceProvider)
                    .deleteTender(widget.customerId, widget.tenderId!),
                onDeleted: (report) {
                  ref.read(customerRevisionProvider.notifier).refresh();
                  final messenger = ScaffoldMessenger.of(context);
                  context.go('/customers/${widget.customerId}');
                  if (report.hasFailures) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('招标已删除，但附件清理失败，下次启动会自动重试')),
                    );
                  }
                },
              ),
            FormSection(
              sectionKey: 'tender-basic',
              title: '基本信息',
              initiallyExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _textField(
                    key: 'tender-project-no',
                    controller: _projectNo,
                    label: '招标项目编号',
                  ),
                  _textField(
                    key: 'tender-name',
                    controller: _name,
                    label: '招标名称',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s12),
                    child: AppDateFormField(
                      fieldKey: const ValueKey('tender-deadline-at'),
                      label: '投标截止日期',
                      value: _deadlineAt,
                      onTap: () => _pickDate(
                        initialValue: _deadlineAt,
                        onChanged: (value) =>
                            setState(() => _deadlineAt = value),
                      ),
                      clearKey: const ValueKey('tender-deadline-at-clear'),
                      onClear: _deadlineAt == null
                          ? null
                          : () => setState(() => _deadlineAt = null),
                    ),
                  ),
                  _dropdown<TenderStatus>(
                    key: 'tender-status',
                    label: '招标状态',
                    value: _status,
                    values: TenderStatus.values,
                    text: (value) => value.label,
                    onChanged: (value) => setState(() => _status = value),
                  ),
                ],
              ),
            ),
            FormSection(
              sectionKey: 'tender-qualification',
              title: '资格核验',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dropdown<TenderDocumentStatus>(
                    key: 'tender-document-status',
                    label: '资料状态',
                    value: _documentStatus,
                    values: TenderDocumentStatus.values,
                    text: (value) => value.label,
                    onChanged: (value) =>
                        setState(() => _documentStatus = value),
                  ),
                  _dropdown<TenderQualificationStatus>(
                    key: 'tender-qualification-status',
                    label: '投标资格',
                    value: _qualificationStatus,
                    values: TenderQualificationStatus.values,
                    text: (value) => value.label,
                    onChanged: (value) =>
                        setState(() => _qualificationStatus = value),
                  ),
                  _textField(
                    key: 'tender-bidder',
                    controller: _bidder,
                    label: '投标主体',
                  ),
                  _textField(
                    key: 'tender-deposit-minor',
                    controller: _depositMinor,
                    label: '保证金（最小货币单位）',
                    keyboardType: TextInputType.number,
                  ),
                  _textField(
                    key: 'tender-customer-experience',
                    controller: _customerExperience,
                    label: '客户经验',
                    maxLines: 2,
                  ),
                  _dropdown<TenderVerificationStatus>(
                    key: 'tender-local-team-status',
                    label: '当地团队确认',
                    value: _localTeamStatus,
                    values: TenderVerificationStatus.values,
                    text: (value) => value.label,
                    onChanged: (value) =>
                        setState(() => _localTeamStatus = value),
                  ),
                  _dropdown<TenderVerificationStatus>(
                    key: 'tender-funding-status',
                    label: '资金确认',
                    value: _fundingStatus,
                    values: TenderVerificationStatus.values,
                    text: (value) => value.label,
                    onChanged: (value) =>
                        setState(() => _fundingStatus = value),
                  ),
                ],
              ),
            ),
            FormSection(
              sectionKey: 'tender-risk',
              title: '授权与风险',
              expanded: _riskExpanded,
              onExpansionChanged: (value) =>
                  setState(() => _riskExpanded = value),
              hasError: _requiresRiskAcknowledgement && !_riskAcknowledged,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dropdown<TenderRiskLevel>(
                    key: 'tender-risk-level',
                    label: '风险级别',
                    value: _riskLevel,
                    values: TenderRiskLevel.values,
                    text: (value) => value.label,
                    onChanged: _setRiskLevel,
                  ),
                  _dropdown<TenderAuthorizationType>(
                    key: 'tender-authorization-type',
                    label: '授权类型',
                    value: _authorizationType,
                    values: TenderAuthorizationType.values,
                    text: (value) => value.label,
                    onChanged: _setAuthorizationType,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s12),
                    child: AppDateFormField(
                      fieldKey: const ValueKey(
                        'tender-authorization-expires-at',
                      ),
                      label: '授权有效期',
                      value: _authorizationExpiresAt,
                      onTap: () => _pickDate(
                        initialValue: _authorizationExpiresAt,
                        onChanged: (value) =>
                            setState(() => _authorizationExpiresAt = value),
                      ),
                      clearKey: const ValueKey(
                        'tender-authorization-expires-at-clear',
                      ),
                      onClear: _authorizationExpiresAt == null
                          ? null
                          : () =>
                                setState(() => _authorizationExpiresAt = null),
                    ),
                  ),
                  _textField(
                    key: 'tender-exclusive-quote-scope',
                    controller: _exclusiveQuoteScope,
                    label: '独家报价范围',
                    maxLines: 2,
                  ),
                  _textField(
                    key: 'tender-floor-price-support',
                    controller: _floorPriceSupport,
                    label: '底价支持',
                    maxLines: 2,
                  ),
                  _textField(
                    key: 'tender-next-action',
                    controller: _nextAction,
                    label: '下一步行动',
                    maxLines: 2,
                  ),
                  if (_requiresRiskAcknowledgement) ...[
                    Container(
                      key: const ValueKey('tender-risk-warning'),
                      margin: const EdgeInsets.only(bottom: AppTokens.s12),
                      padding: const EdgeInsets.all(AppTokens.s12),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: const Text('当前为高风险授权或底价支持，请确认已充分了解风险。'),
                    ),
                    CheckboxListTile(
                      key: const ValueKey('tender-risk-acknowledged'),
                      value: _riskAcknowledged,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('我已确认风险'),
                      onChanged: (value) =>
                          setState(() => _riskAcknowledged = value ?? false),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _textField({
    required String key,
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: TextField(
      key: ValueKey(key),
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Future<void> _pickDate({
    required DateTime? initialValue,
    required ValueChanged<DateTime?> onChanged,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initialValue ?? DateUtils.dateOnly(DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) onChanged(selected);
  }

  Widget _dropdown<T>({
    required String key,
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) text,
    required ValueChanged<T> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: AppDropdownFormField<T>(
      fieldKey: ValueKey(key),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                text(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );
}
