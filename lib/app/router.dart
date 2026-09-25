import 'package:flutter/material.dart';
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
        GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
  ],
);
