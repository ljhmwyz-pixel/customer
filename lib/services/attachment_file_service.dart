// Public named parameters intentionally differ from private backing fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:path/path.dart' as p;

import '../data/attachment_path.dart';

enum AttachmentImageFormat { jpeg, png, webp }

class AttachmentImageRequest {
  const AttachmentImageRequest({
    required this.sourcePath,
    required this.targetPath,
    required this.minWidth,
    required this.minHeight,
    required this.quality,
    required this.autoCorrectionAngle,
    required this.format,
  });

  final String sourcePath;
  final String targetPath;
  final int minWidth;
  final int minHeight;
  final int quality;
  final bool autoCorrectionAngle;
  final AttachmentImageFormat format;
}

abstract interface class AttachmentImageProcessor {
  Future<void> process(AttachmentImageRequest request);
}

class StoredAttachmentFile {
  const StoredAttachmentFile({
    required this.relativePath,
    required this.absolutePath,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String relativePath;
  final String absolutePath;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
}

enum AttachmentFileDeleteResult { deleted, notFound, failed }

abstract interface class AttachmentFileStore {
  Future<StoredAttachmentFile> store({
    required File source,
    required String originalName,
    required String mimeType,
  });

  Future<bool> exists(String relativePath);

  Future<AttachmentFileDeleteResult> delete(String relativePath);

  Future<Set<String>> listStoredPaths();

  Future<String> absolutePath(String relativePath);
}

class AttachmentFileService implements AttachmentFileStore {
  AttachmentFileService({
    Directory? appDirectory,
    Future<Directory> Function()? appDirectoryLoader,
    AttachmentImageProcessor? imageProcessor,
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : _appDirectory = appDirectory,
       _appDirectoryLoader = appDirectoryLoader,
       _imageProcessor = imageProcessor,
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? _defaultId;

  static const _maxCompressedImageBytes = 500000;
  static const _jpegWebpQualities = [85, 75, 65, 55, 45, 35];

  final Directory? _appDirectory;
  final Future<Directory> Function()? _appDirectoryLoader;
  final AttachmentImageProcessor? _imageProcessor;
  final DateTime Function() _clock;
  final String Function() _idGenerator;
  Future<Directory>? _resolvedAppDirectory;

  static String _defaultId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<StoredAttachmentFile> store({
    required File source,
    required String originalName,
    required String mimeType,
  }) async {
    final image = _imageType(mimeType);
    final extension = image?.extension ?? _extensionOf(originalName);
    final outputMimeType = image?.mimeType ?? mimeType;
    final appDirectory = await _loadAppDirectory();
    final relativePath = await _unusedRelativePath(
      appDirectory: appDirectory,
      extension: extension,
    );
    final targetPath = AttachmentPath.resolve(
      appDir: appDirectory.path,
      relativePath: relativePath,
    );
    final target = File(targetPath);
    await target.parent.create(recursive: true);

    if (image != null && _imageProcessor != null) {
      await _processImageOrCopy(source: source, target: target, image: image);
    } else {
      await source.copy(target.path);
    }

    return StoredAttachmentFile(
      relativePath: relativePath,
      absolutePath: target.path,
      originalName: originalName,
      mimeType: outputMimeType,
      sizeBytes: await target.length(),
    );
  }

  @override
  Future<bool> exists(String relativePath) async =>
      File(await absolutePath(relativePath)).exists();

  @override
  Future<AttachmentFileDeleteResult> delete(String relativePath) async {
    try {
      final file = File(await absolutePath(relativePath));
      if (!await file.exists()) return AttachmentFileDeleteResult.notFound;
      await file.delete();
      return AttachmentFileDeleteResult.deleted;
    } on FileSystemException {
      return AttachmentFileDeleteResult.failed;
    }
  }

  @override
  Future<Set<String>> listStoredPaths() async {
    final appDirectory = await _loadAppDirectory();
    final root = Directory(p.join(appDirectory.path, 'attachments'));
    if (!await root.exists()) return {};

    final paths = <String>{};
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relativePath = p.join(
        'attachments',
        p.relative(entity.path, from: root.path),
      );
      paths.add(AttachmentPath.normalizeRelative(relativePath));
    }
    return paths;
  }

  @override
  Future<String> absolutePath(String relativePath) async {
    final appDirectory = await _loadAppDirectory();
    return AttachmentPath.resolve(
      appDir: appDirectory.path,
      relativePath: relativePath,
    );
  }

  Future<Directory> _loadAppDirectory() {
    final directory = _appDirectory;
    if (directory != null) return Future.value(directory);
    final loader = _appDirectoryLoader;
    if (loader == null) {
      throw StateError('必须提供 appDirectory 或 appDirectoryLoader');
    }
    return _resolvedAppDirectory ??= loader();
  }

  Future<String> _unusedRelativePath({
    required Directory appDirectory,
    required String extension,
  }) async {
    final now = _clock();
    final id = _idGenerator();
    var suffix = 0;
    while (true) {
      final candidateId = suffix == 0 ? id : '$id-$suffix';
      final relativePath = AttachmentPath.relativeFor(
        at: now,
        fileId: candidateId,
        extension: extension,
      );
      final candidate = File(
        AttachmentPath.resolve(
          appDir: appDirectory.path,
          relativePath: relativePath,
        ),
      );
      if (!await candidate.exists()) return relativePath;
      suffix++;
    }
  }

  Future<void> _processImageOrCopy({
    required File source,
    required File target,
    required _ImageType image,
  }) async {
    final qualities = image.format == AttachmentImageFormat.png
        ? const [100]
        : _jpegWebpQualities;
    try {
      for (final quality in qualities) {
        if (await target.exists()) await target.delete();
        await _imageProcessor!.process(
          AttachmentImageRequest(
            sourcePath: source.path,
            targetPath: target.path,
            minWidth: 1920,
            minHeight: 1920,
            quality: quality,
            autoCorrectionAngle: true,
            format: image.format,
          ),
        );
        final size = await target.length();
        if (size <= _maxCompressedImageBytes) return;
      }
    } catch (_) {
      if (await target.exists()) await target.delete();
      await source.copy(target.path);
    }
  }

  static String _extensionOf(String originalName) {
    final extension = p.extension(originalName).toLowerCase();
    return extension.length > 1 ? extension.substring(1) : 'bin';
  }

  static _ImageType? _imageType(String mimeType) =>
      switch (mimeType.toLowerCase()) {
        'image/jpeg' || 'image/jpg' => const _ImageType(
          extension: 'jpg',
          mimeType: 'image/jpeg',
          format: AttachmentImageFormat.jpeg,
        ),
        'image/png' => const _ImageType(
          extension: 'png',
          mimeType: 'image/png',
          format: AttachmentImageFormat.png,
        ),
        'image/webp' => const _ImageType(
          extension: 'webp',
          mimeType: 'image/webp',
          format: AttachmentImageFormat.webp,
        ),
        _ => null,
      };
}

class _ImageType {
  const _ImageType({
    required this.extension,
    required this.mimeType,
    required this.format,
  });

  final String extension;
  final String mimeType;
  final AttachmentImageFormat format;
}
