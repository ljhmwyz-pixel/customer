import 'package:customer/data/database.dart';
import 'package:customer/main.dart' as app;
import 'package:customer/services/attachment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('启动清理调用一次孤儿重试', () async {
    final cleaner = _FakeCleaner();

    await app.bootstrapAttachmentCleanup(ProviderContainer(), cleaner: cleaner);

    expect(cleaner.retryCalls, 1);
  });

  test('启动清理失败不阻塞应用启动', () async {
    final cleaner = _FakeCleaner()..error = StateError('scan failed');

    await expectLater(
      app.bootstrapAttachmentCleanup(ProviderContainer(), cleaner: cleaner),
      completes,
    );
  });
}

class _FakeCleaner implements AttachmentGraphCleaner {
  int retryCalls = 0;
  Object? error;

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async => const AttachmentCleanupReport();

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async {
    retryCalls++;
    final currentError = error;
    if (currentError != null) throw currentError;
    return const AttachmentCleanupReport();
  }
}
