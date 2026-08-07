import 'package:flutter/material.dart';

/// Prevents accidental route exits while a form contains unsaved changes.
class UnsavedChangesGuard extends StatefulWidget {
  const UnsavedChangesGuard({
    required this.hasUnsavedChanges,
    required this.child,
    super.key,
  });

  final bool hasUnsavedChanges;
  final Widget child;

  @override
  State<UnsavedChangesGuard> createState() => _UnsavedChangesGuardState();
}

extension UnsavedChangesGuardWidget on Widget {
  Widget protectUnsavedChanges({required bool hasUnsavedChanges}) =>
      UnsavedChangesGuard(hasUnsavedChanges: hasUnsavedChanges, child: this);
}

class _UnsavedChangesGuardState extends State<UnsavedChangesGuard> {
  bool _dialogOpen = false;

  Future<void> _confirmExit() async {
    if (_dialogOpen || !mounted) return;
    _dialogOpen = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('放弃未保存的修改？'),
        content: const Text('当前填写的内容尚未保存，退出后将无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('继续编辑'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: const Text('放弃修改'),
          ),
        ],
      ),
    );
    _dialogOpen = false;
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: !widget.hasUnsavedChanges,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && widget.hasUnsavedChanges) _confirmExit();
    },
    child: widget.child,
  );
}
