import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 极简键值存储，落在应用支持目录下的一个 JSON 文件里。
///
/// 没有引入 shared_preferences：本项目的依赖版本被 flutter_test 的 meta 1.18.0
/// 压制得很紧（见 pubspec.yaml 注释），为存两三个布尔值去动依赖树不值当。
/// 需要存的量级也确实只有这些——业务数据全在 drift 里。
///
/// 全量读写整个文件。键数量是个位数，谈不上性能问题，
/// 换来的是不需要任何缓存一致性逻辑。
class AppPrefs {
  // 字段声明在下方而非用 initializing formal：_file 在首次解析路径后会被重新
  // 赋值缓存，写成 this._file 反而读不出这层意图。
  // ignore: prefer_initializing_formals
  AppPrefs({File? file}) : _file = file;

  /// 非 null 时优先使用，供测试注入临时目录下的文件。
  /// 首次解析路径后也缓存在这里，省掉每次读写都问一遍 path_provider。
  File? _file;

  Map<String, Object?>? _cache;

  static const String fileName = 'prefs.json';

  Future<File> _resolveFile() async {
    final existing = _file;
    if (existing != null) return existing;

    final dir = await getApplicationSupportDirectory();
    return _file = File(p.join(dir.path, fileName));
  }

  Future<Map<String, Object?>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final file = await _resolveFile();
    if (!file.existsSync()) return _cache = <String, Object?>{};

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) {
        return _cache = Map<String, Object?>.from(decoded);
      }
    } on FormatException catch (e) {
      // 文件被截断或手工改坏了。这里存的都是可再次询问的引导标记，
      // 丢掉的代价只是多问用户一次，比启动崩溃好得多。
      debugPrint('prefs.json 解析失败，按空配置处理：$e');
    }
    return _cache = <String, Object?>{};
  }

  Future<bool> getBool(String key, {bool fallback = false}) async {
    final data = await _load();
    final value = data[key];
    return value is bool ? value : fallback;
  }

  Future<void> setBool(String key, bool value) async {
    final data = await _load();
    data[key] = value;

    final file = await _resolveFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
  }

  /// 丢掉内存缓存，下次读取重新落盘取。测试用。
  @visibleForTesting
  void invalidate() => _cache = null;
}
