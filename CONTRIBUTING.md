# Contributing

Use Flutter 3.47.2 / Dart 3.13.2 and run `flutter pub get`. Start with a focused
issue or pull request describing the user-visible problem and the smallest
complete solution. Keep unrelated formatting and generated changes out of a fix.

Before submitting:

```sh
dart format lib test integration_test tool web/drift_worker.dart
flutter analyze
flutter test
```

For platform work, also build and run the affected runner. For database work,
follow [the migration rules](docs/ARCHITECTURE.md). Never rewrite or delete user data
as an upgrade strategy. Test persistence and failed writes, not just the happy path.

Keep domain code free of Flutter imports. UI must use the repository/provider
boundary. Put user-facing text in `lib/l10n/app_en.arb`; do not add remote fonts,
analytics, telemetry, or cloud dependencies. Avoid logging task contents.

Generate Drift code with `dart run build_runner build` and localization with
`flutter gen-l10n`. Commit the lockfile and generated code for reproducible clones.
Review visual changes at phone, medium, and expanded widths, both themes, and
large text. Update golden images only after inspecting the difference.

Use conventional-style commit messages, such as `fix(tasks): preserve reminder on edit`.
Describe the problem, final behavior, and actual validation in pull requests.
