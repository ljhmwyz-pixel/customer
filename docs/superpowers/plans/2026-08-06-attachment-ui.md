# Reusable Attachment UI Implementation Plan

> **For Codex:** Execute each task with test-driven development: add the specified failing test, run it and confirm the expected failure, implement the smallest complete change, then rerun the targeted test. Do not stage or commit until the user explicitly confirms the verified Task 4 result.

**Goal:** 为六类已保存业务记录提供同一套附件列表、添加、预览、打开和确认删除 UI，并通过类型安全路由隔离不同业务归属。

**Architecture:** 使用不可变的 `AttachmentOwnerRoute` 表达路由中的归属类型和正整数 ID，并在查询数据库前完成解析校验。Riverpod family providers 组合现有 `AttachmentDao` 与 `AttachmentFileStore`，生成带文件存在状态的 UI 读模型，并为图片预览解析应用私有目录绝对路径。页面变更继续调用现有 `AttachmentSourceService` 和 `AttachmentService`；成功后失效 owner 级列表 provider，数据库与文件写删规则不在 UI 重复实现。

**Tech Stack:** Flutter、Dart、Riverpod、GoRouter、Drift、photo_view、flutter_test。

---

### Task 1: Define typed owner routes and attachment read providers

**Files:**

- Create: `lib/features/attachments/attachment_providers.dart`
- Create: `test/features/attachments/attachment_page_test.dart`

1. Add tests for all six route segments (`followup`, `order`, `quote`, `sample`, `registration`, `tender`), positive ID conversion to the matching `AttachmentOwner`, value equality, and rejection of unknown types, zero, negative, and non-numeric IDs.
2. Run `flutter test test/features/attachments/attachment_page_test.dart` and confirm compilation fails because `AttachmentOwnerRoute` and its providers do not exist.
3. Implement `AttachmentOwnerType`, immutable `AttachmentOwnerRoute`, `location`, `tryParse`, and conversion to the existing sealed `AttachmentOwner` variants.
4. Add `AttachmentListItem` containing `AttachmentRow row` and `bool fileExists`.
5. Add `attachmentSourceServiceProvider`, owner-scoped `attachmentListProvider`, and attachment-ID-scoped `attachmentPreviewProvider`. The list provider must query only `owner.owner`; the preview provider must return explicit `ready`, `recordNotFound`, `fileNotFound`, `notImage`, or `failed` state and expose an absolute path only for an existing `image/*` record.
6. Rerun the targeted test and confirm the route/provider unit cases pass.

### Task 2: Build responsive attachment list and source actions

**Files:**

- Create: `lib/features/attachments/attachment_page.dart`
- Modify: `test/features/attachments/attachment_page_test.dart`

1. Add widget tests at 320px width for loading, database error, empty state, and a populated list. Assert the app bar count, original name, MIME type, formatted size, and missing-file label without horizontal overflow.
2. Add a dark-mode widget test and assert the same content remains available without hard-coded light colors.
3. Add interaction tests for the add menu labels `拍照`, `从相册选择`, and `从系统文件选择`; selected files must call `AttachmentService.add` with the current typed owner and source metadata, then refresh the list.
4. Add cancellation, unavailable source, malformed source data, selection failure, and add failure tests. Cancellation must remain silent; every actual error must produce a stable Chinese SnackBar; controls must be disabled while an operation is running.
5. Run the page test and confirm it fails because `AttachmentPage` does not exist.
6. Implement `AttachmentPage` as a `ConsumerStatefulWidget`, including loading/error/empty/populated rendering, compact metadata layout, progress state, Material source-selection bottom sheet, and provider invalidation after a successful add.
7. Rerun the page test and fix only failures caused by this page behavior.

### Task 3: Add image preview and external opening

**Files:**

- Create: `lib/features/attachments/attachment_preview_page.dart`
- Create: `test/features/attachments/attachment_preview_page_test.dart`
- Modify: `lib/features/attachments/attachment_page.dart`
- Modify: `test/features/attachments/attachment_page_test.dart`

1. Add preview-page tests for loading, resolvable image rendering through `PhotoView`, missing record, missing physical file, non-image rejection, and path-resolution failure.
2. Run `flutter test test/features/attachments/attachment_preview_page_test.dart` and confirm compilation fails because the preview page does not exist.
3. Implement `AttachmentPreviewPage` using `attachmentPreviewProvider`; construct `FileImage` only for a `ready` result and render stable error messages for all other states.
4. Add list interaction tests proving `image/*` navigates to `/attachments/preview/<id>`, while PDF and other MIME types call `AttachmentService.open` without entering image preview.
5. Cover opener results `fileNotFound`, `noAppToOpen`, `permissionDenied`, `platformFailure`, `failed`, and `recordNotFound` with user-visible messages; `opened` must not show an error.
6. Implement MIME-based tap dispatch and the opener-result message mapping, then rerun both attachment widget test files.

### Task 4: Confirm deletion and refresh owner data

**Files:**

- Modify: `lib/features/attachments/attachment_page.dart`
- Modify: `test/features/attachments/attachment_page_test.dart`

1. Add tests that tapping delete first opens a dialog containing the original filename; cancel must not call the service.
2. Add tests that confirmation calls `AttachmentService.delete`, refreshes the current owner list for `deleted` and `fileNotFound`, and reports `cleanupFailed` while still refreshing because the database row was deleted.
3. Add tests for `recordNotFound` and thrown deletion errors with stable feedback and no stale busy state.
4. Run the page test and confirm the new interaction assertions fail against the current page.
5. Implement confirmation, delete-result mapping, busy-state cleanup in `finally`, and owner-provider invalidation.
6. Rerun the page test and confirm all deletion cases pass.

### Task 5: Register and reject attachment routes

**Files:**

- Modify: `lib/router.dart`
- Modify: `test/features/attachments/attachment_page_test.dart`
- Modify: `test/features/attachments/attachment_preview_page_test.dart`

1. Add router tests for `/attachments/<ownerType>/<positiveId>` and `/attachments/preview/<positiveId>`.
2. Add router tests proving unknown owner types and invalid owner/attachment IDs render `无法打开页面` and do not build attachment pages or start provider queries.
3. Run both attachment test files and confirm the route assertions fail because the routes are unregistered.
4. Add top-level typed attachment and preview routes. Parse every parameter with `tryParse`; return the existing route-error presentation before constructing a page when parsing fails.
5. Rerun both attachment test files and confirm valid and invalid routes behave as specified.

### Task 6: Verify Task 4 without committing

**Files:**

- Verify only; do not modify unrelated files.

1. Run `dart format` on the Task 4 Dart files.
2. Run `flutter test test/features/attachments/attachment_page_test.dart`.
3. Run `flutter test test/features/attachments/attachment_preview_page_test.dart`.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Run `flutter build apk --debug` to confirm Android integration still packages with `photo_view`, the picker channel, and the opener plugin.
7. Run `git diff --check`, `git status --short`, and `git diff --stat`. Confirm `docs/superpowers/plans/2026-08-06-business-attachments.md` remains an untouched user modification and is excluded from the Task 4 file set.
8. Report exact results and wait for explicit user confirmation before staging the Task 4 files or creating a commit.
