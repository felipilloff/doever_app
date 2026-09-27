import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../app/theme/doever_theme.dart';
import '../../../app/theme/theme_generator.dart';
import '../../../app/theme/theme_layer_paint.dart';
import '../domain/custom_theme.dart';

/// A scaled design canvas keeps the sample usable at any editor width.
class ThemeStudioPreview extends StatelessWidget {
  const ThemeStudioPreview({super.key, required this.theme});
  final CustomTheme theme;

  @override
  Widget build(BuildContext context) => Theme(
    data: DoeverTheme.build(
      theme.baseMode == ThemeBrightnessMode.dark
          ? Brightness.dark
          : Brightness.light,
      custom: theme,
    ),
    child: Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final palette = DoeverPalette.of(context)!;
        return Semantics(
          label: AppLocalizations.of(context).themePreviewSemantics,
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: AspectRatio(
                aspectRatio: 560 / 420,
                child: FittedBox(
                  child: SizedBox(
                    width: 560,
                    height: 420,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: ThemeLayerPaint(
                        role: ThemeLayerRole.foundation,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 155,
                              child: ThemeLayerPaint(
                                role: ThemeLayerRole.surface,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: colors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Doever',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 28),
                                      _NavigationSample(
                                        icon: Icons.wb_sunny_outlined,
                                        title: AppLocalizations.of(context)
                                            .myDay,
                                        selected: true,
                                      ),
                                      _NavigationSample(
                                        icon: Icons.inbox_outlined,
                                        title: AppLocalizations.of(context)
                                            .tasks,
                                      ),
                                      _NavigationSample(
                                        icon: Icons.description_outlined,
                                        title: AppLocalizations.of(context)
                                            .notes,
                                      ),
                                      const Spacer(),
                                      const Divider(),
                                      Text(
                                        AppLocalizations.of(context)
                                            .themePersonalSpace,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).myDay,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context).themeRoom,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _TaskSample(
                                      title: AppLocalizations.of(context)
                                          .themeSampleDone,
                                      completed: true,
                                    ),
                                    const SizedBox(height: 10),
                                    _TaskSample(
                                      title: AppLocalizations.of(context)
                                          .themeSampleTask,
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: palette.inputBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: palette.focus,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 18,
                                            color: colors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context)
                                                .addTask,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    const Divider(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .themeLocal,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () {},
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .themeCreate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _NavigationSample extends StatelessWidget {
  const _NavigationSample({
    required this.icon,
    required this.title,
    this.selected = false,
  });
  final IconData icon;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ink = selected ? colors.onSecondaryContainer : colors.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? colors.secondaryContainer : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskSample extends StatelessWidget {
  const _TaskSample({required this.title, this.completed = false});
  final String title;
  final bool completed;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          Checkbox(value: completed, onChanged: (_) {}),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ),
          Icon(
            Icons.star_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    ),
  );
}
