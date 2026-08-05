# Opportunity Follow-up Synchronization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Record every follow-up against an explicitly selected customer project, preserve its five-field history snapshot, synchronize the project's latest follow-up state, and create the next project-linked plan when requested.

**Architecture:** Upgrade Drift from schema v2 to v3 by adding nullable snapshot columns to `followups` and `last_follow_at` to `opportunities`, with an additive, lossless migration and deterministic legacy backfill. Keep validation and orchestration in `CustomerService`; one database transaction inserts the immutable history row, advances customer/project latest state only when appropriate, and creates the project-linked plan, while reminder scheduling remains post-commit.

**Tech Stack:** Flutter 3.44.8, Dart, Material 3, Riverpod 3.3.2, Drift 2.34.3, SQLite, flutter_test.

## Global Constraints

- This phase only implements project selection, five-field follow-up capture, immutable history snapshots, project synchronization, and next-plan creation.
- Do not add quote, sample, registration, tender, dashboard, automatic stage inference, or automatic opportunity-status changes.
- Every new follow-up requires an existing project belonging to the selected customer.
- Customer feedback, current stage, and next action are required after trimming.
- Exactly one of `nextFollowAt` and `pauseReason` must be present; a paused follow-up requires a non-blank reason.
- Existing v1 and v2 databases must upgrade in place without deleting customers, projects, follow-ups, plans, orders, or attachments.
- Backdated follow-ups must not move customer/project `lastFollowAt` backward or replace a newer project's latest state.
- Reminder scheduling happens after the database transaction; scheduling failure returns a warning and must not roll back business data.
- No dependency additions, no push, and one isolated commit only after automated and Android emulator verification.

---

### Task 1: Add the v3 schema and lossless migration

**Files:**
- Modify: `lib/data/tables/followups.dart`
- Modify: `lib/data/tables/opportunities.dart`
- Modify: `lib/data/database.dart`
- Generated: `lib/data/database.g.dart`
- Generated: `lib/data/daos/followup_dao.g.dart`
- Generated: `lib/data/daos/opportunity_dao.g.dart`
- Test: `test/data/migration_test.dart`

**Interfaces:**
- Produces: nullable `FollowupRow.feedback`, `stage`, `nextAction`, `nextFollowAt`, and `pauseReason` snapshot fields.
- Produces: nullable `OpportunityRow.lastFollowAt`.
- Produces: `AppDatabase.schemaVersion == 3` and sequential v1 → v2 → v3 upgrade behavior.

- [x] **Step 1: Write failing new-database and v2-fixture migration tests**

```dart
expect(db.schemaVersion, 3);
expect(await _columnNames(db, 'followups'), containsAll([
  'feedback', 'stage', 'next_action', 'next_follow_at', 'pause_reason',
]));
expect(await _columnNames(db, 'opportunities'), contains('last_follow_at'));

final migratedFollowup = await migrated.customSelect('''
  SELECT feedback, stage, next_action, next_follow_at, pause_reason
  FROM followups WHERE id = 1
''').getSingle();
expect(migratedFollowup.read<String>('feedback'), '旧结论');
expect(migratedFollowup.read<String>('stage'), 'quoted');
expect(migratedFollowup.read<String>('next_action'), '发送修订报价');
expect(migratedFollowup.read<int?>('next_follow_at'), isNull);
expect(migratedFollowup.read<String?>('pause_reason'), isNull);
```

- [x] **Step 2: Run `flutter test test/data/migration_test.dart` and require failure because schema v3 fields and migration do not exist**
- [x] **Step 3: Add nullable Drift columns and implement `_migrateV2ToV3(Migrator m)`**

```sql
UPDATE followups
SET feedback = COALESCE(NULLIF(TRIM(conclusion), ''), content),
    stage = (SELECT opportunity.stage FROM opportunities opportunity
             WHERE opportunity.id = followups.opportunity_id),
    next_action = COALESCE(
      (SELECT NULLIF(TRIM(opportunity.next_action), '')
       FROM opportunities opportunity
       WHERE opportunity.id = followups.opportunity_id),
      '历史跟进（未记录下一步行动）'
    );

UPDATE opportunities
SET last_follow_at = (
  SELECT MAX(followup.occurred_at)
  FROM followups followup
  WHERE followup.opportunity_id = opportunities.id
);
```

