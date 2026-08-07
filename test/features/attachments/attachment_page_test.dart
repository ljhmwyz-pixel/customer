import 'dart:async';
import 'dart:io';

import 'package:customer/data/daos/attachment_dao.dart';
import 'package:customer/data/database.dart';
import 'package:customer/data/database_provider.dart';
import 'package:customer/features/attachments/attachment_page.dart';
import 'package:customer/features/attachments/attachment_providers.dart';
import 'package:customer/models/enums.dart';
import 'package:customer/router.dart' as app_router;
import 'package:customer/services/attachment_file_service.dart';
import 'package:customer/services/attachment_service.dart';
import 'package:customer/services/attachment_service_providers.dart';
import 'package:customer/services/attachment_source_service.dart';
import 'package:customer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../data/helpers.dart';

void main() {
  group('AttachmentOwnerRoute', () {
    const cases =
        <(String, AttachmentOwnerType, AttachmentOwner Function(int))>[
          (
            'followup',
            AttachmentOwnerType.followup,
            FollowupAttachmentOwner.new,
          ),
          ('order', AttachmentOwnerType.order, OrderAttachmentOwner.new),
          ('quote', AttachmentOwnerType.quote, QuoteAttachmentOwner.new),
          ('sample', AttachmentOwnerType.sample, SampleAttachmentOwner.new),
          (
            'registration',
            AttachmentOwnerType.registration,
            RegistrationAttachmentOwner.new,
          ),
          ('tender', AttachmentOwnerType.tender, TenderAttachmentOwner.new),
        ];

    for (final (segment, type, ownerFactory) in cases) {
      test('解析 $segment 并生成类型安全归属和路径', () {
        final route = AttachmentOwnerRoute.tryParse(segment, '42');

        expect(route, AttachmentOwnerRoute(type: type, id: 42));
        expect(route!.location, '/attachments/$segment/42');
        expect(route.owner.runtimeType, ownerFactory(42).runtimeType);
        expect(route.owner.id, 42);
      });
    }

    test('相同类型和 id 具有值相等语义', () {
      const first = AttachmentOwnerRoute(
        type: AttachmentOwnerType.followup,
        id: 7,
      );
      const second = AttachmentOwnerRoute(
        type: AttachmentOwnerType.followup,
        id: 7,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(
        first,
        isNot(
          const AttachmentOwnerRoute(type: AttachmentOwnerType.order, id: 7),
        ),
      );
    });

    test('拒绝未知类型和非正整数 id', () {
      expect(AttachmentOwnerRoute.tryParse('unknown', '1'), isNull);
      expect(AttachmentOwnerRoute.tryParse('followup', 'abc'), isNull);
      expect(AttachmentOwnerRoute.tryParse('followup', '0'), isNull);
      expect(AttachmentOwnerRoute.tryParse('followup', '-1'), isNull);
    });
  });

  group('attachment read providers', () {
    late AppDatabase db;
    late _FakeAttachmentFileStore fileStore;
    late ProviderContainer container;
    late int firstFollowupId;
    late int secondFollowupId;

    setUp(() async {
      db = await openTestDb();
      final customerId = await seedCustomer(db);
      firstFollowupId = await _seedFollowup(db, customerId, '第一次跟进');
      secondFollowupId = await _seedFollowup(db, customerId, '第二次跟进');
      fileStore = _FakeAttachmentFileStore();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          attachmentFileStoreProvider.overrideWithValue(fileStore),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('列表只读取当前 owner 并附带物理文件状态', () async {
      await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/first.jpg',
        originalName: '现场照片.jpg',
        mimeType: 'image/jpeg',
      );
      await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/missing.pdf',
        originalName: '报价单.pdf',
        mimeType: 'application/pdf',
      );
      await _seedAttachment(
        db,
        ownerId: secondFollowupId,
        relativePath: 'attachments/2026/08/other.jpg',
        originalName: '其他跟进.jpg',
        mimeType: 'image/jpeg',
      );
      fileStore.existingPaths.add('attachments/2026/08/first.jpg');

      final items = await container.read(
        attachmentListProvider(
          AttachmentOwnerRoute(
            type: AttachmentOwnerType.followup,
            id: firstFollowupId,
          ),
        ).future,
      );

      expect(items.map((item) => item.row.originalName), [
        '现场照片.jpg',
        '报价单.pdf',
      ]);
      expect(items.map((item) => item.fileExists), [true, false]);
      expect(fileStore.existsPaths, [
        'attachments/2026/08/first.jpg',
        'attachments/2026/08/missing.pdf',
      ]);
    });

    test('数量只统计当前 owner', () async {
      for (var index = 0; index < 2; index++) {
        await _seedAttachment(
          db,
          ownerId: firstFollowupId,
          relativePath: 'attachments/2026/08/first-$index.pdf',
          originalName: '第一个归属-$index.pdf',
          mimeType: 'application/pdf',
        );
      }
      await _seedAttachment(
        db,
        ownerId: secondFollowupId,
        relativePath: 'attachments/2026/08/second.pdf',
        originalName: '第二个归属.pdf',
        mimeType: 'application/pdf',
      );

      final firstCount = await container.read(
        attachmentCountProvider(
          AttachmentOwnerRoute(
            type: AttachmentOwnerType.followup,
            id: firstFollowupId,
          ),
        ).future,
      );
      final secondCount = await container.read(
        attachmentCountProvider(
          AttachmentOwnerRoute(
            type: AttachmentOwnerType.followup,
            id: secondFollowupId,
          ),
        ).future,
      );

      expect(firstCount, 2);
      expect(secondCount, 1);
    });

    test('图片存在时预览状态包含记录和安全绝对路径', () async {
      final id = await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/ready.jpg',
        originalName: '可预览.jpg',
        mimeType: 'image/jpeg',
      );
      fileStore.existingPaths.add('attachments/2026/08/ready.jpg');
      fileStore.resolvedPaths['attachments/2026/08/ready.jpg'] =
          '/app/attachments/2026/08/ready.jpg';

      final state = await container.read(attachmentPreviewProvider(id).future);

      expect(state.status, AttachmentPreviewStatus.ready);
      expect(state.row?.id, id);
      expect(state.absolutePath, '/app/attachments/2026/08/ready.jpg');
      expect(fileStore.existsPaths, ['attachments/2026/08/ready.jpg']);
      expect(fileStore.absolutePaths, ['attachments/2026/08/ready.jpg']);
    });

    test('记录不存在时不访问文件存储', () async {
      final state = await container.read(
        attachmentPreviewProvider(999999).future,
      );

      expect(state.status, AttachmentPreviewStatus.recordNotFound);
      expect(state.row, isNull);
      expect(state.absolutePath, isNull);
      expect(fileStore.existsPaths, isEmpty);
      expect(fileStore.absolutePaths, isEmpty);
    });

    test('物理文件不存在时不解析绝对路径', () async {
      final id = await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/gone.jpg',
        originalName: '已丢失.jpg',
        mimeType: 'image/jpeg',
      );

      final state = await container.read(attachmentPreviewProvider(id).future);

      expect(state.status, AttachmentPreviewStatus.fileNotFound);
      expect(state.row?.id, id);
      expect(state.absolutePath, isNull);
      expect(fileStore.absolutePaths, isEmpty);
    });

    test('非图片不解析绝对路径', () async {
      final id = await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/quote.pdf',
        originalName: '报价.pdf',
        mimeType: 'application/pdf',
      );
      fileStore.existingPaths.add('attachments/2026/08/quote.pdf');

      final state = await container.read(attachmentPreviewProvider(id).future);

      expect(state.status, AttachmentPreviewStatus.notImage);
      expect(state.row?.id, id);
      expect(state.absolutePath, isNull);
      expect(fileStore.absolutePaths, isEmpty);
    });

    test('检查文件存在状态异常时返回 failed', () async {
      final id = await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/exists-error.jpg',
        originalName: '异常图片.jpg',
        mimeType: 'image/jpeg',
      );
      fileStore.existsError = StateError('exists failed');

      final state = await container.read(attachmentPreviewProvider(id).future);

      expect(state.status, AttachmentPreviewStatus.failed);
      expect(state.row?.id, id);
      expect(state.absolutePath, isNull);
      expect(fileStore.absolutePaths, isEmpty);
    });

    test('解析绝对路径异常时返回 failed', () async {
      final id = await _seedAttachment(
        db,
        ownerId: firstFollowupId,
        relativePath: 'attachments/2026/08/path-error.jpg',
        originalName: '路径异常.jpg',
        mimeType: 'image/jpeg',
      );
      fileStore.existingPaths.add('attachments/2026/08/path-error.jpg');
      fileStore.absolutePathError = StateError('path failed');

      final state = await container.read(attachmentPreviewProvider(id).future);

      expect(state.status, AttachmentPreviewStatus.failed);
      expect(state.row?.id, id);
      expect(state.absolutePath, isNull);
    });
  });

  group('AttachmentPage', () {
    late AppDatabase db;
    late _FakeAttachmentFileStore fileStore;
    late _FakeAttachmentSourceService sourceService;
    late _FakeAttachmentService attachmentService;
    late int followupId;

    setUp(() async {
      db = await openTestDb();
      final customerId = await seedCustomer(db);
      followupId = await _seedFollowup(db, customerId, '附件页面');
      fileStore = _FakeAttachmentFileStore();
      sourceService = _FakeAttachmentSourceService();
      attachmentService = _FakeAttachmentService(db, fileStore);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpAttachmentPage(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
      Future<List<AttachmentListItem>> Function(
        Ref ref,
        AttachmentOwnerRoute route,
      )?
      listBuilder,
      bool settle = true,
    }) async {
      final route = AttachmentOwnerRoute(
        type: AttachmentOwnerType.followup,
        id: followupId,
      );
      final router = GoRouter(
        initialLocation: route.location,
        routes: [
          GoRoute(
            path: '/attachments/preview/:id',
            builder: (context, state) =>
                Scaffold(body: Text('预览:${state.pathParameters['id']}')),
          ),
          GoRoute(
            path: '/attachments/:ownerType/:ownerId',
            builder: (context, state) => AttachmentPage(owner: route),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            attachmentFileStoreProvider.overrideWithValue(fileStore),
            attachmentSourceServiceProvider.overrideWithValue(sourceService),
            attachmentServiceProvider.overrideWithValue(attachmentService),
            if (listBuilder != null)
              attachmentListProvider.overrideWith(listBuilder),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: router,
          ),
        ),
      );
      if (settle) await tester.pumpAndSettle();
    }

    testWidgets('320px 空列表展示稳定空状态且无横向溢出', (tester) async {
      await _setNarrowSurface(tester);
      await pumpAttachmentPage(tester);

      expect(find.text('附件（0）'), findsOneWidget);
      expect(find.text('暂无附件'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('加载中与数据库错误有明确状态', (tester) async {
      await _setNarrowSurface(tester);
      final pending = Completer<List<AttachmentListItem>>();
      await pumpAttachmentPage(
        tester,
        listBuilder: (ref, route) => pending.future,
        settle: false,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      pending.completeError(StateError('database failed'));
      await tester.pumpAndSettle();
      expect(find.text('附件加载失败，请重试'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('窄屏列表展示数量、名称、MIME、大小和文件缺失标识', (tester) async {
      await _setNarrowSurface(tester);
      await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/photo.jpg',
        originalName: '展会现场照片.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1536,
      );
      await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/quote.pdf',
        originalName: '正式报价单.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 1024 * 1024,
      );
      fileStore.existingPaths.add('attachments/2026/08/photo.jpg');

      await pumpAttachmentPage(tester);

      expect(find.text('附件（2）'), findsOneWidget);
      expect(find.text('展会现场照片.jpg'), findsOneWidget);
      expect(find.text('image/jpeg · 1.5 KB'), findsOneWidget);
      expect(find.text('正式报价单.pdf'), findsOneWidget);
      expect(find.text('application/pdf · 1.0 MB'), findsOneWidget);
      expect(find.text('文件已丢失'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('暗色主题保留完整列表内容', (tester) async {
      await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/dark.pdf',
        originalName: '暗色报价.pdf',
        mimeType: 'application/pdf',
      );
      fileStore.existingPaths.add('attachments/2026/08/dark.pdf');

      await pumpAttachmentPage(tester, brightness: Brightness.dark);

      expect(find.text('暗色报价.pdf'), findsOneWidget);
      expect(find.textContaining('application/pdf'), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
    });

    testWidgets('添加菜单提供拍照、相册和系统文件三类来源', (tester) async {
      await _setNarrowSurface(tester);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.padding = const FakeViewPadding(left: 12, top: 24, right: 20);
      addTearDown(tester.view.resetPadding);
      await pumpAttachmentPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('拍照'), findsOneWidget);
      expect(find.text('从相册选择'), findsOneWidget);
      expect(find.text('从系统文件选择'), findsOneWidget);
      final firstTileRect = tester.getRect(
        find.ancestor(of: find.text('拍照'), matching: find.byType(ListTile)),
      );
      expect(firstTileRect.left, moreOrLessEquals(12));
      expect(firstTileRect.right, moreOrLessEquals(300));
      expect(tester.takeException(), isNull);
    });

    for (final sourceCase in const [
      ('拍照', _SourceAction.camera),
      ('从相册选择', _SourceAction.gallery),
      ('从系统文件选择', _SourceAction.files),
    ]) {
      testWidgets('${sourceCase.$1}选择成功后按当前归属添加并刷新', (tester) async {
        sourceService.results[sourceCase.$2] =
            const AttachmentSourceResult.selected(
              AttachmentSourceFile(
                sourcePath: '/cache/source.bin',
                originalName: '来源文件.bin',
                mimeType: 'application/octet-stream',
                sizeBytes: 12,
              ),
            );
        await pumpAttachmentPage(tester);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.text(sourceCase.$1));
        await tester.pumpAndSettle();

        expect(sourceService.calls, [sourceCase.$2]);
        expect(attachmentService.addCalls, hasLength(1));
        expect(
          attachmentService.addCalls.single.owner,
          isA<FollowupAttachmentOwner>(),
        );
        expect(attachmentService.addCalls.single.owner.id, followupId);
        expect(
          attachmentService.addCalls.single.source.path,
          '/cache/source.bin',
        );
        expect(attachmentService.addCalls.single.originalName, '来源文件.bin');
        expect(
          attachmentService.addCalls.single.mimeType,
          'application/octet-stream',
        );
        expect(find.text('附件（1）'), findsOneWidget);
        expect(find.text('来源文件.bin'), findsOneWidget);
      });
    }

    testWidgets('取消选择保持静默且不添加', (tester) async {
      sourceService.results[_SourceAction.gallery] =
          const AttachmentSourceResult.cancelled();
      await pumpAttachmentPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();

      expect(attachmentService.addCalls, isEmpty);
      expect(find.byType(SnackBar), findsNothing);
    });

    for (final errorCase in const [
      (AttachmentSourceStatus.unavailable, '当前设备不支持选择系统文件'),
      (AttachmentSourceStatus.invalidData, '无法读取所选文件'),
      (AttachmentSourceStatus.failed, '选择附件失败，请重试'),
    ]) {
      testWidgets('${errorCase.$1.name} 显示稳定错误提示', (tester) async {
        sourceService.results[_SourceAction.files] = switch (errorCase.$1) {
          AttachmentSourceStatus.unavailable =>
            const AttachmentSourceResult.unavailable(),
          AttachmentSourceStatus.invalidData =>
            const AttachmentSourceResult.invalidData(),
          _ => const AttachmentSourceResult.failed(),
        };
        await pumpAttachmentPage(tester);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.text('从系统文件选择'));
        await tester.pumpAndSettle();

        expect(find.text(errorCase.$2), findsOneWidget);
        expect(attachmentService.addCalls, isEmpty);
      });
    }

    testWidgets('附件保存失败显示提示并恢复操作能力', (tester) async {
      sourceService.results[_SourceAction.camera] =
          const AttachmentSourceResult.selected(
            AttachmentSourceFile(
              sourcePath: '/cache/camera.jpg',
              originalName: 'camera.jpg',
              mimeType: 'image/jpeg',
              sizeBytes: 10,
            ),
          );
      attachmentService.addError = StateError('add failed');
      await pumpAttachmentPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('拍照'));
      await tester.pumpAndSettle();

      expect(find.text('附件保存失败，请重试'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byIcon(Icons.add),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('来源操作进行中禁用添加入口', (tester) async {
      sourceService.pending = Completer<AttachmentSourceResult>();
      await pumpAttachmentPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('拍照'));
      await tester.pump();

      final addButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.add),
          matching: find.byType(IconButton),
        ),
      );
      expect(addButton.onPressed, isNull);

      sourceService.pending!.complete(const AttachmentSourceResult.cancelled());
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byIcon(Icons.add),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('点击图片进入对应预览路由且不调用外部打开', (tester) async {
      final id = await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/image.jpg',
        originalName: '预览图片.jpg',
        mimeType: 'image/jpeg',
      );
      fileStore.existingPaths.add('attachments/2026/08/image.jpg');
      await pumpAttachmentPage(tester);

      await tester.tap(find.text('预览图片.jpg'));
      await tester.pumpAndSettle();

      expect(find.text('预览:$id'), findsOneWidget);
      expect(attachmentService.openCalls, isEmpty);
    });

    for (final mimeCase in const [
      ('application/pdf', '报价单.pdf'),
      ('application/octet-stream', '原始数据.bin'),
    ]) {
      testWidgets('${mimeCase.$1} 点击后调用外部打开且不进入图片预览', (tester) async {
        final id = await _seedAttachment(
          db,
          ownerId: followupId,
          relativePath: 'attachments/2026/08/${mimeCase.$2}',
          originalName: mimeCase.$2,
          mimeType: mimeCase.$1,
        );
        fileStore.existingPaths.add('attachments/2026/08/${mimeCase.$2}');
        await pumpAttachmentPage(tester);

        await tester.tap(find.text(mimeCase.$2));
        await tester.pumpAndSettle();

        expect(attachmentService.openCalls, [id]);
        expect(find.text('预览:$id'), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
      });
    }

    for (final errorCase in const [
      (AttachmentOpenResult.recordNotFound, '附件记录不存在'),
      (AttachmentOpenResult.fileNotFound, '文件已丢失'),
      (AttachmentOpenResult.noAppToOpen, '未找到可打开此文件的应用'),
      (AttachmentOpenResult.permissionDenied, '没有权限打开此文件'),
      (AttachmentOpenResult.platformFailure, '无法打开附件，请重试'),
      (AttachmentOpenResult.failed, '无法打开附件，请重试'),
    ]) {
      testWidgets('${errorCase.$1.name} 显示稳定打开提示', (tester) async {
        await _seedAttachment(
          db,
          ownerId: followupId,
          relativePath: 'attachments/2026/08/open.pdf',
          originalName: '待打开.pdf',
          mimeType: 'application/pdf',
        );
        fileStore.existingPaths.add('attachments/2026/08/open.pdf');
        attachmentService.openResult = errorCase.$1;
        await pumpAttachmentPage(tester);

        await tester.tap(find.text('待打开.pdf'));
        await tester.pumpAndSettle();

        expect(find.text(errorCase.$2), findsOneWidget);
      });
    }

    testWidgets('外部打开抛出异常时显示通用提示并恢复操作能力', (tester) async {
      await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/error.pdf',
        originalName: '异常附件.pdf',
        mimeType: 'application/pdf',
      );
      fileStore.existingPaths.add('attachments/2026/08/error.pdf');
      attachmentService.openError = StateError('open failed');
      await pumpAttachmentPage(tester);

      await tester.tap(find.text('异常附件.pdf'));
      await tester.pumpAndSettle();

      expect(find.text('无法打开附件，请重试'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byIcon(Icons.add),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('删除前显示原始文件名且取消不调用服务', (tester) async {
      await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/cancel-delete.pdf',
        originalName: '不要删除.pdf',
        mimeType: 'application/pdf',
      );
      await pumpAttachmentPage(tester);

      await tester.tap(find.byTooltip('删除附件'));
      await tester.pumpAndSettle();

      expect(find.text('不要删除.pdf'), findsWidgets);
      expect(find.text('确认删除附件？'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(attachmentService.deleteCalls, isEmpty);
      expect(find.text('附件（1）'), findsOneWidget);
    });

    for (final result in const [
      AttachmentDeleteResult.deleted,
      AttachmentDeleteResult.fileNotFound,
    ]) {
      testWidgets('${result.name} 删除记录并刷新当前归属列表', (tester) async {
        final id = await _seedAttachment(
          db,
          ownerId: followupId,
          relativePath: 'attachments/2026/08/${result.name}.pdf',
          originalName: '${result.name}.pdf',
          mimeType: 'application/pdf',
        );
        attachmentService.deleteResult = result;
        await pumpAttachmentPage(tester);

        await tester.tap(find.byTooltip('删除附件'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('删除'));
        await tester.pumpAndSettle();

        expect(attachmentService.deleteCalls, [id]);
        expect(find.text('附件（0）'), findsOneWidget);
        expect(find.text('暂无附件'), findsOneWidget);
      });
    }

    testWidgets('文件清理失败时仍刷新列表并显示明确提示', (tester) async {
      final id = await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/cleanup.pdf',
        originalName: '待清理.pdf',
        mimeType: 'application/pdf',
      );
      attachmentService.deleteResult = AttachmentDeleteResult.cleanupFailed;
      await pumpAttachmentPage(tester);

      await tester.tap(find.byTooltip('删除附件'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      expect(attachmentService.deleteCalls, [id]);
      expect(find.text('附件（0）'), findsOneWidget);
      expect(find.text('附件已删除，但文件清理失败'), findsOneWidget);
    });

    testWidgets('删除记录不存在时显示稳定提示并恢复操作能力', (tester) async {
      final id = await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/missing-record.pdf',
        originalName: '记录不存在.pdf',
        mimeType: 'application/pdf',
      );
      attachmentService.deleteResult = AttachmentDeleteResult.recordNotFound;
      await pumpAttachmentPage(tester);

      await tester.tap(find.byTooltip('删除附件'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      expect(attachmentService.deleteCalls, [id]);
      expect(find.text('附件记录不存在'), findsOneWidget);
      expect(find.byTooltip('删除附件'), findsOneWidget);
    });

    testWidgets('删除抛出异常时显示通用提示并恢复操作能力', (tester) async {
      await _seedAttachment(
        db,
        ownerId: followupId,
        relativePath: 'attachments/2026/08/delete-error.pdf',
        originalName: '删除异常.pdf',
        mimeType: 'application/pdf',
      );
      attachmentService.deleteError = StateError('delete failed');
      await pumpAttachmentPage(tester);

      await tester.tap(find.byTooltip('删除附件'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      expect(find.text('删除附件失败，请重试'), findsOneWidget);
      expect(find.byTooltip('删除附件'), findsOneWidget);
    });
  });

  group('attachment owner app route', () {
    testWidgets('有效归属和正整数 id 构建附件页并开始对应查询', (tester) async {
      final queriedRoutes = <AttachmentOwnerRoute>[];
      app_router.router.go('/attachments/followup/7');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        app_router.router.go('/');
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attachmentListProvider.overrideWith((ref, route) async {
              queriedRoutes.add(route);
              return const [];
            }),
          ],
          child: MaterialApp.router(routerConfig: app_router.router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AttachmentPage), findsOneWidget);
      expect(queriedRoutes, const [
        AttachmentOwnerRoute(type: AttachmentOwnerType.followup, id: 7),
      ]);
    });

    for (final path in const [
      '/attachments/unknown/7',
      '/attachments/followup/abc',
      '/attachments/followup/0',
      '/attachments/followup/-1',
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
              attachmentListProvider.overrideWith((ref, route) async {
                queryCount++;
                return const [];
              }),
            ],
            child: MaterialApp.router(routerConfig: app_router.router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('无法打开页面'), findsOneWidget);
        expect(find.byType(AttachmentPage), findsNothing);
        expect(queryCount, 0);
      });
    }
  });
}

Future<int> _seedFollowup(AppDatabase db, int customerId, String content) =>
    db.followupDao.insertAndTouchCustomer(
      customerId: customerId,
      occurredAt: DateTime(2026, 8, 6),
      method: FollowMethod.wechat,
      content: content,
    );

Future<int> _seedAttachment(
  AppDatabase db, {
  required int ownerId,
  required String relativePath,
  required String originalName,
  required String mimeType,
  int sizeBytes = 128,
}) => db.attachmentDao.insertAttachment(
  owner: FollowupAttachmentOwner(ownerId),
  relativePath: relativePath,
  originalName: originalName,
  mimeType: mimeType,
  sizeBytes: sizeBytes,
);

Future<void> _setNarrowSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(320, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

enum _SourceAction { camera, gallery, files }

class _FakeAttachmentSourceService extends AttachmentSourceService {
  final results = <_SourceAction, AttachmentSourceResult>{};
  final calls = <_SourceAction>[];
  Completer<AttachmentSourceResult>? pending;

  @override
  Future<AttachmentSourceResult> pickFromCamera() =>
      _pick(_SourceAction.camera);

  @override
  Future<AttachmentSourceResult> pickFromGallery() =>
      _pick(_SourceAction.gallery);

  @override
  Future<AttachmentSourceResult> pickFromFiles() => _pick(_SourceAction.files);

  Future<AttachmentSourceResult> _pick(_SourceAction action) {
    calls.add(action);
    final pending = this.pending;
    if (pending != null) return pending.future;
    return Future.value(
      results[action] ?? const AttachmentSourceResult.cancelled(),
    );
  }
}

class _AddCall {
  const _AddCall({
    required this.owner,
    required this.source,
    required this.originalName,
    required this.mimeType,
  });

  final AttachmentOwner owner;
  final File source;
  final String originalName;
  final String mimeType;
}

class _FakeAttachmentService extends AttachmentService {
  _FakeAttachmentService(this.db, this.fileStore)
    : super(
        dao: db.attachmentDao,
        fileStore: fileStore,
        opener: const _NeverOpenAttachmentOpener(),
      );

  final AppDatabase db;
  final _FakeAttachmentFileStore fileStore;
  final addCalls = <_AddCall>[];
  final openCalls = <int>[];
  final deleteCalls = <int>[];
  AttachmentOpenResult openResult = AttachmentOpenResult.opened;
  AttachmentDeleteResult deleteResult = AttachmentDeleteResult.deleted;
  Object? addError;
  Object? openError;
  Object? deleteError;

  @override
  Future<AttachmentRow> add({
    required AttachmentOwner owner,
    required File source,
    required String originalName,
    required String mimeType,
  }) async {
    addCalls.add(
      _AddCall(
        owner: owner,
        source: source,
        originalName: originalName,
        mimeType: mimeType,
      ),
    );
    if (addError case final error?) throw error;

    final relativePath = 'attachments/test/${addCalls.length}.bin';
    final id = await db.attachmentDao.insertAttachment(
      owner: owner,
      relativePath: relativePath,
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: 12,
    );
    fileStore.existingPaths.add(relativePath);
    return (await db.attachmentDao.findById(id))!;
  }

  @override
  Future<AttachmentOpenResult> open(int attachmentId) async {
    openCalls.add(attachmentId);
    if (openError case final error?) throw error;
    return openResult;
  }

  @override
  Future<AttachmentDeleteResult> delete(int attachmentId) async {
    deleteCalls.add(attachmentId);
    if (deleteError case final error?) throw error;
    if (deleteResult != AttachmentDeleteResult.recordNotFound) {
      await db.attachmentDao.deleteAttachment(attachmentId);
    }
    return deleteResult;
  }
}

class _NeverOpenAttachmentOpener implements AttachmentOpener {
  const _NeverOpenAttachmentOpener();

  @override
  Future<AttachmentOpenAdapterResult> open(String absolutePath) =>
      throw UnimplementedError();
}

class _FakeAttachmentFileStore implements AttachmentFileStore {
  final existingPaths = <String>{};
  final resolvedPaths = <String, String>{};
  final existsPaths = <String>[];
  final absolutePaths = <String>[];
  Object? existsError;
  Object? absolutePathError;

  @override
  Future<bool> exists(String relativePath) async {
    existsPaths.add(relativePath);
    if (existsError case final error?) throw error;
    return existingPaths.contains(relativePath);
  }

  @override
  Future<String> absolutePath(String relativePath) async {
    absolutePaths.add(relativePath);
    if (absolutePathError case final error?) throw error;
    return resolvedPaths[relativePath] ?? '/app/$relativePath';
  }

  @override
  Future<AttachmentFileDeleteResult> delete(String relativePath) async =>
      AttachmentFileDeleteResult.deleted;

  @override
  Future<Set<String>> listStoredPaths() async => {};

  @override
  Future<StoredAttachmentFile> store({
    required File source,
    required String originalName,
    required String mimeType,
  }) => throw UnimplementedError();
}
