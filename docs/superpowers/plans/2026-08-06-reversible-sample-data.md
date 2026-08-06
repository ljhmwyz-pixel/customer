# Reversible Sample Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add nine opt-in business sample scenarios that can be imported once and removed as one batch without touching formal customer data.

**Architecture:** Add an internal nullable `sample_batch_id` marker only to customer roots, then let existing foreign-key cascades own all child data. A focused `SampleDataService` builds deterministic scenarios in one transaction and removes the marked graph in a database-first cleanup flow, cancelling reminders before commit and deleting attachment files after commit.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Drift 2.34.3, Riverpod 3.3.2, flutter_test.

## Global Constraints

- Import happens only after an explicit user action and confirmation.
- Formal databases stay empty by default; startup never imports sample data.
- All nine sample customers use the fixed marker `phase-f-samples-v1`.
- Batch identity is internal and must survive customer renames, edits, retagging, and new attachments.
- A second import while any active v1 batch customer exists returns `alreadyImported` and writes nothing.
- Undo removes every currently marked root, including user edits and user-added descendants.
- Database deletion is transactional; attachment files are cleaned only after commit so filesystem failure cannot roll back or partially restore database rows.
- No new package dependency is allowed.
- Run Flutter commands serially because concurrent runs can corrupt shared native build assets.
- Do not stage or modify `docs/superpowers/plans/2026-08-06-business-attachments.md`.

---

## File Map

- `lib/data/tables/customers.dart`: nullable internal batch marker.
- `lib/data/database.dart`: schema v8 additive migration and batch index.
- `lib/data/daos/customer_dao.dart`: marker-aware insert, batch lookup, and transactional batch-root deletion.
- `lib/services/sample_data_service.dart`: deterministic nine-scenario import and whole-batch undo orchestration.
- `lib/services/sample_data_providers.dart`: Riverpod construction and refreshable batch state.
- `lib/features/settings/sample_data_page.dart`: explicit import/undo UI with confirmations and progress state.
- `lib/features/settings/settings_page.dart`: entry point under data tools.
- `lib/router.dart`: `/settings/sample-data` route.
- `test/data/sample_v8_migration_test.dart`: fresh-schema and v7-to-v8 preservation evidence.
- `test/services/sample_data_service_test.dart`: scenario coverage, idempotency, rollback, reminder cancellation, and attachment cleanup.
- `test/features/settings/sample_data_page_test.dart`: explicit-action, confirmation, success, and failure UI behavior.

---

### Task 1: Schema v8 And Batch Boundary

**Files:**
- Modify: `lib/data/tables/customers.dart`
- Modify: `lib/data/database.dart`
- Modify: `lib/data/daos/customer_dao.dart`
- Create: `test/data/sample_v8_migration_test.dart`
- Modify generated: `lib/data/database.g.dart`
- Modify generated: `lib/data/daos/customer_dao.g.dart`
- Modify: `test/data/migration_test.dart`
- Modify: `test/data/phase_e_schema_test.dart`
- Modify: `test/data/attachment_v7_migration_test.dart`

**Interfaces:**
- Produces: `Customers.sampleBatchId`, mapped to nullable `CustomerRow.sampleBatchId`.
- Produces: `CustomerDao.insertCustomer(..., String? sampleBatchId)`.
- Produces: `Future<List<CustomerRow>> listBySampleBatch(String batchId)`.
- Produces: `Future<int> countBySampleBatch(String batchId)`.
- Produces: `Future<void> deleteSampleBatchRoots(String batchId)`; callers wrap this with any non-database side effects.

- [ ] **Step 1: Write the failing fresh-schema and migration tests**

Assert a fresh database reports schema version 8, `customers.sample_batch_id` is nullable, and `idx_customers_sample_batch` exists. Create a real v7 fixture with one formal customer, migrate it through `AppDatabase.forTesting`, and assert the row is unchanged with a null marker and `PRAGMA foreign_key_check` is empty.

- [ ] **Step 2: Run the focused tests and confirm the expected failure**

Run: `flutter test test/data/sample_v8_migration_test.dart test/data/migration_test.dart test/data/phase_e_schema_test.dart test/data/attachment_v7_migration_test.dart`

Expected: FAIL because `schemaVersion` is 7 and `sample_batch_id` does not exist.

- [ ] **Step 3: Add the nullable column and additive migration**

Add to `Customers`:

```dart
/// Internal ownership marker for a reversible sample-data import.
TextColumn get sampleBatchId => text().nullable()();
```

