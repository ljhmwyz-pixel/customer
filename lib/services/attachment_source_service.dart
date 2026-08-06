import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum AttachmentImageSource { camera, gallery }

enum AttachmentSourceStatus {
  selected,
  cancelled,
  invalidData,
  unavailable,
  failed,
}

class AttachmentSourceFile {
  const AttachmentSourceFile({
    required this.sourcePath,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String sourcePath;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
}

class AttachmentSourceResult {
  const AttachmentSourceResult._(this.status, [this.file]);

  const AttachmentSourceResult.selected(AttachmentSourceFile file)
    : this._(AttachmentSourceStatus.selected, file);

  const AttachmentSourceResult.cancelled()
    : this._(AttachmentSourceStatus.cancelled);

  const AttachmentSourceResult.invalidData()
    : this._(AttachmentSourceStatus.invalidData);

  const AttachmentSourceResult.unavailable()
    : this._(AttachmentSourceStatus.unavailable);

  const AttachmentSourceResult.failed() : this._(AttachmentSourceStatus.failed);

  final AttachmentSourceStatus status;
  final AttachmentSourceFile? file;
}

abstract interface class AttachmentImagePicker {
  Future<AttachmentSourceFile?> pick(AttachmentImageSource source);
}

class ImagePickerAttachmentAdapter implements AttachmentImagePicker {
  ImagePickerAttachmentAdapter({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<AttachmentSourceFile?> pick(AttachmentImageSource source) async {
    final file = await _picker.pickImage(
      source: source == AttachmentImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    if (file == null) return null;

    return AttachmentSourceFile(
      sourcePath: file.path,
      originalName: file.name,
      mimeType: file.mimeType ?? _imageMimeType(file.name),
      sizeBytes: await file.length(),
    );
  }

  static String _imageMimeType(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.png')) return 'image/png';
    if (lowerName.endsWith('.webp')) return 'image/webp';
    if (lowerName.endsWith('.gif')) return 'image/gif';
    if (lowerName.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}

class AttachmentSourceService {
  AttachmentSourceService({
    AttachmentImagePicker? imagePicker,
    MethodChannel? channel,
  }) : _imagePicker = imagePicker ?? ImagePickerAttachmentAdapter(),
       _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.snyder.customer/attachments';

  final AttachmentImagePicker _imagePicker;
  final MethodChannel _channel;

  Future<AttachmentSourceResult> pickFromCamera() =>
      _pickImage(AttachmentImageSource.camera);

  Future<AttachmentSourceResult> pickFromGallery() =>
      _pickImage(AttachmentImageSource.gallery);

  Future<AttachmentSourceResult> _pickImage(
    AttachmentImageSource source,
  ) async {
    try {
      final file = await _imagePicker.pick(source);
      return file == null
          ? const AttachmentSourceResult.cancelled()
          : AttachmentSourceResult.selected(file);
    } catch (_) {
      return const AttachmentSourceResult.failed();
    }
  }

  Future<AttachmentSourceResult> pickFromFiles() async {
    try {
      final value = await _channel.invokeMethod<Object?>('pickFile');
      if (value == null) return const AttachmentSourceResult.cancelled();
      final file = _parseNativeFile(value);
      return file == null
          ? const AttachmentSourceResult.invalidData()
          : AttachmentSourceResult.selected(file);
    } on MissingPluginException {
      return const AttachmentSourceResult.unavailable();
    } on PlatformException {
      return const AttachmentSourceResult.failed();
    } catch (_) {
      return const AttachmentSourceResult.failed();
    }
  }

  static AttachmentSourceFile? _parseNativeFile(Object value) {
    if (value is! Map) return null;
    final sourcePath = value['sourcePath'];
    final originalName = value['originalName'];
    final mimeType = value['mimeType'];
    final sizeBytes = value['sizeBytes'];
    if (sourcePath is! String ||
        sourcePath.isEmpty ||
        originalName is! String ||
        originalName.isEmpty ||
        mimeType is! String ||
        mimeType.isEmpty ||
        sizeBytes is! int ||
        sizeBytes < 0) {
      return null;
    }
    return AttachmentSourceFile(
      sourcePath: sourcePath,
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );
  }
}
