import 'dart:io';

import 'package:doever/app/app.dart';
import 'package:doever/app/providers.dart';
import 'package:doever/app/router.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/notes/application/notes_providers.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/notes/presentation/block_editor.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_reminders.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('desktop notes → heading → TODO → task → reopen', (tester) async {
    final dir = await Directory.systemTemp.createTemp('doever-notes-smoke-');
    final file = File('${dir.path}/smoke.sqlite');
    var db = AppDatabase(NativeDatabase.createInBackground(file));
    var tasks = DriftTaskRepository(db);
    await tasks.initialize();
    var notes = DriftNoteRepository(db);
    var router = createRouter();
    SharedPreferences.setMockInitialValues({'language': 'en'});
    final prefs = await SharedPreferences.getInstance();
    Widget app() => ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(tasks),
        noteRepositoryProvider.overrideWithValue(notes),
        preferencesProvider.overrideWithValue(prefs),
        remindersProvider.overrideWithValue(FakeReminders()),
      ],
      child: DoeverApp(router: router),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New page').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('note-title')),
      'Desktop journal',
    );
    Finder content() => find.descendant(
      of: find.byType(BlockEditor),
      matching: find.byType(TextField),
    );
    await tester.enterText(content().first, 'Remember this idea');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.enterText(content().last, '# ');
    await tester.pumpAndSettle();
    await tester.enterText(content().last, 'Next steps');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.enterText(content().last, '[] ');
    await tester.pumpAndSettle();
    await tester.enterText(content().last, 'Ship the desktop notes');
    await tester.tap(find.byTooltip('Block actions').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Doever Task'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tasks'));
    await tester.pumpAndSettle();
    final id = (await notes.watchPages().first).single.id;
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    router.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase.createInBackground(file));
    tasks = DriftTaskRepository(db);
    await tasks.initialize();
    notes = DriftNoteRepository(db);
    router = createRouter();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desktop journal'));
    await tester.pumpAndSettle();
    final document = await notes.load(id);
    expect(document.blocks.map((b) => b.content), [
      'Remember this idea',
      'Next steps',
      'Ship the desktop notes',
    ]);
    expect(
      (await db.select(db.tasks).get()).single.title,
      'Ship the desktop notes',
    );
    expect(find.widgetWithText(TextField, 'Next steps'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    router.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });
}
