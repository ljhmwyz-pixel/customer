# 可发现性与导入反馈 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make high-frequency customer actions visible from Today and make the import flow self-explanatory from first open to completion.

**Architecture:** Keep navigation changes at the page layer. Add a small reusable quick-action strip to Today, and keep import state inside the existing import page. No database or service contract changes are needed.

**Tech Stack:** Flutter, GoRouter, Riverpod, existing import service and widget-test patterns.

## Global Constraints

- Preserve existing routes and deep links.
- Keep actions in the thumb-friendly first viewport.
- Do not add decorative cards or a new visual theme.
- Physical-device notification and file-provider behavior remain unverified.

## Tasks

### Task 1: Add failing interaction tests

- [ ] Assert Today renders “新建客户”, “客户列表”, and “导入客户” actions.
- [ ] Assert import page shows step labels, validates unsupported extensions, and exposes “查看客户列表” after success.

### Task 2: Implement Today quick actions

- [ ] Add a compact action strip above the task summary.
- [ ] Route actions to `/customers/new`, `/customers`, and `/settings/customer-contact-import`.
- [ ] Keep the empty-state CTA unchanged as a fallback.

### Task 3: Implement import feedback states

- [ ] Show “第 1 步 / 第 2 步” guidance and selected-file state.
- [ ] Reject unsupported extensions before reading bytes.
- [ ] Add a success action that routes to `/customers` and clears transient result state after navigation.
- [ ] Preserve retry behavior after cancellation or failure.

### Task 4: Verify and document

- [ ] Run focused tests, full analyze, full tests, release build, and diff check.
- [ ] Update both user guides with the Today quick actions and import flow.
- [ ] Install the release APK on the configured emulator; do not claim physical-device verification.
