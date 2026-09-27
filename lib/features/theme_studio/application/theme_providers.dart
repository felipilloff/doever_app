import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/theme_codec.dart';
import '../domain/custom_theme.dart';
import '../domain/theme_presets.dart';
import '../domain/theme_repository.dart';

bool get supportsThemeStudio =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

final themeRepositoryProvider = Provider<ThemeRepository?>((ref) => null);

// Loaded during bootstrap, preventing a flash of the default appearance.
final initialThemeLibraryProvider = Provider<ThemeLibrary>(
  (ref) => ThemeLibrary(
    themes: const [],
    activeId: 'preset:default',
    recentColors: const [],
  ),
);

final themeLibraryProvider = StreamProvider<ThemeLibrary>((ref) async* {
  yield ref.watch(initialThemeLibraryProvider);
  final repository = ref.watch(themeRepositoryProvider);
  if (repository != null) yield* repository.watchLibrary();
});

final appliedCustomThemeProvider = Provider<CustomTheme?>((ref) {
  final ThemeLibrary library =
      ref.watch(themeLibraryProvider).asData?.value ??
      ref.watch<ThemeLibrary>(initialThemeLibraryProvider);
  if (library.activeId == 'preset:default') return null;
  return [
    ...themePresets,
    ...library.themes,
  ].where((theme) => theme.id == library.activeId).firstOrNull;
});

final themePreviewProvider = NotifierProvider<ThemePreview, CustomTheme?>(
  ThemePreview.new,
);

class ThemePreview extends Notifier<CustomTheme?> {
  @override
  CustomTheme? build() => null;
  void set(CustomTheme? value) => state = value;

  void clearIfCurrent(CustomTheme? value) {
    if (ref.mounted && identical(state, value)) state = null;
  }
}

final themeActionsProvider = Provider<ThemeActions>(
  (ref) => ThemeActions(ref.watch(themeRepositoryProvider)),
);

class ThemeActions {
  ThemeActions(this._repository);
  final ThemeRepository? _repository;
  ThemeRepository get _repo =>
      _repository ?? (throw StateError('Theme storage is unavailable'));

  Future<CustomTheme> apply(CustomTheme value, {required bool modified}) async {
    if (value.isBuiltIn && !modified) {
      await _repo.select(value.id);
      return value;
    }
    final now = DateTime.now().toUtc();
    final name = value.name.trim();
    final needsCopyName =
        value.isBuiltIn &&
        themePresets.any(
          (preset) => preset.id == value.id && preset.name == name,
        );
    final saved = value.copyWith(
      id: value.isBuiltIn ? const Uuid().v4() : value.id,
      name: needsCopyName
          ? '${name.substring(0, name.length.clamp(0, 195))} Copy'
          : name,
      createdAt: value.isBuiltIn ? now : value.createdAt,
      updatedAt: now,
    );
    await _repo.save(saved, apply: true);
    return saved;
  }

  Future<void> restoreDefault() => _repo.select('preset:default');
  Future<CustomTheme> duplicate(CustomTheme value) => _repo.duplicate(value);
  Future<void> delete(String id) => _repo.delete(id);
  Future<void> rememberColors(List<int> colors) => _repo.rememberColors(colors);

  Future<CustomTheme> rename(CustomTheme value, String name) async {
    final renamed = value.copyWith(
      name: name.trim(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _repo.save(renamed);
    return renamed;
  }

  Future<CustomTheme> importTheme(String document) async {
    final theme = ThemeCodec.decode(document);
    await _repo.save(theme);
    return theme;
  }
}

final themeLeaveGuardProvider = Provider((ref) => ThemeLeaveGuard());

class ThemeLeaveGuard {
  Future<bool> Function()? check;
  Future<bool> canLeave() async => await check?.call() ?? true;
}
