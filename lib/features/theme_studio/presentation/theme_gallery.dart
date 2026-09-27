import 'package:flutter/material.dart';

import '../../../app/theme/doever_theme.dart';
import '../domain/custom_theme.dart';

class ThemeGallery extends StatelessWidget {
  const ThemeGallery({
    super.key,
    required this.presets,
    required this.saved,
    required this.selectedId,
    required this.activeId,
    required this.onSelect,
    required this.onNew,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
    required this.onImport,
    required this.onExport,
  });

  final List<CustomTheme> presets, saved;
  final String selectedId, activeId;
  final ValueChanged<CustomTheme> onSelect;
  final VoidCallback onNew, onImport, onExport;
  final ValueChanged<CustomTheme> onRename, onDuplicate, onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text('Theme gallery', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            tooltip: 'Import theme',
            onPressed: onImport,
            icon: const Icon(Icons.file_open_outlined),
          ),
          IconButton(
            tooltip: 'Export theme',
            onPressed: onExport,
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      const SizedBox(height: Space.xs),
      Text(
        'Start from a curated look or one you saved.',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: Space.lg),
      _SectionLabel(label: 'Built in', count: presets.length),
      const SizedBox(height: Space.sm),
      for (final theme in presets)
        _ThemeTile(
          theme: theme,
          selected: theme.id == selectedId,
          active: theme.id == activeId,
          onTap: () => onSelect(theme),
          onDuplicate: () => onDuplicate(theme),
        ),
      const SizedBox(height: Space.lg),
      Row(
        children: [
          Expanded(
            child: _SectionLabel(label: 'Saved', count: saved.length),
          ),
          TextButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add),
            label: const Text('New theme'),
          ),
        ],
      ),
      const SizedBox(height: Space.sm),
      if (saved.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Your saved themes will appear here.'),
        )
      else
        for (final theme in saved)
          _ThemeTile(
            theme: theme,
            selected: theme.id == selectedId,
            active: theme.id == activeId,
            onTap: () => onSelect(theme),
            onRename: () => onRename(theme),
            onDuplicate: () => onDuplicate(theme),
            onDelete: () => onDelete(theme),
          ),
    ],
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});
  final String label;
  final int count;
  @override
  Widget build(BuildContext context) => Text(
    '$label · $count',
    style: Theme.of(context).textTheme.labelLarge
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.theme,
    required this.selected,
    required this.active,
    required this.onTap,
    this.onRename,
    this.onDuplicate,
    this.onDelete,
  });
  final CustomTheme theme;
  final bool selected, active;
  final VoidCallback onTap;
  final VoidCallback? onRename, onDuplicate, onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Row(
              children: [
                _Swatch(theme: theme),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (active)
                        Text(
                          'Applied',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.primary),
                        ),
                    ],
                  ),
                ),
                if (onRename != null || onDuplicate != null)
                  PopupMenuButton<String>(
                    tooltip: '${theme.name} actions',
                    onSelected: (value) => switch (value) {
                      'rename' => onRename?.call(),
                      'duplicate' => onDuplicate?.call(),
                      'delete' => onDelete?.call(),
                      _ => null,
                    },
                    itemBuilder: (_) => [
                      if (onRename != null)
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename'),
                        ),
                      if (onDuplicate != null)
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Text('Duplicate'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.theme});
  final CustomTheme theme;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Foundation · Surface · Accent',
    child: Container(
      width: 54,
      height: 38,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (final layer in [theme.foundation, theme.surface, theme.accent])
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(layer.colors.first),
                  gradient: _gradient(layer),
                ),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    ),
  );
}

LinearGradient? _gradient(LayerTheme layer) =>
    layer.mode == ThemeLayerMode.solid
    ? null
    : LinearGradient(colors: layer.colors.map(Color.new).toList());
