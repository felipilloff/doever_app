import 'custom_theme.dart';

final _presetTime = DateTime.utc(2026, 1, 1);

LayerTheme _solid(int color) => LayerTheme(colors: [color]);

LayerTheme _gradient(
  List<int> colors, {
  ThemeGradientDirection direction =
      ThemeGradientDirection.topLeftToBottomRight,
}) => LayerTheme(
  colors: colors,
  mode: ThemeLayerMode.gradient,
  direction: direction,
);

CustomTheme _preset({
  required String id,
  required String name,
  required ThemeBrightnessMode mode,
  required LayerTheme foundation,
  required LayerTheme surface,
  required LayerTheme accent,
}) => CustomTheme(
  id: id,
  name: name,
  baseMode: mode,
  foundation: foundation,
  surface: surface,
  accent: accent,
  createdAt: _presetTime,
  updatedAt: _presetTime,
);

/// Built-in templates. `preset:default` is a sentinel for the original Doever
/// theme and is intentionally bypassed by the app theme selection layer.
final List<CustomTheme> themePresets = List.unmodifiable([
  _preset(
    id: 'preset:default',
    name: 'Doever',
    mode: ThemeBrightnessMode.light,
    foundation: _solid(0xfff8f9f5),
    surface: _solid(0xffffffff),
    accent: _solid(0xff426b59),
  ),
  _preset(
    id: 'preset:midnight',
    name: 'Midnight',
    mode: ThemeBrightnessMode.dark,
    foundation: _gradient([0xff111827, 0xff172033, 0xff201a36]),
    surface: _solid(0xff20283a),
    accent: _gradient([0xff7aa2f7, 0xffbb9af7]),
  ),
  _preset(
    id: 'preset:graphite',
    name: 'Graphite',
    mode: ThemeBrightnessMode.dark,
    foundation: _solid(0xff171717),
    surface: _solid(0xff262626),
    accent: _solid(0xffd4d4d4),
  ),
  _preset(
    id: 'preset:ocean',
    name: 'Ocean',
    mode: ThemeBrightnessMode.light,
    foundation: _gradient([0xffeef8fb, 0xffe6f0f8]),
    surface: _solid(0xfff9fdff),
    accent: _gradient([0xff006d77, 0xff168aad]),
  ),
  _preset(
    id: 'preset:aurora',
    name: 'Aurora',
    mode: ThemeBrightnessMode.dark,
    foundation: _gradient([0xff10231f, 0xff17233a, 0xff2a1833]),
    surface: _solid(0xff1d2d2b),
    accent: _gradient([0xff5eead4, 0xffa78bfa, 0xfff0abfc]),
  ),
  _preset(
    id: 'preset:ember',
    name: 'Ember',
    mode: ThemeBrightnessMode.dark,
    foundation: _gradient([0xff241512, 0xff311817]),
    surface: _solid(0xff38211d),
    accent: _gradient([0xffff8a4c, 0xffffc857]),
  ),
  _preset(
    id: 'preset:forest',
    name: 'Forest',
    mode: ThemeBrightnessMode.light,
    foundation: _gradient([0xffedf5ef, 0xffe6f0e8]),
    surface: _solid(0xfff8fcf8),
    accent: _gradient([0xff2f6b4f, 0xff5b8e5a]),
  ),
  _preset(
    id: 'preset:sand',
    name: 'Sand',
    mode: ThemeBrightnessMode.light,
    foundation: _gradient([0xfffff7e8, 0xfff3e6cf]),
    surface: _solid(0xfffffcf5),
    accent: _gradient([0xff9a5b30, 0xffc07a3e]),
  ),
]);

/// Alias used by persistence and callers that distinguish templates from user
/// themes.
final List<CustomTheme> builtInThemes = themePresets;

final Map<String, CustomTheme> _presetsById = Map.unmodifiable({
  for (final preset in themePresets) preset.id: preset,
});

CustomTheme? themePresetById(String id) => _presetsById[id];

bool isThemePresetId(String id) => _presetsById.containsKey(id);
