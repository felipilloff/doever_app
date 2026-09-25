import 'dart:io';

import 'package:doever/app/app.dart';
import 'package:doever/app/providers.dart';
import 'package:doever/app/router.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_reminders.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('launch → list → task → edit → complete → reopen database', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('doever-smoke-');
    final file = File('${dir.path}/smoke.sqlite');
    var db = AppDatabase(NativeDatabase.createInBackground(file));
    var repo = DriftTaskRepository(db);
    await repo.initialize();
    final prefs = await SharedPreferences.getInstance();
    var router = createRouter();
    Widget app() => ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        preferencesProvider.overrideWithValue(prefs),
        remindersProvider.overrideWithValue(FakeReminders()),
      ],
      child: DoeverApp(router: router),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    if (find.byTooltip('Open navigation').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('New list'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Smoke list');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await tester.enterText(
      find.byKey(const ValueKey('add-task')),
      'Smoke task',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smoke task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Task title'),
      'Updated smoke task',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close details'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Complete task'));
    await tester.pumpAndSettle();
    final rows = await db.select(db.tasks).get();
    final id = rows.single.id;
    expect(rows.single.isCompleted, true);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase.createInBackground(file));
    repo = DriftTaskRepository(db);
    await repo.initialize();
    router = createRouter();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect((await repo.getTask(id))!.title, 'Updated smoke task');
    expect((await repo.getTask(id))!.isCompleted, true);
    expect(
      (await repo.watchLists().first).any((l) => l.name == 'Smoke list'),
      true,
    );
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });
}
