import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_dropdown_form_field.dart';
import '../../widgets/app_form_fields.dart';
import '../../widgets/unsaved_changes_guard.dart';
import '../customers/customer_providers.dart';
import '../customers/customer_widgets.dart';
import 'opportunity_providers.dart';
import 'supplier_substitution.dart';

class OpportunityFormPage extends ConsumerStatefulWidget {
  const OpportunityFormPage({
    required this.customerId,
    this.opportunityId,
    super.key,
  });

  final int customerId;
  final int? opportunityId;

  @override
  ConsumerState<OpportunityFormPage> createState() =>
      _OpportunityFormPageState();
}

class _OpportunityFormPageState extends ConsumerState<OpportunityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  OpportunityStage _stage = OpportunityStage.newLead;
  OpportunityStatus _status = OpportunityStatus.active;
  DateTime? _expectedCloseAt;
  DateTime? _nextFollowAt;
  bool _needsSample = false;
  bool _needsRegistration = false;
  bool _needsAuthorization = false;
  String? _supplierProblem;
  String? _changeWillingness;
  String? _substitutionDifficulty;
  String? _entryPoint;
  String? _investmentAdvice;
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  bool _trackingChanges = false;
  bool _allowLeave = false;
  String? _loadError;

  TextEditingController _controller(String key) => _controllers.putIfAbsent(
    key,
    () => TextEditingController()..addListener(_markDirty),
  );

  void _markDirty() {
    if (_trackingChanges && !_dirty && mounted) setState(() => _dirty = true);
  }

  void _change(VoidCallback update) {
    _markDirty();
    setState(update);
  }

  @override
  void initState() {
    super.initState();
    _controller('currency').text = 'USD';
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await ref.read(
        customerDetailProvider(widget.customerId).future,
      );
      if (detail == null) return _finishLoading('客户不存在');
      final id = widget.opportunityId;
      if (id != null) {
        final value = await ref
            .read(opportunityServiceProvider)
            .findForCustomer(widget.customerId, id);
        if (value == null) return _finishLoading('项目不存在或不属于当前客户');
        _fill(value);
      }
      _finishLoading(null);
    } catch (_) {
      _finishLoading('加载失败，请重试');
    }
  }

  void _fill(OpportunityRow value) {
    void set(String key, Object? value) {
      _controller(key).text = value?.toString() ?? '';
    }

    set('name', value.name);
    set('productCategory', value.productCategory);
    set('productModel', value.productModel);
    set('equipmentBrand', value.equipmentBrand);
    set('equipmentModel', value.equipmentModel);
    set('estimatedAnnualVolume', value.estimatedAnnualVolume);
    set('forecastAmount', _minorText(value.forecastAmountMinor));
    set('currency', value.currency);
    set('probabilityPercent', value.probabilityPercent);
    set('currentSupplier', value.currentSupplier);
    set('currentPurchaseBrand', value.currentPurchaseBrand);
    set('currentPurchasePrice', _minorText(value.currentPurchasePriceMinor));
    set('supplierStability', value.supplierStability);
    _supplierProblem = value.supplierProblem;
    _changeWillingness = value.changeWillingness;
    _substitutionDifficulty = value.substitutionDifficulty;
    set('latestQuote', _minorText(value.latestQuoteMinor));
    set('targetPrice', _minorText(value.targetPriceMinor));
    _entryPoint = value.entryPoint;
    _investmentAdvice = value.investmentAdvice;
    set('latestFeedback', value.latestFeedback);
    set('currentObstacle', value.currentObstacle);
    set('nextAction', value.nextAction);
    _stage = OpportunityStage.fromDb(value.stage);
    _status = OpportunityStatus.fromDb(value.status);
    _expectedCloseAt = _date(value.expectedCloseAt);
    _nextFollowAt = _date(value.nextFollowAt);
    _needsSample = value.needsSample;
    _needsRegistration = value.needsRegistration;
    _needsAuthorization = value.needsAuthorization;
  }

  DateTime? _date(int? milliseconds) => milliseconds == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          milliseconds,
          isUtc: true,
        ).toLocal();

  String _minorText(int? value) {
    if (value == null) return '';
    final whole = value ~/ 100;
    final fraction = value.remainder(100).abs();
    return fraction == 0
        ? '$whole'
        : '$whole.${fraction.toString().padLeft(2, '0')}';
  }

  void _finishLoading(String? error) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadError = error;
      _trackingChanges = true;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _optionalInt(String key, String label) {
    final raw = _controller(key).text.trim();
    if (raw.isEmpty) return null;
    final value = int.tryParse(raw);
    if (value == null) throw OpportunityValidationException('$label需为整数');
    return value;
  }

  int? _optionalMinor(String key, String label) {
    final raw = _controller(key).text.trim();
    if (raw.isEmpty) return null;
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(raw);
    if (match == null) {
      throw OpportunityValidationException('$label格式不正确，最多两位小数');
    }
    final whole = BigInt.parse(match.group(1)!);
    final fraction = BigInt.parse((match.group(2) ?? '').padRight(2, '0'));
    final result = whole * BigInt.from(100) + fraction;
    if (result > BigInt.from(9223372036854775807)) {
      throw OpportunityValidationException('$label超出支持范围');
    }
    return result.toInt();
  }

  String? _text(String key) => _controller(key).text;

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final draft = OpportunityDraft(
        name: _controller('name').text,
        productCategory: _text('productCategory'),
        productModel: _text('productModel'),
        equipmentBrand: _text('equipmentBrand'),
        equipmentModel: _text('equipmentModel'),
        estimatedAnnualVolume: _optionalInt('estimatedAnnualVolume', '预计年用量'),
        forecastAmountMinor: _optionalMinor('forecastAmount', '预计项目金额'),
        currency: _controller('currency').text,
        probabilityPercent: _optionalInt('probabilityPercent', '成交概率'),
        expectedCloseAt: _expectedCloseAt,
        currentSupplier: _text('currentSupplier'),
        currentPurchaseBrand: _text('currentPurchaseBrand'),
        currentPurchasePriceMinor: _optionalMinor(
          'currentPurchasePrice',
          '当前采购价',
        ),
        supplierStability: _text('supplierStability'),
        supplierProblem: _supplierProblem,
        changeWillingness: _changeWillingness,
        substitutionDifficulty: _substitutionDifficulty,
        latestQuoteMinor: _optionalMinor('latestQuote', '最新报价'),
        targetPriceMinor: _optionalMinor('targetPrice', '目标价'),
        entryPoint: _entryPoint,
        investmentAdvice: _investmentAdvice,
        needsSample: _needsSample,
        needsRegistration: _needsRegistration,
        needsAuthorization: _needsAuthorization,
        stage: _stage,
        status: _status,
        latestFeedback: _text('latestFeedback'),
        currentObstacle: _text('currentObstacle'),
        nextAction: _text('nextAction'),
        nextFollowAt: _nextFollowAt,
      );
      final service = ref.read(opportunityServiceProvider);
      final id = widget.opportunityId;
      if (id == null) {
        await service.createOpportunity(widget.customerId, draft);
      } else {
        await service.updateOpportunity(widget.customerId, id, draft);
      }
      ref.read(customerRevisionProvider.notifier).refresh();
      if (mounted) {
        setState(() {
          _allowLeave = true;
          _dirty = false;
        });
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) context.go('/customers/${widget.customerId}');
      }
    } on OpportunityValidationException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _pickDate(bool closeDate) async {
    final current = closeDate ? _expectedCloseAt : _nextFollowAt;
    final value = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (value == null || !mounted) return;
    _change(() {
      if (closeDate) {
        _expectedCloseAt = value;
      } else {
        _nextFollowAt = value;
      }
    });
  }

  SupplierSubstitutionRecommendation get _supplierRecommendation =>
      recommendSupplierSubstitution(
        SupplierSubstitutionInput(
          equipmentBrand: _text('equipmentBrand'),
          equipmentModel: _text('equipmentModel'),
          currentSupplier: _text('currentSupplier'),
          currentPurchaseBrand: _text('currentPurchaseBrand'),
          supplierStability: _text('supplierStability'),
          supplierProblem: _supplierProblem,
          changeWillingness: _changeWillingness,
          substitutionDifficulty: _substitutionDifficulty,
          estimatedAnnualVolume: int.tryParse(
            _controller('estimatedAnnualVolume').text.trim(),
          ),
          expectedCloseAt: _expectedCloseAt,
          stage: _stage,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.opportunityId == null ? '新增项目' : '编辑项目')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _loadError == null
        ? _form()
        : Center(child: Text(_loadError!)),
  ).protectUnsavedChanges(hasUnsavedChanges: _dirty && !_allowLeave);

  Widget _form() => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        _field('name', '项目名称 *', required: true),
        _field('productCategory', '产品类别'),
        _field('productModel', '产品型号'),
        _field('equipmentBrand', '设备品牌', onChanged: (_) => setState(() {})),
        _field('equipmentModel', '设备型号', onChanged: (_) => setState(() {})),
        _field(
          'estimatedAnnualVolume',
          '预计年用量',
          number: true,
          onChanged: (_) => setState(() {}),
        ),
        _field('forecastAmount', '预计项目金额', decimal: true),
        _field('currency', '币种（如 USD）'),
        _field('probabilityPercent', '成交概率（0–100）', number: true),
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s12),
          child: AppDropdownFormField<OpportunityStage>(
            fieldKey: const ValueKey('opportunity-stage'),
            initialValue: _stage,
            decoration: const InputDecoration(labelText: '销售阶段'),
            items: OpportunityStage.values
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => _change(() => _stage = value ?? _stage),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s12),
          child: AppDropdownFormField<OpportunityStatus>(
            fieldKey: const ValueKey('opportunity-status'),
            initialValue: _status,
            decoration: const InputDecoration(labelText: '投入状态'),
            items: OpportunityStatus.values
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => _change(() => _status = value ?? _status),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s12),
          child: AppDateFormField(
            fieldKey: const ValueKey('opportunity-expected-close-at'),
            label: '预计成交日期',
            value: _expectedCloseAt,
            valueText: _expectedCloseAt == null
                ? null
                : formatDateTime(_expectedCloseAt!),
            onTap: () => _pickDate(true),
            clearKey: const ValueKey('opportunity-expected-close-at-clear'),
            onClear: _expectedCloseAt == null
                ? null
                : () => _change(() => _expectedCloseAt = null),
          ),
        ),
        _field('latestFeedback', '最新反馈', lines: 2),
        _field('currentObstacle', '当前障碍', lines: 2),
        _field('nextAction', '下一步动作', lines: 2),
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s12),
          child: AppDateFormField(
            fieldKey: const ValueKey('opportunity-next-follow-at'),
            label: '下次跟进日期',
            value: _nextFollowAt,
            valueText: _nextFollowAt == null
                ? null
                : formatDateTime(_nextFollowAt!),
            onTap: () => _pickDate(false),
            clearKey: const ValueKey('opportunity-next-follow-at-clear'),
            onClear: _nextFollowAt == null
                ? null
                : () => _change(() => _nextFollowAt = null),
          ),
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('供应商与价格信息'),
          children: [
            _field(
              'currentSupplier',
              '当前供应商',
              onChanged: (_) => setState(() {}),
            ),
            _field(
              'currentPurchaseBrand',
              '当前采购品牌',
              onChanged: (_) => setState(() {}),
            ),
            _field('currentPurchasePrice', '当前采购价', decimal: true),
            _field(
              'supplierStability',
              '供应稳定性',
              onChanged: (_) => setState(() {}),
            ),
            _optionField(
              key: 'supplierProblem',
              label: '现供应商问题',
              options: supplierProblemOptions,
              value: _supplierProblem,
              onChanged: (value) => _supplierProblem = value,
            ),
            _optionField(
              key: 'changeWillingness',
              label: '更换意愿',
              options: changeWillingnessOptions,
              value: _changeWillingness,
              onChanged: (value) => _changeWillingness = value,
            ),
            _optionField(
              key: 'substitutionDifficulty',
              label: '替代难度',
              options: substitutionDifficultyOptions,
              value: _substitutionDifficulty,
              onChanged: (value) => _substitutionDifficulty = value,
            ),
            _field('latestQuote', '最新报价', decimal: true),
            _field('targetPrice', '客户目标价', decimal: true),
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('投入建议与前置事项'),
          children: [
            _optionField(
              key: 'entryPoint',
              label: '切入点',
              options: entryPointOptions,
              value: _entryPoint,
              onChanged: (value) => _entryPoint = value,
            ),
            _optionField(
              key: 'investmentAdvice',
              label: '投入建议',
              options: investmentAdviceOptions,
              value: _investmentAdvice,
              onChanged: (value) => _investmentAdvice = value,
            ),
            _recommendationCard(_supplierRecommendation),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('需要样品'),
              value: _needsSample,
              onChanged: (v) => _change(() => _needsSample = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('需要注册'),
              value: _needsRegistration,
              onChanged: (v) => _change(() => _needsRegistration = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('需要授权'),
              value: _needsAuthorization,
              onChanged: (v) => _change(() => _needsAuthorization = v),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s24),
        FilledButton.icon(
          key: const ValueKey('save-opportunity'),
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? '保存中…' : '保存项目'),
        ),
      ],
    ),
  );

  Widget _field(
    String key,
    String label, {
    bool required = false,
    bool number = false,
    bool decimal = false,
    int lines = 1,
    ValueChanged<String>? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: TextFormField(
      key: ValueKey('opportunity-$key'),
      controller: _controller(key),
      decoration: InputDecoration(labelText: label),
      keyboardType: number
          ? TextInputType.number
          : decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : lines > 1
          ? TextInputType.multiline
          : TextInputType.text,
      maxLines: lines,
      onChanged: onChanged,
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? '请输入项目名称' : null
          : null,
    ),
  );

  Widget _optionField({
    required String key,
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final items = optionsWithLegacyValue(options, value);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s12),
      child: KeyedSubtree(
        key: ValueKey('$key-$value'),
        child: AppDropdownFormField<String>(
          fieldKey: ValueKey('opportunity-$key'),
          initialValue: value?.trim().isEmpty ?? true ? null : value,
          decoration: InputDecoration(labelText: label),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('未设置', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            ...items.map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  options.contains(item) ? item : '历史值：$item',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (next) => _change(() => onChanged(next)),
        ),
      ),
    );
  }

  Widget _recommendationCard(
    SupplierSubstitutionRecommendation recommendation,
  ) => Card(
    key: const ValueKey('supplier-recommendation-card'),
    margin: const EdgeInsets.only(bottom: AppTokens.s12),
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('建议切入点：${recommendation.entryPoint}'),
          const SizedBox(height: AppTokens.s4),
          Text('建议投入：${recommendation.investmentAdvice}'),
          const SizedBox(height: AppTokens.s8),
          Text(recommendation.summary),
          ...recommendation.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(top: AppTokens.s4),
              child: Text('• $reason'),
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          FilledButton.tonalIcon(
            key: const ValueKey('apply-supplier-recommendation'),
            onPressed: () => _change(() {
              _entryPoint = recommendation.entryPoint;
              _investmentAdvice = recommendation.investmentAdvice;
            }),
            icon: const Icon(Icons.check_outlined),
            label: const Text('采用建议'),
          ),
        ],
      ),
    ),
  );
}
