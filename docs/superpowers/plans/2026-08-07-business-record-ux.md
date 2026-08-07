# 业务记录维护体验 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make attachments, deletion, current status, and save actions directly reachable from quote, sample, registration, and tender maintenance pages.

**Architecture:** Add one Riverpod-aware shared action header that renders record context, watches the existing attachment-count provider, routes to the existing attachment page, and owns delete confirmation/progress/error behavior. Each record page supplies its existing service delete callback and handles customer refresh plus return navigation. Reuse `StickyFormScaffold` so primary save actions remain reachable without changing record-specific validation.

**Tech Stack:** Flutter Material 3, Riverpod, GoRouter, Drift, existing attachment providers and business services, Flutter widget tests.

## Global Constraints

- Preserve the existing database schema, business status rules, task synchronization, and attachment owner types.
- Show record actions only when a persisted record id exists.
- Keep quote number, version, and amount immutable.
- Keep all Chinese user-facing copy concise and consistent.
- Exclude physical-device validation; use automated tests, release build, and Android emulator validation.

---

### Task 1: Specify And Lock Shared Actions

**Files:**
- Create: `lib/widgets/business_record_actions.dart`
- Create: `test/widgets/business_record_actions_test.dart`

**Interfaces:**
- Consumes: `AttachmentOwnerRoute`, `attachmentCountProvider`, `AttachmentCleanupReport`, and GoRouter navigation.
- Produces: `BusinessRecordActions({title, statusLabel, contextLabel, attachmentOwner, onDelete, onDeleted, enabled})`.

- [x] **Step 1: Write failing widget tests**

  Assert the header renders title/status/context, “附件（2）” opens `attachmentOwner.location`, cancel leaves `onDelete` untouched, and confirm invokes deletion exactly once.

- [x] **Step 2: Run the focused test and confirm failure**

  Run `flutter test test/widgets/business_record_actions_test.dart`; expect failure because `BusinessRecordActions` does not exist.

- [x] **Step 3: Implement the shared action header**

  Use an unframed `Column` with a `ListTile` context row and two full-width actions in a responsive `Wrap`. Watch `attachmentCountProvider`, show a destructive confirmation dialog, disable both actions while deleting, surface stable failure text, and pass the cleanup report to `onDeleted`.

- [x] **Step 4: Run the focused test**

  Run `flutter test test/widgets/business_record_actions_test.dart`; expect all tests to pass.

### Task 2: Integrate Four Record Pages

**Files:**
- Modify: `lib/features/business/quote_outcome_page.dart`
- Modify: `lib/features/business/sample_form_page.dart`
- Modify: `lib/features/business/registration_form_page.dart`
- Modify: `lib/features/business/tender_form_page.dart`
- Modify: `test/features/business/business_pages_test.dart`
- Modify: `test/features/business/phase_e_pages_test.dart`

**Interfaces:**
- Consumes: `BusinessRecordActions` from Task 1 and existing `BusinessService.deleteQuote/deleteSample/deleteRegistration/deleteTender` methods.
- Produces: direct attachment/delete operations and sticky saves on all four maintenance pages.

- [x] **Step 1: Write failing page integration tests**

  Seed each persisted record type and assert its edit page exposes `business-record-attachments` and `business-record-delete`. Assert corresponding new-record pages expose neither action.

- [x] **Step 2: Run focused business-page tests and confirm failure**

  Run `flutter test test/features/business/business_pages_test.dart test/features/business/phase_e_pages_test.dart`; expect missing action keys.

- [x] **Step 3: Wire quote and sample pages**

  Supply quote number/version/received state or sample model/status to the shared header. Call the matching delete service, refresh `customerRevisionProvider`, navigate to `/customers/{customerId}`, and display the attachment cleanup warning when required. Move primary save actions into `StickyFormScaffold` while retaining quote version creation in body content.

- [x] **Step 4: Wire registration and tender pages**

  Supply country/status or tender name/project number/status to the shared header. Use the same delete/refresh/navigation sequence and move each save button into `StickyFormScaffold` without changing validation.

- [x] **Step 5: Run focused tests**

  Run `flutter test test/widgets/business_record_actions_test.dart test/features/business/business_pages_test.dart test/features/business/phase_e_pages_test.dart`; expect all tests to pass.

### Task 3: Documentation And End-To-End Verification

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`

**Interfaces:**
- Consumes: completed UI behavior from Tasks 1 and 2.
- Produces: matching repository and in-app instructions.

- [x] **Step 1: Synchronize both guides**

  Explain that existing quote/sample/registration/tender maintenance pages show status, attachment count, delete action, and a fixed save button; note that deletion removes related attachments and cannot be undone.

- [x] **Step 2: Run static and automated verification**

  Run `dart format`, `flutter analyze`, full `flutter test`, `flutter build apk --release`, and `git diff --check`.

- [x] **Step 3: Validate in the Android emulator**

  Install the release APK on `emulator-5554`; inspect at least one 320-360px-wide long edit form and one quote/sample page for visible, non-overlapping attachment/delete/save controls.

- [x] **Step 4: Commit the isolated phase**

  Stage only this phase and commit with `feat: unify business record actions`.
