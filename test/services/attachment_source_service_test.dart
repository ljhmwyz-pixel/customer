import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/services/attachment_source_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test.customer/attachments');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _FakeImagePicker imagePicker;
  late AttachmentSourceService service;

  setUp(() {
    imagePicker = _FakeImagePicker();
    service = AttachmentSourceService(
      imagePicker: imagePicker,
      channel: channel,
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('图片来源', () {
    test('相机成功时返回实际文件元数据', () async {
      imagePicker.result = const AttachmentSourceFile(
        sourcePath: '/cache/camera.jpg',
        originalName: 'camera.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1234,
      );

      final result = await service.pickFromCamera();

      expect(imagePicker.lastSource, AttachmentImageSource.camera);
      expect(result.status, AttachmentSourceStatus.selected);
      expect(result.file, imagePicker.result);
    });

    test('相册取消时返回 cancelled', () async {
      final result = await service.pickFromGallery();

      expect(imagePicker.lastSource, AttachmentImageSource.gallery);
      expect(result.status, AttachmentSourceStatus.cancelled);
      expect(result.file, isNull);
    });

    test('图片插件失败时返回稳定失败状态', () async {
      imagePicker.error = PlatformException(code: 'picker_failed');

      final result = await service.pickFromCamera();

      expect(result.status, AttachmentSourceStatus.failed);
    });
  });

  group('系统文件来源', () {
    test('成功时解析原生返回值', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'pickFile');
        return <String, Object?>{
          'sourcePath': '/cache/attachment-1.tmp',
          'originalName': '报价单.pdf',
          'mimeType': 'application/pdf',
          'sizeBytes': 2048,
        };
      });

      final result = await service.pickFromFiles();

      expect(result.status, AttachmentSourceStatus.selected);
      expect(result.file?.sourcePath, '/cache/attachment-1.tmp');
      expect(result.file?.originalName, '报价单.pdf');
      expect(result.file?.mimeType, 'application/pdf');
      expect(result.file?.sizeBytes, 2048);
    });

    test('用户取消时返回 cancelled', () async {
      messenger.setMockMethodCallHandler(channel, (_) async => null);

      final result = await service.pickFromFiles();

      expect(result.status, AttachmentSourceStatus.cancelled);
    });

    test('原生返回畸形数据时返回 invalidData', () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        return <String, Object?>{
          'sourcePath': '',
          'originalName': 'bad.pdf',
          'mimeType': 'application/pdf',
          'sizeBytes': -1,
        };
      });

      final result = await service.pickFromFiles();

      expect(result.status, AttachmentSourceStatus.invalidData);
      expect(result.file, isNull);
    });

    test('channel handler 不可用时返回 unavailable', () async {
      final result = await service.pickFromFiles();

      expect(result.status, AttachmentSourceStatus.unavailable);
    });

    test('原生平台失败时返回 failed', () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'read_failed');
      });

      final result = await service.pickFromFiles();

      expect(result.status, AttachmentSourceStatus.failed);
    });
  });
}

class _FakeImagePicker implements AttachmentImagePicker {
  AttachmentImageSource? lastSource;
  AttachmentSourceFile? result;
  Object? error;

  @override
  Future<AttachmentSourceFile?> pick(AttachmentImageSource source) async {
    lastSource = source;
    if (error case final error?) throw error;
    return result;
  }
}
