# Opportunity CRUD and Customer Detail Integration Plan

**Execution status (2026-08-05):** Tasks 1–4 implemented. Task 5 verification passed with `flutter analyze`, 175 tests, a Debug APK build, and `git diff --check`; isolated commit is the remaining gate.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users view, create, edit, and safely delete multiple product opportunities from a customer detail page using the v2 database model.

**Architecture:** Add an opportunity service between Flutter pages and `OpportunityDao`, extend customer detail aggregation to include opportunities, and add dedicated create/edit routes. Keep the existing customer, follow-up, reminder, and order flows unchanged; project-aware follow-up selection belongs to the next independently verified step.

**Tech Stack:** Flutter 3.44.8, Material 3, Riverpod 3.3.2, go_router 17.3.0, Drift 2.34.3, flutter_test.

## Global Constraints

- This step only implements project CRUD and customer-detail presentation.
- Do not add quote, sample, registration, tender, dashboard, or automatic-task behavior.
- Existing migrated “历史项目” and newly created “待确认项目” must be editable like normal projects.
- A project with linked follow-ups, plans, or orders cannot be deleted; the UI must explain why.
- Money remains integer minor units, probability is an integer from 0 through 100, and timestamps remain UTC milliseconds.
- All page writes go through `OpportunityService`; pages do not call DAOs directly.
- Existing 320px dark-mode layout tests must continue passing.

---

### Task 1: Complete opportunity DAO update and deletion-guard queries

**Files:**
- Modify: `lib/data/daos/opportunity_dao.dart`
- Generated: `lib/data/daos/opportunity_dao.g.dart`
- Test: `test/data/opportunity_test.dart`

**Interfaces:**
- Produces: `updateOpportunity(int id, OpportunityUpdate update)`-equivalent named parameters in the DAO.
- Produces: `hasLinkedBusinessRecords(int opportunityId) -> Future<bool>`.

- [ ] **Step 1: Add failing tests for field updates and linked-record detection**

```dart
await db.opportunityDao.updateOpportunity(
  opportunityId,
  name: '更新项目',
  probabilityPercent: const Value(60),
);
expect((await db.opportunityDao.findById(opportunityId))!.name, '更新项目');
expect(await db.opportunityDao.hasLinkedBusinessRecords(opportunityId), isTrue);
```

- [ ] **Step 2: Run `flutter test test/data/opportunity_test.dart` and confirm the missing methods fail compilation**
- [ ] **Step 3: Implement update parameters for every field exposed by the form**
- [ ] **Step 4: Implement one SQL existence query across follow-ups, plans, and orders**
- [ ] **Step 5: Regenerate Drift code and pass the DAO tests**

### Task 2: Add validation-focused opportunity service

**Files:**
- Create: `lib/features/opportunities/opportunity_providers.dart`
- Test: `test/features/opportunities/opportunity_service_test.dart`

**Interfaces:**
- Produces: `OpportunityDraft`, `OpportunityValidationException`, and `OpportunityService`.
- Produces: `createOpportunity`, `updateOpportunity`, and `deleteOpportunity`.

- [ ] **Step 1: Write failing service tests for normalization, valid create/update, and customer ownership**

```dart
final id = await service.createOpportunity(
  customerId,
  const OpportunityDraft(
    name: '  CT 注射器  ',
    currency: ' usd ',
    probabilityPercent: 40,
  ),
);
expect((await db.opportunityDao.findById(id))!.name, 'CT 注射器');
expect((await db.opportunityDao.findById(id))!.currency, 'USD');
```

- [ ] **Step 2: Add failing validation cases for blank name, negative amount/volume, invalid currency, and probability outside 0–100**
- [ ] **Step 3: Implement normalization and DAO delegation**
- [ ] **Step 4: Reject edit/delete when the project belongs to another customer**
- [ ] **Step 5: Reject deletion when `hasLinkedBusinessRecords` is true**
- [ ] **Step 6: Pass the service tests**

### Task 3: Aggregate and display projects on customer detail

**Files:**
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Extends: `CustomerDetailData.opportunities`.
- Displays: project name, product/model, stage, status, forecast amount, weighted amount, and next action.

- [ ] **Step 1: Add a failing detail-page test with two projects**
- [ ] **Step 2: Load projects in `customerDetailProvider`**
- [ ] **Step 3: Add a “项目” section above orders with add, edit, and delete actions**
- [ ] **Step 4: Format weighted amount as `forecastAmountMinor * probabilityPercent ~/ 100` without floating point**
- [ ] **Step 5: Confirm migrated/default projects are shown rather than hidden**
- [ ] **Step 6: Pass existing narrow dark-mode and customer-detail tests**

### Task 4: Add create/edit project form and routes

**Files:**
- Create: `lib/features/opportunities/opportunity_form_page.dart`
- Modify: `lib/router.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Route: `/customers/:customerId/opportunities/new`.
- Route: `/customers/:customerId/opportunities/:opportunityId/edit`.
- Form fields: name, product category/model, equipment brand/model, annual volume, forecast amount, currency, probability, expected close date, current supplier/brand/price, supplier stability/problem, change willingness, substitution difficulty, latest quote, target price, entry point, investment advice, sample/registration/authorization flags, stage, status, latest feedback, obstacle, next action, and next follow date.

- [ ] **Step 1: Add failing widget tests for creating and editing a project**
- [ ] **Step 2: Implement numeric parsing with integer minor units and clear validation messages**
- [ ] **Step 3: Implement a compact primary section and collapsible supplier/advanced sections**
- [ ] **Step 4: Load an existing project only when it belongs to the route customer**
- [ ] **Step 5: Save through `OpportunityService`, refresh customer data, and return to detail**
- [ ] **Step 6: Wire detail-page add/edit/delete actions and deletion confirmation**
- [ ] **Step 7: Pass form, route, and customer-detail widget tests**

### Task 5: Verification and isolated commit

**Files:**
- Modify: `docs/phase6/VERIFICATION.md`
- Modify: `docs/superpowers/plans/2026-08-05-opportunity-crud.md`

**Interfaces:**
- Produces: verification evidence for this step only.

- [ ] **Step 1: Run `dart format` on files changed by this plan**
- [ ] **Step 2: Run `flutter analyze` and require `No issues found`**
- [ ] **Step 3: Run `flutter test` and require zero failures**
- [ ] **Step 4: Run `flutter build apk --debug` and require a generated APK**
- [ ] **Step 5: Run `git diff --check`**
- [ ] **Step 6: Record test count, build result, manual-risk boundaries, and remaining work**
- [ ] **Step 7: Commit only this plan's changes with message `阶段 7：实现客户项目管理`**

## Coverage Review

This step makes the v2 project model usable and covers only SPRD phase B project CRUD. Project selection during follow-up, five-field synchronization, project-aware tasks, quote/sample tracking, and automatic rules remain deliberately excluded so each can receive its own plan, verification gate, and commit.
