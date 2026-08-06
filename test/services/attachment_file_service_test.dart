import 'dart:io';
import 'dart:typed_data';

import 'package:customer/services/attachment_file_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory sandbox;
  late Directory appDirectory;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('attachment-file-test-');
    appDirectory = await Directory('${sandbox.path}/app').create();
  });

  tearDown(() async {
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  Future<File> source(String name, List<int> bytes) async {
    final file = File('${sandbox.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  test('普通文件按年月保存并逐字节复制，返回真实元数据', () async {
    final bytes = List<int>.generate(257, (index) => index % 251);
    final input = await source('报价单.pdf', bytes);
    final service = AttachmentFileService(
      appDirectory: appDirectory,
      clock: () => DateTime(2026, 8, 6),
      idGenerator: () => 'file-001',
    );

    final stored = await service.store(
      source: input,
      originalName: '报价单.pdf',
      mimeType: 'application/pdf',
    );

    expect(stored.relativePath, 'attachments/2026/08/file-001.pdf');
    expect(stored.originalName, '报价单.pdf');
    expect(stored.mimeType, 'application/pdf');
    expect(stored.sizeBytes, bytes.length);
    expect(await File(stored.absolutePath).readAsBytes(), bytes);
    expect(await service.exists(stored.relativePath), isTrue);
    expect(
      await service.absolutePath(stored.relativePath),
      stored.absolutePath,
    );
  });

  test('重复 ID 不覆盖已有文件', () async {
    final firstSource = await source('first.txt', [1, 2, 3]);
    final secondSource = await source('second.txt', [4, 5, 6]);
    final service = AttachmentFileService(
      appDirectory: appDirectory,
      clock: () => DateTime(2026, 8, 6),
      idGenerator: () => 'same-id',
    );

    final first = await service.store(
      source: firstSource,
      originalName: 'first.txt',
      mimeType: 'text/plain',
    );
    final second = await service.store(
      source: secondSource,
      originalName: 'second.txt',
      mimeType: 'text/plain',
    );

    expect(second.relativePath, isNot(first.relativePath));
    expect(await File(first.absolutePath).readAsBytes(), [1, 2, 3]);
    expect(await File(second.absolutePath).readAsBytes(), [4, 5, 6]);
  });

  test('JPEG 使用 1920 边界和自动方向修正，达标后停止质量阶梯', () async {
    final input = await source('photo.jpg', List<int>.filled(700000, 1));
    final processor = _RecordingImageProcessor(
      sizeForQuality: (quality) => quality == 85 ? 600000 : 490000,
    );
    final service = AttachmentFileService(
      appDirectory: appDirectory,
      imageProcessor: processor,
      clock: () => DateTime(2026, 8, 6),
      idGenerator: () => 'jpeg',
    );

    final stored = await service.store(
      source: input,
      originalName: '原图.JPG',
      mimeType: 'image/jpeg',
    );

    expect(processor.requests.map((request) => request.quality), [85, 75]);
    for (final request in processor.requests) {
      expect(request.minWidth, 1920);
      expect(request.minHeight, 1920);
      expect(request.autoCorrectionAngle, isTrue);
      expect(request.format, AttachmentImageFormat.jpeg);
      expect(request.sourcePath, input.path);
      expect(request.targetPath, isNot(input.path));
    }
    expect(stored.relativePath, 'attachments/2026/08/jpeg.jpg');
    expect(stored.mimeType, 'image/jpeg');
    expect(stored.sizeBytes, 490000);
  });

  test('JPEG 最低质量仍超限时保留最低质量结果和真实大小', () async {
    final input = await source('large.jpg', [1, 2, 3]);
    final processor = _RecordingImageProcessor(
      sizeForQuality: (quality) => 500000 + quality,
    );
    final service = AttachmentFileService(
      appDirectory: appDirectory,
      imageProcessor: processor,
      clock: () => DateTime(2026, 8, 6),
      idGenerator: () => 'large',
    );

    final stored = await service.store(
      source: input,
      originalName: 'large.jpg',
      mimeType: 'image/jpeg',
    );

    expect(processor.requests.map((request) => request.quality), [
      85,
      75,
      65,
      55,
      45,
      35,
    ]);
    expect(stored.sizeBytes, 500035);
  });

  test('图片处理异常时清理候选文件并回退复制原图', () async {
    final original = List<int>.generate(99, (index) => index);
    final input = await source('broken.webp', original);
    final processor = _RecordingImageProcessor(
      sizeForQuality: (_) => throw StateError('codec failed'),
    );
    final service = AttachmentFileService(
      appDirectory: appDirectory,
      imageProcessor: processor,
      clock: () => DateTime(2026, 8, 6),
      idGenerator: () => 'fallback',
    );

    final stored = await service.store(
      source: input,
      originalName: 'broken.webp',
      mimeType: 'image/webp',
    );

    expect(await File(stored.absolutePath).readAsBytes(), original);
    expect(stored.mimeType, 'image/webp');
    final files = await Directory(
      '${appDirectory.path}/attachments',
    ).list(recursive: true).where((entity) => entity is File).toList();
    expect(files, hasLength(1));
    expect(files.single.path, stored.absolutePath);
  });

  test('PNG、JPEG、WebP 的扩展名、MIME 和编码格式一致', () async {
    final cases = [
      (
        name: 'a.PNG',
        mime: 'image/png',
        extension: '.png',
        format: AttachmentImageFormat.png,
      ),
      (
        name: 'b.jpeg',
        mime: 'image/jpeg',
        extension: '.jpg',
        format: AttachmentImageFormat.jpeg,
      ),
      (
        name: 'c.webp',
        mime: 'image/webp',
        extension: '.webp',
        format: AttachmentImageFormat.webp,
      ),
    ];

    var id = 0;
    for (final testCase in cases) {
      final input = await source(testCase.name, [1, 2, 3]);
      final processor = _RecordingImageProcessor(sizeForQuality: (_) => 3);
      final service = AttachmentFileService(
        appDirectory: appDirectory,
        imageProcessor: processor,
        clock: () => DateTime(2026, 8, 6),
        idGenerator: () => 'format-${id++}',
      );

      final stored = await service.store(
        source: input,
        originalName: testCase.name,
        mimeType: testCase.mime,
      );

      expect(stored.relativePath, endsWith(testCase.extension));
      expect(stored.mimeType, testCase.mime);
      expect(processor.requests.single.format, testCase.format);
      if (testCase.format == AttachmentImageFormat.png) {
        expect(processor.requests.single.quality, 100);
      }
    }
  });

  test('删除结果稳定区分成功和文件不存在', () async {
    final input = await source('delete.txt', [1]);
    final service = AttachmentFileService(
      appDirectory: appDirectory,
      clock: () => DateTime(2026, 8, 6),
      idGenerator: () => 'delete',
    );
    final stored = await service.store(
      source: input,
      originalName: 'delete.txt',
      mimeType: 'text/plain',
    );

    expect(
      await service.delete(stored.relativePath),
      AttachmentFileDeleteResult.deleted,
    );
    expect(
      await service.delete(stored.relativePath),
      AttachmentFileDeleteResult.notFound,
    );
  });
}

class _RecordingImageProcessor implements AttachmentImageProcessor {
  _RecordingImageProcessor({required this.sizeForQuality});

  final int Function(int quality) sizeForQuality;
  final List<AttachmentImageRequest> requests = [];

  @override
  Future<void> process(AttachmentImageRequest request) async {
    requests.add(request);
    final size = sizeForQuality(request.quality);
    await File(request.targetPath).writeAsBytes(Uint8List(size), flush: true);
  }
}
