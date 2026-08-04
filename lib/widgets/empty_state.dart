import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// 空状态。
///
/// 每个列表都需要有空状态，文案描述当前状态而非解释功能。
/// 见 docs/UI_GUIDELINES.md 第 6 节。
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppTokens.s32, color: scheme.outline),
            const SizedBox(height: AppTokens.s12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTokens.s16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
