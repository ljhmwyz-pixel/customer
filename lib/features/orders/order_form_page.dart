import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/database_provider.dart';
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
  final _piPoNoController = TextEditingController();
  final _currencyController = TextEditingController(text: 'CNY');
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _estimatedArrivalController = TextEditingController();
  final _estimatedRepurchaseController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _orderedAt = DateTime.now();
  DateTime? _estimatedArrivalAt;
  DateTime? _estimatedRepurchaseAt;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  ProductionStatus _productionStatus = ProductionStatus.pending;
  ShippingStatus _shippingStatus = ShippingStatus.pending;
  OrderResult _orderResult = OrderResult.inProgress;
  List<OpportunityRow> _opportunities = [];
  int? _selectedOpportunityId;
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

      final opportunities = await ref
          .read(databaseProvider)
          .opportunityDao
          .listOfCustomer(widget.customerId);
      final service = ref.read(orderServiceProvider);
      final orderId = widget.orderId;
      if (orderId == null) {
        _orderNoController.text = await service.nextOrderNo();
        _selectedOpportunityId = opportunities.length == 1
            ? opportunities.single.id
            : null;
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
        _piPoNoController.text = order.piPoNo ?? '';
        _currencyController.text = order.currency;
        _amountController.text = _editableAmount(order.amountCents);
        _descriptionController.text = order.description ?? '';
        _orderedAt = localDateTime(order.orderedAt);
        _dateController.text = formatDateTime(_orderedAt);
        final estimatedArrivalAt = order.estimatedArrivalAt;
        _estimatedArrivalAt = estimatedArrivalAt == null
            ? null
            : localDateTime(estimatedArrivalAt);
        _estimatedArrivalController.text = _formatOptionalDate(
          _estimatedArrivalAt,
        );
        final estimatedRepurchaseAt = order.estimatedRepurchaseAt;
        _estimatedRepurchaseAt = estimatedRepurchaseAt == null
            ? null
            : localDateTime(estimatedRepurchaseAt);
        _estimatedRepurchaseController.text = _formatOptionalDate(
          _estimatedRepurchaseAt,
        );
        _paymentStatus = PaymentStatus.fromDb(order.paymentStatus);
        _productionStatus = ProductionStatus.fromDb(order.productionStatus);
        _shippingStatus = ShippingStatus.fromDb(order.shippingStatus);
        _orderResult = OrderResult.fromDb(order.orderResult);
        _statusLabel = OrderStatus.fromDb(order.status).label;
        final currentOpportunityId = order.opportunityId;
        _selectedOpportunityId =
            opportunities.any((item) => item.id == currentOpportunityId)
            ? currentOpportunityId
            : opportunities.length == 1
            ? opportunities.single.id
            : null;
      }
      _opportunities = opportunities;
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
    _piPoNoController.dispose();
    _currencyController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _estimatedArrivalController.dispose();
    _estimatedRepurchaseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatOptionalDate(DateTime? value) =>
      value == null ? '' : formatDateTime(value).split(' ').first;

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

  Future<void> _pickOptionalDate({
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? _orderedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    onChanged(DateTime(date.year, date.month, date.day));
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
    final opportunityId = _selectedOpportunityId;
    if (_saving ||
        opportunityId == null ||
        !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final draft = OrderDraft(
        opportunityId: opportunityId,
        orderNo: _orderNoController.text,
        orderedAt: _orderedAt,
        amountCents: parseAmountCents(_amountController.text),
        piPoNo: _piPoNoController.text,
        currency: _currencyController.text,
        paymentStatus: _paymentStatus,
        productionStatus: _productionStatus,
        shippingStatus: _shippingStatus,
        estimatedArrivalAt: _estimatedArrivalAt,
        orderResult: _orderResult,
        estimatedRepurchaseAt: _estimatedRepurchaseAt,
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
          if (_opportunities.isEmpty)
            const _NoOpportunityMessage()
          else if (_opportunities.length == 1)
            TextFormField(
              key: const ValueKey('order-opportunity'),
              readOnly: true,
              initialValue: _opportunities.single.name,
              decoration: const InputDecoration(labelText: '项目'),
            )
          else
            DropdownButtonFormField<int>(
              key: const ValueKey('order-opportunity'),
              initialValue: _selectedOpportunityId,
              decoration: const InputDecoration(labelText: '项目'),
              items: _opportunities
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _selectedOpportunityId = value),
              validator: (value) => value == null ? '请选择关联项目' : null,
            ),
          const SizedBox(height: AppTokens.s12),
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
            key: const ValueKey('order-pi-po-no'),
            controller: _piPoNoController,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'PI/PO 编号'),
          ),
          const SizedBox(height: AppTokens.s12),
          TextFormField(
            key: const ValueKey('order-currency'),
            controller: _currencyController,
            maxLength: 3,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: '币种', hintText: 'CNY'),
          ),
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<PaymentStatus>(
            key: const ValueKey('order-payment-status'),
            initialValue: _paymentStatus,
            decoration: const InputDecoration(labelText: '付款状态'),
            items: PaymentStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(growable: false),
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _paymentStatus = value);
                  },
          ),
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<ProductionStatus>(
            key: const ValueKey('order-production-status'),
            initialValue: _productionStatus,
            decoration: const InputDecoration(labelText: '生产状态'),
            items: ProductionStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(growable: false),
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _productionStatus = value);
                    }
                  },
          ),
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<ShippingStatus>(
            key: const ValueKey('order-shipping-status'),
            initialValue: _shippingStatus,
            decoration: const InputDecoration(labelText: '发货状态'),
            items: ShippingStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(growable: false),
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _shippingStatus = value);
                  },
          ),
          const SizedBox(height: AppTokens.s12),
          _optionalDateField(
            key: 'order-estimated-arrival',
            label: '预计到货日期',
            controller: _estimatedArrivalController,
            value: _estimatedArrivalAt,
            onChanged: (value) => setState(() {
              _estimatedArrivalAt = value;
              _estimatedArrivalController.text = _formatOptionalDate(value);
            }),
          ),
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<OrderResult>(
            key: const ValueKey('order-result'),
            initialValue: _orderResult,
            decoration: const InputDecoration(labelText: '订单结果'),
            items: OrderResult.values
                .map(
                  (result) => DropdownMenuItem(
                    value: result,
                    child: Text(result.label),
                  ),
                )
                .toList(growable: false),
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _orderResult = value);
                  },
          ),
          const SizedBox(height: AppTokens.s12),
          _optionalDateField(
            key: 'order-estimated-repurchase',
            label: '预计复购日期',
            controller: _estimatedRepurchaseController,
            value: _estimatedRepurchaseAt,
            onChanged: (value) => setState(() {
              _estimatedRepurchaseAt = value;
              _estimatedRepurchaseController.text = _formatOptionalDate(value);
            }),
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
            onPressed: _saving || _selectedOpportunityId == null ? null : _save,
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

  Widget _optionalDateField({
    required String key,
    required String label,
    required TextEditingController controller,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) => TextFormField(
    key: ValueKey(key),
    controller: controller,
    readOnly: true,
    onTap: () => _pickOptionalDate(value: value, onChanged: onChanged),
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: value == null
          ? const Icon(Icons.calendar_today_outlined)
          : IconButton(
              tooltip: '清除$label',
              onPressed: _saving ? null : () => onChanged(null),
              icon: const Icon(Icons.clear),
            ),
    ),
  );
}

class _NoOpportunityMessage extends StatelessWidget {
  const _NoOpportunityMessage();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppTokens.s8),
    ),
    child: const Padding(
      padding: EdgeInsets.all(AppTokens.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline),
          SizedBox(width: AppTokens.s8),
          Expanded(child: Text('当前客户暂无项目，请先创建项目后再新增订单。')),
        ],
      ),
    ),
  );
}
