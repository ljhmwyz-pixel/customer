# 客户联系人导入 MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a validated, transactional Excel/CSV import flow for customers and contacts.

**Architecture:** Keep parsing and validation in a pure import service that returns a preview model. The settings page only handles file selection, preview, confirmation, and result presentation. The database writer consumes validated rows inside one Drift transaction and uses existing customer/contact DAOs.

**Tech Stack:** Flutter, Riverpod, Drift, `excel` 4.0.6, existing native file picker channel, Flutter widget tests.

## Global Constraints

- Local-only data; no cloud sync or account system.
- Existing database schema remains v9; no new migration is needed.
- Import scope is customers and contacts only.
- Existing backup/restore remains full replacement and is not changed.
- All user-facing text must be Chinese and documented in both user guides.

## Files

- Create: `lib/services/customer_contact_import_service.dart` (parse, validate, preview, transactional write)
- Create: `lib/services/customer_contact_import_providers.dart` (Riverpod wiring)
- Create: `lib/features/settings/customer_contact_import_page.dart` (UI)
- Modify: `lib/features/settings/settings_page.dart` (visible entry)
- Modify: `lib/router.dart` (route)
- Modify: `lib/features/settings/user_guide_page.dart` and `docs/USER_GUIDE.md` (instructions)
- Test: `test/services/customer_contact_import_service_test.dart`, `test/features/settings/customer_contact_import_page_test.dart`

## Tasks

### Task 1: Define import models and parser contract

- [ ] Add immutable row, issue, preview, and result types.
- [ ] Parse UTF-8 CSV with the first row as headers; parse the first worksheet of XLSX with `Excel.decodeBytes`.
- [ ] Normalize header whitespace and support the exact template headers from the requirements document.
- [ ] Write tests for CSV parsing, missing required fields, duplicate customer numbers, and boolean normalization.

### Task 2: Implement validation and transactional persistence

- [ ] Validate customer name, customer-number uniqueness, enum labels, and contact ownership.
- [ ] Resolve existing customers by customer number; create/update through existing DAOs while preserving legacy default projects.
- [ ] Match contacts by `(customerId, name)`; insert or update through `ContactDao`.
- [ ] Reject invalid rows before opening the write transaction; roll back the entire batch on database failure.
- [ ] Add service tests for create, update, contact upsert, and rollback.

### Task 3: Add settings UI and route

- [ ] Add “客户/联系人导入” directly under Excel 导出 in “我的”.
- [ ] Provide template download through the existing share service pattern.
- [ ] Use the existing native file picker, show preview counts and row-level errors, and disable confirmation while busy.
- [ ] Require explicit confirmation and show final created/updated/skipped/failed counts.
- [ ] Add widget tests for idle, preview, validation error, and successful confirmation states.

### Task 4: Documentation and release verification

- [ ] Document template fields, duplicate rules, backup recommendation, and current scope in both guides.
- [ ] Run focused tests, full `flutter analyze`, full `flutter test`, release build, and `git diff --check`.
- [ ] Run simulator smoke paths and a backup/restore rehearsal; explicitly leave physical-device checks unclaimed.
