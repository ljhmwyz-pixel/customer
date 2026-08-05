# Task Foundation v4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the local database and service contracts so every new task has an explicit customer project, business source, follow-up reason, talking direction, next action, owner, and complete lifecycle timestamps, while preserving all existing data and reminders.

**Architecture:** Use one additive Drift v4 migration. Customer country and project owner/importance become the stable inputs required by the future Today query; task-specific fields remain snapshots on `follow_plans` so later customer or project edits do not rewrite task history. Existing tasks are retained and conservatively backfilled, while all new service writes use the strict v4 contract.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Material 3, Riverpod 3.3.2, Drift 2.34.3, SQLite, flutter_test.

## Global Constraints

- This phase changes data, DAO, and service contracts only; it does not redesign the Today page or add management-statistics UI.
- Existing v1, v2, and v3 databases must upgrade in place without deleting or rebuilding customer, project, follow-up, plan, order, attachment, or reminder data.
- Every newly created task must reference an existing project owned by the selected customer; nullable `opportunityId` remains only for schema compatibility with legacy databases.
- The app remains single-user and local-only. New owner fields default to `本人`, but are stored as text so a later form can display or change them without another schema migration.
- Project importance uses exactly `high`, `normal`, and `low`; migrated projects default to `normal`.
- Task sources use exactly `legacy`, `manual`, `followup`, `quote`, `sample`, `registration`, `tender`, `order`, and `repurchase` so later automatic rules can reuse the same contract.
- New manual tasks require non-blank reason, talking direction, next action, and owner after trimming; each is limited to 100 characters except talking direction, which is limited to 500 characters.
- Automatic task identity is `(sourceType, sourceId, ruleKey)`. `ruleKey` is nullable only for legacy/manual rows; generated follow-up tasks use `next_followup`, and later quote/sample rules can use stable values such as `quote_day_2` without producing duplicates.
- Follow-up-generated tasks copy immutable values into the task row: source `followup`, source id equal to the new follow-up id, rule key `next_followup`, reason `按计划继续跟进`, stage-based talking direction, next action from the follow-up, and owner from the project.
- `title` remains for notification compatibility and equals the normalized next action for all new writes.
- Existing tasks are backfilled with source `legacy`, next action from `title`, owner `本人`, and null reason/talking direction rather than inventing historical business facts.
- Cancelled tasks are terminal, retain their rows, record `cancelledAt`, never appear in open/due/upcoming queries, and have their scheduled notification cancelled by the service.
- No dependency additions, no push, and one isolated commit only after automated verification and non-destructive Android emulator verification.

---

### Task 1: Define v4 enums, columns, and additive migration

**Files:**
- Modify: `lib/models/enums.dart`
- Modify: `lib/data/tables/customers.dart`
- Modify: `lib/data/tables/opportunities.dart`
- Modify: `lib/data/tables/follow_plans.dart`
- Modify: `lib/data/database.dart`
- Generated: `lib/data/database.g.dart`
- Test: `test/data/enum_test.dart`
- Test: `test/data/migration_test.dart`

**Interfaces:**
- Produces: `OpportunityImportance { high, normal, low }`, including `weight` values `2`, `1`, and `0` for future SQL sorting.
- Produces: `TaskSourceType { legacy, manual, followup, quote, sample, registration, tender, order, repurchase }`.
- Extends: `PlanStatus` with `cancelled('cancelled', '已取消')`; `isOpen` is true only for pending, notified, and overdue.
- Produces: nullable `CustomerRow.country`.
- Produces: non-null `OpportunityRow.owner` defaulting to `本人` and non-null `OpportunityRow.importance` defaulting to `normal`.
- Produces: `FollowPlanRow.sourceType`, nullable `sourceId`, `ruleKey`, `reason`, `talkingDirection`, `nextAction`, non-null `owner`, and nullable `cancelledAt`.
- Produces: `AppDatabase.schemaVersion == 4` and sequential v1 -> v2 -> v3 -> v4 upgrades.

- [x] **Step 1: Add failing enum tests for the exact database values, importance weights, cancelled terminal behavior, lowercase values, uniqueness, and invalid-value exceptions**

```dart
expect(OpportunityImportance.values.map((e) => e.dbValue), [
  'high', 'normal', 'low',
]);
expect(OpportunityImportance.high.weight, 2);
expect(OpportunityImportance.normal.weight, 1);
expect(OpportunityImportance.low.weight, 0);
expect(TaskSourceType.values.map((e) => e.dbValue), [
  'legacy', 'manual', 'followup', 'quote', 'sample',
  'registration', 'tender', 'order', 'repurchase',
]);
expect(PlanStatus.cancelled.isOpen, isFalse);
```

- [x] **Step 2: Add failing fresh-v4, v3-to-v4, v2-to-v4, and v1-to-v4 migration assertions**

