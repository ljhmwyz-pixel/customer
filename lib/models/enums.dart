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
  String toString() => 'InvalidEnumValueException: "$value" 不是合法的 $enumName 值';
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
  c('c', 'C'),
  d('d', 'D');

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
    CustomerGrade.d => 0,
  };
}

/// 外贸项目销售阶段。项目而非客户承载阶段，允许同一客户同时推进多个机会。
enum OpportunityStage {
  newLead('new_lead', '新线索'),
  contactEstablished('contact_established', '已建立联系'),
  needsConfirmed('needs_confirmed', '需求确认'),
  quoted('quoted', '已报价'),
  priceNegotiation('price_negotiation', '价格谈判'),
  samplePreparing('sample_preparing', '样品准备'),
  sampleTesting('sample_testing', '样品测试'),
  registrationInProgress('registration_in_progress', '注册进行中'),
  tenderPreparing('tender_preparing', '招标准备'),
  awaitingOrder('awaiting_order', '等待订单'),
  won('won', '已成交'),
  paused('paused', '暂停'),
  lost('lost', '流失');

  const OpportunityStage(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static OpportunityStage fromDb(String value) => values.firstWhere(
    (stage) => stage.dbValue == value,
    orElse: () => throw InvalidEnumValueException('OpportunityStage', value),
  );

  static OpportunityStage fromLegacyCustomerStage(CustomerStage stage) =>
      switch (stage) {
        CustomerStage.potential => newLead,
        CustomerStage.contacted => contactEstablished,
        CustomerStage.intent => needsConfirmed,
        CustomerStage.deal => won,
        CustomerStage.lost => lost,
      };
}

/// 项目投入状态。与销售阶段分开，避免“暂停”同时承担业务阶段和投入决策。
enum OpportunityStatus {
  active('active', '活跃'),
  lowFrequency('low_frequency', '低频维护'),
  paused('paused', '暂停'),
  won('won', '已成交'),
  closed('closed', '已关闭');

  const OpportunityStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static OpportunityStatus fromDb(String value) => values.firstWhere(
    (status) => status.dbValue == value,
    orElse: () => throw InvalidEnumValueException('OpportunityStatus', value),
  );

  bool get isClosed =>
      this == OpportunityStatus.paused ||
      this == OpportunityStatus.won ||
      this == OpportunityStatus.closed;
}

/// 项目重要程度。首页任务排序使用，数值越大优先级越高。
enum OpportunityImportance {
  high('high', '高', 2),
  normal('normal', '普通', 1),
  low('low', '低', 0);

  const OpportunityImportance(this.dbValue, this.label, this.weight);

  final String dbValue;
  final String label;
  final int weight;

  static OpportunityImportance fromDb(String value) => values.firstWhere(
    (importance) => importance.dbValue == value,
    orElse: () =>
        throw InvalidEnumValueException('OpportunityImportance', value),
  );
}

enum SampleStatus {
  preparing('preparing', '准备中'),
  sent('sent', '已寄出'),
  delivered('delivered', '已签收'),
  testing('testing', '测试中'),
  passed('passed', '测试通过'),
  failed('failed', '测试未通过'),
  cancelled('cancelled', '已取消');

  const SampleStatus(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static SampleStatus fromDb(String value) => values.firstWhere(
    (status) => status.dbValue == value,
    orElse: () => throw InvalidEnumValueException('SampleStatus', value),
  );
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
/// 状态机：pending → notified → completed，或 pending → overdue；
/// 任一开放状态都可以取消，completed/cancelled 为终态。
/// 逾期定义为超过计划时间 24 小时未标记完成。
enum PlanStatus {
  /// 待提醒
  pending('pending', '待提醒'),

  /// 已提醒
  notified('notified', '已提醒'),

  /// 已完成
  completed('completed', '已完成'),

  /// 已逾期
  overdue('overdue', '已逾期'),

  /// 已取消
  cancelled('cancelled', '已取消');

  const PlanStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static PlanStatus fromDb(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw InvalidEnumValueException('PlanStatus', value),
  );

  /// 是否仍需要用户处理。完成和取消的计划不再出现在待办里。
  bool get isOpen => this != completed && this != cancelled;
}

/// 任务的业务来源。sourceId 与 ruleKey 共同定位自动生成规则。
enum TaskSourceType {
  legacy('legacy', '历史任务'),
  manual('manual', '手工创建'),
  followup('followup', '跟进记录'),
  quote('quote', '报价'),
  sample('sample', '样品'),
  registration('registration', '注册'),
  tender('tender', '招标'),
  order('order', '订单'),
  repurchase('repurchase', '复购');

  const TaskSourceType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static TaskSourceType fromDb(String value) => values.firstWhere(
    (source) => source.dbValue == value,
    orElse: () => throw InvalidEnumValueException('TaskSourceType', value),
  );
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

  /// 是否计入成交金额。只有完成的订单形成最终成交额。
  bool get countsTowardRevenue => this == completed;

  /// 正常流程中的下一状态。终态没有下一状态。
  OrderStatus? get nextStatus => switch (this) {
    pending => shipped,
    shipped => paid,
    paid => completed,
    completed || cancelled => null,
  };

  /// 是否允许从当前状态流转到 [target]。
  bool canTransitionTo(OrderStatus target) {
    if (target == nextStatus) return true;
    return target == cancelled &&
        (this == pending || this == shipped || this == paid);
  }
}
