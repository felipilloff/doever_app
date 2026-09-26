import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import 'background_canvas.dart';
import 'background_preference.dart';

class BackgroundSettings extends ConsumerStatefulWidget {
  const BackgroundSettings({super.key});

  @override
  ConsumerState<BackgroundSettings> createState() => _BackgroundSettingsState();
}

class _BackgroundSettingsState extends ConsumerState<BackgroundSettings> {
  bool _busy = false;

  Future<void> _change({bool remove = false}) async {
    if (_busy) return;
    final controller = ref.read(backgroundProvider.notifier);
    final s = AppLocalizations.of(context);
    setState(() => _busy = true);
    await perform(context, () async {
      if (remove) {
        await controller.remove();
        return;
      }
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: s.backgroundTitle,
            extensions: const ['png', 'jpg', 'jpeg', 'webp'],
          ),
        ],
      );
      if (file != null && mounted) await controller.importImage(file);
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final value = ref.watch(backgroundProvider);
    final image = value.asData?.value;
    final colors = Theme.of(context).colorScheme;
    final disabled = _busy || value.isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.backgroundTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Space.sm),
        Text(
          s.backgroundDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Space.md),
        Semantics(
          label: s.backgroundPreview,
          image: true,
          child: ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Layout.radius),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer,
                        colors.surfaceContainerHigh,
                      ],
                    ),
                  ),
                  child: BackgroundCanvas(
                    image: image,
                    child: Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_outlined,
                                color: image == null
                                    ? colors.primary
                                    : Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: Space.sm),
                              Expanded(
                                child: Text(
                                  s.myDay,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: image == null
                                            ? colors.onSurface
                                            : Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(Space.md),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.radio_button_unchecked,
                                  size: 20,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: Space.md),
                                Expanded(
                                  child: Text(
                                    s.taskTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: Space.sm),
                                Icon(
                                  Icons.star_outline_rounded,
                                  size: 20,
                                  color: colors.primary,
                                ),
                              ],
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
        if (disabled) ...[
          const SizedBox(height: Space.sm),
          LinearProgressIndicator(semanticsLabel: s.backgroundApplying),
        ],
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: disabled ? null : () => _change(),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                image == null ? s.backgroundChoose : s.backgroundChange,
              ),
            ),
            if (image != null || value.hasError)
              TextButton.icon(
                onPressed: disabled ? null : () => _change(remove: true),
                icon: const Icon(Icons.hide_image_outlined),
                label: Text(s.backgroundRemove),
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Text(
          value.hasError ? s.backgroundLoadError : s.backgroundFormats,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: value.hasError ? colors.error : colors.onSurfaceVariant,
          ),
        ),
        if (image != null) ...[
          const SizedBox(height: Space.xs),
          Text(s.backgroundLocal, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
