import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'theme/doever_theme.dart';

class DoeverApp extends ConsumerWidget {
  const DoeverApp({super.key, required this.router, this.messengerKey});
  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState>? messengerKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Doever',
    debugShowCheckedModeBanner: false,
    routerConfig: router,
    scaffoldMessengerKey: messengerKey,
    theme: DoeverTheme.build(Brightness.light),
    darkTheme: DoeverTheme.build(Brightness.dark),
    themeMode: ref.watch(themeProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
