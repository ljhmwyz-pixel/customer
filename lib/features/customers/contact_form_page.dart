import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/sticky_form_scaffold.dart';
import '../../widgets/unsaved_changes_guard.dart';
import 'customer_providers.dart';

class ContactFormPage extends ConsumerStatefulWidget {
  const ContactFormPage({
    required this.customerId,
    this.contactId,
    this.initialName,
    this.initialPhone,
    super.key,
  });

  final int customerId;
  final int? contactId;
  final String? initialName;
  final String? initialPhone;

  @override
  ConsumerState<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends ConsumerState<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _position = TextEditingController();
  late final TextEditingController _phone;
  final _email = TextEditingController();
  final _whatsapp = TextEditingController();
  final _preference = TextEditingController();
  final _note = TextEditingController();
  bool _decisionMaker = false;
  bool _loading = false;
  bool _saving = false;
  bool _trackingChanges = false;
  bool _allowLeave = false;
  Object? _baseline;

  bool get _editing => widget.contactId != null;

  List<TextEditingController> get _controllers => [
    _name,
    _position,
    _phone,
    _email,
    _whatsapp,
    _preference,
    _note,
  ];

  Object get _currentValue => (
    name: _name.text,
    position: _position.text,
    phone: _phone.text,
    email: _email.text,
    whatsapp: _whatsapp.text,
    preference: _preference.text,
    note: _note.text,
    decisionMaker: _decisionMaker,
  );

  bool get _hasUnsavedChanges =>
      _trackingChanges && !_allowLeave && _baseline != _currentValue;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName ?? '');
    _phone = TextEditingController(text: widget.initialPhone ?? '');
    for (final controller in _controllers) {
      controller.addListener(_formValueChanged);
    }
    if (_editing) {
      _load();
    } else {
      _baseline = _currentValue;
      _trackingChanges = true;
    }
  }

  void _formValueChanged() {
    if (_trackingChanges && mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final row = await ref
        .read(databaseProvider)
        .contactDao
        .findById(widget.contactId!);
    if (!mounted) return;
    if (row == null || row.customerId != widget.customerId) {
      context.pop();
      return;
    }
    _name.text = row.name;
    _position.text = row.position ?? '';
    _phone.text = row.phone ?? '';
    _email.text = row.email ?? '';
    _whatsapp.text = row.whatsapp ?? '';
    _preference.text = row.communicationPreference ?? '';
    _note.text = row.note ?? '';
    setState(() {
      _decisionMaker = row.isDecisionMaker;
      _loading = false;
      _baseline = _currentValue;
      _trackingChanges = true;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_formValueChanged);
    }
    _name.dispose();
    _position.dispose();
    _phone.dispose();
    _email.dispose();
    _whatsapp.dispose();
    _preference.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final draft = ContactDraft(
      name: _name.text,
      position: _position.text,
      phone: _phone.text,
      email: _email.text,
      whatsapp: _whatsapp.text,
      communicationPreference: _preference.text,
      note: _note.text,
      isDecisionMaker: _decisionMaker,
    );
    try {
      final service = ref.read(customerServiceProvider);
      if (_editing) {
        await service.updateContact(
          widget.contactId!,
          draft,
          customerId: widget.customerId,
        );
      } else {
        await service.createContact(widget.customerId, draft);
      }
      ref.read(customerRevisionProvider.notifier).refresh();
      if (mounted) {
        setState(() => _allowLeave = true);
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) context.pop();
      }
    } on CustomerValidationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_editing ? '编辑联系人' : '新增联系人')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : StickyFormScaffold(
            onSubmit: _save,
            submitting: _saving,
            submitLabel: '保存联系人',
            submitKey: const ValueKey('contact-save'),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTokens.s16),
                children: [
                  _field(
                    key: 'contact-name',
                    controller: _name,
                    label: '姓名',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? '联系人名称不能为空'
                        : null,
                  ),
                  _field(controller: _position, label: '职位'),
                  _field(
                    controller: _phone,
                    label: '电话',
                    type: TextInputType.phone,
                  ),
                  _field(
                    key: 'contact-email',
                    controller: _email,
                    label: '邮箱',
                    type: TextInputType.emailAddress,
                  ),
                  _field(
                    key: 'contact-whatsapp',
                    controller: _whatsapp,
                    label: 'WhatsApp',
                    type: TextInputType.phone,
                  ),
                  _field(
                    controller: _preference,
                    label: '沟通偏好',
                    hint: '例如：邮件优先、工作日上午联系',
                  ),
                  SwitchListTile(
                    key: const ValueKey('contact-decision-maker'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('决策人'),
                    value: _decisionMaker,
                    onChanged: (value) =>
                        setState(() => _decisionMaker = value),
                  ),
                  _field(controller: _note, label: '备注', maxLines: 4),
                  const SizedBox(height: AppTokens.s24),
                ],
              ),
            ),
          ),
  ).protectUnsavedChanges(hasUnsavedChanges: _hasUnsavedChanges);

  Widget _field({
    String? key,
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? type,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.s12),
    child: TextFormField(
      key: key == null ? null : ValueKey(key),
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    ),
  );
}
