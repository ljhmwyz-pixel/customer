import 'package:path/path.dart' as p;

/// 附件路径的生成与解析。
///
/// 全部是纯函数，不读文件系统、不调 getApplicationDocumentsDirectory。
/// 这样应用目录变化后（重装、系统迁移、备份恢复到另一台设备）同一条数据库记录
/// 仍能解析出正确的绝对路径，只要传入当时的 appDir。
///
/// 数据库里只存 [relativeFor] 的返回值，绝不存绝对路径。
abstract final class AttachmentPath {
  /// 附件根目录名，位于应用文档目录下。
  static const String rootDirName = 'attachments';

  /// 生成一条新附件的相对路径。
  ///
  /// 按年月分子目录，避免单目录堆积上千文件后系统的目录操作变慢。
  /// [fileId] 应为唯一标识（如 uuid 或时间戳），[extension] 不带点。
  ///
  /// 返回形如 `attachments/2026/08/abc123.jpg`，一律用 `/` 分隔，
  /// 不受运行平台的路径分隔符影响，保证存进库的值跨平台一致。
  static String relativeFor({
    required DateTime at,
    required String fileId,
    required String extension,
  }) {
    final year = at.year.toString().padLeft(4, '0');
    final month = at.month.toString().padLeft(2, '0');
    final ext = extension.startsWith('.') ? extension.substring(1) : extension;
    return '$rootDirName/$year/$month/$fileId.$ext';
  }

  /// 把相对路径还原成当前设备上的绝对路径。
  ///
  /// [appDir] 为应用文档目录的绝对路径，由调用方在运行时取得。
  static String resolve({required String appDir, required String relativePath}) {
    if (p.isAbsolute(relativePath)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        '附件路径必须是相对路径，绝对路径在应用重装后会失效',
      );
    }
    // 用 posix 风格切分，因为库里存的一律是 `/` 分隔。
    final segments = p.posix.split(relativePath);
    return p.joinAll([appDir, ...segments]);
  }

  /// 相对路径所在目录的绝对路径，写文件前需要先建它。
  static String resolveDir({
    required String appDir,
    required String relativePath,
  }) => p.dirname(resolve(appDir: appDir, relativePath: relativePath));
}
