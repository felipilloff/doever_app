import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../core/logging.dart';
import '../../../database/app_database.dart' as db;
import '../domain/custom_theme.dart';
import '../domain/theme_presets.dart';
import '../domain/theme_repository.dart';
import 'theme_codec.dart';

final class DriftThemeRepository implements ThemeRepository {
  DriftThemeRepository(
    this.database, {
    DateTime Function()? clock,
    this.uuid = const Uuid(),
  }) : clock = clock ?? DateTime.now;

  static const maxRecentColors = 12;
  static const _settingsId = 1;
  static const _defaultPresetId = 'preset:default';
  static final _customId = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  final db.AppDatabase database;
  final DateTime Function() clock;
  final Uuid uuid;

  DateTime get _now => clock().toUtc();

  Future<T> _write<T>(Future<T> Function() action) async {
    try {
      return await database.transaction(action);
    } on AppFailure {
      rethrow;
    } catch (error, stack) {
      logFailure('themes.persistence', error, stack);
      throw const AppFailure(FailureKind.persistence);
    }
  }

  Future<T> _read<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppFailure {
      rethrow;
    } catch (error, stack) {
      logFailure('themes.read', error, stack);
      throw const AppFailure(FailureKind.persistence);
    }
  }

  JoinedSelectStatement<HasResultSet, dynamic> _libraryQuery() {
    final query = database.select(database.themeSettings).join([
      leftOuterJoin(database.customThemes, const Constant(true)),
    ])..where(database.themeSettings.id.equals(_settingsId));
    return query;
  }

  @override
  Stream<ThemeLibrary> watchLibrary() => _libraryQuery()
      .watch()
      .map(_library)
      .handleError((Object error, StackTrace stack) {
        if (error is AppFailure) throw error;
        logFailure('themes.watch', error, stack);
        throw const AppFailure(FailureKind.persistence);
      });

  @override
  Future<ThemeLibrary> load() =>
      _read(() async => _library(await _libraryQuery().get()));

  ThemeLibrary _library(List<TypedResult> rows) {
    if (rows.isEmpty) throw const AppFailure(FailureKind.persistence);
    final settings = rows.first.readTable(database.themeSettings);
    final custom = <CustomTheme>[];
    for (final result in rows) {
      final row = result.readTableOrNull(database.customThemes);
      if (row != null) {
        try {
          custom.add(_theme(row));
        } on AppFailure {
          // Keep the stored record intact, but never let one damaged theme
          // prevent the user from opening their tasks and notes.
        }
      }
    }
    custom.sort((a, b) {
      final modified = b.updatedAt.compareTo(a.updatedAt);
      return modified == 0 ? a.id.compareTo(b.id) : modified;
    });
    var activeId = settings.activeCustomThemeId ?? settings.activePresetId;
    if (activeId == null ||
        (settings.activeCustomThemeId == null && !isThemePresetId(activeId)) ||
        (settings.activeCustomThemeId != null &&
            !custom.any((theme) => theme.id == activeId))) {
      activeId = _defaultPresetId;
    }
    return ThemeLibrary(
      themes: custom,
      activeId: activeId,
      recentColors: _recentColors(settings.recentColors),
    );
  }

  CustomTheme _theme(db.CustomThemeRow row) {
    try {
      return ThemeCodec.decode(
        row.document,
        clock: () => row.createdAt,
        createId: () => row.id,
      ).copyWith(
        createdAt: row.createdAt.toUtc(),
        updatedAt: row.updatedAt.toUtc(),
      );
    } on Object catch (error, stack) {
      logFailure('themes.decode_stored', error, stack);
      throw const AppFailure(FailureKind.persistence);
    }
  }

  List<int> _recentColors(String source) {
    try {
      final value = jsonDecode(source);
      if (value is! List || value.length > maxRecentColors) {
        throw const FormatException('Invalid recent colors');
      }
      final colors = value.cast<int>();
      if (colors.toSet().length != colors.length ||
          colors.any((color) => !_opaque(color))) {
        throw const FormatException('Invalid recent colors');
      }
      return colors;
    } on Object catch (error, stack) {
      logFailure('themes.decode_recent', error, stack);
      return const [];
    }
  }

  @override
  Future<void> save(CustomTheme theme, {bool apply = false}) =>
      _write(() async {
        _validCustomId(theme.id);
        final document = ThemeCodec.encode(theme);
        await database
            .into(database.customThemes)
            .insertOnConflictUpdate(
              db.CustomThemesCompanion.insert(
                id: theme.id,
                document: document,
                createdAt: theme.createdAt.toUtc(),
                updatedAt: theme.updatedAt.toUtc(),
              ),
            );
        if (apply) await _selectCustom(theme.id);
      });

  @override
  Future<void> select(String id) => _write(() async {
    if (isThemePresetId(id)) {
      await _setSelection(presetId: id);
      return;
    }
    _validCustomId(id);
    if (await _customRow(id) == null) {
      throw const AppFailure(FailureKind.validation);
    }
    await _selectCustom(id);
  });

  Future<void> _selectCustom(String id) => _setSelection(customId: id);

  Future<void> _setSelection({String? customId, String? presetId}) async {
    if ((customId == null) == (presetId == null)) {
      throw const AppFailure(FailureKind.validation);
    }
    final changed =
        await (database.update(
          database.themeSettings,
        )..where((row) => row.id.equals(_settingsId))).write(
          db.ThemeSettingsCompanion(
            activeCustomThemeId: Value(customId),
            activePresetId: Value(presetId),
          ),
        );
    if (changed != 1) throw const AppFailure(FailureKind.persistence);
  }

  @override
  Future<CustomTheme> duplicate(CustomTheme theme, {String? name}) async {
    final suffix = ' copy';
    final sourceName = theme.name.trim();
    if (sourceName.isEmpty) throw const AppFailure(FailureKind.validation);
    final copyName =
        name ??
        '${sourceName.substring(0, sourceName.length.clamp(0, 200 - suffix.length))}$suffix';
    final time = _now;
    final copy = theme.copyWith(
      id: uuid.v4(),
      name: copyName,
      createdAt: time,
      updatedAt: time,
    );
    await save(copy);
    return copy;
  }

  @override
  Future<void> delete(String id) => _write(() async {
    _validCustomId(id);
    if (await _customRow(id) == null) {
      throw const AppFailure(FailureKind.validation);
    }
    final settings = await (database.select(
      database.themeSettings,
    )..where((row) => row.id.equals(_settingsId))).getSingle();
    if (settings.activeCustomThemeId == id) {
      await _setSelection(presetId: _defaultPresetId);
    }
    final deleted = await (database.delete(
      database.customThemes,
    )..where((row) => row.id.equals(id))).go();
    if (deleted != 1) throw const AppFailure(FailureKind.persistence);
  });

  @override
  Future<void> rememberColors(List<int> colors) => _write(() async {
    if (colors.any((color) => !_opaque(color))) {
      throw const AppFailure(FailureKind.validation);
    }
    final settings = await (database.select(
      database.themeSettings,
    )..where((row) => row.id.equals(_settingsId))).getSingle();
    final recent = <int>{
      ...colors,
      ..._recentColors(settings.recentColors),
    }.take(maxRecentColors).toList();
    final changed =
        await (database.update(
          database.themeSettings,
        )..where((row) => row.id.equals(_settingsId))).write(
          db.ThemeSettingsCompanion(recentColors: Value(jsonEncode(recent))),
        );
    if (changed != 1) throw const AppFailure(FailureKind.persistence);
  });

  Future<db.CustomThemeRow?> _customRow(String id) => (database.select(
    database.customThemes,
  )..where((row) => row.id.equals(id))).getSingleOrNull();

  void _validCustomId(String id) {
    if (!_customId.hasMatch(id)) {
      throw const AppFailure(FailureKind.validation);
    }
  }

  static bool _opaque(int color) => color >= 0xff000000 && color <= 0xffffffff;
}
