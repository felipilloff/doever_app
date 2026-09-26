import 'package:doever/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

void main() {
  test(
    'v1 → v2 retains every task/list/step/reminder column and preferences',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);
      final old = v1.DatabaseAtV1(schema.newConnection());
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
      final before = <String, List<Map<String, Object?>>>{};
      for (final table in ['lists', 'tasks', 'steps', 'reminder_jobs']) {
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
      await verifier.migrateAndValidate(database, 2);
      for (final table in before.keys) {
        expect(
          (await database.customSelect('SELECT * FROM $table').get())
              .map((r) => r.data)
              .toList(),
          before[table],
        );
      }
      expect(await database.select(database.notePages).get(), isEmpty);
      expect(await database.select(database.noteBlocks).get(), isEmpty);
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
