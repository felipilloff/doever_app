import 'dart:convert';

import 'package:uuid/uuid.dart';

enum SessionType { focus, shortBreak, longBreak }

enum SessionState { running, paused, interrupted, completed, cancelled }

enum TimerMode { simple, pomodoro }

class PomodoroConfig {
  const PomodoroConfig({
    this.focusMinutes = 25,
    this.shortMinutes = 5,
    this.longMinutes = 15,
    this.interval = 4,
    this.autoShort = false,
    this.autoLong = false,
    this.autoFocus = false,
    this.notifications = true,
  });
  final int focusMinutes, shortMinutes, longMinutes, interval;
  final bool autoShort, autoLong, autoFocus, notifications;
  bool get valid =>
      [
        focusMinutes,
        shortMinutes,
        longMinutes,
      ].every((v) => v > 0 && v <= 180) &&
      interval > 0 &&
      interval <= 12;
  Duration duration(SessionType type) => Duration(
    minutes: switch (type) {
      SessionType.focus => focusMinutes,
      SessionType.shortBreak => shortMinutes,
      SessionType.longBreak => longMinutes,
    },
  );
  SessionType next(SessionType type, int completed) => type != SessionType.focus
      ? SessionType.focus
      : completed % interval == 0
      ? SessionType.longBreak
      : SessionType.shortBreak;
  bool autoStart(SessionType type) => switch (type) {
    SessionType.focus => autoFocus,
    SessionType.shortBreak => autoShort,
    SessionType.longBreak => autoLong,
  };
  Map<String, Object> toJson() => {
    'focus': focusMinutes,
    'short': shortMinutes,
    'long': longMinutes,
    'interval': interval,
    'autoShort': autoShort,
    'autoLong': autoLong,
    'autoFocus': autoFocus,
    'notifications': notifications,
  };
  factory PomodoroConfig.fromJson(Map<String, dynamic> j) {
    final value = PomodoroConfig(
      focusMinutes: j['focus'] as int,
      shortMinutes: j['short'] as int,
      longMinutes: j['long'] as int,
      interval: j['interval'] as int,
      autoShort: j['autoShort'] as bool,
      autoLong: j['autoLong'] as bool,
      autoFocus: j['autoFocus'] as bool,
      notifications: j['notifications'] as bool,
    );
    if (!value.valid) throw const FormatException('Invalid Pomodoro settings');
    return value;
  }
}

class FocusSession {
  FocusSession({
    required this.id,
    required this.startedAt,
    required this.updatedAt,
    required this.plannedDuration,
    this.actualDuration = Duration.zero,
    this.linkedTaskId,
    this.taskTitleSnapshot,
    this.sessionLabel,
    this.soundscapeId,
    this.soundscapeName,
    this.endedAt,
    this.sessionType = SessionType.focus,
    this.completionState = SessionState.running,
    this.mode = TimerMode.simple,
    this.config = const PomodoroConfig(),
    this.completedBlocks = 0,
  });
  factory FocusSession.start({
    required DateTime now,
    required Duration duration,
    String? taskId,
    String? title,
    String? label,
    String? soundscapeId,
    String? soundscapeName,
    TimerMode mode = TimerMode.simple,
    PomodoroConfig config = const PomodoroConfig(),
    SessionType type = SessionType.focus,
    int completedBlocks = 0,
  }) {
    if (duration <= Duration.zero ||
        duration > const Duration(hours: 3) ||
        !config.valid) {
      throw ArgumentError('Invalid session duration/configuration');
    }
    return FocusSession(
      id: const Uuid().v4(),
      startedAt: now,
      updatedAt: now,
      plannedDuration: duration,
      linkedTaskId: taskId,
      taskTitleSnapshot: title,
      sessionLabel: label,
      soundscapeId: soundscapeId,
      soundscapeName: soundscapeName,
      mode: mode,
      config: config,
      sessionType: type,
      completedBlocks: completedBlocks,
    );
  }
  final String id;
  final String? linkedTaskId,
      taskTitleSnapshot,
      sessionLabel,
      soundscapeId,
      soundscapeName;
  final DateTime startedAt, updatedAt;
  DateTime get createdAt => startedAt;
  final DateTime? endedAt;
  final Duration plannedDuration, actualDuration;
  final SessionType sessionType;
  final SessionState completionState;
  final TimerMode mode;
  final PomodoroConfig config;
  final int completedBlocks;
  bool get terminal =>
      completionState == SessionState.completed ||
      completionState == SessionState.cancelled;
  String get title => taskTitleSnapshot ?? sessionLabel ?? 'Focus without task';
  FocusSession update(SessionState state, Duration elapsed, DateTime now) =>
      FocusSession(
        id: id,
        startedAt: startedAt,
        updatedAt: now,
        plannedDuration: plannedDuration,
        actualDuration: elapsed,
        linkedTaskId: linkedTaskId,
        taskTitleSnapshot: taskTitleSnapshot,
        sessionLabel: sessionLabel,
        soundscapeId: soundscapeId,
        soundscapeName: soundscapeName,
        endedAt:
            state == SessionState.completed || state == SessionState.cancelled
            ? now
            : null,
        sessionType: sessionType,
        completionState: state,
        mode: mode,
        config: config,
        completedBlocks: completedBlocks,
      );
  String encode() => jsonEncode({
    'id': id,
    'started': startedAt.toIso8601String(),
    'updated': updatedAt.toIso8601String(),
    'ended': endedAt?.toIso8601String(),
    'planned': plannedDuration.inMilliseconds,
    'actual': actualDuration.inMilliseconds,
    'task': linkedTaskId,
    'title': taskTitleSnapshot,
    'label': sessionLabel,
    'soundscape': soundscapeId,
    'soundscapeName': soundscapeName,
    'type': sessionType.name,
    'state': completionState.name,
    'mode': mode.name,
    'config': config.toJson(),
    'blocks': completedBlocks,
  });
  factory FocusSession.decode(String document) {
    final j = jsonDecode(document) as Map<String, dynamic>;
    return FocusSession(
      id: (j['id'] as String),
      startedAt: DateTime.parse((j['started'] as String)),
      updatedAt: DateTime.parse((j['updated'] as String)),
      endedAt: j['ended'] == null ? null : DateTime.parse(j['ended'] as String),
      plannedDuration: Duration(milliseconds: j['planned'] as int),
      actualDuration: Duration(milliseconds: j['actual'] as int),
      linkedTaskId: j['task'] as String?,
      taskTitleSnapshot: j['title'] as String?,
      sessionLabel: j['label'] as String?,
      soundscapeId: j['soundscape'] as String?,
      soundscapeName: j['soundscapeName'] as String?,
      sessionType: SessionType.values.byName((j['type'] as String)),
      completionState: SessionState.values.byName((j['state'] as String)),
      mode: TimerMode.values.byName((j['mode'] as String)),
      config: PomodoroConfig.fromJson(j['config'] as Map<String, dynamic>),
      completedBlocks: j['blocks'] as int,
    );
  }
}
