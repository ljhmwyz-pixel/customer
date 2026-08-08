import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database_provider.dart';
import 'services/attachment_service.dart';
import 'services/attachment_service_providers.dart';
import 'services/service_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 用一个容器提前把服务准备好，再把同一个容器交给 ProviderScope，
  // 这样启动期的初始化和界面用的是同一批实例，不会各开一份数据库连接。
  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(container: container, child: const CustomerApp()),
  );

  // 首屏先展示；提醒重排和附件扫描失败或耗时都不应卡住应用启动。
  unawaited(bootstrapBackgroundServices(container));
}

Future<void> bootstrapBackgroundServices(
  ProviderContainer container, {
  Future<void> Function()? reminderBootstrap,
  AttachmentGraphCleaner? cleaner,
}) async {
  try {
    await (reminderBootstrap ?? () => _bootstrapReminders(container))();
  } catch (e, stack) {
    debugPrint('提醒初始化失败：$e\n$stack');
  }
  await bootstrapAttachmentCleanup(container, cleaner: cleaner);
}

Future<void> bootstrapAttachmentCleanup(
  ProviderContainer container, {
  AttachmentGraphCleaner? cleaner,
}) async {
  try {
    final AttachmentGraphCleaner target =
        cleaner ?? container.read(attachmentServiceProvider);
    final report = await target.retryOrphanCleanup();
    if (report.hasFailures) {
      debugPrint('附件孤儿清理失败，待下次启动重试：${report.failedPaths}');
    }
  } catch (e, stack) {
    debugPrint('附件孤儿清理初始化失败：$e\n$stack');
  }
}

/// 启动时恢复提醒。
///
/// 每次启动都全量重排，不判断是否必要。AlarmManager 的闹钟在开机、覆盖安装、
/// 应用被强杀清理后都可能丢失，而判断「这次到底丢没丢」比直接重排复杂得多，
/// 代价只是几十次系统调用。
///
/// 失败不阻塞启动：提醒排不上是功能受损，但应用本身还能正常记录客户。
/// 把异常吞在这里而不是让 main 崩掉。
Future<void> _bootstrapReminders(ProviderContainer container) async {
  try {
    final scheduler = container.read(reminderSchedulerProvider);
    await scheduler.init();

    // 逾期状态是派生的，由启动时批量刷新。放在重排之前：
    // 已逾期的计划不该再排闹钟，先刷状态能让 listUpcoming 过滤掉它们。
    final db = container.read(databaseProvider);
    await db.planDao.markOverdue(now: DateTime.now());

    await scheduler.rescheduleAll();
  } catch (e, stack) {
    debugPrint('提醒初始化失败：$e\n$stack');
  }
}
