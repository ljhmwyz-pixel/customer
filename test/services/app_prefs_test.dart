import 'dart:io';

import 'package:customer/services/app_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late File file;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('prefs_test');
    file = File(p.join(tempDir.path, AppPrefs.fileName));
  });

  tearDown(() => tempDir.delete(recursive: true));

  test('写入后能读出来', () async {
    final prefs = AppPrefs(file: file);
    await prefs.setBool('a', true);

    expect(await prefs.getBool('a'), isTrue);
  });

  test('落盘后新实例仍能读到', () async {
    await AppPrefs(file: file).setBool('onboarded', true);

    // 换实例读，确认值真的进了文件而不是只在内存缓存里。
    // 权限引导标记必须跨进程存活，否则每次启动都会重新弹一遍。
    expect(await AppPrefs(file: file).getBool('onboarded'), isTrue);
  });

  test('未写过的键返回 fallback', () async {
    final prefs = AppPrefs(file: file);

    expect(await prefs.getBool('missing'), isFalse);
    expect(await prefs.getBool('missing', fallback: true), isTrue);
  });

  test('多个键互不覆盖', () async {
    final prefs = AppPrefs(file: file);
    await prefs.setBool('a', true);
    await prefs.setBool('b', false);
    await prefs.setBool('c', true);

    expect(await prefs.getBool('a'), isTrue);
    expect(await prefs.getBool('b'), isFalse);
    expect(await prefs.getBool('c'), isTrue);
  });

  test('文件内容损坏时按空配置处理，不抛异常', () async {
    // 存的都是可再问一次的引导标记，丢掉的代价只是多问一次，
    // 比启动崩掉好得多。这里验的是不崩。
    await file.writeAsString('{ 这不是 json');

    final prefs = AppPrefs(file: file);
    expect(await prefs.getBool('a'), isFalse);

    // 且损坏之后仍能正常写入
    await prefs.setBool('a', true);
    expect(await AppPrefs(file: file).getBool('a'), isTrue);
  });

  test('文件是合法 json 但不是对象时也按空配置处理', () async {
    await file.writeAsString('[1, 2, 3]');

    expect(await AppPrefs(file: file).getBool('a'), isFalse);
  });

  test('非布尔值的键返回 fallback 而不是崩', () async {
    await file.writeAsString('{"a": "yes"}');

    expect(await AppPrefs(file: file).getBool('a'), isFalse);
  });

  test('目录不存在时会自动创建', () async {
    final nested = File(p.join(tempDir.path, 'deep', 'dir', 'prefs.json'));
    await AppPrefs(file: nested).setBool('a', true);

    expect(nested.existsSync(), isTrue);
  });
}
