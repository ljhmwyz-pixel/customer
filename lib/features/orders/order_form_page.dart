import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../customers/customer_providers.dart';
import '../customers/customer_widgets.dart';
import 'order_providers.dart';

const _maxInt64 = 9223372036854775807;

int parseAmountCents(String input) {
  final value = input.trim();
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(value);
  if (match == null) {
    throw const FormatException('请输入有效金额，最多保留两位小数');
  }

  final whole = BigInt.parse(match.group(1)!);
  final fractionText = (match.group(2) ?? '').padRight(2, '0');
  final fraction = fractionText.isEmpty
      ? BigInt.zero
      : BigInt.parse(fractionText);
  final cents = whole * BigInt.from(100) + fraction;
  if (cents <= BigInt.zero) {
    throw const FormatException('订单金额必须大于 0');
  }
  if (cents > BigInt.from(_maxInt64)) {
    throw const FormatException('订单金额超出支持范围');
  }
  return cents.toInt();
}

String formatAmountCents(int cents) {
  final value = BigInt.from(cents);
  final sign = value.isNegative ? '-' : '';
  final absolute = value.abs();
  final yuan = absolute ~/ BigInt.from(100);
  final fraction = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
  return '$sign¥$yuan.$fraction';
}

class OrderFormPage extends ConsumerStatefulWidget {
  const OrderFormPage({required this.customerId, this.orderId, super.key});

  final int customerId;
  final int? orderId;

  @override
  ConsumerState<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends ConsumerState<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderNoController = TextEditingController();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _orderedAt = DateTime.now();
  String? _statusLabel;
  String? _loadError;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => widget.orderId != null;

  @override
  void initState() {
    super.initState();
    _dateController.text = formatDateTime(_orderedAt);
    _load();
  }

  Future<void> _load() async {
    try {
      final customer = await ref.read(
        customerDetailProvider(widget.customerId).future,
      );
      if (customer == null) {
        _finishLoading(error: '客户不存在');
        return;
      }

      final service = ref.read(orderServiceProvider);
      final orderId = widget.orderId;
      if (orderId == null) {
        _orderNoController.text = await service.nextOrderNo();
      } else {
        final order = await service.findOrderForCustomer(
          widget.customerId,
          orderId,
        );
        if (order == null) {
          _finishLoading(error: '订单不存在或不属于当前客户');
          return;
        }
        _orderNoController.text = order.orderNo;
        _amountController.text = _editableAmount(order.amountCents);
        _descriptionController.text = order.description ?? '';
        _orderedAt = localDateTime(order.orderedAt);
        _dateController.text = formatDateTime(_orderedAt);
        _statusLabel = OrderStatus.fromDb(order.status).label;
      }
      _finishLoading();
    } catch (_) {
      _finishLoading(error: '加载失败，请重试');
    }
  }

  void _finishLoading({String? error}) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadError = error;
    });
  }

  String _editableAmount(int cents) {
    final whole = cents ~/ 100;
    final fraction = (cents % 100).abs();
    return fraction == 0
        ? '$whole'
        : '$whole.${fraction.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _orderNoController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _orderedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _orderedAt = DateTime(
        date.year,
        date.month,
        date.day,
        _orderedAt.hour,
        _orderedAt.minute,
      );
      _dateController.text = formatDateTime(_orderedAt);
    });
  }

  String? _validateAmount(String? value) {
    try {
      parseAmountCents(value ?? '');
      return null;
    } on FormatException catch (error) {
      return error.message;
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final draft = OrderDraft(
        orderNo: _orderNoController.text,
        orderedAt: _orderedAt,
        amountCents: parseAmountCents(_amountController.text),
        description: _descriptionController.text,
      );
      final service = ref.read(orderServiceProvider);
      final orderId = widget.orderId;
      if (orderId == null) {
        await service.createOrder(widget.customerId, draft);
      } else {
        await service.updateOrder(widget.customerId, orderId, draft);
      }
      ref.read(customerRevisionProvider.notifier).refresh();
      if (mounted) context.go('/customers/${widget.customerId}');
    } on OrderValidationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEditing ? '编辑订单' : '新增订单')),
    body: _buildBody(),
  );

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _loadError;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Text(error),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          TextFormField(
            key: const ValueKey('order-no'),
            controller: _orderNoController,
            maxLength: 50,
            decoration: const InputDecoration(labelText: '订单号'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? '订单号不能为空' : null,
          ),
          const SizedBox(height: AppTokens.s12),
          TextFormField(
            key: const ValueKey('order-date'),
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
              labelText: '下单日期',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          TextFormField(
            key: const ValueKey('order-amount'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '订单金额',
              prefixText: '¥ ',
            ),
            validator: _validateAmount,
          ),
          const SizedBox(height: AppTokens.s12),
          TextFormField(
            key: const ValueKey('order-description'),
            controller: _descriptionController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: '商品或服务描述'),
          ),
          if (_statusLabel != null) ...[
            const SizedBox(height: AppTokens.s12),
            TextFormField(
              key: const ValueKey('order-status'),
              readOnly: true,
              initialValue: _statusLabel,
              decoration: const InputDecoration(labelText: '订单状态'),
            ),
          ],
          const SizedBox(height: AppTokens.s24),
          FilledButton.icon(
            key: const ValueKey('save-order'),
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
    );
  }
}
