import 'dart:convert';
import 'dart:io';

import 'package:doever/core/errors.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/theme_studio/data/drift_theme_repository.dart';
import 'package:doever/features/theme_studio/data/theme_codec.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

CustomTheme example() => themePresets[1].copyWith(
  id: '12345678-1234-4123-8123-123456789abc',
  name: 'My midnight',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  test(
    'theme document round trip creates fresh identity and preserves all layers',
    () {
      final original = example();
      final decoded = ThemeCodec.decode(ThemeCodec.encode(original));
      expect(decoded.id, isNot(original.id));
      expect(decoded.name, original.name);
      expect(decoded.baseMode, original.baseMode);
      expect(decoded.foundation, original.foundation);
      expect(decoded.surface, original.surface);
      expect(decoded.accent, original.accent);
      expect(decoded.autoBalance, original.autoBalance);
    },
  );

  test(
    'untrusted theme files reject fields, versions, invalid colors and ranges',
    () {
      final mutations = <void Function(Map<String, dynamic>)>[
        (m) => m['format'] = 'other',
        (m) => m['version'] = 2,
        (m) => m['version'] = 1.0,
        (m) => m['resource'] = '/etc/passwd',
        (m) => m.remove('surface'),
        (m) => m['name'] = ' ',
        (m) => m['name'] = 'a' * 201,
        (m) => m['baseMode'] = 'system',
        (m) => m['autoBalance'] = 'true',
        (m) => m['accent']['colors'] = [0x00ffffff],
        (m) => m['accent']['colors'] = [0x100000000],
        (m) => m['accent']['colors'] = ['#ffffff'],
        (m) => m['foundation']['colors'] = <int>[],
        (m) => m['foundation']['colors'] = List.filled(4, 0xff000000),
        (m) => m['foundation']['direction'] = 'unknown',
        (m) => m['surface']['mode'] = 'url',
        (m) => m['surface']['tone'] = -1,
        (m) => m['surface']['intensity'] = 101,
        (m) => m['surface']['gradientStrength'] = '50',
      ];
      for (final mutate in mutations) {
        final data =
            jsonDecode(ThemeCodec.encode(example())) as Map<String, dynamic>;
        mutate(data);
        expect(
          () => ThemeCodec.decode(jsonEncode(data)),
          throwsA(isA<AppFailure>()),
        );
      }
      expect(
        () => ThemeCodec.decode('x' * (ThemeCodec.maxFileBytes + 1)),
        throwsA(isA<AppFailure>()),
      );
    },
  );

  test(
    'CRUD, duplication, bounded recents and active deletion are transactional',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftThemeRepository(db);
      expect((await repository.load()).themes, isEmpty);
      final theme = example();
      await repository.save(theme, apply: true);
      expect((await repository.load()).activeId, theme.id);
      await repository.save(theme.copyWith(name: 'Renamed'));
      expect((await repository.load()).themes.single.name, 'Renamed');
      final copy = await repository.duplicate(theme);
      expect(copy.id, isNot(theme.id));
      expect(copy.foundation, theme.foundation);
      expect((await repository.load()).activeId, theme.id);
      await repository.rememberColors(List.generate(20, (i) => 0xff000000 + i));
      await repository.rememberColors([0xff000010, 0xff000000]);
      final recent = (await repository.load()).recentColors;
      expect(recent, hasLength(12));
      expect(recent.take(2), [0xff000010, 0xff000000]);
      expect(recent.toSet().length, recent.length);
      await repository.delete(theme.id);
      expect((await repository.load()).activeId, 'preset:default');
      expect((await repository.load()).themes.single.id, copy.id);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      await expectLater(
        repository.save(themePresets.first),
        throwsA(isA<AppFailure>()),
      );
      await expectLater(
        repository.delete(themePresets.first.id),
        throwsA(isA<AppFailure>()),
      );
    },
  );

  test(
    'failed active deletion rolls selection and theme back together',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftThemeRepository(db);
      await repository.save(example(), apply: true);
      await db.customStatement(
        "CREATE TRIGGER reject_theme_delete BEFORE DELETE ON custom_themes BEGIN SELECT RAISE(ABORT, 'test failure'); END",
      );
      await expectLater(
        repository.delete(example().id),
        throwsA(isA<AppFailure>()),
      );
      final library = await repository.load();
      expect(library.activeId, example().id);
      expect(library.themes.single.id, example().id);
    },
  );

  test('missing selection and damaged stored themes fall back without losing records', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftThemeRepository(db);
    await repository.save(example(), apply: true);
    await db.customStatement(
      "UPDATE custom_themes SET document = 'invalid' WHERE id = ?",
      [example().id],
    );
    await db.customStatement(
      "UPDATE theme_settings SET recent_colors = 'invalid'",
    );
    final damaged = await repository.load();
    expect(damaged.activeId, 'preset:default');
    expect(damaged.themes, isEmpty);
    expect(damaged.recentColors, isEmpty);
    expect(await db.select(db.customThemes).get(), hasLength(1));
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db.customStatement('DELETE FROM custom_themes');
    expect((await repository.load()).activeId, 'preset:default');
    await db.customStatement(
      "UPDATE theme_settings SET active_custom_theme_id=NULL, active_preset_id='preset:removed'",
    );
    expect((await repository.load()).activeId, 'preset:default');
  });

  test(
    'file-backed active theme survives database close and restart',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'doever-theme-test-',
      );
      final file = File('${directory.path}/themes.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      try {
        await DriftThemeRepository(db).save(example(), apply: true);
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        final loaded = await DriftThemeRepository(db).load();
        expect(loaded.activeId, example().id);
        expect(loaded.themes.single, example());
      } finally {
        await db.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
