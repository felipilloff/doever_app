# Bundled assets

- **Lato** regular and semibold: Łukasz Dziedzic; SIL Open Font License 1.1.
  Files and full license: `assets/fonts/`. Copied unmodified from the installed
  `fonts-lato` distribution. https://www.latofonts.com/
- **SQLite WASM**: unmodified `sqlite3.wasm` from
  https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.5.2 .
  SQLite is public domain; the sqlite3.dart wrapper uses MIT. See upstream
  https://github.com/simolus3/sqlite3.dart/blob/main/sqlite3/LICENSE .
- **Drift worker**: generated locally from `web/drift_worker.dart` using the locked
  Dart/Drift versions. Drift uses MIT:
  https://github.com/simolus3/drift/blob/develop/LICENSE .
- **Material icons**: supplied through the Flutter SDK under their upstream
  license and included in Flutter's generated license registry.

Dart/Flutter package licenses remain with their respective upstream projects.
The repository's MIT license covers Doever's original source, not a relicensing
of third-party assets.

The neutral Doever application mark is original vector artwork in `assets/brand/doever.svg`. Regenerate native icon sizes with `flutter test tool/generate_icons.dart`.
