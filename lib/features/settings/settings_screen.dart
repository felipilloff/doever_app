import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/doever_theme.dart';
import '../../core/widgets/feedback.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(Space.lg),
            children: [
              Text(s.theme, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Space.md),
              ...ThemeMode.values.map(
                (mode) => ListTile(
                  title: Text(switch (mode) {
                    ThemeMode.system => s.systemTheme,
                    ThemeMode.light => s.lightTheme,
                    ThemeMode.dark => s.darkTheme,
                  }),
                  leading: Icon(switch (mode) {
                    ThemeMode.system => Icons.brightness_auto_outlined,
                    ThemeMode.light => Icons.light_mode_outlined,
                    ThemeMode.dark => Icons.dark_mode_outlined,
                  }),
                  trailing: ref.watch(themeProvider) == mode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => perform(
                    context,
                    () => ref.read(themeProvider.notifier).set(mode),
                  ),
                ),
              ),
              const Divider(height: Space.xxl),
              Text(s.language, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Space.md),
              for (final language in const [
                ('en', 'English'),
                ('zh', '中文'),
                ('hi', 'हिन्दी'),
                ('es', 'Español'),
                ('ar', 'العربية'),
              ])
                ListTile(
                  title: Text(language.$2),
                  trailing:
                      (ref.watch(localeProvider)?.languageCode ??
                              Localizations.localeOf(context).languageCode) ==
                          language.$1
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => perform(
                    context,
                    () => ref
                        .read(localeProvider.notifier)
                        .set(Locale(language.$1)),
                  ),
                ),
              const Divider(height: Space.xxl),
              Text(
                s.preferences,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.showCompleted),
                value: ref.watch(completedPreferenceProvider),
                onChanged: (v) => perform(
                  context,
                  () => ref.read(completedPreferenceProvider.notifier).set(v),
                ),
              ),
              const Divider(height: Space.xxl),
              const Icon(Icons.shield_outlined, size: 32),
              const SizedBox(height: Space.md),
              Text(
                s.privacyTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: Space.sm),
              Text(s.privacyBody),
              const SizedBox(height: Space.xl),
              Text(
                '${s.appName} 0.1.0',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(s.tagline),
            ],
          ),
        ),
      ),
    );
  }
}
