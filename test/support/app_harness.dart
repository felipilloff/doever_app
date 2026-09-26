import 'package:doever/app/app.dart';
import 'package:doever/app/router.dart';
import 'package:doever/app/providers.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_reminders.dart';

import 'package:doever/features/notes/application/notes_providers.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';

import 'package:doever/features/tasks/domain/calendar_date.dart';

class AppHarness {
  final database = AppDatabase(NativeDatabase.memory());
  late final repository = DriftTaskRepository(database);
  final router = createRouter();
  late SharedPreferences preferences;
  Future<void> initialize({String theme = 'light'}) async {
    SharedPreferences.setMockInitialValues({'theme': theme});
    preferences = await SharedPreferences.getInstance();
    await repository.initialize();
    final font = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lato-Semibold.ttf'));
    await font.load();
    await (FontLoader(
      'DoeverMono',
    )..addFont(rootBundle.load('assets/fonts/DejaVuSansMono.ttf'))).load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  }

  Widget app({Widget Function(Widget)? wrap, CalendarDate? today}) {
    final child = ProviderScope(
      overrides: [
        if (today != null) todayProvider.overrideWith(() => FixedToday(today)),
        repositoryProvider.overrideWithValue(repository),
        noteRepositoryProvider.overrideWithValue(DriftNoteRepository(database)),
        remindersProvider.overrideWithValue(FakeReminders()),
        preferencesProvider.overrideWithValue(preferences),
      ],
      child: DoeverApp(router: router),
    );
    return wrap?.call(child) ?? child;
  }

  Future<void> dispose() async {
    router.dispose();
    await database.close();
  }
}

class FixedToday extends Today {
  FixedToday(this.date);
  final CalendarDate date;
  @override
  CalendarDate build() => date;
}
