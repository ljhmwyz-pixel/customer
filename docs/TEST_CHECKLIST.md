# Release Test Checklist

## Attachments

### Automated gate

- [x] Fresh v7 schema accepts exactly one of six attachment owners and rejects zero or multiple owners.
- [x] Controlled v6-to-v7 migration preserves follow-up/order attachments and passes `PRAGMA foreign_key_check`.
- [x] Relative-path validation prevents absolute paths and attachment-root escapes.
- [x] Ordinary files copy byte-for-byte; images use orientation correction, 1920px bounds, and bounded quality attempts.
- [x] Add failures remove newly written files without hiding the database error.
- [x] Single-attachment and graph deletion commit database state before physical cleanup.
- [x] Missing files are non-fatal; failed deletes remain deterministic startup-cleanup candidates.
- [x] Customer-tree deletion covers follow-up, order, quote, sample, registration, and tender attachments.
- [x] Project deletion is blocked by follow-ups, plans, orders, quotes, samples, registrations, or tenders.
- [x] Attachment pages cover loading, empty, populated, error, add, preview, open, confirmation, 320px, and dark-mode states.
- [x] `flutter analyze`, full `flutter test`, debug APK, and release APK complete successfully.

### Android emulator

- [x] Install debug APK with `adb install -r` without uninstalling or clearing retained data.
- [x] Cold start reaches `com.snyder.customer/.MainActivity` without Flutter, Drift, SQLite, or Android runtime fatal logs.
- [x] Retained database reports schema v7 and an empty `PRAGMA foreign_key_check`.
- [x] Import an image through the Android photo picker and display its real name, MIME type, and size.
- [x] Open the imported image in the in-app zoomable preview and confirm the rendered image is nonblank.
- [x] Import an ordinary file through `ACTION_OPEN_DOCUMENT` and display its real name, MIME type, and size.
- [x] Open the ordinary file through an available external application.
- [x] Force-stop and cold-start the application; confirm attachment rows and physical files remain visible.
- [x] Confirm attachment deletion in the UI and verify the row and private file both disappear.
- [x] Import and open a PDF through an installed PDF application.

### OnePlus 13 / ColorOS 15

- [ ] Capture an image with the real camera and verify orientation, preview, persisted size, and restart survival.
- [ ] Import image and document files from ColorOS providers, including a cloud-backed provider if used in production.
- [ ] Open PDF and ordinary files with the target device's installed applications.
- [ ] Delete each tested attachment and confirm private files are removed.
- [ ] Repeat after process exit and device restart.

## Release Boundary

- Emulator evidence validates Android platform integration but does not replace ColorOS provider, camera, permission, or external-application compatibility checks.
- Do not mark the attachment feature as target-device complete until every OnePlus 13 / ColorOS 15 item above is checked.
