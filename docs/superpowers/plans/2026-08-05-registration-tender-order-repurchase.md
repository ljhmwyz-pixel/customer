# Registration, Tender, Order, and Repurchase Implementation Plan

> **Execution rule:** Complete one slice at a time. For every slice, first add a failing test and confirm the expected failure, then implement the minimum change, run focused and regression validation, and commit only that verified slice before continuing.

**Goal:** Implement SPRD Phase E registration, tender, decomposed order lifecycle, and repurchase tracking with explainable, idempotent automatic follow-up tasks.

**Architecture:** Advance Drift from schema v5 to v6 with additive registration and tender tables and additive order lifecycle columns. Keep old order rows through a fixed migration mapping. Add ownership-aware services and deterministic business task rules using the existing `(source_type, source_id, rule_key)` identity. Persist each task before scheduling its notification, and retain the task if notification scheduling fails. Add project-scoped forms and dashboard anomaly entries only after the data and rule layers are verified.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Material 3, Riverpod 3.3.2, Drift 2.34.3, SQLite, flutter_test.

## Global Constraints

- Registration, tender, and order records belong to a real opportunity under the same customer; no compatibility or synthetic opportunity may be created by new flows.
- Automatic tasks retain `(source_type, source_id, rule_key)` as their stable identity and remain idempotent across refreshes and restarts.
- Persist a generated task before notification scheduling. A scheduling failure must not roll back the persisted task.
- Paused, lost, won, or closed opportunities do not receive new automatic tasks; closed, abandoned, or disqualified tenders do not receive later deadline reminders.
- Monetary values use integer minor units and an explicit currency. Date relations, required fields, and non-negative amounts are checked by services before persistence.
- Tender authorization values are exactly `nonExclusiveProject`, `regional`, and `none`, displayed as “非独家项目授权”, “区域授权”, and “暂不授权”.
- A first tender defaults to `mediumHigh` risk. Qualification cannot be marked complete without a complete tender document.
- Authorization or floor-price support requires qualification, bidding entity, deposit, local team, and funding checks; a high-risk tender must show an explicit warning before either confirmation.
- Existing theme tokens, 44dp-or-larger tap targets, 320px dark-mode support, and current dependencies remain unchanged.
- Each slice is committed locally after verification. No remote push is part of this plan.

## Fixed v5 Order Migration Mapping

Old orders have one mixed status and no currency. The v5→v6 migration must apply this exact mapping and backfill `CNY`, preserving existing amount/date/customer data:

| v5 `status` | v6 `payment_status` | v6 `production_status` | v6 `shipping_status` | v6 `order_result` |
|---|---|---|---|---|
| `pending` | `pending` | `pending` | `pending` | `inProgress` |
| `shipped` | `pending` | `completed` | `shipped` | `inProgress` |
| `paid` | `paid` | `completed` | `shipped` | `inProgress` |
| `completed` | `paid` | `completed` | `delivered` | `completed` |
| `cancelled` | `cancelled` | `cancelled` | `cancelled` | `cancelled` |

The compatibility `status` column remains readable during Phase E, but all new writes derive it from the decomposed fields. Its removal, if desired, requires a separate schema version and is outside this phase.

---

### E-1: Add schema v6 and preserve v5 data

**Files:**
- Create: `lib/data/tables/registrations.dart`
- Create: `lib/data/tables/tenders.dart`
- Modify: `lib/data/tables/orders.dart`
- Modify: `lib/models/enums.dart`
- Modify: `lib/data/database.dart`
- Generated: `lib/data/database.g.dart`
- Test: `test/data/migration_test.dart`
- Create test: `test/data/phase_e_schema_test.dart`

**Interfaces:**
- `Registrations` stores opportunity, country, requirements, document checklist/status, submitted/expected/actual dates, cost bearer, status, blocker, next action, document-due date, and optional user milestone date/title.
- `Tenders` stores opportunity, project number/name, deadline, document status, qualification, bidder, deposit, customer experience, local team, funding, risk, authorization type/expiry, exclusive quote scope, floor-price support, status, and next action.
- `Orders` adds opportunity id, PI/PO number, currency, independent payment/production/shipping states, estimated arrival, order result, and estimated repurchase date.
- Schema advances from v5 to v6 with foreign keys and indexes for opportunity, status, deadline, expected completion, and repurchase date.