Set `schemaVersion => 8`; on create and upgrade create:

```sql
CREATE INDEX IF NOT EXISTS idx_customers_sample_batch
ON customers(sample_batch_id)
WHERE sample_batch_id IS NOT NULL
```

For `from < 8`, use `m.addColumn(customers, customers.sampleBatchId)` and create the index. Add the optional value to `insertCustomer`, and implement batch queries with exact equality.

- [ ] **Step 4: Regenerate Drift code and pass focused tests**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format lib/data test/data/sample_v8_migration_test.dart`

Run: `flutter test test/data/sample_v8_migration_test.dart test/data/migration_test.dart test/data/phase_e_schema_test.dart test/data/attachment_v7_migration_test.dart`

Expected: all selected tests pass.

- [ ] **Step 5: Commit the isolated schema unit**

```bash
git add lib/data/tables/customers.dart lib/data/database.dart lib/data/database.g.dart lib/data/daos/customer_dao.dart lib/data/daos/customer_dao.g.dart test/data/sample_v8_migration_test.dart test/data/migration_test.dart test/data/phase_e_schema_test.dart test/data/attachment_v7_migration_test.dart docs/superpowers/plans/2026-08-06-reversible-sample-data.md
git commit -m "阶段 F-2：建立可撤销示例数据边界"
```

### Task 2: Deterministic Nine-Scenario Service

**Files:**
- Create: `lib/services/sample_data_service.dart`
- Create: `lib/services/sample_data_providers.dart`
- Create: `test/services/sample_data_service_test.dart`

**Interfaces:**
- Produces: `SampleDataService.batchId == 'phase-f-samples-v1'`.
- Produces: `Future<SampleDataState> inspect()` with `customerCount` and `isImported`.
- Produces: `Future<SampleImportResult> importAll()` where result is `imported` or `alreadyImported`.
- Produces: `Future<SampleUndoResult> undoAll()` with deleted customer count and `AttachmentCleanupReport`.
- Consumes: `AppDatabase`, `ReminderScheduler`, `AttachmentGraphCleaner`, and injected `DateTime Function() clock`.

- [ ] **Step 1: Write failing service tests**

Cover these exact behaviors:

1. Empty database reports not imported.
2. Import creates exactly nine marked customers and at least one matching opportunity for each PRD scenario.
3. Scenario-specific rows exist: Medtron connection-tube entry, Antmed mature supplier, Ulrich price sensitivity, high-pressure tube prospect, ordinary syringe tender, first-time tender with medium-high risk and non-exclusive authorization, testing sample, stalled received quote, and completed order with future repurchase.
4. All timestamps are derived from the injected UTC clock so tests have no wall-clock dependency.
5. A second import returns `alreadyImported` and every table count is unchanged.
6. An injected failure during scenario construction rolls back every row in the batch.
7. Undo cancels every open plan id under marked customers, loads all batch attachments, deletes roots in one transaction, and delegates physical cleanup after database commit.
8. Cleanup failure is returned in the report while all marked database rows remain deleted.
9. Formal unmarked customer graphs are unchanged by undo.
10. A renamed marked customer with an added child record is still fully removed.

- [ ] **Step 2: Run the service test and confirm it fails**

Run: `flutter test test/services/sample_data_service_test.dart`

Expected: FAIL because `SampleDataService` does not exist.

- [ ] **Step 3: Implement import atomically**

Use `db.transaction` around the active-batch check and all inserts. Create nine customer roots with `sampleBatchId: batchId`; then use existing DAO methods to create realistic opportunities and the specific quote, sample, tender, order, follow-up, and plan records. Keep sample names prefixed with `示例｜` for user clarity, but never use names as ownership identifiers.

Dates are relative to a single captured `now = clock().toUtc()`:

```dart
DateTime days(int offset) => now.add(Duration(days: offset));
```

Use past dates to surface stalled quote/sample states and future dates for actionable tender and repurchase tasks. Do not schedule platform reminders during import; after commit call `reminderScheduler.rescheduleAll()` so the database is the sole scheduling source.

- [ ] **Step 4: Implement undo with explicit side-effect ordering**

Load marked customer ids, open plan ids, and customer attachment rows first. Cancel each plan id. Then call:

```dart
attachmentCleaner.deleteGraph(
  loadAttachments: () async => attachments,
  deleteDatabaseGraph: () => db.transaction(
    () => db.customerDao.deleteSampleBatchRoots(batchId),
  ),
)
```

If reminder cancellation throws, abort before database deletion so the user can retry without orphaned alarms. If file cleanup fails, return its failure report and keep the database deletion committed; startup orphan cleanup retries the files.

- [ ] **Step 5: Format and pass focused service tests**

Run: `dart format lib/services/sample_data_service.dart lib/services/sample_data_providers.dart test/services/sample_data_service_test.dart`

Run: `flutter test test/services/sample_data_service_test.dart`

Expected: all service tests pass.

- [ ] **Step 6: Commit the isolated service unit**

```bash
git add lib/services/sample_data_service.dart lib/services/sample_data_providers.dart test/services/sample_data_service_test.dart
git commit -m "阶段 F-3：实现九类可撤销示例场景"
```

### Task 3: Explicit Settings UI

**Files:**
- Create: `lib/features/settings/sample_data_page.dart`
- Modify: `lib/features/settings/settings_page.dart`
- Modify: `lib/router.dart`
- Create: `test/features/settings/sample_data_page_test.dart`

**Interfaces:**
- Consumes: `sampleDataStateProvider` and `sampleDataServiceProvider`.
- Route: `/settings/sample-data`.
- Visible commands: `导入 9 条示例数据` when absent and `撤销全部示例数据` when present.

- [ ] **Step 1: Write failing widget tests**

Assert that opening the page performs only `inspect()` and never imports. Tapping import opens a confirmation dialog explaining that nine editable examples will be added; cancellation performs no write. Confirmation disables repeat actions while running, calls `importAll()`, refreshes state, and shows a success message. Imported state shows the batch count and requires a destructive confirmation before `undoAll()`. Failure keeps the current state and shows a retryable SnackBar.

- [ ] **Step 2: Run the widget test and confirm it fails**

Run: `flutter test test/features/settings/sample_data_page_test.dart`

Expected: FAIL because the page and provider do not exist.

- [ ] **Step 3: Implement route, entry tile, and stateful page**

Add a settings tile with `Icons.science_outlined`, title `示例数据`, and a chevron. Build a quiet settings surface with one unframed explanatory section, current status, and one primary command. Use `AlertDialog` for both confirmations; show a progress indicator in the command while a mutation is active and prevent double taps.

- [ ] **Step 4: Pass widget and navigation tests**

Run: `dart format lib/features/settings/sample_data_page.dart lib/features/settings/settings_page.dart lib/router.dart test/features/settings/sample_data_page_test.dart`

Run: `flutter test test/features/settings/sample_data_page_test.dart test/app_skeleton_test.dart`

Expected: all selected tests pass.

- [ ] **Step 5: Commit the isolated UI unit**

```bash
git add lib/features/settings/sample_data_page.dart lib/features/settings/settings_page.dart lib/router.dart test/features/settings/sample_data_page_test.dart
git commit -m "阶段 F-4：接入示例数据管理入口"
```

### Task 4: Acceptance And Handoff

**Files:**
- Modify: `docs/TEST_CHECKLIST.md`
- Modify: `docs/phase4/VERIFICATION.md`

**Interfaces:**
- Produces reproducible automated and Android emulator evidence for import, idempotency, edit tolerance, and undo isolation.

- [ ] **Step 1: Run static analysis**

Run: `flutter analyze`

Expected: `No issues found!`

- [ ] **Step 2: Run the complete automated suite serially**

Run: `flutter test`

Expected: every test passes with no skipped failure hidden by filtering.

- [ ] **Step 3: Build both Android APK variants serially**

Run: `flutter build apk --debug`

Run: `flutter build apk --release`

Record SHA-256 values with `shasum -a 256 build/app/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/app-release.apk`.

- [ ] **Step 4: Smoke test on the retained Android emulator**

Install the debug APK on `emulator-5554`. Verify the database has no sample rows before explicit action; import produces nine visible customers and dashboard/business examples; reopening the page prevents duplicate import; rename one sample customer and add a child record; undo removes the full marked graph while retained formal data remains; restart confirms persistence of the clean state.

- [ ] **Step 5: Document exact evidence and remaining device boundary**

Update the checklist and verification log with command results, test count, APK hashes, emulator/API version, and manual observations. Keep OnePlus 13 / ColorOS 15 as the remaining physical-device gate; sample data itself must not introduce any new provider-specific dependency.

- [ ] **Step 6: Commit the isolated acceptance unit**

```bash
git add docs/TEST_CHECKLIST.md docs/phase4/VERIFICATION.md
git commit -m "阶段 F-5：完成示例数据验收与交接"
```
