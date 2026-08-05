import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void _clearFilters() {
    _searchController.clear();
    ref.read(customerFilterProvider.notifier).clear();
  }

  void _refresh() {
    ref.read(customerRevisionProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(customerFilterProvider);
    final customers = ref.watch(customerListProvider);
    final tags = ref.watch(allCustomerTagsProvider);
    final hasFilter =
        filter.keyword.trim().isNotEmpty ||
        filter.stage != null ||
        filter.tagId != null;

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
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(customerFilterProvider.notifier)
                                  .setKeyword('');
                            },
                            tooltip: '清空搜索',
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: AppTokens.s8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CustomerStage?>(
                        key: const ValueKey('customer-stage-filter'),
                        initialValue: filter.stage,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: '阶段',
                          prefixIcon: Icon(Icons.filter_alt_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('全部阶段'),
                          ),
                          ...CustomerStage.values.map(
                            (stage) => DropdownMenuItem(
                              value: stage,
                              child: Text(
                                stage.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: ref
                            .read(customerFilterProvider.notifier)
                            .setStage,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Expanded(
                      child: tags.when(
                        data: (values) {
                          final selected =
                              values.any((tag) => tag.id == filter.tagId)
                              ? filter.tagId
                              : null;
                          return DropdownButtonFormField<int?>(
                            key: const ValueKey('customer-tag-filter'),
                            initialValue: selected,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: '标签',
                              prefixIcon: Icon(Icons.sell_outlined),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('全部标签'),
                              ),
                              ...values.map(
                                (tag) => DropdownMenuItem(
                                  value: tag.id,
                                  child: Text(
                                    tag.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: ref
                                .read(customerFilterProvider.notifier)
                                .setTag,
                          );
                        },
                        loading: () => const _DisabledFilter(
                          label: '标签',
                          icon: Icons.sell_outlined,
                        ),
                        error: (_, _) => const _DisabledFilter(
                          label: '标签不可用',
                          icon: Icons.sell_outlined,
                        ),
                      ),
                    ),
                    if (hasFilter) ...[
                      const SizedBox(width: AppTokens.s4),
                      IconButton(
                        key: const ValueKey('clear-customer-filters'),
                        onPressed: _clearFilters,
                        tooltip: '清空筛选',
                        icon: const Icon(Icons.filter_alt_off_outlined),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: customers.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return EmptyState(
                    icon: hasFilter
                        ? Icons.search_off_outlined
                        : Icons.people_outline,
                    message: hasFilter ? '没有符合条件的客户' : '还没有客户',
                    actionLabel: hasFilter ? '清空筛选' : '新建客户',
                    onAction: hasFilter
                        ? _clearFilters
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
