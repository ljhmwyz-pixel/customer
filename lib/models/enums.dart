/// 业务枚举。
///
/// 全部存字符串而非整数，这样导出的 JSON 能直接看懂，
/// 人工检视备份文件时不需要对照码表。
///
/// 每个枚举的 `fromDb` 遇到未知值直接抛异常，不做静默降级。
/// 库里出现非法枚举值意味着有 bug，兜底只会让问题更晚暴露。
library;

/// 数据库中存在非法枚举值。
class InvalidEnumValueException implements Exception {
  InvalidEnumValueException(this.enumName, this.value);

  final String enumName;
  final String value;

  @override
  String toString() =>
      'InvalidEnumValueException: "$value" 不是合法的 $enumName 值';
}

/// 客户阶段。五档固定，不做自定义。
enum CustomerStage {
  /// 潜在客户
  potential('potential', '潜在客户'),

  /// 已接触
  contacted('contacted', '已接触'),

  /// 意向明确
  intent('intent', '意向明确'),

  /// 已成交
  deal('deal', '已成交'),

  /// 已流失
  lost('lost', '已流失');

  const CustomerStage(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static CustomerStage fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw InvalidEnumValueException('CustomerStage', value),
  );

  /// 是否为终态。终态客户不参与「久未联系」提醒。
  bool get isClosed => this == deal || this == lost;
}

/// 客户分级。手动打标，用于列表排序权重。
enum CustomerGrade {
  a('a', 'A'),
  b('b', 'B'),
  c('c', 'C');

  const CustomerGrade(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static CustomerGrade fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw InvalidEnumValueException('CustomerGrade', value),
  );

  /// 排序权重，A 最高。用于 SQL 中的 CASE 表达式。
  int get weight => switch (this) {
    CustomerGrade.a => 3,
    CustomerGrade.b => 2,
    CustomerGrade.c => 1,
  };
}

/// 跟进方式。
enum FollowMethod {
  phone('phone', '电话'),
  wechat('wechat', '微信'),
  meeting('meeting', '面谈'),
  other('other', '其他');

  const FollowMethod(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static FollowMethod fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw InvalidEnumValueException('FollowMethod', value),
  );
}

/// 跟进计划状态。
///
/// 状态机：pending → notified → completed，或 pending → overdue。
/// 逾期定义为超过计划时间 24 小时未标记完成。
enum PlanStatus {
  /// 待提醒
  pending('pending', '待提醒'),

  /// 已提醒
  notified('notified', '已提醒'),

  /// 已完成
  completed('completed', '已完成'),

  /// 已逾期
  overdue('overdue', '已逾期');

  const PlanStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static PlanStatus fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw InvalidEnumValueException('PlanStatus', value),
  );

  /// 是否仍需要用户处理。已完成的计划不再出现在待办里。
  bool get isOpen => this != completed;
}

/// 订单状态。
///
/// 流转：pending → shipped → paid → completed，另设 cancelled 终态。
enum OrderStatus {
  /// 待确认
  pending('pending', '待确认'),

  /// 已发货
  shipped('shipped', '已发货'),

  /// 已收款
  paid('paid', '已收款'),

  /// 已完成
  completed('completed', '已完成'),

  /// 已取消
  cancelled('cancelled', '已取消');

  const OrderStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static OrderStatus fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw InvalidEnumValueException('OrderStatus', value),
  );

  /// 是否计入成交金额。已取消的订单不计入。
  bool get countsTowardRevenue => this != cancelled;
}
