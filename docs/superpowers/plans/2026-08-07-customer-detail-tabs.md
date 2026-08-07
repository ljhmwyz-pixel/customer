# 客户详情四页签 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Split customer detail into four focused, independently scrollable views without changing business behavior.

**Architecture:** Wrap the existing detail scaffold in `DefaultTabController` and place a Material `TabBar` in the app bar. Reuse the existing section widgets in four `RefreshIndicator + ListView` children. Add display flags to the project tile so project and business views share routing code without duplicating business rules.

**Tech Stack:** Flutter Material 3, Riverpod, GoRouter, existing customer detail providers and widget tests.

## Global Constraints

- Preserve all existing routes, provider refresh behavior, and attachment owners.
- Keep the global “记录跟进” floating action visible in all tabs.
- Default to Dynamic when a highlighted plan is supplied.
- No database or service changes.

## Tasks

### Task 1: Lock interaction behavior with tests

- [ ] Assert all four tab labels render at 320px width.
- [ ] Assert Overview contains customer data and contacts.
- [ ] Assert Project excludes nested business records.
- [ ] Assert Business contains grouped records and orders.
- [ ] Assert Dynamic contains plans/followups and is initially selected for plan deep links.

### Task 2: Split the page body

- [ ] Add `DefaultTabController`, app-bar `TabBar`, and four `TabBarView` children.
- [ ] Extract a shared refreshable list wrapper with stable padding.
- [ ] Move existing sections into their target tab without changing callbacks.

### Task 3: Separate project summary from business records

- [ ] Add `showBusinessRecords` and `showProjectActions` options to `_OpportunityTile`.
- [ ] Render project summaries without nested records in Project.
- [ ] Render project context and record maintenance routes in Business.
- [ ] Keep orders in Business and all order state actions unchanged.

### Task 4: Verify and document

- [ ] Update existing customer-detail tests to select the relevant tab before interaction.
- [ ] Run analyze, all tests, release build, diff check, and emulator screenshots.
- [ ] Update repository and in-app user guides.
- [ ] Commit the phase as an isolated change.
