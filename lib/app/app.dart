import '../features/focus/presentation/session_setup.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../features/theme_studio/application/theme_providers.dart';
import '../features/theme_studio/domain/custom_theme.dart';
import 'providers.dart';
import 'theme/doever_theme.dart';
import '../features/focus/presentation/focus_shell.dart';

class DoeverApp extends ConsumerWidget {
  const DoeverApp({super.key, required this.router, this.messengerKey});
  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState>? messengerKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom =
        ref.watch(themePreviewProvider) ??
        ref.watch(appliedCustomThemeProvider);
    final brightness = custom?.baseMode == ThemeBrightnessMode.light
        ? Brightness.light
        : Brightness.dark;
    final theme = custom == null
        ? null
        : DoeverTheme.build(brightness, custom: custom);
    return MaterialApp.router(
      title: 'Doever',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: messengerKey,
      theme: theme ?? DoeverTheme.build(Brightness.light),
      darkTheme: theme ?? DoeverTheme.build(Brightness.dark),
      themeMode: custom == null
          ? ref.watch(themeProvider)
          : brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => FocusShell(
        openSession: () => router.push('/focus/session'),
        quickFocus: () {
          final navigatorContext =
              router.routerDelegate.navigatorKey.currentContext;
          if (navigatorContext != null) showFocusSetup(navigatorContext);
        },
        openFocus: () {
          if (router.routeInformationProvider.value.uri.path != '/focus') {
            router.push('/focus');
          }
        },
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
