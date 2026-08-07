import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Date or date-time picker styled like the app's other form controls.
class AppDateFormField extends StatelessWidget {
  const AppDateFormField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
    this.clearKey,
    this.valueText,
    this.placeholder = '请选择',
    this.prefixIcon,
    super.key,
  });

  final Key fieldKey;
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final Key? clearKey;
  final String? valueText;
  final String placeholder;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return KeyedSubtree(
      key: fieldKey,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        child: InputDecorator(
          isEmpty: false,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: hasValue && onClear != null
                ? IconButton(
                    key: clearKey,
                    tooltip: '清除$label',
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  )
                : const Icon(Icons.calendar_today_outlined),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hasValue ? valueText ?? _formatDate(value!) : placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hasValue
                    ? null
                    : TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