```dart
expect(db.schemaVersion, 4);
expect(await _columnNames(db, 'customers'), contains('country'));
expect(await _columnNames(db, 'opportunities'), containsAll([
  'owner', 'importance',
]));
expect(await _columnNames(db, 'follow_plans'), containsAll([
  'source_type', 'source_id', 'rule_key', 'reason', 'talking_direction',
  'next_action', 'owner', 'cancelled_at',
]));
```

For the migrated task fixture, assert `source_type == 'legacy'`, `next_action == title`, `owner == '本人'`, null reason/talking direction/cancelled timestamp, unchanged id/customer/project/time/status/notified/completed timestamps, unchanged table row counts, `PRAGMA user_version == 4`, and an empty `PRAGMA foreign_key_check` result.

- [x] **Step 3: Run `flutter test test/data/enum_test.dart test/data/migration_test.dart` and require failure because v4 types, fields, and migration do not exist**
- [x] **Step 4: Add the enum and Drift column definitions with database defaults for owner, importance, source type, and status compatibility**
- [x] **Step 5: Implement `_migrateV3ToV4(Migrator m)` using only `addColumn` plus deterministic task backfill**

```sql
UPDATE follow_plans
SET source_type = 'legacy',
    next_action = title,
    owner = '本人'
WHERE source_type = 'legacy';
```

`onUpgrade` must run the existing v1-to-v2 and v2-to-v3 branches first, then run v3-to-v4 whenever `from < 4`.

- [x] **Step 6: Add partial unique index `idx_plans_source_rule` on `(source_type, source_id, rule_key) WHERE source_id IS NOT NULL AND rule_key IS NOT NULL`, then assert duplicate generated-rule insertion fails while separate rule keys for one source remain valid**
- [x] **Step 7: Run `dart run build_runner build --delete-conflicting-outputs`**
- [x] **Step 8: Run the focused enum and migration tests and require all fresh and historical upgrade paths to pass**

### Task 2: Enforce the strict task contract in PlanDao

**Files:**
- Modify: `lib/data/daos/plan_dao.dart`
- Generated: `lib/data/daos/plan_dao.g.dart`
- Test: `test/data/crud_test.dart`
- Test: `test/data/query_test.dart`
- Test: `test/data/cascade_test.dart`

**Interfaces:**
- Provides a strict service-facing insert contract while retaining nullable compatibility parameters for existing low-level reminder fixtures and legacy diagnostic tools; `CustomerService` rejects missing project and required task fields before calling it.
- Produces: `PlanDao.markCancelled(int id, {DateTime? at}) -> Future<int>`.
- Preserves: `findById`, customer/project cascade behavior, notification timestamps, completion, postpone, and overdue transitions.
- Changes: every open query filters by `PlanStatus.isOpen` values instead of merely excluding `completed`.

- [x] **Step 1: Update fixtures to the strict insert contract and add failing CRUD assertions for all task fields**

```dart
final id = await db.planDao.insertPlan(
  customerId: customerId,
  opportunityId: opportunityId,
  sourceType: TaskSourceType.manual,
  reason: '确认采购计划',
  talkingDirection: '确认采购时间、型号和数量',
  nextAction: '电话确认采购计划',
  owner: '本人',
  planAt: planAt,
);
final row = await db.planDao.findById(id);
expect(row!.title, '电话确认采购计划');
expect(row.reason, '确认采购计划');
expect(row.talkingDirection, '确认采购时间、型号和数量');
expect(row.nextAction, '电话确认采购计划');
```

- [x] **Step 2: Add failing query tests proving cancelled tasks are excluded from `listOpenOf`, `listDue`, `listUpcoming`, and `listOpenUntil`, while remaining queryable by id**
- [x] **Step 3: Run `flutter test test/data/crud_test.dart test/data/query_test.dart test/data/cascade_test.dart` and require compile/test failure against the old DAO contract**
- [x] **Step 4: Implement strict insert mapping, `markCancelled`, and a single reusable list of open database values `[pending, notified, overdue]`**
- [x] **Step 5: Replace all open-query predicates with explicit open-status membership and keep stable ordering by time then id**
- [x] **Step 6: Pass focused CRUD, query, foreign-key, cascade, status-transition, overdue, completion, postpone, and cancellation tests**

### Task 3: Upgrade CustomerService task creation and lifecycle behavior

