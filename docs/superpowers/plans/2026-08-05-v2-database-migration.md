# V2 Customer-Opportunity Database Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the local Drift database from the v1 customer-centric schema to a v2 customer-plus-opportunity schema without losing existing customers, follow-ups, plans, orders, tags, contacts, or attachments.

**Architecture:** Add an `opportunities` parent for project-specific sales state and add nullable-but-backfilled opportunity foreign keys to legacy follow-ups, plans, and orders. During the v1-to-v2 upgrade, create one deterministic legacy opportunity per customer, map the old customer stage into the 13-stage opportunity model, and attach every existing business row to that opportunity. Keep existing customer-facing services working while introducing a focused opportunity DAO for subsequent UI migration.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Drift 2.34.3, SQLite, flutter_test, build_runner.

## Global Constraints

- Existing on-device data must be preserved; no destructive reset or drop-all migration is allowed.
- Money remains integer minor units and timestamps remain UTC milliseconds.
- The migration must be transactional and idempotent for a single v1-to-v2 upgrade.
- Existing v1 screens and services must continue compiling and passing tests.
- Every old customer receives exactly one `is_legacy_default = 1` opportunity.
- Every old follow-up, follow plan, and order is backfilled to its customer's legacy opportunity.
- New business code must require a real opportunity ID even though compatibility columns remain nullable at the SQLite schema level.

---

### Task 1: Define the v2 domain and schema

**Files:**
- Modify: `lib/models/enums.dart`
- Create: `lib/data/tables/opportunities.dart`
- Modify: `lib/data/tables/followups.dart`
- Modify: `lib/data/tables/follow_plans.dart`
- Modify: `lib/data/tables/orders.dart`
- Test: `test/data/enum_test.dart`

**Interfaces:**
- Produces: `OpportunityStage`, `OpportunityStatus`, and `Opportunities`.
- Produces: nullable `opportunityId` compatibility columns on legacy business tables.

- [x] **Step 1: Add enum tests for 13 stages and legacy mappings**

```dart
expect(OpportunityStage.values, hasLength(13));
expect(OpportunityStage.fromLegacyCustomerStage(CustomerStage.deal), OpportunityStage.won);
expect(CustomerGrade.values.map((grade) => grade.label), ['A', 'B', 'C', 'D']);
```

- [x] **Step 2: Run `flutter test test/data/enum_test.dart` and confirm the new symbols are missing**
- [x] **Step 3: Implement enums and the opportunities table with customer, project, product, supplier, forecast, stage, status, legacy marker, and timestamps**
- [x] **Step 4: Add `opportunityId` foreign keys to follow-ups, plans, and orders**
- [x] **Step 5: Run the enum tests and generated-code analyzer after Task 2**

### Task 2: Register the schema and generate Drift code

**Files:**
- Modify: `lib/data/database.dart`
- Generated: `lib/data/database.g.dart`
- Generated: `lib/data/daos/*.g.dart`

**Interfaces:**
- Produces: `AppDatabase.opportunities` and generated row/companion types.

- [x] **Step 1: Register `Opportunities` before child business tables in `@DriftDatabase`**
- [x] **Step 2: Increase `schemaVersion` from 1 to 2**
- [x] **Step 3: Run `dart run build_runner build --delete-conflicting-outputs`**
- [x] **Step 4: Run `dart format` on the migration files and tests changed by this plan**

### Task 3: Implement transactional v1-to-v2 migration

**Files:**
- Modify: `lib/data/database.dart`
- Test: `test/data/migration_test.dart`

**Interfaces:**
- Consumes: v1 `customers`, `followups`, `follow_plans`, and `orders`.
- Produces: one legacy opportunity per customer and populated opportunity links.

- [x] **Step 1: Build a real v1 SQLite fixture using the former table definitions and insert customers covering all five legacy stages plus child rows**
- [x] **Step 2: Open the fixture through `AppDatabase.forTesting` and verify upgrade to schema version 2**
- [x] **Step 3: In `onUpgrade`, create `opportunities`, add the three compatibility columns, create indexes, insert legacy opportunities with a SQL stage CASE mapping, and backfill child rows**

```sql
CASE stage
  WHEN 'contacted' THEN 'contact_established'
  WHEN 'intent' THEN 'needs_confirmed'
  WHEN 'deal' THEN 'won'
  WHEN 'lost' THEN 'lost'
  ELSE 'new_lead'
END
```

- [x] **Step 4: Assert counts, stage mappings, foreign-key integrity, user_version, and unchanged legacy data**
- [x] **Step 5: Run `flutter test test/data/migration_test.dart`**

### Task 4: Add opportunity data access while preserving v1 services

**Files:**
- Create: `lib/data/daos/opportunity_dao.dart`
- Generated: `lib/data/daos/opportunity_dao.g.dart`
- Modify: `lib/data/database.dart`
- Test: `test/data/opportunity_test.dart`

**Interfaces:**
- Produces: `insertOpportunity`, `findById`, `listOfCustomer`, `findLegacyDefaultOfCustomer`, `countAll`, and `deleteOpportunity`.

- [x] **Step 1: Write tests for creating multiple opportunities per customer and finding the unique legacy default**
- [x] **Step 2: Implement `OpportunityDao` with stable `updatedAt DESC, id DESC` ordering**
- [x] **Step 3: Register the DAO and regenerate code**
- [x] **Step 4: Run the new DAO tests and existing data tests**

### Task 5: Compatibility, verification, and migration record

**Files:**
- Modify: `docs/phase1/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-v2-database-migration.md`

**Interfaces:**
- Produces: verified migration evidence and an explicit boundary for later UI/business-module work.

- [x] **Step 1: Run `flutter analyze`**
- [x] **Step 2: Run `flutter test`**
- [x] **Step 3: Run `flutter build apk --debug`**
- [x] **Step 4: Run `git diff --check`**
- [x] **Step 5: Record migration behavior, verification counts, and remaining v2 UI/business work**

## Coverage Review

This plan covers the safe schema foundation required by SPRD phase A and the data-model portion of phase B. Quote, sample, registration, tender, automated-rule, dashboard, attachment-expansion, Excel-export, and UI work are intentionally separate implementation plans because each is an independently testable subsystem. The compatibility columns are nullable only to avoid destructive SQLite table rebuilds; migration tests require every legacy row to be populated, and all new opportunity-aware services must reject missing opportunity IDs.
