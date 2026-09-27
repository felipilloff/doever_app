import '../../../app/theme/theme_generator.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/custom_theme.dart';
import '../domain/theme_presets.dart';

/// Translate shipped labels without changing theme identity or user names.
String themeDisplayName(CustomTheme theme, AppLocalizations s) {
  final preset = themePresetById(theme.id);
  if (preset == null || preset.name != theme.name) return theme.name;
  return switch (theme.id) {
    'preset:midnight' => s.themePresetMidnight,
    'preset:graphite' => s.themePresetGraphite,
    'preset:ocean' => s.themePresetOcean,
    'preset:aurora' => s.themePresetAurora,
    'preset:ember' => s.themePresetEmber,
    'preset:forest' => s.themePresetForest,
    'preset:sand' => s.themePresetSand,
    _ => theme.name,
  };
}

String themeWarningText(ThemeContrastWarning warning, AppLocalizations s) =>
    switch (warning) {
      ThemeContrastWarning.hierarchyBalanced => s.themeHierarchyBalanced,
      ThemeContrastWarning.hierarchyLow => s.themeHierarchyLow,
      ThemeContrastWarning.accentAdjusted => s.themeAccentAdjusted,
      ThemeContrastWarning.gradientMissing => s.themeGradientMissing,
      ThemeContrastWarning.lightAdjusted => s.themeLightAdjusted,
      ThemeContrastWarning.darkAdjusted => s.themeDarkAdjusted,
    };
