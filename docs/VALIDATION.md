# Implementation validation

Environment: Ubuntu 26.04, Flutter 3.47.2 stable, Dart 3.13.2.

## Completed

- Strict static analysis, including compatible Riverpod analysis-server lint rules.
- 31 deterministic unit, repository, migration, reminder, widget, accessibility,
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
  ([run 36159427380](https://github.com/felipilloff/doever_app/actions/runs/36159427380)).
  The downloaded executable architecture, required DLLs/assets, and ZIP integrity
  were verified. No interactive Windows runtime test was performed.
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
flutter build apk --debug
flutter build web --no-web-resources-cdn
```

Integration tests use temporary data or a reserved notification ID and clean up
after themselves. Golden generation is deterministic on the pinned Linux toolchain.
