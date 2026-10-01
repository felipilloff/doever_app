import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/logging.dart';
import '../../tasks/domain/task_repository.dart';
import '../data/focus_session_repository.dart';
import '../domain/focus_session.dart';
import '../domain/soundscape.dart';
import 'focus_player.dart';

/// App-owned timer. Monotonic measurements drive time; wall time only detects
/// suspension and provides history timestamps. Audio has an independent life.
class FocusSessionController extends ChangeNotifier {
  FocusSessionController(
    this.repository,
    this.tasks, {
    this.player,
    DateTime Function()? now,
    Duration Function()? monotonic,
    this.onCompleted,
    bool scheduleTicks = true,
  }) : now = now ?? DateTime.now {
    final stopwatch = Stopwatch()..start();
    _monotonic = monotonic ?? (() => stopwatch.elapsed);
    if (scheduleTicks) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    }
  }
  final FocusSessionRepository repository;
  final TaskRepository tasks;
  final FocusPlayer? player;
  final DateTime Function() now;
  final Future<void> Function(FocusSession)? onCompleted;
  late final Duration Function() _monotonic;
  Timer? _ticker;
  FocusSession? session;
  FocusSession? completedFocus;
  Duration elapsed = Duration.zero;
  Duration _lastMono = Duration.zero;
  DateTime? _lastWall;
  bool busy = false, _closed = false;
  bool recoveryFailed = false;
  String? error;
  Future<void> _pending = Future.value();
  bool get active => session != null && !session!.terminal;
  Duration get remaining {
    final value = (session?.plannedDuration ?? Duration.zero) - elapsed;
    return value.isNegative ? Duration.zero : value;
  }

  void _anchor() {
    _lastMono = _monotonic();
    _lastWall = now();
  }

  Future<void> _run(Future<void> Function() action) {
    if (busy || _closed) return _pending;
    busy = true;
    error = null;
    notifyListeners();
    return _pending = (() async {
      try {
        await action();
      } catch (e, stack) {
        error = 'Could not save the session. Please retry.';
        logFailure('focus.session', e, stack);
      } finally {
        busy = false;
        if (!_closed) notifyListeners();
      }
    })();
  }

  Future<void> restore() => _run(() async {
    if (active) return;
    recoveryFailed = true;
    final saved = await repository.recover();
    if (saved == null) {
      recoveryFailed = false;
      return;
    }
    final recovered = saved.update(
      SessionState.interrupted,
      saved.actualDuration,
      now(),
    );
    await repository.save(recovered);
    session = recovered;
    elapsed = recovered.actualDuration;
    recoveryFailed = false;
  });
  Future<void> start({
    required Duration duration,
    String? taskId,
    String? label,
    Soundscape? soundscape,
    TimerMode mode = TimerMode.simple,
    PomodoroConfig config = const PomodoroConfig(),
  }) => _run(() async {
    if (active) return;
    if (recoveryFailed) {
      error = 'Recover the previous session before starting another.';
      return;
    }
    final task = taskId == null ? null : await tasks.getTask(taskId);
    if (taskId != null &&
        (task == null || task.deletedAt != null || task.isCompleted)) {
      error = 'This task is no longer available. Choose another task.';
      return;
    }
    final value = FocusSession.start(
      now: now(),
      duration: duration,
      taskId: task?.id,
      title: task?.title,
      label: label?.trim().isEmpty == true ? null : label?.trim(),
      soundscapeId: soundscape?.id,
      soundscapeName: soundscape?.name,
      mode: mode,
      config: config,
    );
    await repository.save(value);
    session = value;
    completedFocus = null;
    elapsed = Duration.zero;
    _anchor();
    if (soundscape != null && player != null) {
      await player!.select(soundscape);
      if (!player!.playing) await player!.togglePlayback();
    }
  });
  // A missed heartbeat over 15 seconds is conservatively treated as suspension.
  // Keep the last measured time; never count sleep or offline time as work.
  bool _measure() {
    final wall = now();
    final mono = _monotonic();
    final gap = wall.difference(_lastWall ?? wall);
    final delta = mono - _lastMono;
    _lastWall = wall;
    _lastMono = mono;
    if (gap > const Duration(seconds: 15) ||
        gap.isNegative ||
        delta > const Duration(seconds: 15)) {
      return false;
    }
    elapsed += delta.isNegative ? Duration.zero : delta;
    if (elapsed > session!.plannedDuration) elapsed = session!.plannedDuration;
    return true;
  }

  Future<void> tick() async {
    if (_closed || busy || session?.completionState != SessionState.running) {
      return;
    }
    if (!_measure()) {
      await _run(() => _saveState(SessionState.interrupted));
    } else if (remaining == Duration.zero) {
      await finish();
    } else {
      notifyListeners();
    }
  }

  Future<void> _saveState(SessionState state) async {
    final value = session!.update(state, elapsed, now());
    await repository.save(value);
    session = value;
  }

  Future<void> pause() => _run(() async {
    if (session?.completionState != SessionState.running) return;
    final continuous = _measure();
    await _saveState(
      continuous ? SessionState.paused : SessionState.interrupted,
    );
  });
  Future<void> resume() => _run(() async {
    if (!active || session!.completionState == SessionState.running) return;
    await _saveState(SessionState.running);
    _anchor();
  });
  Future<void> finish({bool cancelled = false}) => _run(() async {
    if (!active) return;
    if (session!.completionState == SessionState.running) _measure();
    await _saveState(
      cancelled ? SessionState.cancelled : SessionState.completed,
    );
    final finished = session!;
    if (!cancelled) {
      if (finished.sessionType == SessionType.focus) completedFocus = finished;
      if (finished.config.notifications && onCompleted != null) {
        try {
          await onCompleted!(finished);
        } catch (e, stack) {
          error =
              'Session saved; the completion notification could not be shown.';
          logFailure('focus.notification', e, stack);
        }
      }
      if (finished.mode == TimerMode.pomodoro &&
          finished.config.autoStart(nextType!)) {
        await _next();
      }
    }
  });
  int get nextBlocks =>
      session!.completedBlocks +
      (session!.sessionType == SessionType.focus ? 1 : 0);
  SessionType? get nextType =>
      session?.completionState == SessionState.completed &&
          session?.mode == TimerMode.pomodoro
      ? session!.config.next(session!.sessionType, nextBlocks)
      : null;
  Future<void> next() => _run(_next);
  Future<void> _next() async {
    final type = nextType;
    if (type == null) return;
    final old = session!;
    final value = FocusSession.start(
      now: now(),
      duration: old.config.duration(type),
      taskId: old.linkedTaskId,
      title: old.taskTitleSnapshot,
      label: old.sessionLabel,
      soundscapeId: old.soundscapeId,
      soundscapeName: old.soundscapeName,
      mode: old.mode,
      config: old.config,
      type: type,
      completedBlocks: nextBlocks,
    );
    await repository.save(value);
    session = value;
    elapsed = Duration.zero;
    _anchor();
  }

  Future<void> completeTask() => _run(() async {
    final current = completedFocus;
    if (current?.completionState != SessionState.completed ||
        current?.sessionType != SessionType.focus ||
        current?.linkedTaskId == null) {
      return;
    }
    final task = await tasks.getTask(current!.linkedTaskId!);
    if (task != null && task.deletedAt == null && !task.isCompleted) {
      await tasks.completeTask(task.id, true);
    }
  });
  Future<void>? _shutdown;
  Future<void> shutdown() => _shutdown ??= _close();
  Future<void> _close() async {
    _ticker?.cancel();
    await _pending;
    if (session?.completionState == SessionState.running) await pause();
    _closed = true;
    super.dispose();
  }
}
