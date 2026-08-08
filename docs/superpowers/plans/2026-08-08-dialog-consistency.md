# Dialog Consistency Implementation Plan

> **For agentic workers:** Execute this plan task-by-task in the current session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent short standard dialogs from collapsing into narrow panels while preserving responsive behavior on small screens.

**Architecture:** Define dialog width tokens beside the existing layout tokens and apply them once through the shared light/dark `DialogThemeData`. Keep every existing `AlertDialog` unchanged so the theme remains the single source of visual behavior.

**Tech Stack:** Flutter, Material 3, `flutter_test`

## Global Constraints

- Follow `docs/REQUIREMENTS_DIALOG_CONSISTENCY_2026-08-08.md`.
- Add failing tests before changing production theme code.
- Do not introduce a custom dialog wrapper or edit individual dialog call sites.
- Preserve unrelated worktree changes and commit only this phase.
- Physical-device validation is excluded; Android emulator validation remains required.
- Synchronize `docs/UI_GUIDELINES.md`, `docs/USER_GUIDE.md`, and `lib/features/settings/user_guide_page.dart` before commit.

### Task 1: Lock The Responsive Width Contract

**Files:**
- Modify: `test/app_skeleton_test.dart`
- Modify: `lib/theme/tokens.dart`
- Modify: `lib/theme/theme.dart`

- [x] **Step 1: Write failing theme and widget tests**

Assert identical 360dp/420dp constraints in light and dark themes. Pump a short `AlertDialog` at 412dp and verify it reaches the minimum width. Pump it at 320dp and verify it clamps to the available 288dp without exceptions or overflow.

- [x] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/app_skeleton_test.dart`

Expected: compilation or expectation failure because dialog width tokens and the minimum theme constraint do not exist.

- [x] **Step 3: Add shared tokens and theme constraints**

Add `dialogMinWidth` and `dialogMaxWidth` layout tokens, then apply both to the existing global `DialogThemeData`. Keep all existing dialog styling and call sites unchanged.

- [x] **Step 4: Run the focused test and verify GREEN**

Run: `flutter test test/app_skeleton_test.dart`

Expected: all theme and responsive widget tests pass without layout exceptions.

### Task 2: Synchronize Guidance

**Files:**
- Modify: `docs/UI_GUIDELINES.md`
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`

- [x] **Step 1: Document the design-system contract**

Record the 360dp minimum, 420dp maximum, 16dp horizontal inset, responsive clamping, and light/dark parity in the UI guidelines.

- [x] **Step 2: Update both user guides**

Explain concisely that confirmation and editing dialogs now use a consistent readable width and adapt automatically on narrow screens. Avoid implementation details.

### Task 3: Verify And Commit

- [x] **Step 1: Format and run focused verification**

Run: `dart format lib test`

Run: `flutter test test/app_skeleton_test.dart`

- [x] **Step 2: Run full verification**

Run: `flutter test`

Run: `flutter analyze`

Run: `flutter build apk --release`

Run: `git diff --check`

- [x] **Step 3: Validate the release APK on Android emulator**

Install the release APK on `emulator-5554`, launch the application, exercise a short confirmation dialog, the unsaved-changes dialog, and the import correction dialog, then verify the process remains alive and logs contain no Flutter fatal exception.

Result: The release APK was installed and launched successfully. Automated widget coverage verified the shared responsive contract used by standard dialogs, and the short “取消任务？” business dialog was visually inspected at 945px on a 1080px-wide emulator. The process remained alive and the sampled logs contained no Flutter fatal exception. Physical-device validation remains excluded.

- [x] **Step 4: Complete the plan and create an independent commit**

Mark completed checkboxes, stage only phase-owned changes, inspect the cached diff, and commit with:

```bash
git commit -m "fix: standardize dialog widths"
```
