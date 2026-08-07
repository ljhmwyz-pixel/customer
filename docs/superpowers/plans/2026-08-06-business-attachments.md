# Business Attachments Implementation Plan

> **For Codex:** Execute this plan one task at a time. For every task: add a failing test, confirm the failure, implement the smallest complete change, rerun targeted checks, then stop for user confirmation before committing.

**Goal:** 让报价、样品、注册、招标、订单和跟进记录都能安全管理应用私有目录中的附件，并保证迁移、删除、预览和 Android 文件选择行为可验证。

**Architecture:** 数据库用单一 `attachments` 表和六选一归属约束；Dart 层用类型安全的 `AttachmentOwner` 隔离 nullable 外键组合。文件操作集中在可注入目录的附件服务中，业务记录只通过通用附件页面访问文件。删除时先在事务内收集路径并提交数据库删除，随后删除物理文件；失败项进入可重试的孤儿清理流程，避免数据库回滚后文件已经不可恢复。

**Tech Stack:** Flutter、Dart、Riverpod、Drift/SQLite、image_picker、flutter_image_compress、photo_view、open_filex、Android Kotlin MethodChannel。

---

## SPRD decisions

- 六类已持久化记录支持附件：跟进、订单、报价、样品、注册、招标。
- 草稿没有数据库 ID，不允许提前挂附件；保存记录后从记录操作入口进入附件页。
- 图片保存到应用私有目录，长边不超过 1920px；通过逐级质量压缩尽量接近 500KB，达到最低质量后允许大于目标值并明确记录实际大小。
- 数据库只保存相对路径、原始文件名、 MIME 类型、大小和时间。
- 相机与相册使用 `image_picker`；系统文件选择使用 Android `ACTION_OPEN_DOCUMENT`，不新增 `file_picker`。
- 数据库删除成功后再清理物理文件；清理失败不伪装成数据库失败，而是保留可重试清理记录并向用户提示。
- Android 模拟器覆盖相册、系统文件、预览和打开验证；相机及 ColorOS 文件提供器保留一加 13 真机验收项。

### Task 1: Upgrade the attachment schema to v7

**Files:**

- Modify: `lib/data/tables/attachments.dart`
- Modify: `lib/data/database.dart`
- Modify: `lib/data/daos/attachment_dao.dart`
- Regenerate: `lib/data/database.g.dart`
- Regenerate: `lib/data/daos/attachment_dao.g.dart`
- Create: `test/data/attachment_v7_migration_test.dart`
- Modify: `test/data/migration_test.dart`
- Modify: `test/data/phase_e_schema_test.dart`
- Modify: `test/data/cascade_test.dart`