- [x] **Step 4: Make `onUpgrade` run v1 → v2 and then v2 → v3 when `from < 3`**
- [x] **Step 5: Run `dart run build_runner build --delete-conflicting-outputs`**
- [x] **Step 6: Run `flutter test test/data/migration_test.dart` and require the fresh v3, v1 → v3, v2 → v3, row-count, backfill, `user_version`, and `foreign_key_check` assertions to pass**

### Task 2: Implement atomic project-aware follow-up persistence

**Files:**
- Modify: `lib/data/daos/followup_dao.dart`
- Modify: `lib/data/daos/opportunity_dao.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Generated: `lib/data/daos/followup_dao.g.dart`
- Generated: `lib/data/daos/opportunity_dao.g.dart`
- Test: `test/features/customers/customer_service_test.dart`

**Interfaces:**
- Produces: `FollowupDraft({required int opportunityId, required DateTime occurredAt, required FollowMethod method, required String feedback, required OpportunityStage stage, required String nextAction, String? content, DateTime? nextFollowAt, String? pauseReason})`.
- Produces: `FollowupDao.insertAndTouchCustomer(...)` accepting all snapshot fields.
- Produces: `OpportunityDao.syncLatestFollowup(...) -> Future<bool>`, where `true` means the follow-up became the project's latest state.
- Extends: `CustomerService.addFollowup(int customerId, FollowupDraft draft) -> Future<WriteResult<int>>`.

- [x] **Step 1: Replace legacy follow-up fixtures and write failing validation/ownership tests**

```dart
final draft = FollowupDraft(
  opportunityId: opportunityId,
  occurredAt: DateTime.utc(2026, 8, 5, 10),
  method: FollowMethod.phone,
  feedback: '认可技术方案',
  stage: OpportunityStage.needsConfirmed,
  nextAction: '发送正式报价',
  nextFollowAt: DateTime.utc(2026, 8, 8, 10),
);
await service.addFollowup(customerId, draft);
```

- [x] **Step 2: Run `flutter test test/features/customers/customer_service_test.dart` and require compile/test failure against the legacy draft contract**
- [x] **Step 3: Add DAO snapshot insertion and conditional project synchronization**

```dart
Future<bool> syncLatestFollowup({
  required int opportunityId,
  required DateTime occurredAt,
  required String feedback,
  required OpportunityStage stage,
  required String nextAction,
  DateTime? nextFollowAt,
  DateTime? now,
});
```

The update predicate must be `last_follow_at IS NULL OR last_follow_at < occurredAt`; equal/older timestamps cannot overwrite current state.

- [x] **Step 4: Normalize and validate project ownership, required text, and the exclusive next-date/pause-reason choice in `CustomerService`**
- [x] **Step 5: In one `_db.transaction`, insert the snapshot, conditionally sync project five fields, and insert a plan titled with normalized `nextAction` only when `nextFollowAt` exists**
- [x] **Step 6: Keep scheduler invocation after commit and retain the existing warning behavior**
- [x] **Step 7: Pass service tests for invalid project, cross-customer project, blank fields, invalid next choice, successful synchronization, project isolation, backdated records, pause snapshots, and scheduler failure**

### Task 3: Replace the follow-up form with the five-field project flow

**Files:**
- Modify: `lib/features/customers/followup_form_page.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Uses: `CustomerDetailData.opportunities` and the Task 2 `FollowupDraft` contract.
- Preserves keys: `followup-content`, `followup-next-choice`, and `save-followup`.
- Adds keys: `followup-opportunity`, `followup-feedback`, `followup-stage`, `followup-next-action`, and `followup-pause-reason`.

- [x] **Step 1: Write failing widget tests for single-project defaults, multi-project selection, required fields, and pause reason**

