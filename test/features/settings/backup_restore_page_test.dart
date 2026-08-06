import 'dart:io';

import 'package:customer/services/backup_restore_providers.dart';
import 'package:customer/services/backup_restore_service.dart';
import 'package:customer/features/settings/backup_restore_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('页面打开不自动备份，明确点击后显示成功状态', (tester) async {
    final service = _FakeBackupRestoreActions();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [backupRestoreServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: BackupRestorePage()),
      ),
    );

    expect(service.backupCalls, 0);
    await tester.tap(find.text('备份并分享'));
    await tester.pumpAndSettle();

    expect(service.backupCalls, 1);
    expect(find.textContaining('客户跟进备份_20260806_101112.zip'), findsOneWidget);
    expect(find.textContaining('已生成'), findsOneWidget);
  });
}

class _FakeBackupRestoreActions implements BackupRestoreActions {
  int backupCalls = 0;

  @override
  Future<BackupResult> backupAndShare() async {
    backupCalls++;
    return const BackupResult(
      fileName: '客户跟进备份_20260806_101112.zip',
      sizeBytes: 2048,
    );
  }

  @override
  Future<void> stageRestore(File backup) async {}
}
