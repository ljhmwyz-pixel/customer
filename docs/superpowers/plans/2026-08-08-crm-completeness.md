# CRM Completeness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use verification-before-completion before claiming this plan is complete. Execute inline because the user requested implementation in the current workspace.

**Goal:** Close the highest-value remaining single-device CRM gaps by exposing manual task creation, preserving key opportunity changes, and making automatic task reconciliation durable and recoverable.

**Architecture:** Upgrade Drift to schema v11 with append-only opportunity change rows and a persistent per-opportunity task reconciliation queue. Reuse the existing customer service and reminder scheduler for manual tasks, surface history in the customer activity tab, and expose queued automatic-task repair on the home page and startup path.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift/SQLite, flutter_test

## Global Constraints

- Preserve all existing uncommitted contact snapshot, release hardening, dashboard, and sample-data visibility changes.
- Keep the app offline-only and single-user; add no cloud, account, analytics, or network dependency.
- Existing business records must remain durable even if automatic task generation or Android scheduling fails.
- Schema migration must be additive and preserve v1-v10 upgrade behavior.
- Follow existing compact Material UI patterns and support narrow light/dark viewports.

---

### Task 1: Manual task creation

**Files:**
- Create: `lib/features/customers/plan_form_page.dart`
- Modify: `lib/router.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Modify: `lib/features/settings/user_guide_page.dart`
- Test: `test/features/customers/customer_pages_test.dart`
- Test: `test/features/customers/customer_service_test.dart`

**Interfaces:**
- Consumes: `CustomerService.createPlan(int customerId, PlanDraft draft)` and `customerDetailProvider`.
- Produces: route `/customers/:id/plans/new` and a customer activity-tab action labelled `新建任务`.

- [x] Add a failing widget test proving the activity tab exposes a manual task action and validates required project, reason, direction, action, owner, date, and time fields.
- [x] Add `PlanFormPage` using the existing form section, date/time picker, unsaved-changes guard, and first-error navigation patterns.
- [x] Route the page under the customer detail branch and refresh customer/home providers after a successful scheduled save.
- [x] Add focused service coverage for reminder-scheduling warnings without rolling back the persisted plan.
- [x] Run the focused customer page and service tests.

### Task 2: Opportunity change history and schema v11

**Files:**
- Create: `lib/data/tables/opportunity_changes.dart`
- Create: `lib/data/daos/opportunity_change_dao.dart`
- Modify: `lib/data/database.dart`
- Generate: `lib/data/database.g.dart`
- Generate: `lib/data/daos/opportunity_change_dao.g.dart`
- Modify: `lib/features/opportunities/opportunity_providers.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Test: `test/data/opportunity_change_v11_migration_test.dart`
- Test: `test/features/customers/customer_service_test.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Produces: `OpportunityChangeDao.recordChanges(...)`, `listOfCustomer(int)`, and append-only `OpportunityChangeRow` values.
- Tracks: name, owner, stage, status, forecast amount/currency, probability, expected close, obstacle, next action, and next follow date when changed through the opportunity editor.

- [x] Add a failing v10-to-v11 migration test proving both new tables are created without changing existing customer history.
- [x] Add table, DAO, database registration, indexes, and additive v11 migration.
- [x] Add failing opportunity-service tests for changed-only history rows and no-op updates.
- [x] Update opportunity writes transactionally so the current row and its change rows commit together.
- [x] Load changes in `CustomerDetailData` and render them chronologically in the activity tab with field-aware labels and values.
- [x] Run migration, service, and customer page tests.

### Task 3: Durable automatic-task reconciliation

**Files:**
- Create: `lib/data/tables/task_reconciliation_jobs.dart`
- Modify: `lib/data/daos/plan_dao.dart`
- Modify: `lib/data/database.dart`
- Generate: `lib/data/database.g.dart`
- Generate: `lib/data/daos/plan_dao.g.dart`
- Modify: `lib/services/business_task_rules.dart`
- Modify: `lib/features/business/business_providers.dart`
- Modify: `lib/features/orders/order_providers.dart`
- Modify: `lib/services/service_providers.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/home/home_page.dart`
- Test: `test/services/business_task_rules_test.dart`
- Test: `test/main_bootstrap_test.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Produces: `BusinessTaskRules.reconcileOrQueue(...)`, `retryPending(...)`, and `pendingTaskSyncCountProvider`.
- Queue rule: one row per opportunity, increment attempts and retain the latest local error; clear only after successful reconciliation.

- [x] Add failing rule tests proving a reconciliation failure queues the opportunity and a later retry creates tasks and clears the queue.
- [x] Add queue persistence methods to `PlanDao` and implement resilient reconciliation/retry APIs.
- [x] Replace silent catches in business and order services with the durable API.
- [x] Retry queued opportunities after notification initialization and before the full reminder reschedule.
- [x] Add a compact home-page warning with a retry command and refresh behavior.
- [x] Run rule, bootstrap, and home page tests.

### Task 4: Documentation and release verification

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `docs/TEST_CHECKLIST.md`
- Modify: `README.md`

- [x] Document manual tasks, opportunity change history, and queued automatic-task repair.
- [x] Run `dart run build_runner build` and ensure generated source matches schema v11.
- [x] Run `dart format --output=none --set-exit-if-changed lib test`.
- [x] Run focused migration/service/widget tests, `flutter analyze`, and the full `flutter test` suite.
- [x] Build a production-signed release APK and verify its certificate against the custodied keystore.
- [x] Install the APK on the active emulator and visually verify manual-task and activity-history flows without modifying unrelated source changes.
