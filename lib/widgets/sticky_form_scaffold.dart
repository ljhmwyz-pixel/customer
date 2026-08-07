import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Keeps the primary form action reachable while the keyboard or a long list is open.
class StickyFormScaffold extends StatelessWidget {
  const StickyFormScaffold({
    required this.body,
    required this.onSubmit,
    required this.submitLabel,
    this.submitting = false,
    this.enabled = true,
    this.submitKey,
    super.key,
  });

  final Widget body;
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool submitting;
  final bool enabled;
  final Key? submitKey;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: body),
      SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s8,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: submitKey ?? const ValueKey('sticky-form-submit'),
            onPressed: enabled && !submitting ? onSubmit : null,
            icon: submitting
                ? const SizedBox.square(
                    dimension: AppTokens.s16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(submitting ? '保存中' : submitLabel),
          ),
        ),
      ),
    ],
  );
}
