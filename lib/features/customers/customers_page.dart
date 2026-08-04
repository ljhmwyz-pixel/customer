import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';

/// 客户列表。阶段 0 占位，真实实现在阶段 3。
class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('客户')),
      body: const EmptyState(icon: Icons.people_outline, message: '还没有客户'),
    );
  }
}
