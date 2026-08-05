# Quote and Sample Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement SPRD Phase D quote and sample records, history-preserving workflows, and explainable automatic follow-up task generation for their defined milestones.

**Architecture:** Add versioned `quotes` and `samples` tables linked to opportunities, with dedicated DAOs and service validation. A deterministic rule evaluator derives quote/sample tasks from persisted milestones and inserts them through the existing task identity index, so repeated refreshes never duplicate tasks; generated tasks retain source type, source id, rule key, reason, direction, next action, and owner snapshots.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Material 3, Riverpod 3.3.2, Drift 2.34.3, SQLite, flutter_test.

## Global Constraints

- Quote history is append-only by version; editing a quote creates a new version instead of overwriting a prior version.
- Sample lifecycle preserves sent, delivered, testing, and result timestamps independently.
- Quote workday rules use Monday-Friday only; no country holiday calendar is introduced.
- Automatic tasks use `(source_type, source_id, rule_key)` identity and are idempotent across refresh, restart, and repeated follow-up saves.
- Closed, won, paused, or lost opportunities do not receive new automatic quote/sample tasks.
- Monetary values are stored as integer minor units with explicit currency; quantities and costs must be non-negative.
- Every generated task must expose an explainable reason and next action; no outbound message is generated automatically.
- Use existing theme tokens, 44dp-or-larger tap targets, 320px dark-mode support, and no new dependencies.

---

### Task 1: Add quote/sample schema and migration

**Files:**
- Create: `lib/data/tables/quotes.dart`
- Create: `lib/data/tables/samples.dart`
- Modify: `lib/data/database.dart`
- Modify: `lib/data/tables/opportunities.dart`
- Test: `test/data/migration_test.dart`

**Interfaces:**
- `Quotes` stores opportunity, quote number, version, product model, quantity, currency, unit/total prices, quoted date, valid-until date, received flag, feedback, next-follow date, and result.
- `Samples` stores opportunity, model, quantity, fee, sent/carrier/tracking, delivered/recipient, tester, planned test date, test status/result, and next action.
- Database schema advances from v4 to v5 with additive migration and indexes on opportunity/date/status.

- [x] **Step 1: Write migration tests proving v4 opens as v5 and preserves existing rows.**
- [x] **Step 2: Write constraint tests for quote versions, amounts, quantity, and sample statuses.**
- [x] **Step 3: Run focused migration/schema tests.**
- [x] **Step 4: Add Drift tables, schema version 5 migration, and indexes.**
- [x] **Step 5: Run build_runner and focused migration/schema tests.**

### Task 2: Implement quote and sample DAOs/services

**Files:**
- Create: `lib/data/daos/quote_dao.dart`
- Create: `lib/data/daos/sample_dao.dart`
- Modify: `lib/data/database.dart`
- Create: `lib/features/business/business_providers.dart`
- Test: `test/data/quote_sample_dao_test.dart`
- Test: `test/features/business/business_service_test.dart`

**Interfaces:**
- `QuoteDao.createVersion(...) -> Future<int>`, `listVersions(opportunityId)`, and `latest(opportunityId)` preserve immutable versions.
- `SampleDao.insertSample(...) -> Future<int>`, `updateMilestone(...)`, and `listOf(opportunityId)` preserve independent lifecycle timestamps.
- `BusinessService.createQuoteVersion`, `BusinessService.createSample`, and `BusinessService.updateSampleMilestone` validate opportunity ownership/status and invalidate customer/dashboard providers.

- [x] **Step 1: Write DAO/service tests for versioning, milestones, and ownership.**
- [x] **Step 2: Run focused DAO/service tests.**
- [x] **Step 3: Implement typed DAOs and latest/version queries.**
- [x] **Step 4: Implement service normalization and validation.**
- [x] **Step 5: Pass focused DAO/service tests and regression tests.**

### Task 3: Generate quote/sample automatic tasks

**Files:**
- Create: `lib/services/business_task_rules.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/services/reminder_scheduler.dart` integration call site
- Test: `test/services/business_task_rules_test.dart`
- Test: `test/features/customers/customer_service_test.dart`

**Interfaces:**
- `BusinessTaskRules.generateForOpportunity(int opportunityId, {required DateTime now}) -> Future<List<int>>` evaluates quote/sample milestones.
- Quote rules: 2 workdays, 7 days, 14 days after quote; 30-day no-reply stall; 60-day low-frequency transition; 7 days before validity expiry.
- Sample rules: sent tracking, delivered +3/+7/+14 days, +30-day no-feedback stall, and test-passed +3 days.
- Generated task identity is `quote|sample + sourceId + ruleKey`; each task uses the existing `PlanDao.insertPlan` snapshot fields and schedules reminders after persistence.

- [x] **Step 1: Write rule tests for weekdays, boundaries, closed suppression, and idempotency.**
- [x] **Step 2: Run rule tests.**
- [x] **Step 3: Implement weekday helper and milestone rules.**
- [x] **Step 4: Implement identity-aware tasks and reminder scheduling.**
- [x] **Step 5: Pass rule, service, notification, and migration tests.**

### Task 4: Add quote/sample UI and dashboard integration

**Files:**
- Create: `lib/features/business/quote_form_page.dart`
- Create: `lib/features/business/sample_form_page.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Modify: `lib/features/funnel/funnel_page.dart`
- Modify: `lib/router.dart`
- Test: `test/features/business/business_pages_test.dart`

**Interfaces:**
- Customer detail exposes quote history and sample timeline under the selected opportunity.
- Forms use stable keys `quote-version-*`, `sample-milestone-*`, and `business-save-*`.
- Dashboard quote/sample anomaly rows navigate to filtered customer/project context after source records exist.

- [x] **Step 1: Write widget tests for quote/sample fields and validation.**
- [x] **Step 2: Run focused page tests.**
- [x] **Step 3: Implement compact quote/sample forms with existing theme tokens.**
- [x] **Step 4: Add routes, customer-project entry points, and provider invalidation.**
- [x] **Step 5: Pass focused widget tests and analyzer checks.**

### Task 5: Verify and commit Phase D slice

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-quote-sample-tracking.md`

- [x] **Step 1: Run build_runner, format, analyze, full tests, and diff check.**
- [x] **Step 2: Run flutter build apk.**
- [x] **Step 3: Install and cold-start on Pixel 8 API 37 without clearing data.**
- [x] **Step 4: Capture emulator screenshot evidence.**
- [x] **Step 5: Append counts, APK/device evidence, migration result, and remaining boundaries.**
- [ ] **Step 6: Stage only Phase D files and commit `阶段 D：实现报价样品与自动任务规则`; do not push.**

## Coverage Review

This plan covers SPRD sections 5.5, 5.6, 7.1, 7.2, and the quote/sample portions of 6.2. Registration, tender, order-state decomposition, repurchase, supplier recommendation, Excel export, backup/restore, examples, and target-device seven-day reminder validation remain later Phase E-G work.
