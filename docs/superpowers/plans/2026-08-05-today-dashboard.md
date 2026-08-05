# Today Task Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current week-preview home list with a project-aware Today dashboard that shows all required task context, applies SPRD sorting/filtering, and supports completing or cancelling a task from the thumb zone.

**Architecture:** Add a single DAO query that joins open plans to their customer and project, returns a typed `TodayPlanItem`, and performs stable SQL ordering using local-day boundaries, customer grade, and project importance. Keep the page as a focused scan surface with compact rows, direct task details, and explicit actions; completion/cancellation go through `CustomerService` so database and notification state stay consistent.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Material 3, Riverpod 3.3.2, Drift 2.34.3, SQLite, flutter_test.

## Global Constraints

- The default home route remains `/home` and shows only overdue and today tasks; future tasks are not shown on this screen.
- A task is visible only when its status is pending, notified, or overdue, its project exists, and the project is not paused, won, closed, or at the lost sales stage.
- Every visible row displays customer name, country when present, project and product, latest feedback, follow-up reason, talking direction, next action, owner, and due time or overdue days.
- Sort order is overdue severity first, then customer grade A>B>C>D, then project importance high>normal>low, then due time ascending, then task id ascending.
- Legacy tasks with missing v4 snapshots remain visible using title and project fallback text; the page must not crash on null country or snapshot fields.
- Completion and cancellation are terminal actions. Completion cancels the scheduled reminder; cancellation uses the Stage 9A service warning behavior and never deletes the task row.
- Use existing theme tokens and semantic colors. Keep tap targets at least 44dp, avoid nested cards, support 320px dark mode, and expose icon tooltips for unfamiliar actions.
- No management statistics, anomaly categories, quote/sample entities, automatic business rules, or new dependencies in this stage.

---

### Task 1: Build the project-aware Today query

**Files:**
- Modify: `lib/data/daos/plan_dao.dart`
- Test: `test/data/query_test.dart`
- Test: `test/data/performance_test.dart`

**Interfaces:**
- Produces `TodayPlanItem` with `FollowPlanRow plan`, `CustomerRow customer`, and `OpportunityRow opportunity`.
- Produces `PlanDao.listToday({required DateTime now}) -> Future<List<TodayPlanItem>>`.
- `TodayPlanItem` exposes `customerGrade`, `opportunityImportance`, `projectLabel`, `productLabel`, `latestFeedback`, and `overdueDays(DateTime now)` without doing additional database queries.

- [x] **Step 1: Add failing query tests for today/overdue boundaries, explicit status filtering, closed/lost project suppression, nullable country/snapshots, and required sort order**

```dart
final rows = await db.planDao.listToday(now: DateTime(2026, 8, 5, 12));
expect(rows.map((item) => item.plan.id), [oldestOverdue, highGrade, highImportance, today]);
expect(rows.where((item) => item.customer.country == null), isNotEmpty);
expect(rows.map((item) => item.projectLabel), contains('CT 注射器'));
```

- [x] **Step 2: Run focused query tests and implement the missing contract**
- [x] **Step 3: Implement the inner join and SQL predicates**

```sql
WHERE follow_plans.status IN ('pending', 'notified', 'overdue')
  AND follow_plans.plan_at <= :endOfToday
  AND opportunities.status NOT IN ('paused', 'won', 'closed')
  AND opportunities.stage NOT IN ('lost', 'paused')
ORDER BY
  CASE WHEN follow_plans.plan_at < :startOfToday THEN 0 ELSE 1 END,
  CASE WHEN follow_plans.plan_at < :startOfToday
       THEN :startOfToday - follow_plans.plan_at ELSE 0 END DESC,
  CASE customers.grade WHEN 'a' THEN 3 WHEN 'b' THEN 2 WHEN 'c' THEN 1 ELSE 0 END DESC,
  CASE opportunities.importance WHEN 'high' THEN 2 WHEN 'normal' THEN 1 ELSE 0 END DESC,
  follow_plans.plan_at ASC,
  follow_plans.id ASC
```

- [x] **Step 4: Implement null-safe display fallback getters**
- [ ] **Step 5: Extend the performance fixture to 500 customers and 5,000 plans and require the Today query median to remain under 200ms**
- [x] **Step 6: Pass focused query and performance tests**

### Task 2: Implement the Today page scan surface

**Files:**
- Modify: `lib/features/home/home_page.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Test: `test/features/home/home_page_test.dart` (create)

**Interfaces:**
- `homePlansProvider` uses `PlanDao.listToday(now: DateTime.now())` and no longer extends to the end of the week.
- `_PlanList` groups only `overdue` and `today`, preserving the DAO order within each group.
- Each row uses keys `home-plan-${id}`, `home-plan-complete-${id}`, and `home-plan-cancel-${id}`.

- [x] **Step 1: Add widget tests for required fields and future-task exclusion**
- [ ] **Step 2: Run `flutter test test/features/home/home_page_test.dart` and require failure because the current page only renders customer name/title/time and has no home feature test file**
- [x] **Step 3: Replace week grouping with overdue/today sections and summary count**
- [x] **Step 4: Render complete task context on an un-nested surface**
- [x] **Step 5: Add empty state and pull-to-refresh**
- [x] **Step 6: Pass focused home widget tests**

### Task 3: Add task completion and cancellation actions

**Files:**
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/home/home_page.dart`
- Test: `test/features/customers/customer_service_test.dart`
- Test: `test/features/home/home_page_test.dart`

**Interfaces:**
- Produces `CustomerService.completePlan(int customerId, int planId) -> Future<String?>`; it verifies ownership, marks the task completed, cancels its reminder, and returns a warning if reminder cleanup fails.
- Reuses `CustomerService.cancelPlan` from Stage 9A for cancellation.
- Home actions invalidate `homePlansProvider` and `customerDetailProvider(customerId)` after a successful state change.

- [x] **Step 1: Add service tests for completion timestamp, reminder cancellation, and scheduler warning**
- [ ] **Step 2: Add failing widget tests that tap complete/cancel and assert the row disappears after provider refresh**
- [x] **Step 3: Implement `completePlan` with persist-then-cleanup ordering**
- [x] **Step 4: Wire complete/cancel actions and inline warnings**
- [x] **Step 5: Pass focused service and widget tests**

### Task 4: Verify, document, and commit stage 9B

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-today-dashboard.md`

- [x] **Step 1: Run build_runner**
- [x] **Step 2: Run dart format**
- [x] **Step 3: Run flutter analyze**
- [x] **Step 4: Run flutter test**
- [x] **Step 5: Run flutter build apk**
- [x] **Step 6: Run git diff --check**
- [x] **Step 7: Install and cold-start on Pixel 8 API 37**
- [x] **Step 8: Capture widget/emulator visual evidence**
- [x] **Step 9: Append verification evidence**
- [ ] **Step 10: Stage only stage 9B files and commit `阶段 9B：实现今日任务看板`**
- [ ] **Step 11: Confirm a clean worktree; do not push**

## Coverage Review

Tasks 1-3 cover the SPRD default-home fields, project/status filtering, deterministic sorting, null-safe legacy display, completion/cancellation behavior, and narrow dark-mode layout. Quote/sample anomaly categories and management statistics remain outside this stage because their source entities are not yet implemented.
