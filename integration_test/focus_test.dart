import 'package:doever/features/focus/application/focus_session_controller.dart';
import 'package:doever/features/focus/application/session_providers.dart';
import 'package:doever/features/focus/data/focus_session_repository.dart';
import 'package:doever/features/focus/domain/focus_session.dart';

import 'dart:io';

import 'package:doever/app/app.dart';
import 'package:doever/app/providers.dart';
import 'package:doever/app/router.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/focus/application/focus_player.dart';
import 'package:doever/features/focus/application/focus_providers.dart';
import 'package:doever/features/focus/data/drift_focus_repository.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:doever/features/focus/presentation/focus_controls.dart';
import 'package:doever/features/notes/application/notes_providers.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_focus_audio.dart';
import '../test/support/fake_reminders.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Focus persists a mix across desktop routes and application restart',
    (tester) async {
      final dir = await Directory.systemTemp.createTemp('doever-focus-');
      final file = File('${dir.path}/focus.sqlite');
      SharedPreferences.setMockInitialValues({'language': 'en'});
      final preferences = await SharedPreferences.getInstance();
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var tasks = DriftTaskRepository(db);
      await tasks.initialize();
      var repo = DriftFocusRepository(db);
      var audio = FakeFocusAudio();
      var player = FocusPlayer(repo, audio, await repo.loadPreferences());
      var elapsed = Duration.zero;
      FocusSessionController makeSessions() => FocusSessionController(
        FocusSessionRepository(db),
        tasks,
        player: player,
        scheduleTicks: false,
        monotonic: () => elapsed,
        now: () => DateTime.utc(2026).add(elapsed),
      );
      var sessions = makeSessions();
      var router = createRouter();
      Widget app() => ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(tasks),
          preferencesProvider.overrideWithValue(preferences),
          remindersProvider.overrideWithValue(FakeReminders()),
          noteRepositoryProvider.overrideWithValue(DriftNoteRepository(db)),
          focusPlayerProvider.overrideWithValue(player),
          focusSessionProvider.overrideWithValue(sessions),
        ],
        child: DoeverApp(router: router),
      );
      try {
        await tester.pumpWidget(app());
        router.go('/focus');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Rainy café'));
        await tester.tap(find.text('Rainy café'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FocusPlayButton).last);
        await tester.pumpAndSettle();
        expect(player.playing, true);
        player.update(
          player.mix!.tracks
              .firstWhere((t) => t.sound == FocusSound.lightRain)
              .copyWith(volume: .27),
        );
        await player.add(FocusSound.brown);
        await player.save('Desktop retreat');
        final id = player.mix!.id;
        final taskId = await tasks.createTask('Desktop focus session');
        router.go('/task/$taskId');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start Focus'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();
        expect(sessions.session!.linkedTaskId, taskId);
        elapsed += const Duration(seconds: 8);
        await sessions.tick();
        for (final route in ['/', '/notes', '/settings', '/focus']) {
          router.go(route);
          await tester.pumpAndSettle();
          expect(audio.playing, true);
          expect(find.text('Desktop retreat'), findsWidgets);
        }
        expect(audio.calls.where((c) => c == 'play'), hasLength(2));
        router.go('/focus/session');
        await tester.pumpAndSettle();
        expect(sessions.elapsed, const Duration(seconds: 8));
        await tester.tap(find.text('Pause'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Resume'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Finish Session'));
        await tester.pumpAndSettle();
        expect(sessions.session!.completionState, SessionState.completed);
        await tester.tap(find.text('Complete Task'));
        await tester.pumpAndSettle();
        expect((await tasks.getTask(taskId))!.isCompleted, true);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await sessions.shutdown();
        await player.shutdown();
        router.dispose();
        await db.close();
        db = AppDatabase(NativeDatabase.createInBackground(file));
        tasks = DriftTaskRepository(db);
        await tasks.initialize();
        repo = DriftFocusRepository(db);
        audio = FakeFocusAudio();
        player = FocusPlayer(repo, audio, await repo.loadPreferences());
        sessions = makeSessions();
        await sessions.restore();
        expect(sessions.active, false);
        final history = await sessions.repository.watchHistory().first;
        expect(history.single.taskTitleSnapshot, 'Desktop focus session');
        expect(history.single.actualDuration, const Duration(seconds: 8));
        router = createRouter();
        await tester.pumpWidget(app());
        router.go('/focus');
        await tester.pumpAndSettle();
        expect(player.mix!.id, id);
        expect(player.playing, false);
        expect(audio.calls, isEmpty);
        expect(
          player.mix!.tracks
              .firstWhere((t) => t.sound == FocusSound.lightRain)
              .volume,
          .27,
        );
        expect((await repo.watchSoundscapes().first).single.id, id);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await sessions.shutdown();
        await player.shutdown();
        router.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
}
