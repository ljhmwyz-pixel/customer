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
