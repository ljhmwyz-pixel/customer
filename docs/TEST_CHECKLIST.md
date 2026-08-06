# Release Test Checklist

## Attachments

### Automated gate

- [x] Fresh v7 schema accepts exactly one of six attachment owners and rejects zero or multiple owners.
- [x] Controlled v6-to-v7 migration preserves follow-up/order attachments and passes `PRAGMA foreign_key_check`.
- [x] Relative-path validation prevents absolute paths and attachment-root escapes.
- [x] Ordinary files copy byte-for-byte; images use orientation correction, 1920px bounds, and bounded quality attempts.
- [x] Add failures remove newly written files without hiding the database error.
- [x] Single-attachment and graph deletion commit database state before physical cleanup.
- [x] Missing files are non-fatal; failed deletes remain deterministic startup-cleanup candidates.
- [x] Customer-tree deletion covers follow-up, order, quote, sample, registration, and tender attachments.
- [x] Project deletion is blocked by follow-ups, plans, orders, quotes, samples, registrations, or tenders.
- [x] Attachment pages cover loading, empty, populated, error, add, preview, open, confirmation, 320px, and dark-mode states.
- [x] `flutter analyze`, full `flutter test`, debug APK, and release APK complete successfully.

## Reversible Sample Data

### Automated gate

- [x] Fresh schema is v8 with nullable internal `customers.sample_batch_id` and a partial lookup index.
- [x] v7-to-v8 migration preserves formal customers with a null sample marker and passes `PRAGMA foreign_key_check`.
- [x] Nine PRD scenarios import atomically with deterministic UTC-clock data and realistic opportunity, follow-up, plan, quote, sample, tender, and order rows.
- [x] Re-import is idempotent and does not reschedule reminders or change any table count.
- [x] A collision in the final scenario rolls back all nine customer graphs.
- [x] Undo finds roots by the internal marker after customer edits, cancels open reminders, deletes database graphs transactionally, and delegates attachment file cleanup after commit.
- [x] Formal customers remain untouched; physical cleanup failures are reported for startup retry.
- [x] Settings page requires explicit confirmation for import and undo and keeps state on mutation failure.
- [x] `flutter analyze` and full `flutter test` complete successfully after the sample-data stage.

### Android emulator

- [x] Install debug APK with `adb install -r` without clearing retained attachment data.
- [x] Settings > 示例数据 initially shows `尚未导入` and performs no write automatically.
- [x] Confirmed import shows `已导入 9 条`; customer list displays sample customers.
- [x] Force-stop and cold-start preserve the imported batch state.
- [x] Confirmed undo returns to `尚未导入` and reports `已撤销 9 条示例数据`.

### OnePlus 13 / ColorOS 15

- [ ] Repeat explicit import, edit, restart, and whole-batch undo on the target device.

### Android emulator

- [x] Install debug APK with `adb install -r` without uninstalling or clearing retained data.
- [x] Cold start reaches `com.snyder.customer/.MainActivity` without Flutter, Drift, SQLite, or Android runtime fatal logs.
- [x] Retained database reports schema v7 and an empty `PRAGMA foreign_key_check`.
- [x] Import an image through the Android photo picker and display its real name, MIME type, and size.
- [x] Open the imported image in the in-app zoomable preview and confirm the rendered image is nonblank.
- [x] Import an ordinary file through `ACTION_OPEN_DOCUMENT` and display its real name, MIME type, and size.
- [x] Open the ordinary file through an available external application.
- [x] Force-stop and cold-start the application; confirm attachment rows and physical files remain visible.
- [x] Confirm attachment deletion in the UI and verify the row and private file both disappear.
- [x] Import and open a PDF through an installed PDF application.

### OnePlus 13 / ColorOS 15

- [ ] Capture an image with the real camera and verify orientation, preview, persisted size, and restart survival.
- [ ] Import image and document files from ColorOS providers, including a cloud-backed provider if used in production.
- [ ] Open PDF and ordinary files with the target device's installed applications.
- [ ] Delete each tested attachment and confirm private files are removed.
- [ ] Repeat after process exit and device restart.

## Release Boundary

- Emulator evidence validates Android platform integration but does not replace ColorOS provider, camera, permission, or external-application compatibility checks.
- Do not mark the attachment feature as target-device complete until every OnePlus 13 / ColorOS 15 item above is checked.

## Excel Export

### Automated gate

- [x] Export snapshot reads all four workspaces transactionally and retains legacy orders without a project link.
- [x] Workbook contains exactly four named Chinese sheets with typed dates, amounts, percentages, formulas, frozen headers, filters, and status rules.
- [x] File adapter writes atomically, uses the XLSX MIME type, and keeps a retryable final file when sharing fails.
- [x] Settings entry requires an explicit tap, blocks duplicate taps while generating, and exposes success/failure states.
- [x] `flutter analyze` reports no issues; full `flutter test` passes 420 tests.
- [x] Debug and release APKs build successfully.
- [x] Empty workbook opens and re-saves successfully through LibreOffice Calc headless.

### OnePlus 13 / ColorOS 15

- [ ] Verify the Android Sharesheet receives the XLSX MIME type and a nonempty workbook.
- [ ] Verify a compatible spreadsheet application opens all four sheets and preserves Chinese text, formulas, and typed values.

## Backup and Restore

### Automated gate

- [x] Backup ZIP contains `customer.sqlite`, `data.json`, all private attachment files, schema version, and SHA-256 checksums.
- [x] Restore rejects missing manifest/data, incompatible schema, invalid SQLite headers, corrupt SQLite integrity, missing attachment entries, and checksum mismatches.
- [x] Restore stages database and attachments before startup replacement and consumes pending state only once.
- [x] Startup replacement removes stale WAL/SHM files and preserves the existing database when staging validation fails.
- [x] Application startup calls the existing reminder `rescheduleAll()` flow after the restored database is opened.
- [x] Backup/restore service and settings-page tests pass with the full test suite.

### Local acceptance

- [x] Debug APK builds successfully with the backup/restore entry point.
- [x] File-level end-to-end test backs up a real v8 SQLite file plus attachment, restores into another application directory, and verifies the database, attachment, and consumed pending state.

### Target device boundary

- [ ] Verify backup sharing and restore file selection through OnePlus 13 / ColorOS 15 providers.
