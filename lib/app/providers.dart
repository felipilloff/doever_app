import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/notifications/reminder_service.dart';
import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/domain/task.dart';
import '../features/tasks/domain/calendar_date.dart';
import '../features/tasks/application/task_actions.dart';

final repositoryProvider = Provider<TaskRepository>(
  (ref) => throw StateError('Repository not bootstrapped'),
);
final remindersProvider = Provider<ReminderService>(
  (ref) => throw StateError('Reminders not bootstrapped'),
);
final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('Preferences not bootstrapped'),
);
final actionsProvider = Provider(
  (ref) =>
      TaskActions(ref.watch(repositoryProvider), ref.watch(remindersProvider)),
);
final tasksProvider = StreamProvider.autoDispose.family<List<Task>, TaskQuery>(
  (ref, query) => ref.watch(repositoryProvider).watchTasks(query),
);
final taskProvider = StreamProvider.autoDispose.family<Task?, String>(
  (ref, id) => ref.watch(repositoryProvider).watchTask(id),
);
final stepsProvider = StreamProvider.autoDispose.family<List<TaskStep>, String>(
  (ref, id) => ref.watch(repositoryProvider).watchSteps(id),
);
final listsProvider = StreamProvider(
  (ref) => ref.watch(repositoryProvider).watchLists(),
);
final todayProvider = NotifierProvider<Today, CalendarDate>(Today.new);

class Today extends Notifier<CalendarDate> {
  @override
  CalendarDate build() {
    final timer = Timer.periodic(const Duration(seconds: 15), (_) => refresh());
    ref.onDispose(timer.cancel);
    return CalendarDate.fromLocal(DateTime.now());
  }

  void refresh() {
    state = CalendarDate.fromLocal(DateTime.now());
  }
}

final themeProvider = NotifierProvider<ThemePreference, ThemeMode>(
  ThemePreference.new,
);

class ThemePreference extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.values.firstWhere(
    (m) => m.name == ref.read(preferencesProvider).getString('theme'),
    orElse: () => ThemeMode.system,
  );
  Future<void> set(ThemeMode value) async {
    await ref.read(preferencesProvider).setString('theme', value.name);
    state = value;
  }
}

final completedPreferenceProvider = NotifierProvider<CompletedPreference, bool>(
  CompletedPreference.new,
);

class CompletedPreference extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(preferencesProvider).getBool('showCompleted') ?? true;
  Future<void> set(bool value) async {
    await ref.read(preferencesProvider).setBool('showCompleted', value);
    state = value;
  }
}
