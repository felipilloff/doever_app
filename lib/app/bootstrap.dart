import '../features/focus/application/focus_session_controller.dart';
import '../features/focus/application/session_providers.dart';
import '../features/focus/data/focus_session_repository.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logging.dart';
import '../core/notifications/local_reminders.dart';
import '../core/notifications/reminder_worker.dart';
import '../database/app_database.dart';
import '../features/tasks/data/drift_task_repository.dart';
import '../features/notes/data/drift_note_repository.dart';
import '../features/notes/application/notes_providers.dart';
import '../features/theme_studio/application/theme_providers.dart';
import '../features/theme_studio/data/drift_theme_repository.dart';
import '../l10n/app_localizations.dart';
import 'app.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/doever_theme.dart';
import '../features/focus/application/focus_player.dart';
import '../features/focus/application/focus_providers.dart';
import '../features/focus/data/drift_focus_repository.dart';
import '../features/focus/data/soloud_audio_engine.dart';
import '../features/focus/domain/soundscape.dart';

class DoeverBootstrap extends StatefulWidget {
  const DoeverBootstrap({super.key});
  @override
  State<DoeverBootstrap> createState() => _DoeverBootstrapState();
}

class _DoeverBootstrapState extends State<DoeverBootstrap> {
  final _router = createRouter();
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  AppDatabase? _database;
  ReminderWorker? _worker;
  FocusPlayer? _focus;
  FocusSessionController? _sessions;
  late Future<Widget> _app = _initialize();
  Future<Widget> _initialize() async {
    final database = _database = AppDatabase();
    try {
      final repository = DriftTaskRepository(database);
      await repository.initialize();
      final preferences = await SharedPreferences.getInstance();
      final themes = DriftThemeRepository(database);
      final themeLibrary = await themes.load();
      if (supportsFocus) {
        final focusRepository = DriftFocusRepository(database);
        _focus = FocusPlayer(
          focusRepository,
          SoloudAudioEngine(),
          FocusPreferences(),
        );
        // A damaged Focus preference must not prevent access to Tasks/Notes.
        await _focus!.reloadPreferences();
      }
      final reminders = LocalReminders(
        onOpen: (id) => _router.go('/task/${Uri.encodeComponent(id)}'),
      );
      if (supportsFocus) {
        _sessions = FocusSessionController(
          FocusSessionRepository(database),
          repository,
          player: _focus,
          onCompleted: (session) => reminders.showFocusCompletion(
            title: 'Focus session complete',
            body: '${session.title} · ${session.actualDuration.inMinutes} min',
          ),
        );
        await _sessions!.restore();
      }
      var notified = false;
      _worker = ReminderWorker(
        database,
        reminders,
        onFailure: () {
          if (!notified && _messenger.currentContext != null) {
            notified = true;
            _messenger.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(_messenger.currentContext!)
                      .reminderPending,
                ),
              ),
            );
          }
        },
      )..start();
      return ProviderScope(
        overrides: [
          focusPlayerProvider.overrideWithValue(_focus),
          focusSessionProvider.overrideWithValue(_sessions),
          repositoryProvider.overrideWithValue(repository),
          noteRepositoryProvider.overrideWithValue(
            DriftNoteRepository(database),
          ),
          preferencesProvider.overrideWithValue(preferences),
          themeRepositoryProvider.overrideWithValue(themes),
          initialThemeLibraryProvider.overrideWithValue(themeLibrary),
          remindersProvider.overrideWithValue(reminders),
        ],
        child: DoeverApp(router: _router, messengerKey: _messenger),
      );
    } catch (error, stack) {
      logFailure('bootstrap.database_or_preferences', error, stack);
      await _sessions?.shutdown();
      await _focus?.shutdown();
      _focus = null;
      await database.close();
      _database = null;
      rethrow;
    }
  }

  @override
  void dispose() {
    unawaited(_close());
    _router.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _worker?.dispose();
    await _sessions?.shutdown();
    await _focus?.shutdown();
    await _database?.close();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
    future: _app,
    builder: (context, snapshot) {
      if (snapshot.hasData) return snapshot.data!;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DoeverTheme.build(Brightness.light),
        darkTheme: DoeverTheme.build(Brightness.dark),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final s = AppLocalizations.of(context);
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.appName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: Space.md),
                      Text(
                        snapshot.hasError ? s.startupError : s.tagline,
                        textAlign: TextAlign.center,
                      ),
                      if (snapshot.hasError)
                        TextButton(
                          onPressed: () => setState(() => _app = _initialize()),
                          child: Text(s.retry),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
