import 'dart:io';

import 'package:doever/database/app_database.dart';
import 'package:doever/features/focus/application/focus_player.dart';
import 'package:doever/features/focus/application/focus_session_controller.dart';
import 'package:doever/features/focus/data/drift_focus_repository.dart';
import 'package:doever/features/focus/data/focus_session_repository.dart';
import 'package:doever/features/focus/domain/focus_session.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:doever/features/tasks/domain/task.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_focus_audio.dart';

void main() {
  late AppDatabase db;
  late DriftTaskRepository tasks;
  late FocusSessionRepository repository;
  late FocusSessionController timer;
  late FocusPlayer player;
  late FakeFocusAudio audio;
  late Duration monotonic;
  late DateTime wall;
  late int notifications;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tasks = DriftTaskRepository(db);
    await tasks.initialize();
    repository = FocusSessionRepository(db);
    audio = FakeFocusAudio();
    player = FocusPlayer(DriftFocusRepository(db), audio, FocusPreferences());
    monotonic = Duration.zero;
    wall = DateTime.utc(2026);
    notifications = 0;
    timer = FocusSessionController(
      repository,
      tasks,
      player: player,
      scheduleTicks: false,
      now: () => wall,
      monotonic: () => monotonic,
      onCompleted: (_) async {
        notifications++;
      },
    );
  });
  tearDown(() async {
    await timer.shutdown();
    await player.shutdown();
    await db.close();
  });
  Future<void> advance(Duration delta) async {
    monotonic += delta;
    wall = wall.add(delta);
    await timer.tick();
  }

  test('monotonic timer, legal transitions, pause/resume, audio isolation and early finish', () async {
    final id = await tasks.createTask('Original title');
    await timer.start(
      duration: const Duration(minutes: 25),
      taskId: id,
      soundscape: focusPresets.first,
    );
    expect(timer.session!.id, matches(RegExp(r'^[a-f0-9-]{36}$')));
    expect(audio.playing, true);
    await timer.start(duration: const Duration(minutes: 5));
    expect(timer.session!.linkedTaskId, id);
    await advance(const Duration(milliseconds: 2400));
    expect(
      timer.remaining,
      const Duration(minutes: 25) - const Duration(milliseconds: 2400),
    );
    await timer.pause();
    expect(audio.playing, true);
    await advance(const Duration(hours: 1));
    expect(timer.elapsed, const Duration(milliseconds: 2400));
    await timer.resume();
    player.toggleMute();
    await player.select(focusPresets.last);
    await advance(const Duration(milliseconds: 7600));
    expect(timer.elapsed, const Duration(seconds: 10));
    await tasks.updateTask(id, const TaskPatch(title: 'Renamed'));
    await timer.finish();
    expect(notifications, 1);
    expect((await tasks.getTask(id))!.isCompleted, false);
    await timer.resume();
    await timer.finish();
    expect(notifications, 1);
    expect(timer.session!.completionState, SessionState.completed);
    await timer.completeTask();
    expect((await tasks.getTask(id))!.isCompleted, true);
    await tasks.deleteTask(id);
    final history = await repository.watchHistory().first;
    expect(history.single.taskTitleSnapshot, 'Original title');
    expect(history.single.actualDuration, const Duration(seconds: 10));
    expect(history.single.linkedTaskId, id);
    expect(audio.playing, true);
    expect(await repository.recover(), isNull);
  });
  test(
    'completion caps elapsed duration; cancellation creates no next phase',
    () async {
      await timer.start(duration: const Duration(seconds: 2), label: 'Reading');
      await advance(const Duration(seconds: 3));
      expect(timer.session!.actualDuration, const Duration(seconds: 2));
      expect(timer.session!.title, 'Reading');
      expect(timer.session!.endedAt, wall);
      await timer.start(
        duration: const Duration(minutes: 1),
        mode: TimerMode.pomodoro,
      );
      await advance(const Duration(seconds: 4));
      await timer.finish(cancelled: true);
      expect(timer.nextType, isNull);
      expect(notifications, 1);
      expect((await repository.watchHistory().first).length, 2);
    },
  );
  test(
    'sleep and backwards clock changes pause without counting gaps',
    () async {
      await timer.start(duration: const Duration(minutes: 25));
      await advance(const Duration(seconds: 10));
      await advance(const Duration(hours: 1));
      expect(timer.session!.completionState, SessionState.interrupted);
      expect(timer.elapsed, const Duration(seconds: 10));
      await timer.resume();
      wall = wall.subtract(const Duration(minutes: 5));
      await timer.tick();
      expect(timer.session!.completionState, SessionState.interrupted);
      expect(timer.elapsed, const Duration(seconds: 10));
    },
  );
  test(
    'custom Pomodoro cycles prepare short/long breaks and respect auto-start',
    () async {
      const config = PomodoroConfig(
        focusMinutes: 2,
        shortMinutes: 1,
        longMinutes: 3,
        interval: 2,
      );
      await timer.start(
        duration: config.duration(SessionType.focus),
        mode: TimerMode.pomodoro,
        config: config,
      );
      await timer.finish();
      expect(timer.active, false);
      expect(timer.nextType, SessionType.shortBreak);
      await timer.next();
      expect(timer.session!.plannedDuration, const Duration(minutes: 1));
      await timer.pause();
      await advance(const Duration(seconds: 10));
      await timer.resume();
      expect(timer.elapsed, Duration.zero);
      await timer.finish();
      await timer.next();
      await timer.finish();
      expect(timer.nextType, SessionType.longBreak);
      await timer.next();
      expect(timer.session!.plannedDuration, const Duration(minutes: 3));
      await timer.finish(cancelled: true);
      const auto = PomodoroConfig(
        interval: 1,
        autoLong: true,
        autoShort: true,
        autoFocus: true,
      );
      await timer.start(
        duration: const Duration(seconds: 2),
        mode: TimerMode.pomodoro,
        config: auto,
      );
      await advance(const Duration(seconds: 2));
      expect(timer.session!.sessionType, SessionType.longBreak);
      expect(timer.active, true);
      await timer.finish();
      expect(timer.session!.sessionType, SessionType.focus);
    },
  );
  test('interrupted restore keeps checkpoint, ignores offline time, never starts audio', () async {
    await timer.start(duration: const Duration(minutes: 5));
    await advance(const Duration(seconds: 6));
    await timer.pause();
    await timer.resume();
    // Simulate a second process reading the last committed transition.
    final restored = FocusSessionController(
      repository,
      tasks,
      scheduleTicks: false,
      now: () => wall.add(const Duration(days: 1)),
    );
    await restored.restore();
    expect(restored.session!.completionState, SessionState.interrupted);
    expect(restored.elapsed, const Duration(seconds: 6));
    expect(audio.calls, isEmpty);
    await restored.shutdown();
  });
  test('invalid durations and missing/deleted tasks cannot start', () async {
    await timer.start(duration: Duration.zero);
    expect(timer.error, isNotNull);
    expect(timer.active, false);
    await timer.start(duration: const Duration(minutes: 5), taskId: 'missing');
    expect(timer.error, isNotNull);
    expect(timer.active, false);
    expect(
      () => FocusSession.start(now: wall, duration: const Duration(days: 1)),
      throwsArgumentError,
    );
    expect(
      () => PomodoroConfig.fromJson({
        ...const PomodoroConfig().toJson(),
        'interval': 0,
      }),
      throwsFormatException,
    );
  });
  test('notification failure preserves completion and history', () async {
    final failing = FocusSessionController(
      repository,
      tasks,
      scheduleTicks: false,
      onCompleted: (_) async => throw StateError('notification unavailable'),
    );
    await failing.start(duration: const Duration(minutes: 1));
    await failing.finish();
    expect(failing.session!.completionState, SessionState.completed);
    expect(failing.error, contains('Session saved'));
    expect((await repository.watchHistory().first).length, 1);
    await failing.shutdown();
  });
  test('storage failure preserves prior state; recovery failure blocks duplicate starts', () async {
    final failingRepository = FailingSessionRepository(db);
    final failing = FocusSessionController(
      failingRepository,
      tasks,
      scheduleTicks: false,
    );
    await failing.restore();
    expect(failing.recoveryFailed, true);
    await failing.start(duration: const Duration(minutes: 1));
    expect(failing.active, false);
    failingRepository.fail = false;
    await failing.restore();
    await failing.start(duration: const Duration(minutes: 1));
    failingRepository.fail = true;
    await failing.finish();
    expect(failing.session!.completionState, SessionState.running);
    expect(failing.error, isNotNull);
    failingRepository.fail = false;
    await failing.finish();
    expect(failing.session!.completionState, SessionState.completed);
    await failing.shutdown();
  });
  test('auto short breaks preserve explicit task completion and notification opt-out', () async {
    final id = await tasks.createTask('Keep completion optional');
    await timer.start(
      duration: const Duration(seconds: 1),
      taskId: id,
      mode: TimerMode.pomodoro,
      config: const PomodoroConfig(autoShort: true, notifications: false),
    );
    await advance(const Duration(seconds: 1));
    expect(timer.session!.sessionType, SessionType.shortBreak);
    expect(notifications, 0);
    expect((await tasks.getTask(id))!.isCompleted, false);
    await timer.completeTask();
    expect((await tasks.getTask(id))!.isCompleted, true);
  });
  test(
    'file-backed history survives closing and reopening the database',
    () async {
      final dir = await Directory.systemTemp.createTemp('doever-session-test');
      final file = File('${dir.path}/sessions.sqlite');
      var disk = AppDatabase(NativeDatabase(file));
      try {
        final session = FocusSession.start(
          now: wall,
          duration: const Duration(minutes: 25),
          label: 'Study',
        ).update(SessionState.completed, const Duration(minutes: 12), wall);
        await FocusSessionRepository(disk).save(session);
        await disk.close();
        disk = AppDatabase(NativeDatabase(file));
        final saved = (await FocusSessionRepository(
          disk,
        ).watchHistory().first).single;
        expect(saved.encode(), session.encode());
      } finally {
        await disk.close();
        await dir.delete(recursive: true);
      }
    },
  );
}

class FailingSessionRepository extends FocusSessionRepository {
  FailingSessionRepository(super.db);
  bool fail = true;
  @override
  Future<void> save(FocusSession session) async {
    if (fail) throw StateError('Storage unavailable');
    await super.save(session);
  }

  @override
  Future<FocusSession?> recover() async {
    if (fail) throw StateError('Storage unavailable');
    return super.recover();
  }
}
