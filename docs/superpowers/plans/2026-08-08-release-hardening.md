# Production Release Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use verification-before-completion before claiming this plan is complete. Execute the tasks inline in this session because the user already requested implementation.

**Goal:** Turn the current Android-only local CRM candidate into a reproducible, privacy-conscious release artifact without weakening existing offline behavior or fabricating physical-device evidence.

**Architecture:** Keep runtime business code unchanged except for startup degradation and notification privacy. Make release signing explicit and externally supplied, deny platform-level automatic data extraction in favor of the app's validated backup format, and codify release gates in tests, CI, and operator documentation.

**Tech Stack:** Flutter, Dart, Android Gradle Kotlin DSL, GitHub Actions, Drift, flutter_test

## Global Constraints

- Preserve all existing uncommitted contact-snapshot and dashboard work.
- Do not create, commit, or print a production keystore or its passwords.
- A release build must fail when production signing inputs are absent; verification may use an ephemeral temporary keystore.
- Physical-device and seven-day reminder checks remain explicitly unverified until performed on the target device.
- Do not add cloud services, analytics, accounts, or network dependencies.

---

### Task 1: Release identity and signing gate

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Create: `android/key.properties.example`
- Create: `test/release_hardening_test.dart`

**Interfaces:**
- Consumes: Android release tasks and local `android/key.properties` values.
- Produces: a `release` signing config that never falls back to the debug certificate.

- [x] Set the package version to `2.1.0+2` so runtime metadata matches the v2.1 guide.
- [x] Load `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` from ignored `android/key.properties`.
- [x] Fail release task configuration with a clear message when the file or required values are missing.
- [x] Add a checked-in example file containing names only, never secrets.
- [x] Add a repository guard test asserting that release does not reference the debug signing config.

### Task 2: Data exposure boundaries

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `android/app/src/main/res/xml/backup_rules.xml`
- Create: `android/app/src/main/res/xml/data_extraction_rules.xml`
- Modify: `lib/services/notification_service.dart`
- Modify: `test/release_hardening_test.dart`

**Interfaces:**
- Consumes: Android backup/data-transfer policy and local notification visibility.
- Produces: explicit exclusion from system backup/device transfer and private lock-screen notifications.

- [x] Disable implicit Android app-data backup and bind explicit empty extraction rules for supported Android versions.
- [x] Change notification visibility from `public` to `private` while preserving title, actions, and in-app behavior.
- [x] Extend the guard test to cover manifest backup attributes, extraction rules, and private notification visibility.

### Task 3: Non-blocking startup and local failure visibility

**Files:**
- Modify: `lib/main.dart`
- Create: `test/main_bootstrap_test.dart`

**Interfaces:**
- Consumes: existing reminder bootstrap and attachment orphan cleanup functions.
- Produces: `bootstrapBackgroundServices(ProviderContainer)` that runs after `runApp` and isolates failures per service.

- [x] Extract a public bootstrap coordinator with independent reminder and attachment cleanup failure boundaries.
- [x] Start the widget tree before scheduling the coordinator with `unawaited`, so platform initialization cannot indefinitely block first paint.
- [x] Add tests proving attachment cleanup still runs when reminder bootstrap fails and that bootstrap returns without throwing.

### Task 4: Repeatable release gates and operator documentation

**Files:**
- Create: `.github/workflows/android-release-gate.yml`
- Replace: `README.md`
- Modify: `docs/USER_GUIDE.md`
- Modify: `docs/TEST_CHECKLIST.md`

**Interfaces:**
- Consumes: pinned Flutter dependencies, guard tests, temporary CI signing credentials, and existing target-device checklist.
- Produces: a repeatable build gate and a human release/runbook boundary.

- [x] Add CI steps for dependency restore, code generation, formatting check, analyze, Flutter tests, app-native release tests, and an ephemeral-signed release APK.
- [x] Document local setup, signing custody, versioning, backup limitations, release commands, and the target-device gate in the README.
- [x] Fix user-guide section numbering and document private lock-screen behavior plus plaintext backup custody.
- [x] Update the release checklist to schema v10 and add signing-certificate, destructive restore, seven-day target-device, and clean-tag gates.

### Task 5: Verification

- [x] Run `dart format` on every touched Dart file.
- [x] Run focused release-hardening and bootstrap tests.
- [x] Run `dart run build_runner build`, `flutter analyze`, and the full `flutter test` suite.
- [x] Generate an ephemeral keystore outside the repository and build a signed release APK with it.
- [x] Verify the APK certificate is not `Android Debug`, run app-native release tests, and run `git diff --check`.
- [x] Review the final working tree without committing or modifying unrelated changes.
