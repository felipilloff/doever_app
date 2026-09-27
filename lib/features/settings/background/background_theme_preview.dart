import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/theme_layer_paint.dart';
import '../../../../l10n/app_localizations.dart';
import 'background_canvas.dart';

/// Inherits the active app ThemeData, including custom semantic layers and
/// gradients. The photo treatment is the same one used by the task workspace.
class BackgroundThemePreview extends StatelessWidget {
  const BackgroundThemePreview({super.key, required this.image});
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: s.backgroundPreview,
      image: true,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FittedBox(
                child: SizedBox(
                  width: 576,
                  height: 324,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 155,
                        child: ThemeLayerPaint(
                          role: ThemeLayerRole.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Doever',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    s.myDay,
                                    style: TextStyle(
                                      color: colors.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(s.tasks),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(s.notes),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: BackgroundCanvas(
                          image: image,
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.myDay,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: image == null
                                            ? colors.onSurface
                                            : Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: true,
                                          onChanged: (_) {},
                                        ),
                                        Expanded(
                                          child: Text(
                                            s.themeSampleTask,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.star_outline_rounded,
                                          color: colors.primary,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: FilledButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add, size: 18),
                                    label: Text(s.addTask),
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
