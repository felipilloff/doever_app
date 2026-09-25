# Implementation validation

Environment: Ubuntu 26.04, Flutter 3.47.2 stable, Dart 3.13.2.

## Completed

- Strict static analysis, including compatible Riverpod analysis-server lint rules.
- 31 deterministic unit, repository, migration, reminder, widget, accessibility,
  responsive/text-scaling, and golden-image tests.
- Android debug APK build, including native SQLite assets, notification receivers,
  Java desugaring, and the application runner.
- Pixel 7 Android emulator integration: launch, create list/task, edit, complete,
  close/reopen a file-backed database, verify preserved fields and lists.
- Real Android notification adapter: schedule, replace with the same ID, inspect
  pending native requests, cancel, and verify removal. This test does not claim
  to verify notification delivery timing or permission dialogs.
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

## Still requires target hardware / release validation

Windows cannot be built or run on this Linux host. A manual Windows GitHub Actions
build workflow is included, but has not been dispatched. Validate its installer
identity and OS reminders before distributing a Windows release.

Apple builds were not run. Linux native build prerequisites (GTK development
libraries, CMake, Ninja, Clang) are missing. Android was tested on an emulator,
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
flutter build apk --debug
flutter build web --no-web-resources-cdn
```

Integration tests use temporary data or a reserved notification ID and clean up
after themselves. Golden generation is deterministic on the pinned Linux toolchain.
