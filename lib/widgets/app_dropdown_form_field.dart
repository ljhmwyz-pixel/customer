import 'package:flutter/material.dart';

import '../theme/tokens.dart';

Key appDropdownMenuItemKey(Object? value) =>
    ValueKey<Object?>(('app-dropdown-item', value));

/// App-wide dropdown with a menu that follows the form field's width.
class AppDropdownFormField<T> extends StatefulWidget {
  const AppDropdownFormField({
    required this.items,
    required this.onChanged,
    this.fieldKey,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.validator,
    super.key,
  });

  final Key? fieldKey;
  final T? initialValue;
  final InputDecoration decoration;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  State<AppDropdownFormField<T>> createState() =>
      _AppDropdownFormFieldState<T>();
}

class _AppDropdownFormFieldState<T> extends State<AppDropdownFormField<T>> {
  final _formFieldKey = GlobalKey<FormFieldState<T>>();
  final _menuController = MenuController();
  bool _isOpen = false;

  bool get _enabled => widget.items != null && widget.onChanged != null;

  @override
  void didUpdateWidget(covariant AppDropdownFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formFieldKey.currentState?.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) => FormField<T>(
    key: _formFieldKey,
    initialValue: widget.initialValue,
    enabled: _enabled,
    validator: widget.validator,
    builder: (field) => KeyedSubtree(
      key: widget.fieldKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = widget.items ?? <DropdownMenuItem<T>>[];
          final selectedIndex = items.indexWhere(
            (item) => item.value == field.value,
          );
          final selectedChild = selectedIndex < 0
              ? null
              : items[selectedIndex].child;
          final colors = Theme.of(context).colorScheme;
          final width = constraints.maxWidth;

          return MenuAnchor(
            controller: _menuController,
            crossAxisUnconstrained: false,
            onOpen: () => setState(() => _isOpen = true),
            onClose: () => setState(() => _isOpen = false),
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(
                colors.surfaceContainerLowest,
              ),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              elevation: const WidgetStatePropertyAll(4),
              shadowColor: WidgetStatePropertyAll(
                colors.shadow.withValues(alpha: 0.18),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: AppTokens.s8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.r8),
                ),
              ),
              fixedSize: WidgetStatePropertyAll(Size.fromWidth(width)),
              maximumSize: WidgetStatePropertyAll(Size(width, 320)),
            ),
            menuChildren: [
              for (final item in items)
                MenuItemButton(
                  key: appDropdownMenuItemKey(item.value),
                  onPressed: item.enabled
                      ? () {
                          field.didChange(item.value);
                          widget.onChanged?.call(item.value);
                        }
                      : null,
                  style: const ButtonStyle(
                    alignment: Alignment.centerLeft,
                    minimumSize: WidgetStatePropertyAll(
                      Size(0, AppTokens.minTouchTarget),
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: AppTokens.s12),
                    ),
                  ),
                  child: item.child,
                ),
            ],
            builder: (context, controller, child) => InkWell(
              onTap: _enabled
                  ? () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppTokens.r8),
              child: InputDecorator(
                isEmpty: selectedIndex < 0,
                isFocused: _isOpen,
                decoration: widget.decoration.copyWith(
                  enabled: _enabled,
                  errorText: field.errorText ?? widget.decoration.errorText,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: selectedChild == null
                          ? const SizedBox.shrink()
                          : DefaultTextStyle.merge(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              child: selectedChild,
                            ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Icon(
                      _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: _enabled
                          ? colors.onSurfaceVariant
                          : colors.onSurface.withValues(alpha: 0.38),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
