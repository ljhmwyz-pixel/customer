# Attachment Deletion Consistency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Execute this plan inline, one task at a time. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure deleting any persisted business record or customer graph commits database deletion before physical attachment cleanup, and reliably retries failed cleanup on the next app startup.

**Architecture:** `AttachmentService` owns the deletion ordering through a callback-based graph deletion API: load paths first, await the caller's database transaction, then delete files and return a stable cleanup report. Failed files become deterministic orphans because their database rows are already gone; startup reconciliation enumerates stored files and subtracts all live database paths, so no schema migration or cleanup queue is needed. Business services retain ownership validation and transaction boundaries while delegating only attachment path cleanup.

**Tech Stack:** Flutter, Dart, Riverpod, Drift/SQLite, `dart:io`, `flutter_test`.

## Global Constraints

- Cover follow-up, order, quote, sample, registration, tender, and full customer-tree deletion.
- Never delete a physical file before its database graph commits successfully.
- A missing physical file is a successful cleanup condition, not a database failure.
- A physical deletion failure must remain discoverable and retryable on the next startup.
- Project deletion remains blocked by any linked follow-up, plan, order, quote, sample, registration, or tender.
- Run Flutter commands serially because concurrent Flutter processes can corrupt shared native build assets.
- Preserve `docs/superpowers/plans/2026-08-06-business-attachments.md` as an unstaged user-owned change.

---

### Task 1: Add graph cleanup and orphan reconciliation

**Files:**
- Modify: `lib/data/daos/attachment_dao.dart`
- Modify: `lib/services/attachment_file_service.dart`
- Modify: `lib/services/attachment_service.dart`
- Modify: `test/services/attachment_file_service_test.dart`
- Modify: `test/services/attachment_service_test.dart`

**Interfaces:**
- Produces: `AttachmentFileStore.listStoredPaths() -> Future<Set<String>>`
- Produces: `AttachmentDao.listOfCustomer(int)` and `AttachmentDao.listOfOpportunity(int)`
- Produces: `AttachmentCleanupReport`, `AttachmentGraphCleaner.deleteGraph(...)`, and `retryOrphanCleanup()`

- [x] Add a failing file-service test that stores two files and expects `listStoredPaths()` to return normalized `attachments/...` paths while ignoring directories.
- [x] Add a failing service test where `deleteDatabaseGraph` throws; assert no physical delete call occurs and the original database exception escapes.
- [x] Add failing service tests proving paths are loaded before the database callback, missing files are non-fatal, and failed file deletions appear in `AttachmentCleanupReport.failedPaths`.
- [x] Add a failing retry test with referenced, orphaned, missing, and delete-failing paths; assert only physical paths absent from `AttachmentDao.listAll()` are cleanup candidates.
- [x] Implement recursive stored-file enumeration below the validated attachment root, without following paths outside that root.
- [x] Add attachment DAO graph queries for customer and opportunity ownership across all six foreign keys.
- [x] Implement `AttachmentGraphCleaner.deleteGraph`: snapshot distinct normalized paths, await the database callback, then map deleted/not-found/failed results into a report.
- [x] Implement startup reconciliation by enumerating physical paths first, loading live database paths second, and deleting only the set difference.
- [x] Run `flutter test test/services/attachment_file_service_test.dart` and `flutter test test/services/attachment_service_test.dart` serially.

### Task 2: Route six record deletions through graph cleanup

**Files:**
- Modify: `lib/data/daos/quote_dao.dart`
- Modify: `lib/data/daos/sample_dao.dart`
- Modify: `lib/data/daos/registration_dao.dart`
- Modify: `lib/data/daos/tender_dao.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/orders/order_providers.dart`
- Modify: `lib/features/business/business_providers.dart`
- Modify: `lib/services/attachment_service_providers.dart`
- Modify: `test/features/customers/customer_service_test.dart`
- Modify: `test/features/orders/order_service_test.dart`
- Modify: `test/features/business/business_service_test.dart`

**Interfaces:**
- Consumes: `AttachmentGraphCleaner.deleteGraph(...)`
- Produces: service deletion methods returning `AttachmentCleanupReport`

- [x] Add test helpers that create attachment rows for every owner type and use a fake file store to observe cleanup.
- [x] Add a failing follow-up deletion test proving ownership validation, database removal, and post-commit physical cleanup.
- [x] Extend the existing order deletion test to prove its attachment is removed only after the order row is gone.
- [x] Add failing quote, sample, registration, and tender deletion tests covering correct ownership and each owner-specific attachment path.
- [x] Add `findById` where absent and owner-specific DAO delete primitives for quote, sample, registration, and tender.
- [x] Inject `AttachmentGraphCleaner` into `CustomerService`, `OrderService`, and `BusinessService`, with Riverpod providers supplying `AttachmentService`.
- [x] Implement the six service deletion methods with ownership checks and database transactions passed to `deleteGraph`.
- [x] Return cleanup reports so UI callers can distinguish committed deletion from physical cleanup warnings without rolling back business state.
- [x] Run the three affected service test files serially.

### Task 3: Make customer-tree deletion and project guards complete

**Files:**
- Modify: `lib/data/daos/opportunity_dao.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/opportunities/opportunity_providers.dart`
- Modify: `lib/services/attachment_service_providers.dart`
- Modify: `test/features/customers/customer_service_test.dart`
- Modify: `test/features/opportunities/opportunity_service_test.dart`

**Interfaces:**
- Consumes: `AttachmentDao.listOfCustomer(int)` and `AttachmentGraphCleaner.deleteGraph(...)`
- Produces: complete project guard and customer-tree cleanup behavior

- [x] Add a failing customer deletion test that seeds attachments under all six record types and asserts all database rows disappear before physical cleanup begins.
- [x] Add a failure test proving a database deletion exception preserves customer data and skips every file delete.
- [x] Keep open-plan reminder cancellation before database deletion, then wrap the customer delete itself in a transaction passed to `deleteGraph`.
- [x] Add parameterized failing project guard cases for quote, sample, registration, and tender.
- [x] Extend `hasLinkedBusinessRecords` SQL, `variables`, and `readsFrom` to all seven linked tables.
- [x] Run customer and opportunity service tests serially.

### Task 4: Retry cleanup during bootstrap and verify the stage

**Files:**
- Modify: `lib/main.dart`
- Create: `test/services/attachment_bootstrap_test.dart`
- Modify: `docs/superpowers/plans/2026-08-06-attachment-deletion-consistency.md`

**Interfaces:**
- Consumes: `AttachmentService.retryOrphanCleanup()`
- Produces: non-blocking startup cleanup with observable debug diagnostics

- [x] Extract an injectable `bootstrapAttachmentCleanup(ProviderContainer)` function and add a failing test proving it invokes reconciliation once.
- [x] Add a failure test proving reconciliation exceptions are contained so the application can still start.
- [x] Invoke attachment cleanup during `main` bootstrap after the shared `ProviderContainer` is created; log failed paths without treating missing files as failures.
- [x] Run all targeted deletion, cascade, service, and bootstrap tests serially.
- [x] Run `dart run build_runner build --delete-conflicting-outputs` if DAO generation requires it, then rerun affected tests.
- [x] Run `flutter analyze`, full `flutter test`, `flutter build apk --debug`, and `git diff --check` serially.
- [x] Mark every completed checklist item, inspect exact changed files, and stop before staging for user confirmation.
