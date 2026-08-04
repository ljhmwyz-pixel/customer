/// 通知 payload 的编解码。
///
/// payload 是通知与应用之间唯一的数据通道，点击通知时原样带回。
/// 用 `planId:customerId` 这种极简格式而不是 JSON：字段只有两个整数，
/// 上 JSON 解析没有收益，还多一份出错可能。
///
/// 解析失败一律返回 null 而不抛异常。payload 来自系统传回的字符串，
/// 应用更新后格式可能与旧通知不一致，抛异常会让点击通知直接崩溃。
class NotificationPayload {
  const NotificationPayload({required this.planId, required this.customerId});

  final int planId;
  final int customerId;

  String encode() => '$planId:$customerId';

  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split(':');
    if (parts.length != 2) return null;

    final planId = int.tryParse(parts[0]);
    final customerId = int.tryParse(parts[1]);
    if (planId == null || customerId == null) return null;

    return NotificationPayload(planId: planId, customerId: customerId);
  }

  @override
  String toString() => 'NotificationPayload($planId, $customerId)';

  @override
  bool operator ==(Object other) =>
      other is NotificationPayload &&
      other.planId == planId &&
      other.customerId == customerId;

  @override
  int get hashCode => Object.hash(planId, customerId);
}

/// 通知动作的 id。这些字符串会跨进程传递，改动等于破坏兼容。
abstract final class NotificationActions {
  /// 「已完成」
  static const String complete = 'plan_complete';

  /// 「推迟一天」
  static const String postpone = 'plan_postpone';
}