- [ ] Add migration tests that create a real v5 database containing all five legacy order statuses, open it as v6, and assert the exact mapping table above and row preservation.
- [ ] Add schema tests for registration/tender foreign keys, allowed enums, non-negative money, date indexes, and order lifecycle columns.
- [ ] Run `flutter test test/data/migration_test.dart test/data/phase_e_schema_test.dart` and record that the new assertions fail for missing v6 structures.
- [ ] Add enums, Drift tables, v6 migration, compatibility derivation, indexes, and generated code.
- [ ] Run `dart format lib test`, the focused tests, `flutter test test/data/cascade_test.dart test/data/crud_test.dart`, and `flutter analyze`.
- [ ] Stage only E-1 files and commit `阶段 E-1：新增注册招标与订单迁移结构`.

### E-2: Implement registration and tender data services

**Files:**
- Create: `lib/data/daos/registration_dao.dart`
- Create: `lib/data/daos/tender_dao.dart`
- Generated: `lib/data/daos/registration_dao.g.dart`
- Generated: `lib/data/daos/tender_dao.g.dart`
- Modify: `lib/data/database.dart`
- Modify: `lib/features/business/business_providers.dart`
- Create test: `test/data/registration_tender_dao_test.dart`
- Modify test: `test/features/business/business_service_test.dart`

**Interfaces:**
- `RegistrationDao` provides insert, update, get, watch/list by opportunity, and due-record queries.
- `TenderDao` provides insert, update, get, watch/list by opportunity, and open-deadline queries.
- `BusinessService.createRegistration/updateRegistration` normalizes text, verifies customer/opportunity ownership, validates date order, and requires the next action for blocked records.
- `BusinessService.createTender/updateTender` enforces fixed authorization values, first-tender risk default, document-before-qualification, prerequisite checks, and explicit high-risk acknowledgement.

- [ ] Write DAO/service tests for CRUD, ownership rejection, normalization, date relations, first-tender risk, qualification gating, authorization prerequisites, and high-risk acknowledgement.
- [ ] Run the focused tests and confirm failures identify the missing DAOs and service behavior.
- [ ] Implement typed DAOs and the minimum registration/tender validation paths.
- [ ] Run build generation, `dart format lib test`, focused DAO/service tests, existing quote/sample service tests, and `flutter analyze`.
- [ ] Stage only E-2 files and commit `阶段 E-2：实现注册招标数据服务与风控校验`.

### E-3: Upgrade order service and repurchase lifecycle

**Files:**
- Modify: `lib/data/daos/order_dao.dart`
- Generated: `lib/data/daos/order_dao.g.dart`
- Modify: `lib/features/orders/order_providers.dart`
- Modify: `lib/features/orders/order_form_page.dart`
- Modify test: `test/features/orders/order_service_test.dart`
- Modify test: `test/data/dashboard_query_test.dart`

**Interfaces:**
- `OrderService.createOrder/updateOrder` requires a real customer-owned opportunity and accepts PI/PO number, currency, amount, three lifecycle states, arrival date, result, and repurchase date.
- Legacy aggregate status and dashboard成交额 remain compatible and are deterministically derived from the new result/lifecycle fields.
- Saving a new valid order completes open repurchase tasks for the same customer/opportunity and retains a newly confirmed next repurchase date.

- [ ] Add tests for real-project ownership, independent states, currency/amount normalization, aggregate compatibility, and completion of an older repurchase task after a new order.
- [ ] Run the focused order/dashboard tests and confirm the assertions fail against the legacy mixed-state service.
- [ ] Implement DAO queries, service validation, compatibility derivation, and repurchase-task completion in one transaction with the order write.
- [ ] Update the existing order form only enough to exercise the verified service contract; full Phase E navigation polish remains E-5.
- [ ] Run build generation, `dart format lib test`, focused tests, customer/dashboard regressions, and `flutter analyze`.
- [ ] Stage only E-3 files and commit `阶段 E-3：拆分订单状态并接通复购闭环`.

### E-4: Generate registration, tender, and repurchase tasks

