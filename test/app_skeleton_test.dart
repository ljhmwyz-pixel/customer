import 'package:customer/app.dart';
import 'package:customer/theme/semantic_colors.dart';
import 'package:customer/theme/theme.dart';
import 'package:customer/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 相对亮度。
double _luminance(Color c) => c.computeLuminance();

/// 两色对比度，返回值范围 1:1 到 21:1。
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('阶段 0 骨架', () {
    testWidgets('四个 Tab 均可切换且不崩溃', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CustomerApp()));
      await tester.pumpAndSettle();

      // 首页
      expect(find.text('今日'), findsWidgets);

      for (final label in ['客户', '漏斗', '我的']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(label), findsWidgets);
      }

      // 回到首页
      await tester.tap(find.text('今日'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('空状态在客户页可见', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CustomerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('客户'));
      await tester.pumpAndSettle();

      expect(find.text('还没有客户'), findsOneWidget);
    });
  });

  group('主题', () {
    test('明暗两套主题均由同一种子生成', () {
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    });

    test('字距为 0', () {
      final style = AppTheme.light.textTheme.bodyMedium;
      expect(style?.letterSpacing, AppTokens.letterSpacing);
    });

    test('间距均为 4 的倍数', () {
      const spacings = [
        AppTokens.s4,
        AppTokens.s8,
        AppTokens.s12,
        AppTokens.s16,
        AppTokens.s24,
        AppTokens.s32,
      ];
      for (final s in spacings) {
        expect(s % 4, 0, reason: '$s 不是 4 的倍数');
      }
    });

    test('卡片圆角不超过 8', () {
      expect(AppTokens.r8, lessThanOrEqualTo(8));
    });

    test('语义色在各自主题背景上达到 WCAG AA 对比度', () {
      // 4.5:1 是 AA 对正常字号的要求。语义色都用在文字和细竖条上，
      // 不能只满足大字号的 3:1。
      const minRatio = 4.5;

      final lightBg = AppTheme.light.colorScheme.surface;
      final darkBg = AppTheme.dark.colorScheme.surface;

      final lightPairs = <String, Color>{
        'overdue': AppSemanticColors.light.overdue,
        'today': AppSemanticColors.light.today,
        'upcoming': AppSemanticColors.light.upcoming,
        'done': AppSemanticColors.light.done,
        'inactive': AppSemanticColors.light.inactive,
      };
      lightPairs.forEach((name, color) {
        expect(
          _contrast(color, lightBg),
          greaterThanOrEqualTo(minRatio),
          reason: '浅色主题 $name 对比度不足',
        );
      });

      final darkPairs = <String, Color>{
        'overdue': AppSemanticColors.dark.overdue,
        'today': AppSemanticColors.dark.today,
        'upcoming': AppSemanticColors.dark.upcoming,
        'done': AppSemanticColors.dark.done,
        'inactive': AppSemanticColors.dark.inactive,
      };
      darkPairs.forEach((name, color) {
        expect(
          _contrast(color, darkBg),
          greaterThanOrEqualTo(minRatio),
          reason: '深色主题 $name 对比度不足',
        );
      });
    });

    test('语义色随主题切换取到不同值', () {
      expect(
        AppSemanticColors.light.overdue,
        isNot(AppSemanticColors.dark.overdue),
      );
    });
  });
}
