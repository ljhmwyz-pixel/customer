import 'package:customer/services/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('编解码', () {
    test('往返一致', () {
      const payload = NotificationPayload(planId: 12, customerId: 34);
      final decoded = NotificationPayload.decode(payload.encode());

      expect(decoded, payload);
      expect(decoded?.planId, 12);
      expect(decoded?.customerId, 34);
    });

    test('编码格式是 planId:customerId', () {
      expect(
        const NotificationPayload(planId: 7, customerId: 8).encode(),
        '7:8',
      );
    });
  });

  group('解析容错', () {
    // payload 由系统跨进程传回，应用更新后可能拿到旧格式。
    // 这些用例全部要求返回 null 而不是抛异常：抛了就等于点通知直接崩。
    test('null 与空串返回 null', () {
      expect(NotificationPayload.decode(null), isNull);
      expect(NotificationPayload.decode(''), isNull);
    });

    test('分段数不对返回 null', () {
      expect(NotificationPayload.decode('12'), isNull);
      expect(NotificationPayload.decode('1:2:3'), isNull);
    });

    test('非数字返回 null', () {
      expect(NotificationPayload.decode('a:2'), isNull);
      expect(NotificationPayload.decode('1:b'), isNull);
      expect(NotificationPayload.decode(':'), isNull);
    });

    test('负数能正常解析', () {
      // 数据库自增 id 不会是负数，但解析层不该自己加业务判断，
      // 越界的 id 查不到记录，由调用方处理。
      final decoded = NotificationPayload.decode('-1:-2');
      expect(decoded?.planId, -1);
      expect(decoded?.customerId, -2);
    });
  });

  test('动作 id 不能随意改动', () {
    // 这两个字符串会被写进已排期的通知里跨进程传递。改了之后，
    // 用户设备上此前排好的通知按钮会失效且不报错。
    expect(NotificationActions.complete, 'plan_complete');
    expect(NotificationActions.postpone, 'plan_postpone');
  });
}