```dart
expect(find.text('项目：CT 注射器'), findsOneWidget);
await tester.enterText(
  find.byKey(const ValueKey('followup-feedback')),
  '客户认可方案',
);
await tester.enterText(
  find.byKey(const ValueKey('followup-next-action')),
  '发送报价',
);
```

- [x] **Step 2: Run the focused `customer_pages_test.dart` follow-up tests and require failure because project/five-field widgets are absent**
- [x] **Step 3: Auto-select and display the only project; require a dropdown when multiple projects exist**
- [x] **Step 4: Initialize stage from the selected project and reset it whenever project selection changes**
- [x] **Step 5: Implement required feedback, stage, next-action, next-date, and conditional pause-reason controls; keep method/content in a secondary section**
- [x] **Step 6: Build the Task 2 draft, use `nextAction` as the generated plan title, refresh providers, preserve warning display, and return to customer detail**
- [x] **Step 7: Pass all focused follow-up widget tests including the 320px dark-mode layout case**

### Task 4: Present immutable follow-up snapshots in customer detail

**Files:**
- Modify: `lib/features/customers/customer_detail_page.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Displays: snapshot feedback, stage label, next action, next follow date, or pause reason from each `FollowupRow`.
- Falls back: legacy nullable snapshot fields continue to render using `conclusion`/`content` without crashing.

- [x] **Step 1: Write a failing detail test proving two snapshots for the same project remain independently visible**
- [x] **Step 2: Add compact snapshot rendering to the existing follow-up timeline card**

```dart
final feedback = row.feedback ?? row.conclusion ?? row.content;
final stage = row.stage == null
    ? null
    : OpportunityStage.fromDb(row.stage!).label;
```

- [x] **Step 3: Render `pauseReason` when present; otherwise render formatted `nextFollowAt` when present**
- [x] **Step 4: Run `flutter test test/features/customers/customer_pages_test.dart` and require all customer page tests to pass**

### Task 5: Verify on tooling and Android emulator, then commit

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-opportunity-followup-sync.md`

**Interfaces:**
- Produces: fresh automated and Android emulator evidence for phase 8.
- Produces: one local commit named `阶段 8：实现项目化跟进与五字段同步`.

- [x] **Step 1: Run `dart run build_runner build --delete-conflicting-outputs`**
- [x] **Step 2: Run `dart format` on every Dart file changed by this plan**
- [x] **Step 3: Run `flutter analyze` and require `No issues found`**
- [x] **Step 4: Run `flutter test` and require zero failures; record the exact test count**
- [x] **Step 5: Run `flutter build apk --debug` and require `build/app/outputs/flutter-apk/app-debug.apk`**
- [x] **Step 6: Run `git diff --check` and require no output**
- [x] **Step 7: Install/upgrade the debug APK on the Pixel 8 API 37 emulator without clearing app data**
- [ ] **Step 8: Manually verify cold-start database upgrade, single-project auto-selection, multi-project selection, five-field synchronization to only the selected project, two retained history rows, same-project next plan, and required pause reason**
- [x] **Step 9: Record commands, test count, APK path, emulator device, migration result, and manual scenarios in `docs/phase6/VERIFICATION.md`**
- [ ] **Step 10: Review `git diff --stat`, `git diff`, and `git status --short`; stage only phase 8 files and commit with `git commit -m '阶段 8：实现项目化跟进与五字段同步'`**
- [ ] **Step 11: Confirm `git status --short --branch` reports `main` ahead of origin with a clean worktree; do not push**

## Coverage Review

Tasks 1–4 cover additive v3 migration, immutable snapshots, explicit project ownership, the five required fields, correct latest-state handling for backdated entries, project-linked next plans, required pause reasons, and readable history. Task 5 covers fresh static analysis, full tests, APK compilation, non-destructive emulator upgrade, end-to-end Android behavior, and the isolated commit gate. Quotes, samples, registration, tenders, dashboard changes, automatic stage/status inference, and phase 9 remain intentionally outside this plan.