**Files:**
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/models/enums.dart`
- Test: `test/features/customers/customer_service_test.dart`
- Test: `test/services/notification_action_test.dart`

**Interfaces:**
- Produces: `PlanDraft({required int opportunityId, required String reason, required String talkingDirection, required String nextAction, String owner = '本人', required DateTime planAt})`.
- Produces: `CustomerService.createPlan(int customerId, PlanDraft draft) -> Future<WriteResult<int>>` with project ownership and normalized required-field validation.
- Produces: `CustomerService.cancelPlan(int customerId, int planId) -> Future<String?>` that verifies ownership, updates the database, then cancels the scheduled reminder; null means success and a non-null message means cancellation was saved but notification cleanup failed.
- Produces: `String talkingDirectionForStage(OpportunityStage stage)` with the exact mappings from SPRD section 9.
- Extends: `CustomerService.addFollowup` to insert the generated task with source type `followup`, source id equal to the inserted follow-up row, rule key `next_followup`, normalized project owner, stage-based talking direction, and next action from the immutable follow-up snapshot.

- [x] **Step 1: Add failing service tests for missing project, cross-customer project, blank/oversized fields, whitespace normalization, successful manual creation, and cancellation ownership**
- [x] **Step 2: Add a failing follow-up service assertion proving the generated task has `sourceType == followup`, `sourceId == followupId`, `ruleKey == 'next_followup'`, reason `按计划继续跟进`, the stage-based talking direction, copied next action, copied project owner, and the same customer/project ids**
- [x] **Step 3: Add failing tests proving cancellation is persisted before scheduler cancellation, scheduler cancellation is attempted exactly once, and a scheduler exception returns a warning without restoring the task to an open state**
- [x] **Step 4: Run `flutter test test/features/customers/customer_service_test.dart test/services/notification_action_test.dart` and require failure against the legacy draft and generated-plan behavior**
- [x] **Step 5: Implement the stage-to-talking-direction mapping exactly as follows**

```dart
OpportunityStage.newLead || OpportunityStage.contactEstablished =>
  '确认设备品牌/型号、经营品牌、现有供应商、医院覆盖和产品需求',
OpportunityStage.needsConfirmed =>
  '确认年用量、具体型号、采购时间和注册要求',
OpportunityStage.quoted || OpportunityStage.priceNegotiation =>
  '确认报价是否收到、内部反馈、目标价格、竞争价格和决策时间',
OpportunityStage.samplePreparing || OpportunityStage.sampleTesting =>
  '确认物流、签收、测试负责人、测试日期、初步结果和正式报告',
OpportunityStage.registrationInProgress || OpportunityStage.tenderPreparing =>
  '确认文件截止、投标主体、资质、保证金、授权和项目时间表',
OpportunityStage.awaitingOrder =>
  '确认 PI/PO、付款安排、采购审批和预计下单时间',
OpportunityStage.won =>
  '确认库存、销售速度、终端反馈和下一次补货时间',
OpportunityStage.paused || OpportunityStage.lost =>
  '确认暂停或流失原因，以及是否存在恢复推进的条件',
```

- [x] **Step 6: Replace legacy-default project creation in `createPlan` with explicit project ownership validation and strict field normalization**
- [x] **Step 7: Update follow-up-generated task insertion inside the existing transaction; fetch the project owner before the transaction and keep reminder scheduling after commit**
- [x] **Step 8: Implement cancellation as a persisted terminal transition followed by best-effort notification cancellation, then pass all focused service and notification-action tests**

### Task 4: Verify v4 on tooling and Android, then commit

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-task-foundation-v4.md`

**Interfaces:**
- Produces: fresh automated and emulator evidence for phase 9A.
- Produces: one local commit named `阶段 9A：升级任务数据模型`.

- [x] **Step 1: Run `dart run build_runner build --delete-conflicting-outputs`**
- [x] **Step 2: Run `dart format` on every Dart file changed by this plan**
- [x] **Step 3: Run `flutter analyze` and require `No issues found`**
- [x] **Step 4: Run `flutter test` and require zero failures; record the exact test count**
- [x] **Step 5: Run `flutter build apk --debug` and require `build/app/outputs/flutter-apk/app-debug.apk`**
- [x] **Step 6: Run `git diff --check` and require no output**
- [x] **Step 7: Install the debug APK with `adb install -r` on the existing Pixel 8 API 37 emulator without clearing application data**
- [x] **Step 8: Cold-start the app and verify existing customers, projects, follow-ups, plans, orders, and reminder history remain visible**
- [x] **Step 9: Inspect the emulator database and require `PRAGMA user_version == 4`, all new columns/indexes present, legacy task ids/counts/timestamps unchanged, and `PRAGMA foreign_key_check` empty**
- [x] **Step 10: Verify generated follow-up task source/rule/snapshot values through the focused service test, and verify the upgraded emulator database retains the existing reminder rows**
- [x] **Step 11: Record commands, test count, APK path, emulator device, migration result, and manual checks in `docs/phase6/VERIFICATION.md`**
- [ ] **Step 12: Review `git diff --stat`, `git diff`, and `git status --short`; stage only phase 9A files and commit with `git commit -m '阶段 9A：升级任务数据模型'`**
- [ ] **Step 13: Confirm `git status --short --branch` is clean and ahead of origin; do not push**

## Coverage Review

Tasks 1-3 provide every persistent field needed by SPRD 5.10 and the future Today query, explicit customer-project ownership, business-source extensibility, immutable task snapshots, all five required statuses, reliable cancellation, and lossless v1/v2/v3 migration. Task 4 provides the isolated verification and commit gate. The Today presentation and sorting are intentionally reserved for phase 9B; management statistics are phase 9C; quote/sample automatic rules remain phase D because their source entities do not exist yet.
