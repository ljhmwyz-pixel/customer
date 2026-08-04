import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';

/// 新客户开发漏斗。阶段 0 占位，真实实现在阶段 4。
class FunnelPage extends StatelessWidget {
  const FunnelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('漏斗')),
      body: const EmptyState(
        icon: Icons.filter_alt_outlined,
        message: '还没有数据，添加客户后这里会按阶段汇总',
      ),
    );
  }
}
