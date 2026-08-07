import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database_provider.dart';
import '../../theme/tokens.dart';
import '../customers/customer_providers.dart';
import 'business_providers.dart';

class QuoteFormPage extends ConsumerStatefulWidget {
  const QuoteFormPage({
    required this.customerId,
    required this.opportunityId,
    this.sourceQuoteId,
    super.key,
  });
  final int customerId;
  final int opportunityId;
  final int? sourceQuoteId;

  @override
  ConsumerState<QuoteFormPage> createState() => _QuoteFormPageState();
}

class _QuoteFormPageState extends ConsumerState<QuoteFormPage> {
  final no = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final amount = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.sourceQuoteId != null) _loadSource(widget.sourceQuoteId!);
  }

  Future<void> _loadSource(int sourceId) async {
    final quote = await ref.read(databaseProvider).quoteDao.findById(sourceId);
    if (!mounted ||
        quote == null ||
        quote.opportunityId != widget.opportunityId) {
      return;
    }
    no.text = quote.quoteNo;
    quantity.text = '${quote.quantity}';
    amount.text = quote.totalAmountMinor?.toString() ?? '';
  }

  @override
  void dispose() {
    no.dispose();
    quantity.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsedQuantity = int.tryParse(quantity.text.trim());
    final parsedAmount = amount.text.trim().isEmpty
        ? null
        : int.tryParse(amount.text.trim());
    if (no.text.trim().isEmpty ||
        parsedQuantity == null ||
        parsedAmount == null && amount.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写有效的报价编号、数量和金额')));
      return;
    }
    setState(() => saving = true);
    try {
      await ref
          .read(businessServiceProvider)
          .createQuoteVersion(
            customerId: widget.customerId,
            opportunityId: widget.opportunityId,
            quoteNo: no.text,
            quantity: parsedQuantity,
            totalAmountMinor: parsedAmount,
            quotedAt: DateTime.now(),
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
    appBar: AppBar(title: const Text('新增报价版本')),
    body: ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        TextField(
          key: const ValueKey('quote-version-no'),
          controller: no,
          decoration: const InputDecoration(labelText: '报价编号'),
        ),
        const SizedBox(height: AppTokens.s12),
        TextField(
          key: const ValueKey('quote-version-quantity'),
          controller: quantity,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '数量'),
        ),
        const SizedBox(height: AppTokens.s12),
        TextField(
          key: const ValueKey('quote-version-amount'),
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '总金额（最小货币单位）'),
        ),
        const SizedBox(height: AppTokens.s24),
        FilledButton(
          key: const ValueKey('business-save-quote'),
          onPressed: saving ? null : _save,
          child: const Text('保存报价'),
        ),
      ],
    ),
  );
}
