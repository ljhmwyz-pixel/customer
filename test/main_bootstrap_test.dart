import 'package:customer/data/database.dart';
import 'package:customer/main.dart' as app;
import 'package:customer/services/attachment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'background bootstrap isolates reminder failure from attachment cleanup',
    () async {
      final cleaner = _FakeCleaner();

      await expectLater(
        app.bootstrapBackgroundServices(
          ProviderContainer(),
          reminderBootstrap: () =>
              Future<void>.error(StateError('alarm failed')),
          cleaner: cleaner,
        ),
        completes,
      );

      expect(cleaner.retryCalls, 1);
    },
  );
}

class _FakeCleaner implements AttachmentGraphCleaner {
  int retryCalls = 0;

  @override
  Future<AttachmentCleanupReport> deleteGraph({
    required Future<Iterable<AttachmentRow>> Function() loadAttachments,
    required Future<void> Function() deleteDatabaseGraph,
  }) async => const AttachmentCleanupReport();

  @override
  Future<AttachmentCleanupReport> retryOrphanCleanup() async {
    retryCalls++;
    return const AttachmentCleanupReport();
  }
}
