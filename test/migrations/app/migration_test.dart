import 'package:doever/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

void main() {
  for (final version in [1, 2, 3, 4]) {
    test(
      'v$version → v5 retains tasks, Notes, themes and preferences',
      () async {
        final verifier = SchemaVerifier(GeneratedHelper());
        final schema = await verifier.schemaAt(version);
        final old = version == 1
            ? v1.DatabaseAtV1(schema.newConnection())
            : version == 2
            ? v2.DatabaseAtV2(schema.newConnection())
            : version == 3
            ? v3.DatabaseAtV3(schema.newConnection())
            : v4.DatabaseAtV4(schema.newConnection());
        await old.customStatement(
          "INSERT INTO lists (id,name,sort_order,created_at,updated_at) VALUES ('inbox','Tasks',1024,1,2),('custom','Work',2048,1,2)",
        );
        await old.customStatement(
          "INSERT INTO tasks (id,list_id,title,notes,is_important,my_day_date,due_date,reminder_at,recurrence_rule,sort_order,created_at,updated_at,is_completed,completed_at,next_occurrence_id) VALUES ('task','custom','Preserve task','Private notes',1,'2026-09-26','2026-09-27',1790467200,'FREQ=DAILY',1024,1,2,1,3,'next')",
        );
        await old.customStatement(
          "INSERT INTO steps (id,task_id,title,is_completed,sort_order,created_at,updated_at,deleted_at) VALUES ('step','task','Step',1,1024,1,2,3)",
        );
        await old.customStatement(
          "INSERT INTO reminder_jobs (task_id,revision,pending) VALUES ('task',4,1)",
        );
        if (version >= 2) {
          await old.customStatement(
            "INSERT INTO note_pages (id,title,sort_order,created_at,updated_at) VALUES ('page','Local page',1024,1,2)",
          );
          await old.customStatement(
            "INSERT INTO note_blocks (id,page_id,type,content,checked,url,image_name,detail,icon,expanded,sort_order,created_at,updated_at,deleted_at) VALUES ('block','page','toggle','Keep this text',1,'https://example.com','kept.png','Nested text','info',0,1024,1,2,3)",
          );
        }
        if (version >= 3) {
          await old.customStatement(
            "INSERT INTO custom_themes (id,document,created_at,updated_at) VALUES ('theme','preserve exact serialized theme',1,2)",
          );
          await old.customStatement(
            "INSERT INTO theme_settings (id,active_custom_theme_id,active_preset_id,recent_colors) VALUES (1,'theme',NULL,'[4278190080]')",
          );
        }
        if (version == 4) {
          await old.customStatement(
            "INSERT INTO focus_soundscapes (id,document) VALUES ('mix','preserve mix exactly')",
          );
          await old.customStatement(
            "INSERT INTO focus_settings (id,mix,master_volume,muted) VALUES (1,'preserve settings',0.27,1)",
          );
        }
        final before = <String, List<Map<String, Object?>>>{};
        for (final table in [
          if (version == 4) ...['focus_soundscapes', 'focus_settings'],
          'lists',
          'tasks',
          'steps',
          'reminder_jobs',
          if (version >= 2) ...['note_pages', 'note_blocks'],
          if (version >= 3) ...['custom_themes', 'theme_settings'],
        ]) {
          before[table] = (await old.customSelect('SELECT * FROM $table').get())
              .map((r) => r.data)
              .toList();
        }
        SharedPreferences.setMockInitialValues({
          'theme': 'dark',
          'language': 'es',
          'showCompleted': false,
          'backgroundImage': 'kept.png',
        });
        final prefs = await SharedPreferences.getInstance();
        final database = AppDatabase(schema.newConnection());
        await verifier.migrateAndValidate(database, 5);
        for (final table in before.keys) {
          expect(
            (await database.customSelect('SELECT * FROM $table').get())
                .map((r) => r.data)
                .toList(),
            before[table],
          );
        }
        if (version == 1) {
          expect(await database.select(database.notePages).get(), isEmpty);
          expect(await database.select(database.noteBlocks).get(), isEmpty);
        }
        if (version < 3) {
          expect(await database.select(database.customThemes).get(), isEmpty);
          final themeSettings = await database
              .select(database.themeSettings)
              .getSingle();
          expect(themeSettings.id, 1);
          expect(themeSettings.activePresetId, 'preset:default');
          expect(themeSettings.activeCustomThemeId, isNull);
          expect(themeSettings.recentColors, '[]');
        }
        if (version < 4) {
          expect(
            await database.select(database.focusSoundscapes).get(),
            isEmpty,
          );
          expect(await database.select(database.focusSettings).get(), isEmpty);
        }
        expect(await database.select(database.focusSessions).get(), isEmpty);
        expect(
          await database.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        expect(prefs.getString('theme'), 'dark');
        expect(prefs.getString('language'), 'es');
        expect(prefs.getBool('showCompleted'), false);
        expect(prefs.getString('backgroundImage'), 'kept.png');
        await old.close();
        await database.close();
      },
    );
  }
}
