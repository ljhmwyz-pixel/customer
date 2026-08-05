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
