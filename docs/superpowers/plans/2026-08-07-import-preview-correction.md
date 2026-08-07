# Import Preview Correction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to correct validation fields or explicitly exclude bad rows inside the customer/contact import preview, with immediate full-preview revalidation.

**Architecture:** Extend the import domain model with field-aware issues and immutable row replacement, then expose one service method that revalidates an existing row collection. Extract the preview UI into a focused widget that groups issues per line, edits only invalid fields, and reports corrected or removed rows back to the page; the page remains the owner of import state and database submission.

**Tech Stack:** Flutter, Material 3, Riverpod, Drift, `flutter_test`, Dart unit tests

## Global Constraints

- Follow requirements in `docs/REQUIREMENTS_IMPORT_PREVIEW_CORRECTION_2026-08-07.md`.
- Do not change the database schema, import template, record matching rules, or transaction behavior.
- Use failing tests before production implementation.
- Preserve unrelated worktree changes and commit only this phase.
- Physical-device validation is excluded; Android emulator validation remains required.
- Synchronize both `docs/USER_GUIDE.md` and `lib/features/settings/user_guide_page.dart` before commit.

---

### Task 1: Field-Aware Revalidation

**Files:**
- Modify: `test/services/customer_contact_import_service_test.dart`
- Modify: `lib/services/customer_contact_import_service.dart`

**Interfaces:**
- Produces: `CustomerContactImportIssue.field`, `CustomerContactImportRow.withValues(Map<String, String>)`, and `CustomerContactImportService.revalidate(List<CustomerContactImportRow>)`.
- Preserves: original line numbers, untouched values, existing `preview` and `importPreview` contracts.

- [x] **Step 1: Write failing service tests**

Add tests that assert an invalid email issue identifies `联系人邮箱`, replacing only that field preserves the row line/name, and `revalidate` clears the issue. Add a duplicate-number case where editing or removing the duplicate row causes full-preview revalidation to clear the cross-row issue.

- [x] **Step 2: Run service tests and verify RED**

Run: `flutter test test/services/customer_contact_import_service_test.dart`

Expected: compilation fails because `field`, `withValues`, and `revalidate` do not exist.

- [x] **Step 3: Implement immutable correction and shared validation**

Add the field key to every issue, implement `withValues` by copying the map and overriding supplied values, and move the current validation loop into `revalidate`. Make `preview` decode bytes and delegate to `revalidate`, while preserving decoded headers.

- [x] **Step 4: Run service tests and verify GREEN**

Run: `flutter test test/services/customer_contact_import_service_test.dart`

Expected: all service tests pass, including import of corrected values.

### Task 2: Grouped Preview Correction UI

**Files:**
- Modify: `test/features/settings/customer_contact_import_page_test.dart`
- Modify: `lib/features/settings/customer_contact_import_page.dart`

**Interfaces:**
- Consumes: field-aware issues and `CustomerContactImportService.revalidate` from Task 1.
- Produces: public `CustomerContactImportPreviewPanel`, callbacks for corrected and removed rows, and page-owned revalidation.

- [x] **Step 1: Write failing widget tests**

Construct a preview with two issues on one line and assert it renders one grouped error section, current values, a disabled import action, and “修正本行” / “不导入此行”. Exercise correction to verify the callback receives changed values. Exercise row removal and assert cancellation preserves the row while confirmation calls the removal callback.

- [x] **Step 2: Run widget tests and verify RED**

Run: `flutter test test/features/settings/customer_contact_import_page_test.dart`

Expected: compilation fails because the preview panel and callbacks do not exist.

- [x] **Step 3: Implement grouped preview and correction dialog**

Group issues by source line, render one bordered error container per line, and display issue field/message/current value. Use text fields for customer number/name/email and dropdown fields for stage/grade. Return a corrected immutable row only after explicit confirmation. Put row exclusion behind a confirmation dialog.

- [x] **Step 4: Revalidate in the page state**

On correction, replace the matching row and call `service.revalidate`. On removal, filter the row and call `service.revalidate`. Clear stale import results after either action and keep the existing confirmation/import transaction unchanged.

- [x] **Step 5: Run widget tests and verify GREEN**

Run: `flutter test test/features/settings/customer_contact_import_page_test.dart`

Expected: all import-page tests pass with no layout exceptions.

### Task 3: Guides And Full Verification

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`
- Modify: `docs/superpowers/plans/2026-08-07-import-preview-correction.md`

**Interfaces:**
- Documents the exact correction and row-exclusion workflow delivered by Tasks 1 and 2.

- [x] **Step 1: Synchronize both guides**

Document that validation problems are grouped by source row, invalid fields can be corrected in-app, unwanted rows can be excluded only after confirmation, and no import occurs until all retained rows pass validation.

- [x] **Step 2: Format and run focused regression**

Run: `dart format lib test`

Run: `flutter test test/services/customer_contact_import_service_test.dart test/features/settings/customer_contact_import_page_test.dart`

Expected: formatting is stable and focused tests pass.

- [x] **Step 3: Run full verification**

Run: `flutter analyze`

Run: `flutter test`

Run: `flutter build apk --release`

Expected: no analyzer issues, all tests pass, and release APK is produced.

- [x] **Step 4: Validate on Android emulator**

Install the release APK on `emulator-5554`, launch `com.snyder.customer/.MainActivity`, confirm the process remains alive and the activity is resumed, then inspect application logs for fatal crashes.

- [x] **Step 5: Complete plan and create an independent commit**

Mark completed checkboxes, stage only phase-owned changes, run cached diff checks, and commit with:

```bash
git commit -m "feat: correct import preview errors"
```