**Files:**
- Modify: `lib/services/business_task_rules.dart`
- Modify: `lib/data/daos/plan_dao.dart`
- Generated: `lib/data/daos/plan_dao.g.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify test: `test/services/business_task_rules_test.dart`
- Modify test: `test/features/customers/customer_service_test.dart`

**Interfaces:**
- `BusinessTaskRules.generateForOpportunity(...)` adds registration expected-completion, document-due, and user-milestone rules.
- Open tenders generate `deadline-30d`, `deadline-14d`, `deadline-7d`, `deadline-3d`, and `deadline-1d` tasks at their exact boundaries.
- Completed orders generate `repurchase-30d`; a later order completes the prior task through the E-3 service flow.
- Every rule persists via the current task identity before calling the reminder scheduler and catches scheduling errors without deleting the task.

- [ ] Add rule tests for every boundary, repeat generation, closed/paused suppression, tender close/abandon/disqualification suppression, task-first persistence, and scheduler-failure retention.
- [ ] Run focused rule tests and confirm failures for the new source types and failure-degradation contract.
- [ ] Implement deterministic rule evaluation and the smallest Plan DAO additions needed to query/complete repurchase tasks.
- [ ] Run `dart format lib test`, focused rule/service tests, notification tests, migration tests, and `flutter analyze`.
- [ ] Stage only E-4 files and commit `阶段 E-4：实现注册招标复购自动任务规则`.

### E-5: Add Phase E forms, routes, project entry points, and anomalies

**Files:**
- Create: `lib/features/business/registration_form_page.dart`
- Create: `lib/features/business/tender_form_page.dart`
- Modify: `lib/features/orders/order_form_page.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Modify: `lib/features/funnel/funnel_page.dart`
- Modify: `lib/router.dart`
- Create test: `test/features/business/phase_e_pages_test.dart`
- Modify test: `test/features/orders/order_service_test.dart`
- Modify test: `test/features/funnel/funnel_page_test.dart`

**Interfaces:**
- Customer detail exposes registration, tender, and order actions under a selected real opportunity.
- Registration and tender forms expose all SPRD fields, inline validation, risk warning/acknowledgement, and stable keys prefixed `registration-` and `tender-`.
- Order form selects a real opportunity and separately edits payment, production, shipping, result, arrival, and repurchase fields with stable keys prefixed `order-`.
- Funnel anomalies show overdue registration, imminent tender, and due repurchase entries and navigate to their customer/project context.

- [ ] Write widget tests for all required fields, project selection, validation, tender risk warning, save flows, anomaly rows, and navigation.
- [ ] Run focused widget tests and confirm failures for missing pages/routes/fields.
- [ ] Implement compact forms, routes, customer-project entry points, provider invalidation, and anomaly navigation using existing design tokens.
- [ ] Run `dart format lib test`, focused widget tests, app skeleton/customer/funnel regressions, and `flutter analyze`.
- [ ] Stage only E-5 files and commit `阶段 E-5：接入注册招标订单表单与异常入口`.

### E-6: Verify Phase E end to end

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-registration-tender-order-repurchase.md`
- Create: `docs/superpowers/plans/2026-08-05-phase-e-end-to-end-verification.md`

- [x] Run build generation and assert generated files have no uncommitted drift.
- [x] Run `dart format --output=none --set-exit-if-changed lib test` and `flutter analyze`.
- [x] Run the complete `flutter test` suite and record the exact passing count: 240 tests.
- [x] Run `flutter build apk --debug` and record the resulting APK path, 192328026-byte size, and SHA-256 digest.
- [x] Install the APK on the configured Android emulator without clearing existing app data, then cold-start and verify the retained database upgrades from v5 to v6 with its 9 customers and 9 opportunities preserved.
- [x] Inspect the registration, tender, decomposed order, and dashboard routes without saving acceptance-only records; use automated tests for lifecycle/rule cases that the retained database cannot exhibit.
- [x] Capture emulator evidence and append commands, results, migration outcome, and remaining later-phase boundaries to `docs/phase6/VERIFICATION.md`.
- [x] Compare implemented fields/rules against SPRD sections 5.7, 5.8, 5.9, 6.2, 7.4, 7.5, 12, 17, and 18.
- [x] Run the Phase E placeholder scan, final formatting, analysis, complete tests, and diff review against the three verification documents.
- [x] Stage only the three E-6 verification/plan files and commit `阶段 E-6：完成注册招标订单复购验收`.

**Evidence boundary:** The retained emulator had zero v5 order rows and no current registration, tender, or repurchase anomalies. The five-state order mapping and concrete anomaly-card behavior are therefore proven by controlled automated tests, while the emulator proves retained-data v5→v6 migration, UI reachability, and anomaly empty-state behavior. OnePlus 13/ColorOS behavior and seven-day notification observation remain release gates outside this E-6 commit.

## Coverage Review

This plan covers SPRD registration, tender, government-bid controls, decomposed order tracking, repurchase reminders, relevant dashboard anomalies, and Phase E acceptance criteria. Supplier recommendation, Excel export, backup/restore, example data, and seven-day target-device reminder observation remain Phase F-G work and are not silently folded into Phase E.
