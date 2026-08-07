import 'package:flutter/material.dart';

/// Reveals the actionable part of a validation error and moves input focus.
Future<void> revealFormError({
  required GlobalKey targetKey,
  FocusNode? focusNode,
}) async {
  await WidgetsBinding.instance.endOfFrame;
  final context = targetKey.currentContext;
  if (context == null || !context.mounted) return;
  await Scrollable.ensureVisible(
    context,
    alignment: 0.15,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
  );
  focusNode?.requestFocus();
}
