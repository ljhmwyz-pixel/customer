# Business Attachment Entry Points Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Execute each task test-first and keep Flutter commands serial because concurrent runs contend for the shared native-assets directory.

**Goal:** Expose saved follow-ups, orders, quotes, samples, registrations, and tenders in the customer detail flow with an attachment action and live attachment count for each persisted record.

**Architecture:** Extend `CustomerDetailData` with project-scoped business history so the customer detail page remains the single read boundary. Add an owner-scoped Riverpod count provider beside the existing attachment list provider. Reuse `AttachmentOwnerRoute.location` for every navigation action; draft forms remain attachment-free because no owner ID exists before save.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, Drift, flutter_test.

## Global Constraints

- Support exactly six persisted owner types: follow-up, order, quote, sample, registration, and tender.
- Never expose an attachment action from a create form or for a record without a positive database ID.
- Parse and navigate through `AttachmentOwnerRoute`; do not construct nullable foreign-key combinations in UI code.
- Keep Flutter test commands serial.
- Do not stage or modify `docs/superpowers/plans/2026-08-06-business-attachments.md`.

---

### Task 1: Load project-scoped business history

**Files:**

- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `test/features/customers/customer_pages_test.dart`

**Interfaces:**

- Consumes: `QuoteDao.listVersions(int)`, `SampleDao.listOf(int)`, `RegistrationDao.listOf(int)`, and `TenderDao.listOf(int)`.
- Produces: immutable `OpportunityBusinessRecords` and `CustomerDetailData.businessByOpportunity`.

- [x] Add a provider test that seeds two projects and different quote/sample/registration/tender rows, reads `customerDetailProvider`, and proves every row is present only under its own opportunity ID.
- [x] Run the named test and confirm compilation fails because `businessByOpportunity` does not exist.
- [x] Add this immutable read model:

```dart
class OpportunityBusinessRecords {
  const OpportunityBusinessRecords({
    required this.quotes,
    required this.samples,
    required this.registrations,
    required this.tenders,
  });

  final List<QuoteRow> quotes;
  final List<SampleRow> samples;
  final List<RegistrationRow> registrations;
  final List<TenderRow> tenders;
}
```

- [x] Load the four DAO lists for each already-loaded opportunity and expose them as an unmodifiable `Map<int, OpportunityBusinessRecords>`.
- [x] Rerun the named provider test and the existing customer provider/page tests.

### Task 2: Add an owner-scoped attachment count

**Files:**

- Modify: `lib/features/attachments/attachment_providers.dart`
- Modify: `lib/features/attachments/attachment_page.dart`
- Modify: `test/features/attachments/attachment_page_test.dart`

**Interfaces:**

- Consumes: `AttachmentDao.countOf(AttachmentOwner)`.
- Produces: `attachmentCountProvider`, a `FutureProvider.family<int, AttachmentOwnerRoute>`.

- [x] Add a test that seeds attachments for two different owners and proves each `attachmentCountProvider` query returns only its owner's count.
- [x] Add widget assertions proving successful add and every database-row-deleting result invalidate both the list and count providers.
- [x] Run the attachment page test and confirm the count API assertions fail.
- [x] Implement:

```dart
final attachmentCountProvider = FutureProvider.family<int, AttachmentOwnerRoute>(
  (ref, route) => ref.watch(attachmentDaoProvider).countOf(route.owner),
);
```

- [x] Invalidate `attachmentCountProvider(widget.owner)` after add, `deleted`, `fileNotFound`, `cleanupFailed`, and `recordNotFound` outcomes.
- [x] Rerun `flutter test test/features/attachments/attachment_page_test.dart`.

### Task 3: Expose six persisted-record attachment actions

**Files:**

- Modify: `lib/features/customers/customer_detail_page.dart`
- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `test/features/business/business_pages_test.dart`
- Modify: `test/features/business/phase_e_pages_test.dart`

**Interfaces:**

- Consumes: `CustomerDetailData.businessByOpportunity`, `attachmentCountProvider`, and `AttachmentOwnerRoute.location`.
- Produces: stable keys in the form `attachment-<owner-segment>-<id>`.

- [x] Seed one record of every owner type plus one attachment per record. Assert the customer detail shows saved quote, sample, registration, and tender summaries, not only create controls.
- [x] Assert each of the six attachment controls displays count `1` and navigates to its exact path:

```text
/attachments/followup/<id>
/attachments/order/<id>
/attachments/quote/<id>
/attachments/sample/<id>
/attachments/registration/<id>
/attachments/tender/<id>
```

- [x] Run the named page tests and confirm they fail because the historical rows and controls are absent.
- [x] Add a reusable private `ConsumerWidget` attachment action that watches the count provider, shows a numeric `Badge`, and navigates with `context.push(route.location)`.
- [x] Keep order and follow-up layouts intact while adding their attachment action.
- [x] Render quote, sample, registration, and tender rows beneath their owning opportunity with concise identity/status text and the reusable attachment action.
- [x] Verify 320px width and dark mode produce no overflow.
- [x] Rerun the three affected widget test files.

### Task 4: Verify without staging the user plan

**Files:** Verify only.

- [x] Run `dart format` on all changed Dart files.
- [x] Run the attachment page test.
- [x] Run the customer page test.
- [x] Run the quote/sample and registration/tender page tests.
- [x] Run `flutter analyze`.
- [x] Run `flutter test`.
- [x] Run `flutter build apk --debug`.
- [x] Run `git diff --check` and inspect `git status --short`.
- [x] Confirm `docs/superpowers/plans/2026-08-06-business-attachments.md` remains unstaged and unmodified by this task.
