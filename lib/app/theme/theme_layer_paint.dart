import 'package:flutter/material.dart';

import 'theme_generator.dart';

enum ThemeLayerRole { foundation, surface, accent }

/// Paints one intentional semantic layer. Material component colors continue
/// to come from the app's single [ColorScheme].
class ThemeLayerPaint extends StatelessWidget {
  const ThemeLayerPaint({
    super.key,
    required this.role,
    required this.child,
    this.fallbackColor,
  });

  final ThemeLayerRole role;
  final Widget child;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final palette = DoeverPalette.of(context);
    final theme = Theme.of(context);
    final fallback =
        fallbackColor ??
        switch (role) {
          ThemeLayerRole.foundation => theme.scaffoldBackgroundColor,
          ThemeLayerRole.surface => theme.colorScheme.surfaceContainerLow,
          ThemeLayerRole.accent => theme.colorScheme.primary,
        };
    final (colors, gradient, foreground) = palette == null
        ? ([fallback], null, null)
        : switch (role) {
            ThemeLayerRole.foundation => (
              palette.foundation,
              palette.foundationGradient,
              palette.textPrimary,
            ),
            ThemeLayerRole.surface => (
              palette.surface,
              palette.surfaceGradient,
              palette.textPrimary,
            ),
            ThemeLayerRole.accent => (
              palette.accent,
              palette.accentGradient,
              palette.onAccent,
            ),
          };
    return Material(
      color: palette == null ? fallback : Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: gradient == null ? colors.first : null,
          gradient: gradient,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: child,
          ),
        ),
      ),
    );
  }
}
