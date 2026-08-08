import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/main.dart' as app;
import 'package:customer/services/attachment_service.dart';
import 'package:customer/services/reminder_scheduler.dart';
import 'package:customer/services/service_providers.dart';
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

  test(
    'reminder bootstrap retries queued business tasks before reschedule',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final customerId = await db.customerDao.insertCustomer(name: '启动修复客户');
      final opportunityId = await db.opportunityDao.insertOpportunity(
        customerId: customerId,
        name: '启动修复项目',
      );
      await db.registrationDao.insertRegistration(
        opportunityId: opportunityId,
        expectedCompletedAt: DateTime.utc(2026, 9, 20),
      );
      await db.planDao.enqueueTaskReconciliation(
        opportunityId,
        error: StateError('previous failure'),
      );
      final scheduler = _FakeScheduler();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);

      await app.bootstrapReminders(container, now: DateTime.utc(2026, 8, 8));

      expect(await db.planDao.countTaskReconciliationJobs(), 0);
      expect(await db.planDao.listOf(customerId), hasLength(1));
      expect(scheduler.initCalls, 1);
      expect(scheduler.rescheduleCalls, 1);
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

class _FakeScheduler implements ReminderScheduler {
  int initCalls = 0;
  int rescheduleCalls = 0;

  @override
  Future<void> cancelForPlan(int planId) async {}

  @override
  Future<void> init() async => initCalls++;

  @override
  Future<List<int>> pendingIds() async => [];

  @override
  Future<int> rescheduleAll() async {
    rescheduleCalls++;
    return 0;
  }

  @override
  Future<void> scheduleForPlan(
    FollowPlanRow plan, {
    required String customerName,
  }) async {}
}
