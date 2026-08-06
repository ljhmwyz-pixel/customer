# Attachment End-to-End Verification Implementation Plan

> **For agentic workers:** Execute checks serially and record only fresh evidence. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce reproducible automated, Android emulator, packaging, and target-device handoff evidence for the completed attachment feature.

**Architecture:** Keep automated correctness, emulator platform integration, and ColorOS target-device compatibility as separate evidence classes. Reuse the retained emulator database without clearing user data, and document every unverified boundary instead of inferring it from unit tests.

**Tech Stack:** Flutter 3.44.8, Dart, Drift/SQLite, ADB, Android 17/API 37 emulator.

## Global Constraints

- Run Flutter commands serially.
- Install with `adb install -r`; do not uninstall, clear app data, or reset the emulator database.
- Do not treat AOSP emulator behavior as ColorOS camera or file-provider evidence.
- Preserve `docs/superpowers/plans/2026-08-06-business-attachments.md` as an unstaged user-owned change.

---

- [x] Run `flutter analyze` and full `flutter test`; record exact results.
- [x] Build debug and release APKs and record SHA-256 values.
- [x] Install the debug APK without clearing retained data; inspect cold-start logs and the v7 database.
- [x] Import and preview an image through the Android photo picker.
- [x] Import and externally open an ordinary file through `ACTION_OPEN_DOCUMENT`.
- [x] Force-stop and cold-start; confirm database rows, physical files, and UI count survive.
- [x] Confirm UI deletion and verify database plus private-file removal.
- [x] Import and open a PDF on the emulator.
- [x] Update the PRD implementation status and create a reusable release checklist.
- [x] Write `docs/phase4/VERIFICATION.md` with evidence and explicit open boundaries.
- [x] Run final docs/source checks, stage exact G-7 files, and commit locally without push, amend, or squash.
