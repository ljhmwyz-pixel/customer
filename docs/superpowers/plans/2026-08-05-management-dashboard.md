# Management Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the SPRD management dashboard and explainable anomaly entry points that are supported by the current customer, opportunity, follow-up, order, and task entities.

**Architecture:** Add one typed aggregate query to `CustomerDao` for dashboard metrics and one typed anomaly query for long-silent customers and projects needing internal support. The existing `/funnel` route becomes a compact dashboard with tappable metric rows that navigate to existing customer/project lists; unsupported quote/sample/tender/registration/repurchase categories remain explicitly unavailable until their source entities exist.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Material 3, Riverpod 3.3.2, Drift 2.34.3, SQLite, flutter_test.

## Global Constraints

- Do not invent quote, sample, registration, tender, or repurchase data before those source entities are implemented.
- All displayed numbers must come from one consistent `now` timestamp and use UTC milliseconds for persisted dates.
- Every metric and supported anomaly must provide an explainable drill-down target or an explicit unavailable state.
- Exclude lost, paused, won, and closed projects from active pipeline counts and forecast totals.
- Weighted forecast is `forecast_amount_minor * probability_percent / 100`, rounded down to integer minor units.
- Long silence uses the existing customer-grade cadence: A 14 days, B 30 days, C 60 days, D 60 days; customers in deal/lost stages are excluded.
- Internal-support anomalies are active projects with a non-empty `current_obstacle`; blank obstacles are not anomalies.
- Use existing theme tokens, semantic colors, 44dp-or-larger tap targets, and support 320px dark mode without nested cards.
- No new dependencies, schema migration, automatic business rules, or Excel/export work in this stage.

---

### Task 1: Define dashboard aggregate contracts

**Files:**
- Modify: `lib/data/daos/customer_dao.dart`
- Test: `test/data/dashboard_query_test.dart` (create)

**Interfaces:**
- Produces `DashboardMetrics` with `totalCustomers`, `customerCountsByGrade`, `projectCountsByStage`, `followupsThisWeek`, `stalledQuoteCount`, `stalledSampleCount`, `forecastAmountMinor`, `weightedForecastAmountMinor`, and `wonAmountMinor`.
- Produces `DashboardAnomaly` with `customerId`, `customerName`, `opportunityId`, `opportunityName`, `kind`, `severity`, and `detail`.
- Produces `CustomerDao.dashboardMetrics({required DateTime now})` and `CustomerDao.dashboardAnomalies({required DateTime now})`.

- [x] **Step 1: Write failing tests for metric totals, grade/stage buckets, week boundaries, forecast exclusion, weighted amounts, and won order totals.**

```dart
final metrics = await db.customerDao.dashboardMetrics(now: DateTime(2026, 8, 5, 12));
expect(metrics.totalCustomers, 3);
expect(metrics.customerCountsByGrade[CustomerGrade.a], 1);
expect(metrics.forecastAmountMinor, 120000);
expect(metrics.weightedForecastAmountMinor, 60000);
```

- [x] **Step 2: Write failing anomaly tests for long silence and internal support, including exclusion of deal/lost customers and paused/closed projects.**
- [x] **Step 3: Run focused tests and verify the new contracts.**
- [x] **Step 4: Implement aggregate queries with one captured `now` and typed mapping.**
- [x] **Step 5: Implement supported anomaly mapping with stable ordering and null-safe details.**
- [x] **Step 6: Run focused dashboard query tests and existing regression tests.**

### Task 2: Build the dashboard provider and page

**Files:**
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/funnel/funnel_page.dart`
- Test: `test/features/funnel/funnel_page_test.dart` (create)

**Interfaces:**
- Produces `dashboardProvider -> AsyncValue<DashboardData>` where `DashboardData` contains metrics and anomalies from Task 1.
- The `/funnel` route renders the dashboard without changing navigation or introducing a second management route.

- [x] **Step 1: Write widget tests for metric labels/values, anomalies, and unsupported-module state.**
- [x] **Step 2: Run focused widget tests against the former placeholder page.**
- [x] **Step 3: Implement `dashboardProvider` with revision invalidation and one `now` per refresh.**
- [x] **Step 4: Replace the placeholder funnel page with compact dashboard sections.**
- [x] **Step 5: Add tappable metric/anomaly rows with customer drill-down.**
- [x] **Step 6: Add explicit unavailable rows for unsupported anomaly modules.**
- [x] **Step 7: Pass focused widget tests and analyzer checks.**

### Task 3: Verify and commit 9C

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-management-dashboard.md`

- [x] **Step 1: Run build_runner.**
- [x] **Step 2: Format changed Dart files and run git diff --check.**
- [x] **Step 3: Run flutter analyze.**
- [x] **Step 4: Run flutter test.**
- [x] **Step 5: Run flutter build apk.**
- [x] **Step 6: Install and cold-start on Pixel 8 API 37 without clearing data.**
- [x] **Step 7: Capture emulator screenshot and inspect unsupported state.**
- [x] **Step 8: Append verification evidence and unsupported-module boundaries.**
- [ ] **Step 9: Stage only 9C files and commit `阶段 9C：实现管理统计与异常视图`; do not push.**

## Coverage Review

This stage completes the currently supportable portion of SPRD section 6.2 and 6.3. Quote-after-no-reply, quote-expiry, sample, tender, registration, and repurchase anomalies are intentionally not represented until their source entities and history tables are implemented in stages D/E. Excel export, backup/restore, examples, and target-device seven-day reminder validation remain later SPRD stages.
