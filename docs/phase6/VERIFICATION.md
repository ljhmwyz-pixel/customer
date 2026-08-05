# Phase 6–7 Verification Record

## Stage 7: Opportunity CRUD and Customer Detail Integration

Date: 2026-08-05

Scope verified:

- Opportunity DAO full-field updates and a single linked-record existence query.
- Opportunity service normalization, validation, customer ownership checks, and protected deletion.
- Customer detail aggregation and display of all projects, including migrated/default projects.
- Create/edit project routes and the complete project form defined by the Stage 7 plan.
- Forecast and weighted amounts use integer minor units without floating-point arithmetic.
- Existing narrow 320px dark-mode customer-detail coverage remains active.

Fresh verification evidence:

- `dart format`: 9 files checked, no formatting changes required.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 175 tests passed, zero failures.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk`.
- `git diff --check`: passed with no whitespace errors.

Manual-risk boundaries:

- This stage does not add project selection to follow-ups, plans, or orders; existing flows continue to use the compatibility project.
- Quote, sample, registration, tender, dashboard, automatic-task, and five-field synchronization workflows remain outside this stage.
- Device-specific visual and keyboard behavior should receive a physical-device smoke test before release packaging.

## Stage 8: Project Follow-ups and Five-field Synchronization

Date: 2026-08-05

Fresh automated evidence:

- `dart run build_runner build --delete-conflicting-outputs`: exit 0, 14 outputs written; the installed build_runner reports that the legacy flag is removed and ignores it.
- `dart format`: all 13 changed Dart files formatted.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 188 tests passed, zero failures.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk` (about 183 MB).
- `flutter test test/features/customers/customer_pages_test.dart`: 18 tests passed, including single/multiple projects, pause validation, immutable snapshots, and 320px dark mode.
- `flutter test test/features/customers/customer_service_test.dart`: 19 tests passed, including ownership, synchronization, project isolation, backdated records, pauses, and scheduler degradation.

Android emulator evidence:

- Device: Pixel 8 AVD (`emulator-5554`), Android API 37.
- Upgrade command: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`. No uninstall or app-data clear was performed.
- Cold launch completed with `LaunchState: COLD`; logcat contained no Flutter or Android runtime errors.
- Existing 131072-byte `customer.sqlite`, eight visible customers, existing plans, and migrated `历史项目` records remained available after upgrade.
- Read-only database copy reported `PRAGMA user_version = 3` and all five follow-up snapshot columns.
- The single-project form displayed `项目：历史项目` and initialized its stage from that project.
- A scheduled follow-up was saved on the migrated project. The database snapshot has a non-null `opportunity_id`, feedback, stage, next action, and next-follow time; the same project received the latest-state values and a linked plan.

Remaining device-only checks before the Stage 8 commit:

- Complete a reliable multi-project selector switch on the emulator and confirm the selected project alone changes.
- Save a paused follow-up on the emulator, confirm the required pause reason, no new plan, and two independently visible history rows.

These remaining paths are covered by widget and service tests, but are intentionally not recorded as manual emulator passes.

## Stage 9A: Task Data Foundation v4

Date: 2026-08-05

Scope verified:

- Additive v3-to-v4 migration for customer country, project owner/importance, task source/rule identity, task snapshots, and cancellation timestamp.
- `PlanStatus.cancelled` terminal behavior and explicit open-task query filtering.
- Strict service-level project ownership and task snapshot validation, with a compatibility adapter retained only for low-level reminder fixtures.
- Follow-up-generated task identity and de-duplication: `followup + followupId + next_followup`.
- Cancellation persistence before notification cleanup, including scheduler-failure warning behavior.

Fresh automated evidence:

- `dart run build_runner build --delete-conflicting-outputs`: exit 0; installed build_runner reports that the legacy flag is ignored.
- `dart format`: 15 files checked, 4 formatted.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 195 tests passed, zero failures.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk`.
- Focused migration, DAO, service, and notification tests all passed; the generated follow-up task fields, unique source/rule index, cancellation terminal state, and historical backfill are covered.

Android emulator evidence:

- Device: Pixel 8 AVD (`emulator-5554`), Android API 37.
- Upgrade command: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`. No uninstall or app-data clear was performed.
- Cold start completed after force-stop/launch. Logcat contained Flutter startup output and no `FATAL EXCEPTION`, `SQLiteException`, or Drift error.
- Read-only database copy reported `PRAGMA user_version = 4`, an empty `PRAGMA foreign_key_check`, `idx_plans_source_rule`, all v4 task columns, and 9 customers / 9 projects / 9 tasks retained.
- Existing task/reminder rows remained available after upgrade; legacy tasks retained `source_type = legacy`, `owner = 本人`, and their original ids/statuses/timestamps.

Manual-risk boundaries:

- The emulator pass this stage records migration and cold-start preservation. Follow-up-generated v4 field values and cancellation behavior are covered by service/DAO tests rather than a second manual data mutation on the existing user database.
- The Today presentation, task sorting UI, and management statistics remain reserved for stages 9B and 9C.

## Stage 9B: Today Task Dashboard

Date: 2026-08-05

Fresh automated evidence:

- `dart run build_runner build --delete-conflicting-outputs`: exit 0; installed build_runner reports the legacy flag is ignored.
- `dart format`: changed Stage 9B Dart files formatted.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 199 tests passed, zero failures.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk`.
- `git diff --check`: passed with no whitespace errors.

