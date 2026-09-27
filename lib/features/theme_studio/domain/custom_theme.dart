enum ThemeBrightnessMode { light, dark }

enum ThemeLayerMode { solid, gradient }

enum ThemeGradientDirection {
  topToBottom,
  bottomToTop,
  leftToRight,
  rightToLeft,
  topLeftToBottomRight,
  topRightToBottomLeft,
  bottomLeftToTopRight,
  bottomRightToTopLeft,
}

final class LayerTheme {
  LayerTheme({
    required List<int> colors,
    this.mode = ThemeLayerMode.solid,
    this.direction = ThemeGradientDirection.topToBottom,
    this.tone = 50,
    this.intensity = 100,
    this.gradientStrength = 100,
  }) : colors = List.unmodifiable(colors);

  final List<int> colors;
  final ThemeLayerMode mode;
  final ThemeGradientDirection direction;
  final double tone;
  final double intensity;
  final double gradientStrength;

  LayerTheme copyWith({
    List<int>? colors,
    ThemeLayerMode? mode,
    ThemeGradientDirection? direction,
    double? tone,
    double? intensity,
    double? gradientStrength,
  }) => LayerTheme(
    colors: colors ?? this.colors,
    mode: mode ?? this.mode,
    direction: direction ?? this.direction,
    tone: tone ?? this.tone,
    intensity: intensity ?? this.intensity,
    gradientStrength: gradientStrength ?? this.gradientStrength,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayerTheme &&
          _listEquals(colors, other.colors) &&
          mode == other.mode &&
          direction == other.direction &&
          tone == other.tone &&
          intensity == other.intensity &&
          gradientStrength == other.gradientStrength;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(colors),
    mode,
    direction,
    tone,
    intensity,
    gradientStrength,
  );
}

final class CustomTheme {
  const CustomTheme({
    required this.id,
    required this.name,
    required this.baseMode,
    required this.foundation,
    required this.surface,
    required this.accent,
    required this.createdAt,
    required this.updatedAt,
    this.autoBalance = true,
  });

  final String id;
  final String name;
  final ThemeBrightnessMode baseMode;
  final LayerTheme foundation;
  final LayerTheme surface;
  final LayerTheme accent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool autoBalance;

  bool get isBuiltIn => id.startsWith('preset:');

  CustomTheme copyWith({
    String? id,
    String? name,
    ThemeBrightnessMode? baseMode,
    LayerTheme? foundation,
    LayerTheme? surface,
    LayerTheme? accent,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? autoBalance,
  }) => CustomTheme(
    id: id ?? this.id,
    name: name ?? this.name,
    baseMode: baseMode ?? this.baseMode,
    foundation: foundation ?? this.foundation,
    surface: surface ?? this.surface,
    accent: accent ?? this.accent,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    autoBalance: autoBalance ?? this.autoBalance,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTheme &&
          id == other.id &&
          name == other.name &&
          baseMode == other.baseMode &&
          foundation == other.foundation &&
          surface == other.surface &&
          accent == other.accent &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          autoBalance == other.autoBalance;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    baseMode,
    foundation,
    surface,
    accent,
    createdAt,
    updatedAt,
    autoBalance,
  );
}

final class ThemeLibrary {
  ThemeLibrary({
    required List<CustomTheme> themes,
    this.activeId = 'preset:default',
    List<int> recentColors = const [],
  }) : themes = List.unmodifiable(themes),
       recentColors = List.unmodifiable(recentColors);

  final List<CustomTheme> themes;
  final String activeId;
  final List<int> recentColors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeLibrary &&
          _listEquals(themes, other.themes) &&
          activeId == other.activeId &&
          _listEquals(recentColors, other.recentColors);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(themes),
    activeId,
    Object.hashAll(recentColors),
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
