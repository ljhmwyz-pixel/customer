import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A compact, keyboard-friendly section for long forms.
class FormSection extends StatefulWidget {
  const FormSection({
    required this.sectionKey,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.hasError = false,
    super.key,
  });

  final String sectionKey;
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool hasError;

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  late bool _expanded = widget.expanded ?? widget.initiallyExpanded;

  bool get _effectiveExpanded => widget.expanded ?? _expanded;

  @override
  void didUpdateWidget(covariant FormSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != oldWidget.expanded) {
      setState(() => _expanded = widget.expanded!);
    }
  }

  void _setExpanded(bool value) {
    if (widget.expanded == null) setState(() => _expanded = value);
    widget.onExpansionChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final expanded = _effectiveExpanded;
    return KeyedSubtree(
      key: ValueKey('form-section-state-${widget.sectionKey}-$expanded'),
      child: ExpansionTile(
        key: ValueKey('form-section-header-${widget.sectionKey}'),
        initiallyExpanded: expanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: AppTokens.s8),
        title: Text(widget.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.hasError)
              Semantics(
                label: '该区块有错误',
                child: Icon(
                  Icons.error_outline,
                  key: ValueKey('form-section-error-${widget.sectionKey}'),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            const SizedBox(width: AppTokens.s8),
            const Icon(Icons.expand_more),
          ],
        ),
        onExpansionChanged: _setExpanded,
        children: [widget.child],
      ),
    );
  }
}