Stage coverage:

- `PlanDao.listToday` joins customer/project data, excludes future and closed/lost projects, and applies deterministic overdue/grade/importance/time/id ordering.
- Today rows expose project, product, feedback, reason, talking direction, next action, owner, country-safe customer text, and timing.
- Home actions complete or cancel tasks through `CustomerService`, preserving rows and cleaning reminders with warnings on scheduler failure.
- Widget coverage verifies future-task exclusion and narrow-page rendering; service coverage verifies completion timestamps and reminder cleanup degradation.

Android emulator evidence:

- Device: Pixel 8 AVD (`emulator-5554`), Android API 37.
- Upgrade: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`, no data clear.
- Cold launch: `adb -s emulator-5554 shell monkey -p com.snyder.customer 1`; launch completed, no `FATAL EXCEPTION`, `SQLiteException`, or Drift error.
- Screenshot captured at `/tmp/customer-stage9b.png` for manual visual inspection.

Manual-risk boundary: the emulator pass confirms install and cold-start compatibility; task action taps remain covered by widget/service tests.

## Stage 9C: Management Dashboard and Supported Anomalies

Date: 2026-08-05

Fresh automated evidence:

- `dart run build_runner build --delete-conflicting-outputs`: exit 0; installed build_runner reports the legacy flag is ignored.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 202 tests passed, zero failures.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk`.
- `git diff --check`: passed with no whitespace errors.

Delivered scope:

- Typed aggregate metrics for customer totals/grades, active project stages, current-week follow-ups, three-month forecast, weighted forecast, and completed-order revenue.
- Explainable long-silence and internal-support anomaly queries with customer/project drill-down targets.
- Funnel placeholder replaced by a compact dashboard; unsupported quote/sample/registration/tender/repurchase categories are explicitly marked unavailable rather than shown as false zeroes.
- Widget coverage includes metric labels, anomaly display, and unsupported-module copy.

Android emulator evidence:

- Device: Pixel 8 AVD (`emulator-5554`), Android API 37.
- Upgrade: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`, no data clear.
- Cold launch: `adb -s emulator-5554 shell monkey -p com.snyder.customer 1`; no `FATAL EXCEPTION`, `SQLiteException`, or Drift error in the inspected logcat window.
- Screenshot captured at `/tmp/customer-stage9c.png` for visual inspection.

Manual-risk boundary: quote/sample/registration/tender/repurchase metrics remain unavailable until their source entities exist; target-device seven-day reminder validation remains a later release gate.

## Stage D: Quote, Sample, and Automatic Task Rules

Date: 2026-08-05

Fresh automated evidence:

- `dart run build_runner build --delete-conflicting-outputs`: exit 0; installed build_runner reports the legacy flag is ignored.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 210 tests passed, zero failures.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk`.
- `git diff --check`: passed with no whitespace errors.

Delivered scope:

- v4-to-v5 additive migration with quote-version and sample-lifecycle tables, constraints, indexes, and preservation of legacy business rows.
- Quote DAO/service supports immutable versions, latest lookup, amount/date validation, and opportunity ownership checks.
- Sample DAO/service preserves sent/delivered/testing/result milestones and validates lifecycle dates.
- Quote/sample automatic tasks use source/rule identity, weekday-aware quote milestones, sample milestone rules, closed-project suppression, and reminder scheduling after persistence.
- Customer project entries open compact quote/sample forms with stable test keys and provider invalidation.

Android emulator evidence:

