import 'package:flutter/material.dart';

import 'tokens.dart';

/// 业务语义色的取值入口。
///
/// 语义色不参与 ColorScheme 推导，因为「逾期是红的」这件事不能随主色变化。
/// 但明暗背景需要不同明度才能保证可读，所以由这里按当前主题选择。
/// 页面代码统一用 `AppSemanticColors.of(context).overdue`，不直接读 AppTokens。
class AppSemanticColors {
  const AppSemanticColors({
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.done,
    required this.inactive,
  });

  /// 逾期未跟进
  final Color overdue;

  /// 今日待跟进
  final Color today;

  /// 未来待跟进
  final Color upcoming;

  /// 已完成
  final Color done;

  /// 已流失、停用
  final Color inactive;

  static const AppSemanticColors light = AppSemanticColors(
    overdue: AppTokens.overdue,
    today: AppTokens.today,
    upcoming: AppTokens.upcoming,
    done: AppTokens.done,
    inactive: AppTokens.inactive,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    overdue: AppTokens.overdueDark,
    today: AppTokens.todayDark,
    upcoming: AppTokens.upcomingDark,
    done: AppTokens.doneDark,
    inactive: AppTokens.inactiveDark,
  );

  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
