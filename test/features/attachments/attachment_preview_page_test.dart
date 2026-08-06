import 'dart:async';
import 'dart:io';

import 'package:customer/data/database.dart';
import 'package:customer/features/attachments/attachment_preview_page.dart';
import 'package:customer/features/attachments/attachment_providers.dart';
import 'package:customer/router.dart' as app_router;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  Future<void> pumpPreview(
    WidgetTester tester, {
    required Future<AttachmentPreviewState> Function(Ref ref, int id) builder,
  }) => tester.pumpWidget(
    ProviderScope(
      overrides: [attachmentPreviewProvider.overrideWith(builder)],
      child: const MaterialApp(home: AttachmentPreviewPage(attachmentId: 7)),
    ),
  );

  testWidgets('预览状态加载中显示进度', (tester) async {
    final pending = Completer<AttachmentPreviewState>();

    await pumpPreview(tester, builder: (ref, id) => pending.future);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(
      const AttachmentPreviewState(
        status: AttachmentPreviewStatus.recordNotFound,
      ),
    );
    await tester.pump();
  });

  testWidgets('图片就绪时使用 PhotoView 展示并显示原始文件名', (tester) async {
    final image = File(
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
    ).absolute;
    final row = _row(originalName: '展会现场.png');

    await pumpPreview(
      tester,
      builder: (ref, id) async => AttachmentPreviewState(
        status: AttachmentPreviewStatus.ready,
        row: row,
        absolutePath: image.path,
      ),
    );
    await tester.pump();

    expect(find.text('展会现场.png'), findsOneWidget);
    expect(find.byType(PhotoView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final errorCase in const [
    (AttachmentPreviewStatus.recordNotFound, '附件记录不存在'),
    (AttachmentPreviewStatus.fileNotFound, '文件已丢失'),
    (AttachmentPreviewStatus.notImage, '此附件不是图片'),
    (AttachmentPreviewStatus.failed, '图片预览失败，请重试'),
  ]) {
    testWidgets('${errorCase.$1.name} 显示稳定反馈且不创建图片', (tester) async {
      await pumpPreview(
        tester,
        builder: (ref, id) async => AttachmentPreviewState(
          status: errorCase.$1,
          row: errorCase.$1 == AttachmentPreviewStatus.recordNotFound
              ? null
              : _row(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(errorCase.$2), findsOneWidget);
      expect(find.byType(PhotoView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  group('attachment preview app route', () {
    testWidgets('正整数 id 构建预览页并开始对应查询', (tester) async {
      final queriedIds = <int>[];
      app_router.router.go('/attachments/preview/7');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        app_router.router.go('/');
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attachmentPreviewProvider.overrideWith((ref, id) async {
              queriedIds.add(id);
              return const AttachmentPreviewState(
                status: AttachmentPreviewStatus.recordNotFound,
              );
            }),
          ],
          child: MaterialApp.router(routerConfig: app_router.router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AttachmentPreviewPage), findsOneWidget);
      expect(queriedIds, [7]);
    });

    for (final path in const [
      '/attachments/preview/abc',
      '/attachments/preview/0',
      '/attachments/preview/-1',
    ]) {
      testWidgets('$path 在查询前显示路由错误', (tester) async {
        var queryCount = 0;
        app_router.router.go(path);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          app_router.router.go('/');
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              attachmentPreviewProvider.overrideWith((ref, id) async {
                queryCount++;
                return const AttachmentPreviewState(
                  status: AttachmentPreviewStatus.recordNotFound,
                );
              }),
            ],
            child: MaterialApp.router(routerConfig: app_router.router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('无法打开页面'), findsOneWidget);
        expect(find.byType(AttachmentPreviewPage), findsNothing);
        expect(queryCount, 0);
      });
    }
  });
}

AttachmentRow _row({String originalName = '附件.png'}) => AttachmentRow(
  id: 7,
  followupId: 1,
  relativePath: 'attachments/2026/08/preview.png',
  originalName: originalName,
  mimeType: 'image/png',
  sizeBytes: 68,
  createdAt: 1,
  updatedAt: 1,
);
