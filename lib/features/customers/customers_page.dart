import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/daos/customer_dao.dart';
import '../../data/database.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import 'customer_providers.dart';
import 'customer_widgets.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(customerFilterProvider).keyword,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(customerFilterProvider.notifier).setKeyword('');
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(customerFilterProvider.notifier).clear();
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _CustomerFiltersSheet(),
    );
  }

  void _refresh() {
    ref.read(customerRevisionProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(customerFilterProvider);
    final customers = ref.watch(customerListProvider);
    final tags = ref.watch(allCustomerTagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('客户')),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add-customer'),
        onPressed: () => context.push('/customers/new'),
        tooltip: '新建客户',
        child: const Icon(Icons.person_add_outlined),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s8,
              AppTokens.s16,
              AppTokens.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const ValueKey('customer-search'),
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: ref
                      .read(customerFilterProvider.notifier)
                      .setKeyword,
                  decoration: InputDecoration(
                    hintText: '搜索名称、公司或电话',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: filter.keyword.isEmpty
                        ? null
                        : IconButton(
                            key: const ValueKey('clear-customer-search'),
                            onPressed: _clearSearch,
                            tooltip: '清空搜索',
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: AppTokens.s8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    key: const ValueKey('open-customer-filters'),
                    onPressed: _showFilters,
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('筛选'),
                        if (filter.activeFilterCount > 0) ...[
                          const SizedBox(width: AppTokens.s4),
                          Container(
                            key: const ValueKey('customer-filter-count'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.s8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filter.activeFilterCount}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (filter.hasNonKeywordFilters) ...[
                  const SizedBox(height: AppTokens.s8),
                  _ActiveFilterSummary(filter: filter, tags: tags),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: customers.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return EmptyState(
                    icon: filter.hasFilters
                        ? Icons.search_off_outlined
                        : Icons.people_outline,
                    message: filter.hasFilters ? '没有符合条件的客户' : '还没有客户',
                    actionLabel: filter.hasFilters ? '清空筛选' : '新建客户',
                    onAction: filter.hasFilters
                        ? _clearAllFilters
                        : () => context.push('/customers/new'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _refresh();
                    await ref.read(customerListProvider.future);
                  },
                  child: ListView.separated(
                    key: const ValueKey('customer-list'),
                    padding: const EdgeInsets.only(bottom: AppTokens.s32 * 3),
                    itemCount: data.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = data.items[index];
                      return CustomerRowTile(
                        item: item,
                        tags: data.tagsByCustomer[item.customer.id] ?? const [],
                        onTap: () =>
                            context.push('/customers/${item.customer.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => CustomerAsyncError(onRetry: _refresh),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerFiltersSheet extends ConsumerWidget {
  const _CustomerFiltersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(customerFilterProvider);
    final notifier = ref.read(customerFilterProvider.notifier);
    final tags = ref.watch(allCustomerTagsProvider);
    final dynamicOptions = ref.watch(customerFilterOptionsProvider);

    return FractionallySizedBox(
      key: const ValueKey('customer-filters-sheet'),
      heightFactor: 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s12,
              AppTokens.s8,
              AppTokens.s8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '筛选客户',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  key: const ValueKey('close-customer-filters'),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: '关闭',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              key: const ValueKey('customer-filters-list'),
              padding: const EdgeInsets.all(AppTokens.s16),
              children: [
                _FilterDropdown<CustomerStage>(
                  fieldKey: 'customer-stage-filter',
                  label: '客户阶段',
                  allLabel: '全部客户阶段',
                  icon: Icons.flag_outlined,
                  value: filter.customerStage,
                  options: CustomerStage.values,
                  labelFor: (value) => value.label,
                  onChanged: notifier.setCustomerStage,
                ),
                const SizedBox(height: AppTokens.s12),
                tags.when(
                  data: (values) => _FilterDropdown<int>(
                    fieldKey: 'customer-tag-filter',
                    label: '标签',
                    allLabel: '全部标签',
                    icon: Icons.sell_outlined,
                    value: values.any((tag) => tag.id == filter.tagId)
                        ? filter.tagId
                        : null,
                    options: values.map((tag) => tag.id).toList(),
                    labelFor: (id) =>
                        values.firstWhere((tag) => tag.id == id).name,
                    onChanged: notifier.setTag,
                  ),
                  loading: () => const _DisabledFilter(
                    label: '标签',
                    icon: Icons.sell_outlined,
                  ),
                  error: (_, _) => const _DisabledFilter(
                    label: '标签不可用',
                    icon: Icons.sell_outlined,
                  ),
                ),
                const SizedBox(height: AppTokens.s12),
                dynamicOptions.when(
                  data: (values) => Column(
                    children: [
                      _FilterDropdown<String>(
                        fieldKey: 'customer-country-filter',
                        label: '国家',
                        allLabel: '全部国家',
                        icon: Icons.public_outlined,
                        value: filter.country,
                        options: values.countries,
                        labelFor: (value) => value,
                        onChanged: notifier.setCountry,
                      ),
                      const SizedBox(height: AppTokens.s12),
                      _FilterDropdown<String>(
                        fieldKey: 'customer-supplier-filter',
                        label: '当前供应商',
                        allLabel: '全部供应商',
                        icon: Icons.factory_outlined,
                        value: filter.currentSupplier,
                        options: values.currentSuppliers,
                        labelFor: (value) => value,
                        onChanged: notifier.setCurrentSupplier,
                      ),
                      const SizedBox(height: AppTokens.s12),
                      _FilterDropdown<String>(
                        fieldKey: 'customer-entry-point-filter',
                        label: '替代切入点',
                        allLabel: '全部切入点',
                        icon: Icons.alt_route_outlined,
                        value: filter.entryPoint,
                        options: values.entryPoints,
                        labelFor: (value) => value,
                        onChanged: notifier.setEntryPoint,
                      ),
                      const SizedBox(height: AppTokens.s12),
                      _FilterDropdown<String>(
                        fieldKey: 'customer-product-category-filter',
                        label: '产品分类',
                        allLabel: '全部产品分类',
                        icon: Icons.category_outlined,
                        value: filter.productCategory,
                        options: values.productCategories,
                        labelFor: (value) => value,
                        onChanged: notifier.setProductCategory,
                      ),
                      const SizedBox(height: AppTokens.s12),
                      _FilterDropdown<String>(
                        fieldKey: 'customer-product-model-filter',
                        label: '产品型号',
                        allLabel: '全部产品型号',
                        icon: Icons.inventory_2_outlined,
                        value: filter.productModel,
                        options: values.productModels,
                        labelFor: (value) => value,
                        onChanged: notifier.setProductModel,
                      ),
                      const SizedBox(height: AppTokens.s12),
                      _FilterDropdown<String>(
                        fieldKey: 'customer-equipment-brand-filter',
                        label: '设备品牌',
                        allLabel: '全部设备品牌',
                        icon: Icons.precision_manufacturing_outlined,
                        value: filter.equipmentBrand,
                        options: values.equipmentBrands,
                        labelFor: (value) => value,
                        onChanged: notifier.setEquipmentBrand,
                      ),
                    ],
                  ),
                  loading: () => const Column(
                    children: [
                      _DisabledFilter(label: '国家', icon: Icons.public_outlined),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '当前供应商',
                        icon: Icons.factory_outlined,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '替代切入点',
                        icon: Icons.alt_route_outlined,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '产品分类',
                        icon: Icons.category_outlined,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '产品型号',
                        icon: Icons.inventory_2_outlined,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '设备品牌',
                        icon: Icons.precision_manufacturing_outlined,
                      ),
                    ],
                  ),
                  error: (_, _) => const Column(
                    children: [
                      _DisabledFilter(
                        label: '动态筛选项不可用',
                        icon: Icons.error_outline,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '产品分类不可用',
                        icon: Icons.category_outlined,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '产品型号不可用',
                        icon: Icons.inventory_2_outlined,
                      ),
                      SizedBox(height: AppTokens.s12),
                      _DisabledFilter(
                        label: '设备品牌不可用',
                        icon: Icons.precision_manufacturing_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s12),
                _FilterDropdown<CustomerGrade>(
                  fieldKey: 'customer-grade-filter',
                  label: '客户等级',
                  allLabel: '全部客户等级',
                  icon: Icons.grade_outlined,
                  value: filter.customerGrade,
                  options: CustomerGrade.values,
                  labelFor: (value) => value.label,
                  onChanged: notifier.setCustomerGrade,
                ),
                const SizedBox(height: AppTokens.s12),
                _FilterDropdown<OpportunityStage>(
                  fieldKey: 'customer-opportunity-stage-filter',
                  label: '销售阶段',
                  allLabel: '全部销售阶段',
                  icon: Icons.trending_up_outlined,
                  value: filter.opportunityStage,
                  options: OpportunityStage.values,
                  labelFor: (value) => value.label,
                  onChanged: notifier.setOpportunityStage,
                ),
                const SizedBox(height: AppTokens.s12),
                _FilterDropdown<OpportunityStatus>(
                  fieldKey: 'customer-opportunity-status-filter',
                  label: '项目状态',
                  allLabel: '全部项目状态',
                  icon: Icons.toggle_on_outlined,
                  value: filter.opportunityStatus,
                  options: OpportunityStatus.values,
                  labelFor: (value) => value.label,
                  onChanged: notifier.setOpportunityStatus,
                ),
                const SizedBox(height: AppTokens.s12),
                dynamicOptions.when(
                  data: (values) => _FilterDropdown<String>(
                    fieldKey: 'customer-owner-filter',
                    label: '负责人',
                    allLabel: '全部负责人',
                    icon: Icons.badge_outlined,
                    value: filter.owner,
                    options: values.owners,
                    labelFor: (value) => value,
                    onChanged: notifier.setOwner,
                  ),
                  loading: () => const _DisabledFilter(
                    label: '负责人',
                    icon: Icons.badge_outlined,
                  ),
                  error: (_, _) => const _DisabledFilter(
                    label: '负责人不可用',
                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: AppTokens.s12),
                _FilterDateTile(
                  fieldKey: 'customer-expected-close-from',
                  label: '预计成交开始日期',
                  value: filter.expectedCloseFrom,
                  firstDate: _earlierDate(
                    DateTime(2000),
                    filter.expectedCloseTo,
                  ),
                  lastDate: filter.expectedCloseTo ?? DateTime(2100),
                  onChanged: notifier.setExpectedCloseFrom,
                ),
                const SizedBox(height: AppTokens.s12),
                _FilterDateTile(
                  fieldKey: 'customer-expected-close-to',
                  label: '预计成交结束日期',
                  value: filter.expectedCloseTo,
                  firstDate: filter.expectedCloseFrom ?? DateTime(2000),
                  lastDate: _laterDate(
                    DateTime(2100),
                    filter.expectedCloseFrom,
                  ),
                  onChanged: notifier.setExpectedCloseTo,
                ),
                const SizedBox(height: AppTokens.s16),
                Text('异常状态', style: Theme.of(context).textTheme.titleSmall),
                _AnomalyFilterTile(
                  fieldKey: 'customer-anomaly-stalled-quote',
                  label: '报价停滞（30 天未确认收到）',
                  selected: filter.anomalies.contains(
                    CustomerAnomalyFilter.stalledQuote,
                  ),
                  onChanged: () => notifier.toggleAnomaly(
                    CustomerAnomalyFilter.stalledQuote,
                  ),
                ),
                _AnomalyFilterTile(
                  fieldKey: 'customer-anomaly-stalled-sample',
                  label: '样品停滞（交付 30 天无测试反馈）',
                  selected: filter.anomalies.contains(
                    CustomerAnomalyFilter.stalledSample,
                  ),
                  onChanged: () => notifier.toggleAnomaly(
                    CustomerAnomalyFilter.stalledSample,
                  ),
                ),
                _AnomalyFilterTile(
                  fieldKey: 'customer-anomaly-long-silence',
                  label: '长期沉默（按客户等级）',
                  selected: filter.anomalies.contains(
                    CustomerAnomalyFilter.longSilence,
                  ),
                  onChanged: () =>
                      notifier.toggleAnomaly(CustomerAnomalyFilter.longSilence),
                ),
                const SizedBox(height: AppTokens.s24),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTokens.s16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('clear-customer-filter-sheet'),
                    onPressed: filter.hasNonKeywordFilters
                        ? notifier.clearNonKeywordFilters
                        : null,
                    child: const Text('清除全部'),
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('完成'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.fieldKey,
    required this.label,
    required this.allLabel,
    required this.icon,
    required this.value,
    required this.options,
    required this.labelFor,
    required this.onChanged,
  });

  final String fieldKey;
  final String label;
  final String allLabel;
  final IconData icon;
  final T? value;
  final List<T> options;
  final String Function(T value) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T?>(
    key: ValueKey(fieldKey),
    initialValue: options.contains(value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    items: [
      DropdownMenuItem<T?>(value: null, child: Text(allLabel)),
      ...options.map(
        (option) => DropdownMenuItem<T?>(
          value: option,
          child: Text(
            labelFor(option),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
    onChanged: onChanged,
  );
}

class _FilterDateTile extends StatelessWidget {
  const _FilterDateTile({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final String fieldKey;
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    key: ValueKey(fieldKey),
    contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
    leading: const Icon(Icons.event_outlined),
    title: Text(label),
    subtitle: Text(value == null ? '不限' : _formatFilterDate(value!)),
    trailing: value == null
        ? const Icon(Icons.chevron_right)
        : IconButton(
            key: ValueKey('$fieldKey-clear'),
            onPressed: () => onChanged(null),
            tooltip: '清除$label',
            icon: const Icon(Icons.close),
          ),
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(AppTokens.s12),
    ),
    onTap: () async {
      final today = _dateOnly(DateTime.now());
      var pickerFirstDate = _dateOnly(firstDate);
      var pickerLastDate = _dateOnly(lastDate);
      final currentDate = value == null ? null : _dateOnly(value!);
      if (currentDate != null && currentDate.isBefore(pickerFirstDate)) {
        pickerFirstDate = currentDate;
      }
      if (currentDate != null && currentDate.isAfter(pickerLastDate)) {
        pickerLastDate = currentDate;
      }
      final initialDate = _clampDate(
        currentDate ?? today,
        pickerFirstDate,
        pickerLastDate,
      );
      final selected = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: pickerFirstDate,
        lastDate: pickerLastDate,
      );
      if (selected != null) onChanged(selected);
    },
  );
}

class _AnomalyFilterTile extends StatelessWidget {
  const _AnomalyFilterTile({
    required this.fieldKey,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String fieldKey;
  final String label;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    key: ValueKey(fieldKey),
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    title: Text(label),
    value: selected,
    onChanged: (_) => onChanged(),
  );
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _earlierDate(DateTime value, DateTime? other) =>
    other != null && other.isBefore(value) ? other : value;

DateTime _laterDate(DateTime value, DateTime? other) =>
    other != null && other.isAfter(value) ? other : value;

DateTime _clampDate(DateTime value, DateTime firstDate, DateTime lastDate) {
  if (value.isBefore(firstDate)) return firstDate;
  if (value.isAfter(lastDate)) return lastDate;
  return value;
}

String _formatFilterDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

class _ActiveFilterSummary extends ConsumerWidget {
  const _ActiveFilterSummary({required this.filter, required this.tags});

  final CustomerFilter filter;
  final AsyncValue<List<TagRow>> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(customerFilterProvider.notifier);
    final loadedTags = tags.whenOrNull(data: (values) => values);
    final tagName = loadedTags
        ?.where((tag) => tag.id == filter.tagId)
        .firstOrNull
        ?.name;
    final chips = <Widget>[
      if (filter.customerStage != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-stage',
          label: '客户阶段：${filter.customerStage!.label}',
          onDeleted: () => notifier.setCustomerStage(null),
        ),
      if (filter.tagId != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-tag',
          label: '标签：${tagName ?? filter.tagId}',
          onDeleted: () => notifier.setTag(null),
        ),
      if (filter.country != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-country',
          label: '国家：${filter.country}',
          onDeleted: () => notifier.setCountry(null),
        ),
      if (filter.customerGrade != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-grade',
          label: '等级：${filter.customerGrade!.label}',
          onDeleted: () => notifier.setCustomerGrade(null),
        ),
      if (filter.currentSupplier != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-supplier',
          label: '供应商：${filter.currentSupplier}',
          onDeleted: () => notifier.setCurrentSupplier(null),
        ),
      if (filter.entryPoint != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-entry-point',
          label: '切入点：${filter.entryPoint}',
          onDeleted: () => notifier.setEntryPoint(null),
        ),
      if (filter.opportunityStage != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-opportunity-stage',
          label: '销售阶段：${filter.opportunityStage!.label}',
          onDeleted: () => notifier.setOpportunityStage(null),
        ),
      if (filter.owner != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-owner',
          label: '负责人：${filter.owner}',
          onDeleted: () => notifier.setOwner(null),
        ),
      if (filter.productCategory != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-product-category',
          label: '产品品类：${filter.productCategory}',
          onDeleted: () => notifier.setProductCategory(null),
        ),
      if (filter.productModel != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-product-model',
          label: '产品型号：${filter.productModel}',
          onDeleted: () => notifier.setProductModel(null),
        ),
      if (filter.equipmentBrand != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-equipment-brand',
          label: '设备品牌：${filter.equipmentBrand}',
          onDeleted: () => notifier.setEquipmentBrand(null),
        ),
      if (filter.opportunityStatus != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-opportunity-status',
          label: '项目状态：${filter.opportunityStatus!.label}',
          onDeleted: () => notifier.setOpportunityStatus(null),
        ),
      if (filter.expectedCloseFrom != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-expected-close-from',
          label: '预计成交自 ${_formatFilterDate(filter.expectedCloseFrom!)}',
          onDeleted: () => notifier.setExpectedCloseFrom(null),
        ),
      if (filter.expectedCloseTo != null)
        _SummaryChip(
          chipKey: 'customer-filter-chip-expected-close-to',
          label: '预计成交至 ${_formatFilterDate(filter.expectedCloseTo!)}',
          onDeleted: () => notifier.setExpectedCloseTo(null),
        ),
      if (filter.anomalies.contains(CustomerAnomalyFilter.stalledQuote))
        _SummaryChip(
          chipKey: 'customer-filter-chip-stalled-quote',
          label: '报价停滞',
          onDeleted: () =>
              notifier.toggleAnomaly(CustomerAnomalyFilter.stalledQuote),
        ),
      if (filter.anomalies.contains(CustomerAnomalyFilter.stalledSample))
        _SummaryChip(
          chipKey: 'customer-filter-chip-stalled-sample',
          label: '样品停滞',
          onDeleted: () =>
              notifier.toggleAnomaly(CustomerAnomalyFilter.stalledSample),
        ),
      if (filter.anomalies.contains(CustomerAnomalyFilter.longSilence))
        _SummaryChip(
          chipKey: 'customer-filter-chip-long-silence',
          label: '长期沉默',
          onDeleted: () =>
              notifier.toggleAnomaly(CustomerAnomalyFilter.longSilence),
        ),
      TextButton.icon(
        key: const ValueKey('clear-customer-filters'),
        onPressed: notifier.clearNonKeywordFilters,
        icon: const Icon(Icons.filter_alt_off_outlined),
        label: const Text('清除全部'),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < chips.length; index++) ...[
            if (index > 0) const SizedBox(width: AppTokens.s8),
            chips[index],
          ],
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.chipKey,
    required this.label,
    required this.onDeleted,
  });

  final String chipKey;
  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => InputChip(
    key: ValueKey(chipKey),
    label: Text(label),
    onDeleted: onDeleted,
  );
}

class _DisabledFilter extends StatelessWidget {
  const _DisabledFilter({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      enabled: false,
    ),
    child: const SizedBox(height: AppTokens.s24),
  );
}
