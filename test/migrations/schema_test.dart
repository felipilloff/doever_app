import 'package:doever/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app/generated/schema.dart';

void main() {
  test('fresh schema matches the committed v2 baseline', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final db = AppDatabase(NativeDatabase.memory());
    try {
      await verifier.migrateAndValidate(db, 2);
    } finally {
      await db.close();
    }
  });
  test('opening a v1 database retains data and validates its schema', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    try {
      await db.customStatement(
        "INSERT INTO lists (id,name,sort_order,created_at,updated_at) VALUES ('existing','Preserved',0,0,0)",
      );
      await verifier.migrateAndValidate(db, 2);
      expect((await db.select(db.lists).get()).single.name, 'Preserved');
    } finally {
      await db.close();
    }
  });
}
