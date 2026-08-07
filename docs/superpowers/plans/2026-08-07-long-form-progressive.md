# 注册与招标渐进展开 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (recommended) to execute this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce first-screen complexity in registration and tender forms while preserving every existing field and business rule.

**Architecture:** Add a reusable controlled `FormSection` widget based on `ExpansionTile`. Registration and tender pages own section expansion state and pass stable keys to the section headers. Tender risk inputs update the parent expansion state so the relevant section opens automatically when confirmation becomes necessary.

**Tech Stack:** Flutter Material 3, Riverpod, existing `AppTokens`, Flutter widget tests.

## Global Constraints

- Preserve all existing field `ValueKey`s, service calls, validation messages, and sticky save behavior.
- Keep the action header and delete/attachment routes from the preceding phase unchanged.
- Do not hide any required risk warning or validation result inside a collapsed section.
- Keep 320px width, dark-mode, and keyboard layouts free of overflow.

---

### Task 1: Add The Reusable Section Primitive

**Files:**
- Create: `lib/widgets/form_section.dart`
- Create: `test/widgets/form_section_test.dart`

**Interfaces:**
- Produces: `FormSection({sectionKey, title, child, initiallyExpanded, expanded, onExpansionChanged, hasError})`.

- [x] **Step 1: Write failing widget tests**

  Assert a collapsed section hides its child, tapping `form-section-header-<sectionKey>` reveals it, and `hasError` exposes an error semantic label without changing expansion behavior.

- [x] **Step 2: Run the focused test and confirm failure**

  Run `flutter test test/widgets/form_section_test.dart`; expect compilation failure because the widget does not exist.

- [x] **Step 3: Implement the controlled section**

  Use `ExpansionTile` with `initiallyExpanded` for uncontrolled use, `expanded` for parent-controlled use, `ValueKey('form-section-header-$sectionKey')` on the tile, and a small error icon/label when `hasError` is true.

- [x] **Step 4: Run the focused test**

  Run `flutter test test/widgets/form_section_test.dart`; expect all tests to pass.

### Task 2: Group Registration Fields

**Files:**
- Modify: `lib/features/business/registration_form_page.dart`
- Modify: `test/features/business/phase_e_pages_test.dart`

**Interfaces:**
- Consumes: `FormSection` from Task 1.
- Produces: sections `registration-basic`, `registration-documents`, and `registration-progress` while retaining all existing field keys.

- [x] **Step 1: Write failing section visibility tests**

  Assert registration new page shows `registration-basic` and `registration-progress` content, does not show `registration-document-checklist` until `registration-documents` is expanded, and saving still creates one record.

- [x] **Step 2: Run focused registration tests and confirm failure**

  Run `flutter test test/features/business/phase_e_pages_test.dart`; expect the new section assertions to fail.

- [x] **Step 3: Move fields into sections**

  Keep country, status, current obstacle, and next action in the initially expanded sections. Put requirements, checklist, document status, dates, cost bearer, due date, milestone date, and title in the documents section, initially collapsed. Do not alter `_save`.

- [x] **Step 4: Run focused registration tests**

  Run `flutter test test/features/business/phase_e_pages_test.dart`; expect existing validation and save tests plus section tests to pass.

### Task 3: Group Tender Fields And Auto-Open Risk

**Files:**
- Modify: `lib/features/business/tender_form_page.dart`
- Modify: `test/features/business/phase_e_pages_test.dart`

**Interfaces:**
- Consumes: `FormSection` from Task 1.
- Produces: sections `tender-basic`, `tender-qualification`, and `tender-risk` with automatic risk-section expansion.

- [x] **Step 1: Write failing tender section tests**

  Assert basic fields are visible, qualification and authorization fields are hidden until their headers are tapped, and high-risk floor-price input automatically reveals the risk confirmation section.

- [x] **Step 2: Run focused tender tests and confirm failure**

  Run `flutter test test/features/business/phase_e_pages_test.dart`; expect the section assertions to fail.

- [x] **Step 3: Move fields and wire expansion state**

  Keep project number, name, deadline, and status in basic. Put document/qualification/bidder/deposit/experience/team/funding in qualification. Put risk, authorization, expiry, exclusive scope, floor-price support, next action, and risk confirmation in risk. When `_requiresRiskAcknowledgement` becomes true, set the controlled risk section to expanded.

- [x] **Step 4: Run focused business tests**

  Run `flutter test test/features/business/phase_e_pages_test.dart`; expect risk validation, narrow-layout, and section tests to pass.

### Task 4: Sync Guides And Verify

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`
- Modify: `docs/superpowers/plans/2026-08-07-long-form-progressive.md`

- [x] **Step 1: Update both guides**

  Explain that registration and tender forms open core fields first and allow details to be expanded without losing values; mention automatic risk-section expansion.

- [x] **Step 2: Run verification**

  Run `dart format`, focused tests, `flutter analyze`, full `flutter test`, `flutter build apk --release`, and `git diff --check`.

- [x] **Step 3: Check the emulator**

  Install the release APK on `emulator-5554` and inspect a narrow registration or tender form for section headers, risk expansion, and sticky save.

- [x] **Step 4: Commit**

  Commit as `feat: progressively disclose long business forms`.