- [ ] Add tests for a fresh v7 database: six owner columns and indexes exist, exactly one owner is accepted, zero or multiple owners are rejected, and every parent foreign key cascades.
- [ ] Run `flutter test test/data/attachment_v7_migration_test.dart` and confirm it fails against v6.
- [ ] Add a real v6 fixture containing follow-up and order attachments; verify v6→v7 preserves every value and leaves `PRAGMA foreign_key_check` empty.
- [ ] Extend `Attachments` with quote, sample, registration and tender foreign keys and a six-way CHECK constraint.
- [ ] Rebuild `attachments` in `_migrateV6ToV7`, copy existing rows without changing IDs or metadata, and recreate all six owner indexes.
- [ ] Raise `schemaVersion` and update existing latest-schema expectations from v6 to v7 without weakening older v1/v2/v3/v5 migration coverage.
- [ ] Introduce a sealed `AttachmentOwner` API in the DAO so callers cannot construct invalid nullable-ID combinations; add list/count helpers for all six owner types.
- [ ] Regenerate Drift output with `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run the new migration test, existing migration/cascade/CRUD/schema tests, `flutter analyze`, and inspect the generated migration SQL assertions.

### Task 2: Implement private attachment storage

**Files:**

- Create: `lib/services/attachment_file_service.dart`
- Create: `lib/services/attachment_service.dart`
- Create: `lib/services/attachment_service_providers.dart`
- Create: `test/services/attachment_file_service_test.dart`
- Create: `test/services/attachment_service_test.dart`
- Modify: `lib/data/attachment_path.dart`
- Modify: `test/data/attachment_path_test.dart`

- [ ] First add red tests proving `AttachmentPath` rejects absolute paths, empty paths, the bare `attachments` directory, non-attachment roots and normalized `..` escapes; resolution must remain below `<appDir>/attachments/`.
- [ ] Add file-service red tests with an injected temporary app directory, fixed clock and deterministic ID generator. Cover `attachments/YYYY/MM/`, collision-free generated names, byte-for-byte ordinary-file copying, retained original display name/MIME type and actual stored size.
- [ ] Define an injectable image processor boundary so unit tests do not invoke platform plugins. Verify every attempt requests automatic orientation correction and a 1920×1920 bound, uses descending JPEG/WebP quality steps, stops at the first candidate at or below 500KB, and retains the lowest-quality candidate with its real size when the target cannot be reached.
- [ ] Verify a codec/plugin exception removes temporary candidates and falls back to copying the original bytes. Keep file extension, encoded format and MIME type mutually consistent; PNG remains PNG and is resized without pretending JPEG bytes are PNG.
- [ ] Implement `AttachmentFileService`: resolve the app-private root lazily, reuse `AttachmentPath` for all path construction/resolution, create year/month directories, generate non-conflicting target names, finalize one stored file, and expose stable exists/delete results.
- [ ] Add orchestration red tests against an in-memory v7 database. On add, write the file first and insert only its relative path plus original name, MIME type and actual size; if insertion throws, remove the newly stored file and preserve the database failure.
- [ ] Add service red tests for a missing database row, a database row whose physical file is missing, successful deletion, failed physical deletion, successful opening, no compatible application, permission/platform failure and unknown opener failure. Public results must not expose `open_filex` result classes or plugin exceptions.
- [ ] Implement `AttachmentService` with injectable DAO, file service and opener adapter. Delete the database row before physical cleanup so a database failure cannot strand an already-deleted file; return a stable cleanup-failure result for Task 6 to make retryable.
- [ ] Add Riverpod providers for the production app-directory loader, image processor, opener, file service and attachment service without adding new dependencies or starting Android picker/UI work.
- [ ] Run targeted red/green checks: `flutter test test/data/attachment_path_test.dart`, `flutter test test/services/attachment_file_service_test.dart`, and `flutter test test/services/attachment_service_test.dart`.
- [ ] Run full verification: `flutter analyze`, `flutter test`, `git diff --check`, then inspect `git status --short` and `git diff --stat`. Stop before staging or committing and request explicit user confirmation.

### Task 3: Add Android attachment sources

**Files:**

- Create: `lib/services/attachment_source_service.dart`
- Modify: `android/app/src/main/kotlin/com/snyder/customer/MainActivity.kt`
- Modify if required by verified plugin behavior: `android/app/src/main/AndroidManifest.xml`
- Create: `test/services/attachment_source_service_test.dart`
- Create: `android/app/src/test/kotlin/com/snyder/customer/AttachmentPickerTest.kt`

- [ ] Write Dart channel tests for success, cancellation, malformed native data, unavailable handler, and platform failure.
- [ ] Add camera and gallery adapters through `image_picker`.
- [ ] Add a dedicated `com.snyder.customer/attachments` channel and `ACTION_OPEN_DOCUMENT` with `CATEGORY_OPENABLE` and `*/*`.
- [ ] Return a copied cache/private source path plus original name, MIME type and actual byte size; handle cancellation exactly once.
- [ ] Add compatible lifecycle handling for the existing `FlutterActivity` and test result parsing in isolation.
- [ ] Run Dart tests, Android unit tests, `flutter analyze`, and a debug APK build.

### Task 4: Build the reusable attachment UI

**Files:**

- Create: `lib/features/attachments/attachment_page.dart`
- Create: `lib/features/attachments/attachment_providers.dart`
- Create: `lib/features/attachments/attachment_preview_page.dart`
- Modify: `lib/router.dart`
- Create: `test/features/attachments/attachment_page_test.dart`
- Create: `test/features/attachments/attachment_preview_page_test.dart`

- [ ] Write widget tests for loading, empty, populated, error, add-source, cancellation and delete-confirmation states at 320px width and in dark mode.
- [ ] Show attachment count, original name, type, size and missing-file state.
- [ ] Add source selection for camera, gallery and system files with progress/error feedback.
- [ ] Preview images with `photo_view`; open PDF and other files with `open_filex` and surface unsupported-app errors.
- [ ] Delete only after confirmation and refresh the owner-scoped list/count.
- [ ] Add typed routes containing owner type and ID, rejecting unknown types before querying data.
- [ ] Run attachment widget tests, router tests and `flutter analyze`.

### Task 5: Expose all six persisted record types

**Files:**

- Modify: `lib/features/customers/customer_detail_page.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/business/business_providers.dart`
- Modify: `lib/data/daos/quote_dao.dart`
- Modify: `lib/data/daos/sample_dao.dart`
- Modify: `lib/data/daos/registration_dao.dart`
- Modify: `lib/data/daos/tender_dao.dart`
- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `test/features/business_pages_test.dart`
- Modify: `test/features/business/phase_e_pages_test.dart`

- [ ] Write failing provider/page tests proving each persisted record exposes an attachment action with its correct owner ID.
- [ ] Extend customer detail data to load and display quote, sample, registration and tender records under each project rather than only showing create buttons.
- [ ] Add attachment actions and counts to follow-up timeline entries and order rows.
- [ ] Add attachment actions and counts to quote, sample, registration and tender rows.
- [ ] Keep create forms free of attachment state; after saving, return to the persisted-record list where the new attachment action is available.
- [ ] Add DAO lookup/delete primitives needed by record actions, preserving customer/project ownership checks in services.
- [ ] Run affected provider/widget tests and `flutter analyze`.

### Task 6: Make physical deletion consistent

**Files:**

- Modify: `lib/services/attachment_service.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/opportunities/opportunity_providers.dart`
- Modify: `lib/features/orders/order_providers.dart`
- Modify: `lib/features/business/business_providers.dart`
- Modify: `test/services/attachment_service_test.dart`
- Modify: `test/features/customers/customer_service_test.dart`
- Modify: `test/features/opportunities/opportunity_service_test.dart`
- Modify: `test/features/orders/order_service_test.dart`

- [ ] Write failing tests for single attachment, six business records, customer-tree deletion, database failure, missing file, and file-delete failure.
- [ ] Collect attachment paths before the database transaction, delete the business graph in the transaction, then clean files after commit.
- [ ] Persist or deterministically rediscover failed physical deletions so cleanup is retryable on next startup/settings action.
- [ ] Ensure customer deletion covers every attachment below projects and direct customer business records.
- [ ] Preserve the existing rule that projects with linked business records cannot be deleted; include quote/sample/registration/tender in that guard.
- [ ] Run all deletion/service/cascade tests and `flutter analyze`.

### Task 7: Validate and hand off the attachment stage

**Files:**

- Modify: `docs/PRD.md`
- Modify: `docs/TEST_CHECKLIST.md`

- [ ] Run `flutter test` and `flutter analyze` from a clean generated-code state.
- [ ] Build debug and release APKs.
- [ ] On Android emulator verify gallery import, system file import, image preview, PDF/ordinary file opening, deletion and process restart persistence.
- [ ] Verify a migrated v6 database with real follow-up/order attachments and inspect `PRAGMA foreign_key_check`.
- [ ] Record camera and OnePlus 13 / ColorOS 15 file-provider cases as real-device acceptance items, not simulator-complete claims.
- [ ] Check every SPRD attachment requirement against implementation and tests; search changed code/docs for `TODO`, `TBD`, placeholders and inconsistent owner names.
- [ ] Present exact changed files and validation evidence to the user; only after explicit confirmation, stage exact files and create one attachment-stage commit without push/amend/squash.
