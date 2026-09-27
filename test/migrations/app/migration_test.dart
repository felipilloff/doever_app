import 'package:doever/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  for (final version in [1, 2]) {
    test(
      'v$version → v3 retains task/list/step/reminder/Notes data and preferences',
      () async {
        final verifier = SchemaVerifier(GeneratedHelper());
        final schema = await verifier.schemaAt(version);
        final old = version == 1
            ? v1.DatabaseAtV1(schema.newConnection())
            : v2.DatabaseAtV2(schema.newConnection());
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
        if (version == 2) {
          await old.customStatement(
            "INSERT INTO note_pages (id,title,sort_order,created_at,updated_at) VALUES ('page','Local page',1024,1,2)",
          );
          await old.customStatement(
            "INSERT INTO note_blocks (id,page_id,type,content,checked,url,image_name,detail,icon,expanded,sort_order,created_at,updated_at,deleted_at) VALUES ('block','page','toggle','Keep this text',1,'https://example.com','kept.png','Nested text','info',0,1024,1,2,3)",
          );
        }
        final before = <String, List<Map<String, Object?>>>{};
        for (final table in [
          'lists',
          'tasks',
          'steps',
          'reminder_jobs',
          if (version == 2) ...['note_pages', 'note_blocks'],
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
        await verifier.migrateAndValidate(database, 3);
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
        expect(await database.select(database.customThemes).get(), isEmpty);
        final themeSettings = await database
            .select(database.themeSettings)
            .getSingle();
        expect(themeSettings.id, 1);
        expect(themeSettings.activePresetId, 'preset:default');
        expect(themeSettings.activeCustomThemeId, isNull);
        expect(themeSettings.recentColors, '[]');
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
