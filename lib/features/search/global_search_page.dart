import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/daos/customer_dao.dart';
import '../../data/database_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';

final globalSearchProvider = FutureProvider.autoDispose
    .family<List<GlobalSearchResult>, String>((ref, keyword) {
      return ref.watch(customerDaoProvider).globalSearch(keyword);
    });

class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  final _controller = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _keyword.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('全局搜索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s8,
              AppTokens.s16,
              AppTokens.s12,
            ),
            child: TextField(
              key: const ValueKey('global-search-field'),
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _keyword = value),
              decoration: InputDecoration(
                hintText: '搜索客户、联系人、项目、订单或跟进',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: keyword.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清空搜索',
                        onPressed: () {
                          _controller.clear();
                          setState(() => _keyword = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: keyword.isEmpty
                ? const EmptyState(
                    icon: Icons.manage_search_outlined,
                    message: '输入关键词查找全部业务记录',
                  )
                : ref
                      .watch(globalSearchProvider(keyword))
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => const Center(child: Text('搜索失败，请重试')),
                        data: (results) => results.isEmpty
                            ? const EmptyState(
                                icon: Icons.search_off_outlined,
                                message: '没有找到匹配记录',
                              )
                            : ListView.separated(
                                key: const ValueKey('global-search-results'),
                                itemCount: results.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) =>
                                    _SearchResultTile(result: results[index]),
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});

  final GlobalSearchResult result;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (result.type) {
      GlobalSearchResultType.customer => (Icons.business_outlined, '客户'),
      GlobalSearchResultType.contact => (Icons.person_outline, '联系人'),
      GlobalSearchResultType.opportunity => (
        Icons.track_changes_outlined,
        '项目',
      ),
      GlobalSearchResultType.order => (Icons.receipt_long_outlined, '订单'),
      GlobalSearchResultType.followup => (Icons.chat_bubble_outline, '跟进'),
    };
    return ListTile(
      key: ValueKey('global-search-${result.type.name}-${result.recordId}'),
      minVerticalPadding: AppTokens.s8,
      leading: Icon(icon),
      title: Text(result.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$label · ${result.customerName} · ${result.subtitle}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/customers/${result.customerId}'),
    );
  }
}
