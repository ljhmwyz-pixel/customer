import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../data/database_provider.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../customers/customer_providers.dart';
import 'business_providers.dart';

class SampleFormPage extends ConsumerStatefulWidget {
  const SampleFormPage({
    required this.customerId,
    required this.opportunityId,
    this.sampleId,
    super.key,
  });
  final int customerId;
  final int opportunityId;
  final int? sampleId;

  @override
  ConsumerState<SampleFormPage> createState() => _SampleFormPageState();
}

class _SampleFormPageState extends ConsumerState<SampleFormPage> {
  final model = TextEditingController();
  final quantity = TextEditingController(text: '1');
  bool saving = false;
  SampleStatus status = SampleStatus.preparing;
  final result = TextEditingController();
  final nextAction = TextEditingController();

  bool get editing => widget.sampleId != null;

  @override
  void initState() {
    super.initState();
    if (widget.sampleId != null) _load(widget.sampleId!);
  }

  Future<void> _load(int id) async {
    final row = await ref.read(databaseProvider).sampleDao.findById(id);
    if (!mounted || row == null || row.opportunityId != widget.opportunityId) {
      return;
    }
    model.text = row.sampleModel ?? '';
    quantity.text = '${row.quantity}';
    result.text = row.testResult ?? '';
    nextAction.text = row.nextAction ?? '';
    setState(() => status = SampleStatus.fromDb(row.status));
  }

  @override
  void dispose() {
    model.dispose();
    quantity.dispose();
    result.dispose();
    nextAction.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsed = int.tryParse(quantity.text.trim());
    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写有效的样品数量')));
      return;
    }
    setState(() => saving = true);
    try {
      final service = ref.read(businessServiceProvider);
      if (editing) {
        await service.updateSampleMilestone(
          widget.customerId,
          widget.sampleId!,
          status: status,
          testResult: Value(result.text),
          nextAction: Value(nextAction.text),
        );
      } else {
        await service.createSample(
          customerId: widget.customerId,
          opportunityId: widget.opportunityId,
          sampleModel: model.text,
          quantity: parsed,
          status: status,
          testResult: result.text,
          nextAction: nextAction.text,
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
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(editing ? '更新样品节点' : '新增样品')),
    body: ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        TextField(
          key: const ValueKey('sample-milestone-model'),
          controller: model,
          decoration: const InputDecoration(labelText: '样品型号'),
        ),
        const SizedBox(height: AppTokens.s12),
        DropdownButtonFormField<SampleStatus>(
          key: const ValueKey('sample-milestone-status'),
          initialValue: status,
          decoration: const InputDecoration(labelText: '样品节点'),
          items: SampleStatus.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              )
              .toList(growable: false),
          onChanged: saving ? null : (value) => setState(() => status = value!),
        ),
        const SizedBox(height: AppTokens.s12),
        TextField(
          key: const ValueKey('sample-milestone-result'),
          controller: result,
          maxLines: 2,
          decoration: const InputDecoration(labelText: '测试结果'),
        ),
        const SizedBox(height: AppTokens.s12),
        TextField(
          key: const ValueKey('sample-milestone-next-action'),
          controller: nextAction,
          maxLines: 2,
          decoration: const InputDecoration(labelText: '下一步行动'),
        ),
        const SizedBox(height: AppTokens.s12),
        TextField(
          key: const ValueKey('sample-milestone-quantity'),
          controller: quantity,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '数量'),
        ),
        const SizedBox(height: AppTokens.s24),
        FilledButton(
          key: const ValueKey('business-save-sample'),
          onPressed: saving ? null : _save,
          child: Text(editing ? '保存节点' : '保存样品'),
        ),
      ],
    ),
  );
}
