# Phase E End-to-End Verification Plan

> **Execution rule:** Complete the checklist in order. Preserve the emulator's existing application data, record fresh evidence for every acceptance claim, and commit only the three Phase E verification documents after all checks pass.

**Goal:** Prove that the completed Phase E implementation matches the applicable SPRD requirements, passes the full automated suite, and upgrades the configured Android emulator from the retained v5 database to v6 without data loss.

**Architecture:** Treat automated tests, the AOSP emulator, and later ColorOS target-device validation as separate evidence layers. Use the retained emulator database for a real v5→v6 additive migration and row-preservation check. Use the controlled v5 migration fixture for the five-state order mapping because the retained emulator database has no legacy order rows. Exercise the implemented UI paths without adding acceptance-only production code.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Drift 2.34.3, SQLite, Android Debug Bridge, Android API 37 emulator.

## Step 1: Lock the pre-upgrade baseline

- [x] Confirm the configured emulator and installed package without uninstalling or clearing application data.
- [x] Export `app_flutter/customer.sqlite` to `/tmp/customer-before-e6.sqlite` through `run-as`.
- [x] Record `PRAGMA user_version = 5`, an empty foreign-key check, and retained row counts: 9 customers, 9 opportunities, 0 orders.
- [x] Confirm the v5 database has no `registrations` or `tenders` tables and has only the legacy order lifecycle fields plus `opportunity_id`.
- [x] State explicitly that the empty emulator order table cannot prove the five legacy-status mappings; retain the controlled v5 migration test as that evidence.

## Step 2: Validate source and produce a fresh APK

- [x] Run Drift/build generation: exit 0 with 166 outputs and no uncommitted generated-code drift.
- [x] Run `dart format --output=none --set-exit-if-changed lib test`: 109 files checked, 0 changed.
- [x] Run `flutter analyze`: `No issues found!`.
- [x] Run the complete `flutter test` suite serially: 240 tests passed.
- [x] Run `flutter build apk --debug`: `build/app/outputs/flutter-apk/app-debug.apk`, 192328026 bytes, SHA-256 `a1895727eb452634813aa75fab87922ba6e97a8e60e954b313875f049b812755`.

## Step 3: Perform the retained-data v5→v6 upgrade

- [x] Install the fresh APK with `adb install -r`; result `Success`, with no uninstall or application-data clear.
- [x] Force-stop and cold-start the app; the inspected logcat window contained no `FATAL EXCEPTION`, `SQLiteException`, or Drift migration error.
- [x] Export the upgraded database and confirm `PRAGMA user_version = 6` plus an empty `PRAGMA foreign_key_check`.
- [x] Confirm the original 9 customers and 9 opportunities remain and the original 0-order count is unchanged.
- [x] Confirm `registrations` and `tenders`, their indexes, and all decomposed order lifecycle columns exist.
- [x] Run the controlled v5 migration coverage in the complete suite to prove the exact pending/shipped/paid/completed/cancelled mapping and legacy-field preservation.

## Step 4: Verify Phase E behavior and SPRD coverage

- [x] Inspect emulator paths for home tasks, customer/project context, registration, tender, decomposed order/repurchase fields, and dashboard anomalies without saving acceptance-only records.
- [x] Record manual emulator observations separately from Widget, service, DAO, and migration-test evidence; the unobserved actual-arrival control, concrete anomaly cards, and five-state migration are not claimed as manual passes.
- [x] Compare fields and business rules against SPRD sections 5.7, 5.8, 5.9, 6.2, 7.4, 7.5, 12, 17, and 18.
- [x] Record target-device-only boundaries, including OnePlus 13/ColorOS behavior and seven-day notification observation.

## Step 5: Record, re-verify, and commit

- [x] Append fresh commands, results, migration evidence, UI evidence, SPRD mapping, and remaining boundaries to `docs/phase6/VERIFICATION.md`.
- [x] Mark supported E-6 items complete in the parent Phase E plan and preserve honest boundaries for evidence that cannot be produced on this emulator.
- [x] Scan Phase E source, tests, and documents for unresolved implementation markers; no in-scope placeholders remain.
- [x] Run final formatting, analysis, full tests, `git diff --check`, and a focused review of the staged diff.
- [x] Stage only the E-6 plan and verification documents, then commit `阶段 E-6：完成注册招标订单复购验收` locally without pushing.
