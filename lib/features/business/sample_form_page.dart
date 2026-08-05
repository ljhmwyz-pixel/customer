import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../customers/customer_providers.dart';
import 'business_providers.dart';

class SampleFormPage extends ConsumerStatefulWidget {
  const SampleFormPage({
    required this.customerId,
    required this.opportunityId,
    super.key,
  });
  final int customerId;
  final int opportunityId;

  @override
  ConsumerState<SampleFormPage> createState() => _SampleFormPageState();
}

class _SampleFormPageState extends ConsumerState<SampleFormPage> {
  final model = TextEditingController();
  final quantity = TextEditingController(text: '1');
  bool saving = false;

  @override
  void dispose() {
    model.dispose();
    quantity.dispose();
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
      await ref
          .read(businessServiceProvider)
          .createSample(
            customerId: widget.customerId,
            opportunityId: widget.opportunityId,
            sampleModel: model.text,
            quantity: parsed,
            status: SampleStatus.preparing,
          );
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
    appBar: AppBar(title: const Text('新增样品')),
    body: ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        TextField(
          key: const ValueKey('sample-milestone-model'),
          controller: model,
          decoration: const InputDecoration(labelText: '样品型号'),
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
          child: const Text('保存样品'),
        ),
      ],
    ),
  );
}
