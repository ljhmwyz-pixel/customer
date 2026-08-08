# Contact Name Snapshot Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use verification-before-completion before claiming this plan is complete.

**Goal:** Make follow-up contact names immutable historical snapshots so later contact edits or deletion do not rewrite timeline and export history.

**Architecture:** Add a nullable snapshot column to `followups`, populate it in a v10 additive migration, and write it through `CustomerService` after validating contact ownership. Timeline and export reads prefer the snapshot while retaining a current-contact fallback for compatible legacy data.

**Tech Stack:** Flutter, Dart, Drift, SQLite, Riverpod, flutter_test

---

### Task 1: Add the v10 storage model and migration

- [x] Add `contactNameSnapshot` to the follow-up Drift table.
- [x] Raise the database schema version to 10.
- [x] Add an additive v9-to-v10 migration and backfill names for contacts that still exist.
- [x] Add migration coverage for associated and unassociated historical follow-ups.
- [x] Regenerate Drift output.

### Task 2: Capture the snapshot on new follow-ups

- [x] Extend the follow-up DAO write API with the snapshot value.
- [x] Resolve and validate the selected contact in `CustomerService`.
- [x] Persist the trimmed contact name with the follow-up.
- [x] Test that contact edits and deletion leave the stored snapshot unchanged.

### Task 3: Prefer the snapshot in timeline and export reads

- [x] Resolve timeline contact labels from the snapshot before current contact data.
- [x] Export the snapshot with a current-contact fallback for old nullable rows.
- [x] Cover deleted-contact behavior in widget and export tests.

### Task 4: Update schema expectations and user guidance

- [x] Update latest-schema assertions and backup manifest expectations to v10.
- [x] Document that contact names are retained as follow-up history.
- [x] Preserve deliberately old fixture versions.

### Task 5: Verify the feature

- [x] Format all touched Dart files.
- [x] Run focused migration, DAO, service, widget, export, and backup tests.
- [x] Run `flutter analyze` and `git diff --check`.
- [x] Review the final diff and working tree without committing the new work.
