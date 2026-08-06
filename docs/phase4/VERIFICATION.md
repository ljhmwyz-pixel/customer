# Phase 4 Attachment Verification Record

Date: 2026-08-06

Status: automated and Android emulator common flows pass; target-device checks remain open.

## Delivered Scope

- One v7 attachment table with six exclusive owners: follow-up, order, quote, sample, registration, and tender.
- App-private relative-path storage, image normalization/compression, Android photo/camera sources, and `ACTION_OPEN_DOCUMENT` file import.
- Reusable owner-scoped list, count, add, image preview, external open, and confirmed-delete UI.
- Saved-record attachment entry points and count badges for all six owners; draft forms remain attachment-free.
- Database-first record/customer graph deletion, stable cleanup reports, user warnings, and deterministic orphan retry at startup.
- Project deletion guards covering follow-ups, plans, orders, quotes, samples, registrations, and tenders.

## Automated Evidence

- `dart run build_runner build --delete-conflicting-outputs`: exit 0; the installed build_runner warns that the legacy flag is ignored and regenerated the expected Drift accessor.
- `flutter analyze`: `No issues found!`.
- `flutter test`: 399 tests passed, zero failures.
- `flutter build apk --debug`: success, SHA-256 `e4882c5976ffa1c86b61cef0fbab03ed4825fd0418f16c57f54c5d5cddbee116`.
- `flutter build apk --release`: success, 65.9 MB, SHA-256 `2970c505465437233c8e28dcaca723c1d384c0fc23fd852284de87044ddbc3f1`.
- `git diff --check`: passed before the G-6 commit.

The suite includes controlled v6-to-v7 migration with real follow-up/order attachment rows, six-owner constraints and cascades, private file operations, compression degradation, typed routes, UI states, all six record entry points, database-failure preservation, missing-file behavior, failed cleanup retry, full customer-tree deletion, project guards, and startup reconciliation.

## Android Emulator Evidence

Environment:

- Device: `sdk_gphone16k_arm64` AOSP emulator (`emulator-5554`).
- Android: 17 / API 37.
- Flutter: 3.44.8.
- Upgrade: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`; result `Success`, with no uninstall or app-data clear.

Cold-start and retained-data observations:

- `topResumedActivity` was `com.snyder.customer/.MainActivity`.
- The inspected logcat window contained no `FATAL EXCEPTION`, `SQLiteException`, Drift error, or `E/flutter` entry.
- A read-only database copy reported `PRAGMA user_version = 7`, 9 customers, 10 opportunities, and an empty `PRAGMA foreign_key_check`.

Common attachment flow:

1. Opened the saved follow-up attachment page; the initial count was zero.
2. Imported `62.png` through the Android photo picker. The page showed `image/png` and 156.8 KB.
3. Opened the in-app preview. The screenshot at `/tmp/customer-attachment-preview.png` showed a nonblank, correctly framed image.
4. Imported `customer-attachment.txt` through the system Documents UI. The page showed `text/plain` and 22.0 KB.
5. Opened the text attachment through Android's chooser and HTML Viewer.
6. The private database contained two relative paths under `attachments/2026/08/`, and both physical files existed below `app_flutter/attachments/2026/08/`.
7. Force-stopped and cold-started the app. The same saved follow-up attachment page showed both rows and count 2.
8. Imported `attachment-qa.pdf` through Documents UI. The page showed `application/pdf` and 1.6 KB, and Android Drive PDF Viewer rendered the complete one-page file.
9. Confirmed deletion of `attachment-qa.pdf`. The UI count changed from 3 to 2, attachment id 3 no longer existed in SQLite, and `app_flutter/attachments/2026/08/1786004349753585.pdf` no longer existed; the image and text attachments remained intact.

## Open Acceptance Items

- AOSP photo and Documents UI behavior does not prove real camera capture or ColorOS file-provider compatibility.
- OnePlus 13 / ColorOS 15 camera, provider, external PDF application, process-exit, and restart checks remain required before target-device completion is claimed.

The repeatable release checklist is `docs/TEST_CHECKLIST.md`.

## Phase F Sample Data Evidence

Date: 2026-08-06

Status: v8 migration, nine reversible scenarios, settings UI, and AOSP emulator flow pass; OnePlus 13 / ColorOS 15 remains open.

Automated evidence:

- `flutter analyze`: `No issues found!`.
- `flutter test`: 411 tests passed, zero failures.
- `flutter build apk --debug`: success, SHA-256 `5175f30d03f2ff33d61ec122ec27ed0f0a2bd9cdefeaf113e22c2943e7b61dce`.
- `flutter build apk --release`: success, 66.0 MB, SHA-256 `b74943823f3823bc20b35f6df3f282331875073b38e7f24dd6b8697088fec5a2`.
- Focused service evidence: six service tests cover nine scenario fields, duplicate import, transaction rollback, edit-tolerant undo, reminder cancellation, attachment path handoff, and cleanup-failure reporting.

Emulator evidence:

- Device `emulator-5554`, AOSP `sdk_gphone16k_arm64`, Android 17 / API 37, 1080x2400.
- Debug APK installed with `adb install -r`; existing attachment data was retained.
- Settings page initially showed `尚未导入`; no sample rows were created before the explicit command.
- After confirmation, page showed `已导入 9 条`, and the customer list showed `示例｜Medtron 合作商`, `示例｜普通注射器招标客户`, and `示例｜样品测试客户` among existing records.
- After force-stop and cold-start, the sample page still showed `已导入 9 条`.
- After confirmation of whole-batch undo, the page showed `尚未导入` and the SnackBar `已撤销 9 条示例数据`.

The internal batch marker is `phase-f-samples-v1`; it is not user-editable or used as a visible tag, so renaming or adding child records cannot detach a sample graph from undo.
