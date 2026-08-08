import 'package:flutter/material.dart';

/// 设计常量的唯一来源。
///
/// 页面代码只引用这里的常量，不写字面量数字。
/// 数值依据 docs/UI_GUIDELINES.md，改动需同步文档。
abstract final class AppTokens {
  // ── 主色种子 ──
  // 冷静的蓝绿色作为品牌强调色；大面积背景在 theme.dart 中保持中性。
  // 用 ColorScheme.fromSeed 推导出明暗两套完整色板。
  static const Color seedColor = Color(0xFF3F6B66);

  // ── 间距　只用 4 的倍数 ──
  /// 紧邻元素，如图标与文字之间
  static const double s4 = 4;

  /// 组内元素，如列表项之间
  static const double s8 = 8;

  /// 卡片内部 padding
  static const double s12 = 12;

  /// 页面左右边距、卡片间距
  static const double s16 = 16;

  /// 区块之间
  static const double s24 = 24;

  /// 页面顶部、大区块分隔
  static const double s32 = 32;

  // ── 圆角 ──
  /// 标记、徽章
  static const double r4 = 4;

  /// 卡片、按钮、输入框。卡片圆角不超过此值。
  static const double r8 = 8;

  /// 弹窗、底部抽屉
  static const double r12 = 12;

  // ── 字号　固定六档，不随视口缩放 ──
  /// 标记内文字
  static const double f10 = 10;

  /// 辅助信息、时间戳
  static const double f12 = 12;

  /// 次要信息、跟进内容
  static const double f14 = 14;

  /// 正文、客户名称
  static const double f16 = 16;

  /// 区块标题
  static const double f20 = 20;

  /// 页面主标题，每页最多一处
  static const double f24 = 24;

  // ── 字重　只用三档 ──
  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemibold = FontWeight.w600;

  // ── 业务语义色 ──
  // 不从主色推导，因为含义需要跨明暗主题保持稳定。
  // 每个语义有明暗两个值：色相保持一致以稳定含义，明度按背景调整以保证
  // 对比度。深色变体在近黑背景上的对比度均达到 WCAG AA（4.5:1）以上。
  // 页面代码不直接引用这些常量，通过 AppSemanticColors.of(context) 取值。
  /// 逾期
  static const Color overdue = Color(0xFFC62828);
  static const Color overdueDark = Color(0xFFFF8A80);

  /// 今日待办
  // 比常见的 0xFFE65100 更深：那个值在浅色 surface 上只有 3.6:1，不达 AA。
  static const Color today = Color(0xFFBF360C);
  static const Color todayDark = Color(0xFFFFB74D);

  /// 未来待办
  static const Color upcoming = Color(0xFF1565C0);
  static const Color upcomingDark = Color(0xFF82B1FF);

  /// 已完成
  static const Color done = Color(0xFF2E7D32);
  static const Color doneDark = Color(0xFF81C784);

  /// 已流失、停用
  static const Color inactive = Color(0xFF616161);
  static const Color inactiveDark = Color(0xFF9E9E9E);

  // ── 布局约束 ──
  /// 标准弹窗在常规手机上的最小宽度；窄屏由父级可用空间自动收缩
  static const double dialogMinWidth = 360;

  /// 标准弹窗在平板或宽屏上的最大宽度
  static const double dialogMaxWidth = 420;

  /// 最小触摸目标，所有可点击元素的实际点击区域不得小于此值
  static const double minTouchTarget = 48;

  /// 逾期项左侧竖条宽度
  static const double accentBarWidth = 3;

  /// 时间线竖线宽度
  static const double timelineLineWidth = 2;

  /// 时间线圆点直径
  static const double timelineDotSize = 8;

  /// 字距一律为 0
  static const double letterSpacing = 0;
}
