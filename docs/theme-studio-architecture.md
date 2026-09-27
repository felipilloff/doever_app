# Theme Studio

Theme Studio extends the existing `DoeverTheme`, `ColorScheme`, and Riverpod
integration. It does not own tasks, Notes, navigation, or database connections.
The advanced editor is available on Windows and Linux.

## Color model

Pure Dart theme definitions contain opaque ARGB colors. Foundation, Surface,
and Accent each support one solid color or two to three gradient stops. Tone
is a relative HCT adjustment (50 leaves the authored tone unchanged); intensity
scales chroma, and gradient strength controls the distance between stops.
Readability corrections operate on derived colors, preserving authored colors.
Custom themes have an explicit light or dark base mode. The original Doever
theme continues to support the existing system/light/dark preference.

## Storage and editing

Drift schema 3 adds custom themes and a singleton theme selection/recent-color
record. Migration is additive and supports both version 1 and version 2 users.
Deleting the active custom theme restores the default in the same transaction.
Built-in presets are immutable; editing one saves a new UUID-backed copy.

The editor keeps a session-local draft and bounded undo history. Slider ticks
never write to SQLite. Apply persists; Cancel discards. Temporary app preview
uses a separate presentation provider and never changes persistent selection.
The same router, repositories, and Notes editor remain mounted during changes.

## Rendering boundaries

Material widgets consume the generated ColorScheme. A ThemeExtension supplies
semantic interaction colors and intentional Foundation/Surface/Accent gradient
painting. Existing photo backgrounds retain their own readability scrim.
Theme files contain data only; import validates the format and every range,
and assigns fresh identity. No theme content is uploaded or remotely loaded.
