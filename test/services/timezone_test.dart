import 'package:customer/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('时区反查', () {
    // 这个函数错了的后果是所有提醒都排到错误的时刻，而且在开发机上不一定复现，
    // 所以必须单独验。
    test('本机时区能解析出来，不会退回 UTC 兜底', () {
      final location = resolveLocalLocation();
      final now = DateTime.now();

      expect(
        location.timeZone(now.millisecondsSinceEpoch).offset,
        now.timeZoneOffset,
        reason: '解析出的时区偏移必须与系统一致',
      );
    });

    test('UTC+8 优先命中 Asia/Shanghai 而非同偏移的冷门位置', () {
      // UTC+8 能匹配到 Asia/Makassar、Australia/Perth 等几十个位置，
      // 计算上等价但日志里出现它们会误导排障，所以要保证优先级生效。
      // 目标设备在中国大陆，本机时区也是 UTC+8，可以直接断言。
      if (DateTime.now().timeZoneOffset != const Duration(hours: 8)) {
        return;
      }
      expect(resolveLocalLocation().name, 'Asia/Shanghai');
    });

    test('解析结果可直接用于 TZDateTime 换算', () {
      final location = resolveLocalLocation();
      final utc = DateTime.utc(2026, 8, 4, 1, 30);
      final converted = tz.TZDateTime.from(utc, location);

      // 换算不能改变绝对时刻，只改变展示用的墙上时间。
      expect(
        converted.millisecondsSinceEpoch,
        utc.millisecondsSinceEpoch,
        reason: 'TZDateTime.from 不该移动时间点',
      );
    });
  });
}