- Device: Pixel 8 AVD (`emulator-5554`), Android API 37.
- Upgrade: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`, no data clear.
- Cold launch: `adb -s emulator-5554 shell monkey -p com.snyder.customer 1`; no `FATAL EXCEPTION`, `SQLiteException`, or Drift error in the inspected logcat window.
- Screenshot captured at `/tmp/customer-stageD.png`.

Manual-risk boundary: quote/sample forms currently provide core creation and milestone persistence; full history timeline presentation and Phase E registration/tender/order decomposition/repurchase remain later work.

## Stage E: Registration, Tender, Order Lifecycle, and Repurchase

Date: 2026-08-05

Fresh source and package evidence:

- `dart run build_runner build --delete-conflicting-outputs`: exit 0 with 166 outputs; generated files had no uncommitted drift.
- `dart format --output=none --set-exit-if-changed lib test`: 109 files checked, 0 changed.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 240 tests passed, zero failures. The suite includes migration, schema, DAO, service, task-rule, and Widget coverage for Phase E.
- `flutter build apk --debug`: generated `build/app/outputs/flutter-apk/app-debug.apk`, 192328026 bytes, SHA-256 `a1895727eb452634813aa75fab87922ba6e97a8e60e954b313875f049b812755`.

Retained-data Android emulator migration evidence:

- Device: `sdk_gphone16k_arm64` AOSP emulator (`emulator-5554`), Android API 37; package `com.snyder.customer`.
- Before upgrade, a fresh read-only copy of `app_flutter/customer.sqlite` reported SHA-256 `5ef5ff356b75d9e41882e6ed6fd7b632bc7e2e9cfca39535a52b39068c6df084`, `PRAGMA user_version = 5`, 9 customers, 9 opportunities, 0 orders, an empty `PRAGMA foreign_key_check`, and no registration or tender tables.
- Upgrade used `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`. The package was not uninstalled and its application data was not cleared.
- After force-stop and cold launch, `topResumedActivity` was `com.snyder.customer/.MainActivity`. The inspected logcat window contained no `FATAL EXCEPTION`, `SQLiteException`, or Drift migration error.
- After upgrade, a fresh database copy reported SHA-256 `b6bc45dfa73247d06817271e811f56fc79d5cb28bc294a3a522d4f02fc3e4a33`, `PRAGMA user_version = 6`, 9 customers, 9 opportunities, 0 orders, and an empty `PRAGMA foreign_key_check`.
- The upgraded database contains the registration and tender tables and indexes, plus the decomposed payment, production, shipping, result, arrival, and repurchase order columns.
- The retained emulator database contained no v5 orders, so it does not prove the five legacy-order mappings. `test/data/migration_test.dart` supplies that evidence with controlled v5 rows for `pending`, `shipped`, `paid`, `completed`, and `cancelled`, asserting the fixed v6 mapping and preservation of legacy fields.

Read-only emulator UI observations:

- Home loaded the retained tasks and showed `逾期 3 · 今天 1`, four task rows, customer/project/next-action/owner context, and all four bottom navigation destinations.
- Customer list and customer detail loaded retained data. The inspected customer showed project `历史项目 · 新线索 · 活跃`, its next action, quote/sample/project actions, the order entry, two follow-up plans, and the follow-up entry.
- The registration route exposed country/region, requirements, document checklist and status, submitted/expected/actual dates, cost bearer, registration status, blocker, next action, document deadline, and user milestone fields. Defaults and the save entry were visible; no acceptance-only record was saved.
- The tender route exposed project identity, bid deadline, document and qualification status, bidder, deposit, experience, local-team and funding checks, risk, authorization, authorization expiry, exclusive quote scope, floor-price support, tender status, next action, and save entry. High-risk controls were visible; no acceptance-only record was saved.
- The order route exposed generated order number, order date, amount, PI/PO number, currency, independent payment/production/shipping states, estimated arrival, result, estimated repurchase date, description, and save entry. The actual-arrival field was not claimed as manually observed in this pass; persistence and lifecycle behavior remain covered by source and automated tests.
- The management dashboard loaded against the upgraded database and reported 9 customers (`A 0 · B 0 · C 9 · D 0`), two current-week follow-ups, zero three-month forecast/weighted forecast/completed revenue, and the anomaly section.
- The anomaly section correctly rendered its empty state because this retained database has no registration, tender, or due-repurchase anomaly rows. Specific overdue-registration, imminent-tender, and due-repurchase cards and navigation are covered by `test/features/funnel/funnel_page_test.dart`, not claimed as manual emulator observations.

SPRD coverage evidence:

- Sections 5.7–5.9: the registration, tender, and decomposed order fields are represented by schema, service, form, and Widget coverage; records are scoped to a real customer-owned opportunity.
- Sections 6.2, 7.4, and 7.5: registration milestones, tender deadline boundaries, and repurchase rules use stable source/rule identities, suppress ineligible closed states, persist before scheduling, and retain persisted tasks if scheduling fails.
- Section 12: the dashboard integrates supported overdue registration, imminent tender, and due repurchase anomalies with customer/project context; unsupported or absent data is not presented as a false positive.
- Sections 17 and 18: integer minor-unit money, explicit currency, date/ownership validation, tender qualification/authorization prerequisites, default risk, explicit high-risk acknowledgement, and the fixed v5 order migration mapping are exercised by automated tests.

Remaining target-device and time-based boundaries:

- This AOSP emulator does not substitute for the required OnePlus 13/ColorOS permission, notification, keyboard, and visual smoke test.
- A real seven-day reminder observation window has not elapsed; scheduling boundaries, idempotency, and failure degradation are automated-test evidence only until that release gate is completed.
- No acceptance-only registration, tender, or order rows were inserted into the retained user database during this pass.
