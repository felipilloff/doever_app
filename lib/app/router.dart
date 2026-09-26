import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notes/application/notes_providers.dart';
import '../features/notes/presentation/notes_screen.dart';

import 'package:go_router/go_router.dart';

import '../features/tasks/presentation/task_screen.dart';
import '../features/tasks/presentation/task_detail.dart';
import '../features/settings/settings_screen.dart';

GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const TaskScreen(),
      routes: [
        GoRoute(
          path: 'task/:id',
          builder: (_, state) =>
              Scaffold(body: TaskDetail(id: state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'notes',
          redirect: (_, _) => supportsNotes ? null : '/',
          onExit: (context, _) =>
              ProviderScope.containerOf(context)
                  .read(noteLeaveGuardProvider)
                  .flush(),
          builder: (_, _) => const NotesScreen(),
        ),
        GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
  ],
);
