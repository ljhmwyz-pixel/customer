import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_dropdown_form_field.dart';
import 'customer_providers.dart';

class CustomerFormPage extends ConsumerStatefulWidget {
  const CustomerFormPage({this.customerId, super.key});

  final int? customerId;

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _customerNoController = TextEditingController();
  final _customerTypeController = TextEditingController();
  final _ownerController = TextEditingController(text: '本人');
  final _phoneController = TextEditingController();
  final _wechatController = TextEditingController();
  final _addressController = TextEditingController();
  final _sourceController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _tenderExperienceController = TextEditingController();
  final _tenderQualificationController = TextEditingController();
  final _tenderBidderController = TextEditingController();
  final _localTeamStatusController = TextEditingController();
  final _fundingStatusController = TextEditingController();

  CustomerStage _stage = CustomerStage.potential;
  CustomerGrade _grade = CustomerGrade.c;
  bool _showMore = false;
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  bool get _isEditing => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() => _loading = true);
    try {
      final detail = await ref.read(
        customerDetailProvider(widget.customerId!).future,
      );
      if (!mounted) return;
      if (detail == null) {
        setState(() {
          _loading = false;
          _loadError = '客户不存在';
        });
        return;
      }
      final customer = detail.customer;
      _nameController.text = customer.name;
      _companyController.text = customer.company ?? '';
      _customerNoController.text = customer.customerNo ?? '';
      _customerTypeController.text = customer.customerType ?? '';
      _ownerController.text = customer.owner;
      _phoneController.text = customer.phone ?? '';
      _wechatController.text = customer.wechat ?? '';
      _addressController.text = customer.address ?? '';
      _sourceController.text = customer.source ?? '';
      _noteController.text = customer.note ?? '';
      _tenderExperienceController.text = customer.tenderExperience ?? '';
      _tenderQualificationController.text = customer.tenderQualification ?? '';
      _tenderBidderController.text = customer.tenderBidder ?? '';
      _localTeamStatusController.text = customer.localTeamStatus ?? '';
      _fundingStatusController.text = customer.fundingStatus ?? '';
      _tagsController.text = detail.tags.map((tag) => tag.name).join('，');
      setState(() {
        _stage = CustomerStage.fromDb(customer.stage);
        _grade = CustomerGrade.fromDb(customer.grade);
        _showMore = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '加载失败，请重试';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _customerNoController.dispose();
    _customerTypeController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _wechatController.dispose();
    _addressController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    _tenderExperienceController.dispose();
    _tenderQualificationController.dispose();
    _tenderBidderController.dispose();
    _localTeamStatusController.dispose();
    _fundingStatusController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String value) => value
      .split(RegExp(r'[,，\n]'))
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final draft = CustomerDraft(
      name: _nameController.text,
      customerNo: _customerNoController.text,
      customerType: _customerTypeController.text,
      owner: _ownerController.text,
      company: _companyController.text,
      phone: _phoneController.text,
      wechat: _wechatController.text,
      address: _addressController.text,
      source: _sourceController.text,
      note: _noteController.text,
      tenderExperience: _tenderExperienceController.text,
      tenderQualification: _tenderQualificationController.text,
      tenderBidder: _tenderBidderController.text,
      localTeamStatus: _localTeamStatusController.text,
      fundingStatus: _fundingStatusController.text,
      stage: _stage,
      grade: _grade,
      tagNames: _parseTags(_tagsController.text),
    );
    try {
      final service = ref.read(customerServiceProvider);
      if (_isEditing) {
        await service.updateCustomer(widget.customerId!, draft);
        ref.read(customerRevisionProvider.notifier).refresh();
        if (mounted) context.pop();
      } else {
        final customerId = await service.createCustomer(draft);
        ref.read(customerRevisionProvider.notifier).refresh();
        if (mounted) await _showCreatedActions(customerId);
      }
    } on CustomerValidationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showCreatedActions(int customerId) async {
    final action = await showDialog<_CreatedAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('客户已创建'),
        content: const Text('接下来可以查看客户资料，或立即记录首条跟进。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _CreatedAction.view),
            child: const Text('查看客户'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _CreatedAction.followup),
            child: const Text('记录首条跟进'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _CreatedAction.followup:
        context.go('/customers/$customerId/followups/new');
      case _CreatedAction.view:
      case null:
        context.go('/customers/$customerId');
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑客户' : '新建客户')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _LoadFailure(message: _loadError!, onRetry: _loadCustomer)
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s16,
                  AppTokens.s8,
                  AppTokens.s16,
                  AppTokens.s32,
                ),
                children: [
                  TextFormField(
                    key: const ValueKey('customer-name'),
                    controller: _nameController,
                    autofocus: !_isEditing,
                    maxLength: 50,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: '客户名称',
                      hintText: '请输入客户名称',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? '客户名称不能为空'
                        : null,
                    onFieldSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: AppTokens.s8),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppTokens.r8),
                    onTap: () => setState(() => _showMore = !_showMore),
                    child: SizedBox(
                      height: AppTokens.minTouchTarget,
                      child: Row(
                        children: [
                          const Icon(Icons.tune),
                          const SizedBox(width: AppTokens.s8),
                          const Expanded(child: Text('更多信息')),
                          Icon(
                            _showMore ? Icons.expand_less : Icons.expand_more,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showMore) ...[
                    const SizedBox(height: AppTokens.s8),
                    _TextField(controller: _companyController, label: '公司'),
                    ExpansionTile(
                      key: const ValueKey('customer-management-section'),
                      tilePadding: EdgeInsets.zero,
                      title: const Text('客户管理'),
                      children: [
                        _TextField(
                          controller: _customerNoController,
                          label: '客户编号',
                        ),
                        _TextField(
                          controller: _customerTypeController,
                          label: '客户类型',
                        ),
                        _TextField(controller: _ownerController, label: '负责人'),
                      ],
                    ),
                    _TextField(
                      controller: _phoneController,
                      label: '电话',
                      keyboardType: TextInputType.phone,
                    ),
                    _TextField(controller: _wechatController, label: '微信'),
                    _TextField(controller: _addressController, label: '地址'),
                    _TextField(controller: _sourceController, label: '来源'),
                    AppDropdownFormField<CustomerStage>(
                      initialValue: _stage,
                      decoration: const InputDecoration(labelText: '阶段'),
                      items: CustomerStage.values
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
                      onChanged: (value) {
                        if (value != null) setState(() => _stage = value);
                      },
                    ),
                    const SizedBox(height: AppTokens.s12),
                    SegmentedButton<CustomerGrade>(
                      segments: CustomerGrade.values
                          .map(
                            (grade) => ButtonSegment(
                              value: grade,
                              label: Text('${grade.label} 级'),
                            ),
                          )
                          .toList(),
                      selected: {_grade},
                      onSelectionChanged: (selection) {
                        setState(() => _grade = selection.first);
                      },
                    ),
                    const SizedBox(height: AppTokens.s12),
                    TextFormField(
                      controller: _tagsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '标签',
                        hintText: '多个标签用逗号或换行分隔',
                      ),
                    ),
                    ExpansionTile(
                      key: const ValueKey('customer-tender-section'),
                      tilePadding: EdgeInsets.zero,
                      title: const Text('招投标能力'),
                      children: [
                        _TextField(
                          controller: _tenderExperienceController,
                          label: '招标经验',
                        ),
                        _TextField(
                          controller: _tenderQualificationController,
                          label: '投标资格',
                        ),
                        _TextField(
                          controller: _tenderBidderController,
                          label: '投标主体',
                        ),
                        _TextField(
                          controller: _localTeamStatusController,
                          label: '当地团队状态',
                        ),
                        _TextField(
                          controller: _fundingStatusController,
                          label: '资金状态',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s12),
                    TextFormField(
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: '备注'),
                    ),
                  ],
                  const SizedBox(height: AppTokens.s24),
                  FilledButton.icon(
                    key: const ValueKey('save-customer'),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: AppTokens.s16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? '保存中' : '保存'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: AppTokens.s16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    ),
  );
}

enum _CreatedAction { view, followup }
