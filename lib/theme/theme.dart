import 'package:flutter/material.dart';

import 'tokens.dart';

/// 明暗两套主题。
///
/// 由 AppTokens.seedColor 单一种子推导出全部语义色槽，
/// 这样调整整体配色只需改一个值。
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final generated = ColorScheme.fromSeed(
      seedColor: AppTokens.seedColor,
      brightness: brightness,
    );
    final scheme = generated.copyWith(
      surface: brightness == Brightness.light
          ? const Color(0xFFFAFBFA)
          : const Color(0xFF111615),
      surfaceContainerLowest: brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF0C100F),
      surfaceContainer: brightness == Brightness.light
          ? const Color(0xFFF3F6F4)
          : const Color(0xFF1A211F),
      surfaceContainerHighest: brightness == Brightness.light
          ? const Color(0xFFE9EFEC)
          : const Color(0xFF26302D),
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppTokens.s16,
        toolbarHeight: 64,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      // 卡片圆角不超过 r8，这是工具型应用保持规整感的关键。
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s12,
          vertical: AppTokens.s12,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r8),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        modalBackgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        modalElevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.r12),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 640),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: scheme.shadow.withValues(alpha: 0.18),
        menuPadding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
        ),
        textStyle: _textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.24),
        barrierColor: Colors.black54,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s24,
        ),
        constraints: const BoxConstraints(
          minWidth: AppTokens.dialogMinWidth,
          maxWidth: AppTokens.dialogMaxWidth,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
        ),
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
        ),
        insetPadding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          0,
          AppTokens.s16,
          AppTokens.s16,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppTokens.s8,
        contentPadding: EdgeInsets.symmetric(horizontal: AppTokens.s16),
      ),
    );
  }

  /// 六档字号，三档字重，字距一律为 0。
  static const TextTheme _textTheme = TextTheme(
    // f24　页面主标题
    headlineSmall: TextStyle(
      fontSize: AppTokens.f24,
      fontWeight: AppTokens.wSemibold,
      letterSpacing: AppTokens.letterSpacing,
    ),
    // f20　区块标题
    titleLarge: TextStyle(
      fontSize: AppTokens.f20,
      fontWeight: AppTokens.wSemibold,
      letterSpacing: AppTokens.letterSpacing,
    ),
    // f16　正文、客户名称
    titleMedium: TextStyle(
      fontSize: AppTokens.f16,
      fontWeight: AppTokens.wMedium,
      letterSpacing: AppTokens.letterSpacing,
    ),
    bodyLarge: TextStyle(
      fontSize: AppTokens.f16,
      fontWeight: AppTokens.wRegular,
      letterSpacing: AppTokens.letterSpacing,
    ),
    // f14　次要信息
    bodyMedium: TextStyle(
      fontSize: AppTokens.f14,
      fontWeight: AppTokens.wRegular,
      letterSpacing: AppTokens.letterSpacing,
    ),
    // f12　辅助信息、时间戳
    bodySmall: TextStyle(
      fontSize: AppTokens.f12,
      fontWeight: AppTokens.wRegular,
      letterSpacing: AppTokens.letterSpacing,
    ),
    // f10　标记内文字
    labelSmall: TextStyle(
      fontSize: AppTokens.f10,
      fontWeight: AppTokens.wMedium,
      letterSpacing: AppTokens.letterSpacing,
    ),
  );
}
