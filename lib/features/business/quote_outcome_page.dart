import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/database_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_form_fields.dart';
import '../customers/customer_providers.dart';
import 'business_providers.dart';

class QuoteOutcomePage extends ConsumerStatefulWidget {
  const QuoteOutcomePage({
    required this.customerId,
    required this.opportunityId,
    required this.quoteId,
    super.key,
  });

  final int customerId;
  final int opportunityId;
  final int quoteId;

  @override
  ConsumerState<QuoteOutcomePage> createState() => _QuoteOutcomePageState();
}

class _QuoteOutcomePageState extends ConsumerState<QuoteOutcomePage> {
  final _feedback = TextEditingController();
  final _result = TextEditingController();
  QuoteRow? _quote;
  DateTime? _nextFollowAt;
  bool _received = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quote = await ref
        .read(databaseProvider)
        .quoteDao
        .findById(widget.quoteId);
    if (!mounted) return;
    if (quote == null || quote.opportunityId != widget.opportunityId) {
      setState(() {
        _loading = false;
        _error = '报价记录不存在';
      });
      return;
    }
    _feedback.text = quote.customerFeedback ?? '';
    _result.text = quote.result ?? '';
    setState(() {
      _quote = quote;
      _received = quote.customerReceived;
      _nextFollowAt = quote.nextFollowAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              quote.nextFollowAt!,
              isUtc: true,
            );
      _loading = false;
    });
  }

  @override
  void dispose() {
    _feedback.dispose();
    _result.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(businessServiceProvider)
          .updateQuoteOutcome(
            widget.customerId,
            widget.quoteId,
            customerReceived: _received,
            customerFeedback: Value(_feedback.text),
            nextFollowAt: Value(_nextFollowAt),
            result: Value(_result.text),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickNextFollowAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextFollowAt?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => _nextFollowAt = date);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('更新报价结果')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!))
        : ListView(
            padding: const EdgeInsets.all(AppTokens.s16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: Text('${_quote!.quoteNo} · v${_quote!.version}'),
                subtitle: const Text('报价编号、版本和金额不可修改；价格变化请新增版本。'),
              ),
              SwitchListTile(
                key: const ValueKey('quote-customer-received'),
                contentPadding: EdgeInsets.zero,
                title: const Text('客户已收到报价'),
                value: _received,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _received = value),
              ),
              const SizedBox(height: AppTokens.s12),
              TextField(
                key: const ValueKey('quote-customer-feedback'),
                controller: _feedback,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '客户反馈'),
              ),
              const SizedBox(height: AppTokens.s12),
              AppDateFormField(
                fieldKey: const ValueKey('quote-next-follow-at'),
                label: '下次跟进日期',
                value: _nextFollowAt,
                onTap: _pickNextFollowAt,
                onClear: _nextFollowAt == null
                    ? null
                    : () => setState(() => _nextFollowAt = null),
              ),
              const SizedBox(height: AppTokens.s12),
              TextField(
                key: const ValueKey('quote-result'),
                controller: _result,
                maxLines: 2,
                decoration: const InputDecoration(labelText: '报价结果'),
              ),
              const SizedBox(height: AppTokens.s24),
              FilledButton.icon(
                key: const ValueKey('quote-outcome-save'),
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? '保存中' : '保存结果'),
              ),
              const SizedBox(height: AppTokens.s8),
              OutlinedButton.icon(
                key: const ValueKey('quote-new-version'),
                onPressed: _saving
                    ? null
                    : () => context.push(
                        '/customers/${widget.customerId}/opportunities/${widget.opportunityId}/quotes/new?from=${widget.quoteId}',
                      ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('基于此报价新增版本'),
              ),
            ],
          ),
  );
}
