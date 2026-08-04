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
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: _textTheme,
      // 卡片圆角不超过 r8，这是工具型应用保持规整感的关键。
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r8),
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
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.r12),
          ),
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
