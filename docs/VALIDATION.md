# Implementation validation

Environment: Ubuntu 26.04, Flutter 3.47.2 stable, Dart 3.13.2.

## Completed

- Strict static analysis, including compatible Riverpod analysis-server lint rules.
- 45 deterministic unit, repository, migration, reminder, widget, accessibility,
  responsive/text-scaling, and golden-image tests.
- Android debug APK build, including native SQLite assets, notification receivers,
  Java desugaring, and the application runner.
- Normal Android APK installed and launched to the My Day empty state. No
  startup notification prompt appeared; Android reported POST_NOTIFICATIONS
  as not granted while Doever remained the foreground activity.
- Pixel 7 Android emulator integration: launch, create list/task, edit, complete,
  close/reopen a file-backed database, verify preserved fields and lists.
- Real Android notification adapter: schedule, replace with the same ID, inspect
  pending native requests, cancel, and verify removal. This test does not claim
  to verify notification delivery timing or permission dialogs.
- Windows x64 release build completed successfully on GitHub Actions
  ([run 36159427380](https://github.com/felipilloff/doever_app/actions/runs/36159427380));
  the five-language update also compiled in [run 36163424252](https://github.com/felipilloff/doever_app/actions/runs/36163424252).
  The downloaded executable architecture, required DLLs/assets, and ZIP integrity
  were verified. No interactive Windows runtime test was performed.
- The language selector switches English, Mandarin Chinese, Hindi, Spanish, and Arabic,
  saves the choice across app restarts, uses right-to-left layout for Arabic,
  and defaults to English for unsupported system locales; tested at phone width.
- Linux x86_64 release build and packaged archive verified after extraction,
  including shared-library resolution. The extracted release executable was
  launched and initialized an isolated local database successfully.
  The Linux desktop integration smoke test
  passed creation, editing, completion, and file-backed persistence checks.
- Web release compilation with `--no-web-resources-cdn`; local SQLite WASM and
  Drift worker are included. Web runtime storage and reload/offline behavior have
  not been exercised in a browser in this environment.
- Rendered desktop and phone screenshots in light/dark mode inspected; layouts
  tested at 390, 900, and 1440 logical pixels and at 200% text scaling.
- Desktop task creation/detail editing, completion/reopening, importance, search
  shortcut/Escape, deletion/undo; phone list creation/navigation and step creation.
- Fresh schema compared to the committed v1 baseline; existing v1 data preserved.
- File-backed database restart, soft deletion, list migration, sorting, recurrence
  month/leap boundaries, wildcard-safe search, and durable reminder retries.

## Desktop single-instance update

- Linux release and extracted TAR.GZ passed repeated launch, concurrent launch,
  and restart-after-termination checks using a private D-Bus session and temporary data.
- Windows release compiled and passed the same native process smoke test in
  [run 36190933363](https://github.com/felipilloff/doever_app/actions/runs/36190933363).
  The test now runs before publishing the Windows artifact in Platform builds.
- Both updated archives and SHA-256 manifests were verified. Foreground focus
  and minimizing/restoring windows still require an interactive desktop check.

## Desktop background customization

- Real image decoding, resizing, local copying and restart persistence are tested;
  invalid and oversized replacements preserve the existing image. Replacement and
  removal clean up the managed copy without changing the original file.
- Widget checks cover native-picker cancellation through a test adapter, preview,
  task rendering in both themes, removal, and absence of controls on Android.
- Settings and desktop screenshots with a custom background were visually inspected.
  Reproduce them with `flutter test test/background_test.dart --dart-define=backgroundScreenshots=true`.
- Linux release, web release, Windows release and Android debug compilation passed.
  Windows CI also passed the native single-instance check in
  [run 36212233048](https://github.com/felipilloff/doever_app/actions/runs/36212233048).
- The extracted Linux package passed duplicate/concurrent launch and restart checks.
- Both updated archives include the native file-selector library; ZIP integrity,
  Windows x64 architecture, and SHA-256 manifests were verified.
- Interactive native file-dialog behavior still requires target-system validation.

## Notes / Pages update

- 45 tests pass with the existing task, localization, background and golden suites.
  Notes coverage includes CRUD/tombstones, ordering, duplication, compatible
  conversion, task creation, serialized autosave, retry after failure and history.
- Migration v1 → v2 is schema-verified and compares every existing task, list,
  step and reminder-job column before/after; preferences are retained separately.
- Widget checks cover navigation, page/title editing, slash keyboard commands,
  Markdown shortcuts, checkbox edits, task creation, duplicate/delete/undo/redo,
  title and in-page search, page/block drag and menu movement, and Ctrl+N/F/Z.
  Unsupported-platform navigation is rejected. Layouts cover both themes and a
  narrow desktop window with 200% text scaling.
- Native Linux and Windows integration creates a page, text/heading/TODO blocks,
  creates a task, closes/reopens the file-backed database and verifies both page
  and task. Windows integration passed in
  [run 36227397981](https://github.com/felipilloff/doever_app/actions/runs/36227397981).
- The full CI validation, including regenerated Drift code consistency, passed in
  [run 36227397790](https://github.com/felipilloff/doever_app/actions/runs/36227397790).
- Linux/Windows release, Android debug and web compilation passed. Both desktop
  packages include the native image picker and URL launcher. The extracted Linux package resolves
  its native libraries and passed the single-instance/restart regression check.
- Image tests exercise managed copying, source removal and invalid-input/path
  rejection. Native file-dialog interaction and browser launching require manual
  validation; tests do not open remote URLs.

## Still requires target hardware / release validation

Windows was compiled on its native GitHub Actions runner, since this local host
is Linux. Interactive Windows behavior, installer identity, and OS reminder
delivery still require validation on Windows before a signed release.

Apple builds were not run. Linux was built and tested on Ubuntu 26.04 x86_64;
compatibility with older distributions is not certified. Android was tested on an emulator,
not physical OEM devices. The APK uses debug signing and is not a store release.

Before release, verify on target systems:

1. First launch never prompts for notifications; assigning a reminder prompts only
   when required. Denial and settings revocation remain understandable.
2. Foreground/background notification delivery, device reboot, OS battery saving,
   clock/timezone changes, deletion/completion cancellation, and subsequent edits.
3. Windows pending reminders with and without MSIX identity; removal of already
   shown notifications requires package identity.
4. TalkBack/Narrator/VoiceOver, keyboard-only use, high contrast, and reduced motion.
5. Large task datasets on representative hardware, disk-full failures, process
   termination during writes, and backup/restore behavior.

## Reproduce

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test tool web/drift_worker.dart
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d <android-device>
flutter test integration_test/reminders_test.dart -d <android-device>
dbus-run-session -- flutter test integration_test/notes_test.dart -d linux
flutter test integration_test/notes_test.dart -d windows # on Windows
flutter build apk --debug
flutter build web --no-web-resources-cdn
```

Integration tests use temporary data or a reserved notification ID and clean up
after themselves. Golden generation is deterministic on the pinned Linux toolchain.
