import 'package:customer/app.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/router.dart';
import 'package:customer/theme/semantic_colors.dart';
import 'package:customer/theme/theme.dart';
import 'package:customer/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'data/helpers.dart';

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

Finder _navigationDestination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _pumpApp(WidgetTester tester) async {
  router.go('/');
  final db = await openTestDb();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await db.close();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const CustomerApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<Rect> _showShortDialogAt(
  WidgetTester tester, {
  required double viewportWidth,
}) async {
  await tester.binding.setSurfaceSize(Size(viewportWidth, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认'),
                  content: const Text('确定吗？', key: Key('short-dialog-content')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ),
              child: const Text('打开弹窗'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('打开弹窗'));
  await tester.pumpAndSettle();
  final dialogSurface = find
      .ancestor(
        of: find.byKey(const Key('short-dialog-content')),
        matching: find.byType(Material),
      )
      .last;
  return tester.getRect(dialogSurface);
}

void main() {
  group('应用骨架', () {
    testWidgets('四个 Tab 均可切换且不崩溃', (tester) async {
      await _pumpApp(tester);

      // 首页
      expect(find.text('今日'), findsWidgets);

      for (final label in ['客户', '漏斗', '我的']) {
        await tester.tap(_navigationDestination(label));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(label), findsWidgets);
      }

      // 回到首页
      await tester.tap(_navigationDestination('今日'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('空状态在客户页可见', (tester) async {
      await _pumpApp(tester);

      await tester.tap(_navigationDestination('客户'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

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

    test('明暗主题使用相同的弹窗宽度约束', () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        expect(
          theme.dialogTheme.constraints?.minWidth,
          AppTokens.dialogMinWidth,
        );
        expect(
          theme.dialogTheme.constraints?.maxWidth,
          AppTokens.dialogMaxWidth,
        );
      }
    });

    testWidgets('常规屏幕上的短弹窗不会收缩成窄条', (tester) async {
      final rect = await _showShortDialogAt(tester, viewportWidth: 412);

      expect(rect.width, greaterThanOrEqualTo(AppTokens.dialogMinWidth));
      expect(rect.width, lessThanOrEqualTo(AppTokens.dialogMaxWidth));
      expect(tester.takeException(), isNull);
    });

    testWidgets('窄屏弹窗自动收缩并保留安全边距', (tester) async {
      final rect = await _showShortDialogAt(tester, viewportWidth: 320);

      expect(rect.width, closeTo(288, 0.1));
      expect(rect.left, greaterThanOrEqualTo(AppTokens.s16));
      expect(320 - rect.right, greaterThanOrEqualTo(AppTokens.s16));
      expect(tester.takeException(), isNull);
    });
  });
}
