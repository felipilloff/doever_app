import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../features/theme_studio/domain/custom_theme.dart';

enum ThemeContrastWarning {
  hierarchyBalanced,
  hierarchyLow,
  accentAdjusted,
  gradientMissing,
  lightAdjusted,
  darkAdjusted,
}

@immutable
final class DoeverPalette extends ThemeExtension<DoeverPalette> {
  DoeverPalette({
    required List<Color> foundation,
    required List<Color> surface,
    required List<Color> accent,
    required this.foundationGradient,
    required this.surfaceGradient,
    required this.accentGradient,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.hover,
    required this.pressed,
    required this.selected,
    required this.disabled,
    required this.focus,
    required this.inputBackground,
    required this.overlay,
    required this.elevatedSurface,
    required this.onAccent,
    required List<ThemeContrastWarning> warnings,
    required this.colors,
  }) : foundation = List.unmodifiable(foundation),
       surface = List.unmodifiable(surface),
       accent = List.unmodifiable(accent),
       warnings = List.unmodifiable(warnings);

  final List<Color> foundation;
  final List<Color> surface;
  final List<Color> accent;
  final LinearGradient? foundationGradient;
  final LinearGradient? surfaceGradient;
  final LinearGradient? accentGradient;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;
  final Color hover;
  final Color pressed;
  final Color selected;
  final Color disabled;
  final Color focus;
  final Color inputBackground;
  final Color overlay;
  final Color elevatedSurface;
  final Color onAccent;
  final List<ThemeContrastWarning> warnings;
  final ColorScheme colors;

  static DoeverPalette? of(BuildContext context) =>
      Theme.of(context).extension<DoeverPalette>();

  @override
  DoeverPalette copyWith({
    List<Color>? foundation,
    List<Color>? surface,
    List<Color>? accent,
    LinearGradient? foundationGradient,
    LinearGradient? surfaceGradient,
    LinearGradient? accentGradient,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? hover,
    Color? pressed,
    Color? selected,
    Color? disabled,
    Color? focus,
    Color? inputBackground,
    Color? overlay,
    Color? elevatedSurface,
    Color? onAccent,
    List<ThemeContrastWarning>? warnings,
    ColorScheme? colors,
  }) => DoeverPalette(
    foundation: foundation ?? this.foundation,
    surface: surface ?? this.surface,
    accent: accent ?? this.accent,
    foundationGradient: foundationGradient ?? this.foundationGradient,
    surfaceGradient: surfaceGradient ?? this.surfaceGradient,
    accentGradient: accentGradient ?? this.accentGradient,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    hover: hover ?? this.hover,
    pressed: pressed ?? this.pressed,
    selected: selected ?? this.selected,
    disabled: disabled ?? this.disabled,
    focus: focus ?? this.focus,
    inputBackground: inputBackground ?? this.inputBackground,
    overlay: overlay ?? this.overlay,
    elevatedSurface: elevatedSurface ?? this.elevatedSurface,
    onAccent: onAccent ?? this.onAccent,
    warnings: warnings ?? this.warnings,
    colors: colors ?? this.colors,
  );

  @override
  DoeverPalette lerp(covariant DoeverPalette? other, double t) {
    if (other == null) return this;
    return DoeverPalette(
      foundation: _lerpLists(foundation, other.foundation, t),
      surface: _lerpLists(surface, other.surface, t),
      accent: _lerpLists(accent, other.accent, t),
      foundationGradient: LinearGradient.lerp(
        foundationGradient,
        other.foundationGradient,
        t,
      ),
      surfaceGradient: LinearGradient.lerp(
        surfaceGradient,
        other.surfaceGradient,
        t,
      ),
      accentGradient: LinearGradient.lerp(
        accentGradient,
        other.accentGradient,
        t,
      ),
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      pressed: Color.lerp(pressed, other.pressed, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      warnings: t < .5 ? warnings : other.warnings,
      colors: ColorScheme.lerp(colors, other.colors, t),
    );
  }
}

abstract final class ThemeGenerator {
  static CustomTheme? _lastDefinition;
  static DoeverPalette? _lastPalette;

  static DoeverPalette generate(CustomTheme theme) {
    // Preview, contrast feedback, and app preview share the same immutable
    // draft. Derive its palette once per change, never once per consumer.
    if (theme == _lastDefinition) return _lastPalette!;
    final palette = _generate(theme);
    _lastDefinition = theme;
    _lastPalette = palette;
    return palette;
  }

  static DoeverPalette _generate(CustomTheme theme) {
    final warnings = <ThemeContrastWarning>[];
    final light = theme.baseMode == ThemeBrightnessMode.light;
    var foundation = _transform(
      theme.foundation,
      fallback: light ? const Color(0xfff8f9f5) : const Color(0xff171c19),
      warnings: warnings,
    );
    var surface = _transform(
      theme.surface,
      fallback: light ? Colors.white : const Color(0xff101512),
      warnings: warnings,
    );
    var accent = _transform(
      theme.accent,
      fallback: const Color(0xff426b59),
      warnings: warnings,
    );

    final safeRange = light ? (55.0, 100.0) : (0.0, 45.0);
    final balancedFoundationRange = light ? (88.0, 96.0) : (0.0, 24.0);
    final balancedSurfaceRange = light ? (94.0, 100.0) : (8.0, 32.0);
    foundation = _clampLayer(
      foundation,
      theme.autoBalance ? balancedFoundationRange : safeRange,
      warnings,
    );
    surface = _clampLayer(
      surface,
      theme.autoBalance ? balancedSurfaceRange : safeRange,
      warnings,
    );

    final foundationTone = _tone(_representative(foundation.colors));
    final surfaceTone = _tone(_representative(surface.colors));
    final hierarchy = surfaceTone - foundationTone;
    if (hierarchy < 3.5) {
      if (theme.autoBalance) {
        final correction = (4 - hierarchy) / 2;
        foundation = _shiftLayer(foundation, -correction);
        surface = _shiftLayer(surface, correction);
        warnings.add(ThemeContrastWarning.hierarchyBalanced);
      } else {
        warnings.add(ThemeContrastWarning.hierarchyLow);
      }
    }

    final foundationColor = _representative(foundation.colors);
    final surfaceColor = _representative(surface.colors);
    final sharedSamples = [
      ..._samples(foundation.colors),
      ..._samples(surface.colors),
      ..._samples([foundationColor, surfaceColor]),
    ];
    final textPrimary = _foreground(
      sharedSamples,
      light: light,
      ratio: 4.6,
      hue: _hct(_representative(foundation.colors)).hue,
      preferredTone: light ? 10 : 95,
    );
    final textSecondary = _foreground(
      sharedSamples,
      light: light,
      ratio: 4.6,
      hue: _hct(_representative(foundation.colors)).hue,
      preferBoundary: true,
    );
    final textMuted = _foreground(
      sharedSamples,
      light: light,
      ratio: 3,
      hue: _hct(_representative(foundation.colors)).hue,
      preferBoundary: true,
    );

    var accentSamples = _samples(accent.colors);
    var onAccent = _bestBlackOrWhite(accentSamples);
    if (_minimumContrast(onAccent, accentSamples) < 4.5) {
      final targetTone = light ? 40.0 : 80.0;
      accent = _retargetLayer(accent, targetTone);
      accent = _clampLayer(
        accent,
        light ? (8.0, 45.0) : (60.0, 94.0),
        warnings,
      );
      accentSamples = _samples(accent.colors);
      onAccent = _bestBlackOrWhite(accentSamples);
      warnings.add(ThemeContrastWarning.accentAdjusted);
    }

    final accentColor = _representative(accent.colors);
    final primary = _accessibleColor(accentColor, sharedSamples, ratio: 4.6);
    final onPrimary = _bestBlackOrWhite([primary]);
    final focus = _accessibleColor(accentColor, sharedSamples, ratio: 3.1);
    final brightness = light ? Brightness.light : Brightness.dark;
    final accentHct = _hct(accentColor);
    final backgroundTones = sharedSamples.map(_tone);
    final selectedTone = light
        ? math.max(backgroundTones.reduce(math.min), _tone(surfaceColor) - 4)
        : math.min(backgroundTones.reduce(math.max), _tone(surfaceColor) + 4);
    final selected = Color(
      Hct.from(
        accentHct.hue,
        math.min(accentHct.chroma, 16),
        selectedTone,
      ).toInt(),
    );
    final onSelected = _bestBlackOrWhite([selected]);
    final elevatedSurface = Color.lerp(
      surfaceColor,
      light ? Colors.white : textPrimary,
      light ? .45 : .08,
    )!;
    final border = Color.lerp(foundationColor, textMuted, light ? .35 : .48)!;
    final divider = Color.lerp(foundationColor, textMuted, light ? .22 : .34)!;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: brightness,
          surface: foundationColor,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          surface: foundationColor,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
          surfaceContainerLowest: surfaceColor,
          surfaceContainerLow: Color.lerp(surfaceColor, foundationColor, .18),
          surfaceContainer: Color.lerp(surfaceColor, foundationColor, .30),
          surfaceContainerHigh: Color.lerp(surfaceColor, foundationColor, .42),
          surfaceContainerHighest: Color.lerp(
            surfaceColor,
            foundationColor,
            .55,
          ),
          secondaryContainer: selected,
          onSecondaryContainer: onSelected,
          outline: border,
          outlineVariant: divider,
        );

    return DoeverPalette(
      foundation: foundation.colors,
      surface: surface.colors,
      accent: accent.colors,
      foundationGradient: foundation.gradient,
      surfaceGradient: surface.gradient,
      accentGradient: accent.gradient,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      border: border,
      divider: divider,
      hover: accentColor.withValues(alpha: .08),
      pressed: accentColor.withValues(alpha: .14),
      selected: selected,
      disabled: textPrimary.withValues(alpha: .38),
      focus: focus,
      inputBackground: Color.lerp(surfaceColor, foundationColor, .12)!,
      overlay: (light ? Colors.black : Colors.white).withValues(alpha: .54),
      elevatedSurface: elevatedSurface,
      onAccent: onAccent,
      warnings: warnings,
      colors: scheme,
    );
  }
}

final class _LayerColors {
  const _LayerColors(this.colors, this.mode, this.direction);

  final List<Color> colors;
  final ThemeLayerMode mode;
  final ThemeGradientDirection direction;

  LinearGradient? get gradient =>
      mode == ThemeLayerMode.gradient && colors.length >= 2
      ? LinearGradient(
          begin: _alignments(direction).$1,
          end: _alignments(direction).$2,
          colors: colors,
        )
      : null;
}

_LayerColors _transform(
  LayerTheme layer, {
  required Color fallback,
  required List<ThemeContrastWarning> warnings,
}) {
  final source = layer.colors.isEmpty
      ? [fallback.toARGB32()]
      : layer.colors.take(3).toList();
  var mode = layer.mode;
  if (mode == ThemeLayerMode.gradient && source.length < 2) {
    mode = ThemeLayerMode.solid;
    warnings.add(ThemeContrastWarning.gradientMissing);
  }
  if (mode == ThemeLayerMode.solid && source.length > 1) {
    source.removeRange(1, source.length);
  }
  final strength = (layer.gradientStrength.clamp(0, 100) / 100).toDouble();
  final intensity = (layer.intensity.clamp(0, 100) / 100).toDouble();
  final toneDelta = layer.tone.clamp(0, 100).toDouble() - 50;
  final anchor = Hct.fromInt(_opaque(source.first));
  final colors = <Color>[];
  for (final value in source) {
    final stop = Hct.fromInt(_opaque(value));
    final hue = _lerpHue(anchor.hue, stop.hue, strength);
    final chroma = _lerp(anchor.chroma, stop.chroma, strength) * intensity;
    final tone = (_lerp(anchor.tone, stop.tone, strength) + toneDelta)
        .clamp(0, 100)
        .toDouble();
    colors.add(Color(Hct.from(hue, chroma, tone).toInt()));
  }
  return _LayerColors(colors, mode, layer.direction);
}

_LayerColors _clampLayer(
  _LayerColors layer,
  (double, double) range,
  List<ThemeContrastWarning> warnings,
) {
  var corrected = false;
  final colors = layer.colors.map((color) {
    final hct = _hct(color);
    final tone = hct.tone.clamp(range.$1, range.$2).toDouble();
    corrected |= (tone - hct.tone).abs() > 2;
    return Color(Hct.from(hct.hue, hct.chroma, tone).toInt());
  }).toList();
  if (corrected) {
    warnings.add(
      range.$1 > 50
          ? ThemeContrastWarning.lightAdjusted
          : ThemeContrastWarning.darkAdjusted,
    );
  }
  return _LayerColors(colors, layer.mode, layer.direction);
}

_LayerColors _shiftLayer(_LayerColors layer, double delta) => _LayerColors(
  layer.colors.map((color) {
    final hct = _hct(color);
    return Color(
      Hct.from(
        hct.hue,
        hct.chroma,
        (hct.tone + delta).clamp(0, 100).toDouble(),
      ).toInt(),
    );
  }).toList(),
  layer.mode,
  layer.direction,
);

_LayerColors _retargetLayer(_LayerColors layer, double targetTone) {
  final delta = targetTone - _tone(_representative(layer.colors));
  return _shiftLayer(layer, delta);
}

Color _foreground(
  List<Color> backgrounds, {
  required bool light,
  required double ratio,
  required double hue,
  double? preferredTone,
  bool preferBoundary = false,
}) {
  final tones = light
      ? Iterable<double>.generate(51, (i) => 50 - i.toDouble())
      : Iterable<double>.generate(51, (i) => 50 + i.toDouble());
  final candidates = preferBoundary
      ? tones
      : [preferredTone ?? (light ? 10 : 95)];
  Color? lastSafe;
  for (final tone in candidates) {
    final color = Color(Hct.from(hue, 4, tone).toInt());
    if (_minimumContrast(color, backgrounds) >= ratio) {
      if (!preferBoundary) return color;
      lastSafe = color;
      break;
    }
  }
  return lastSafe ?? _bestBlackOrWhite(backgrounds);
}

Color _bestBlackOrWhite(List<Color> backgrounds) {
  const black = Colors.black;
  const white = Colors.white;
  return _minimumContrast(black, backgrounds) >=
          _minimumContrast(white, backgrounds)
      ? black
      : white;
}

Color _accessibleColor(
  Color desired,
  List<Color> backgrounds, {
  required double ratio,
}) {
  if (_minimumContrast(desired, backgrounds) >= ratio) return desired;
  final source = _hct(desired);
  Color? best;
  var bestDistance = double.infinity;
  for (var tone = 0; tone <= 100; tone++) {
    final candidate = Color(
      Hct.from(source.hue, source.chroma, tone.toDouble()).toInt(),
    );
    if (_minimumContrast(candidate, backgrounds) < ratio) continue;
    final distance = (tone - source.tone).abs();
    if (distance < bestDistance) {
      best = candidate;
      bestDistance = distance;
    }
  }
  return best ?? _bestBlackOrWhite(backgrounds);
}

double _minimumContrast(Color foreground, List<Color> backgrounds) {
  final luminance = foreground.computeLuminance();
  var minimum = 21.0;
  for (final background in backgrounds) {
    final other = background.computeLuminance();
    final ratio =
        (math.max(luminance, other) + .05) / (math.min(luminance, other) + .05);
    minimum = math.min(minimum, ratio);
  }
  return minimum;
}

List<Color> _samples(List<Color> colors) => [
  for (var i = 0; i <= 32; i++) _sample(colors, i / 32),
];

Color _sample(List<Color> colors, double t) {
  if (colors.length == 1) return colors.first;
  final position = t * (colors.length - 1);
  final start = position.floor().clamp(0, colors.length - 2);
  return Color.lerp(colors[start], colors[start + 1], position - start)!;
}

Color _representative(List<Color> colors) => _sample(colors, .5);

Hct _hct(Color color) => Hct.fromInt(color.toARGB32());

double _tone(Color color) => _hct(color).tone;

int _opaque(int argb) => 0xff000000 | (argb & 0x00ffffff);

double _lerp(double a, double b, double t) => a + (b - a) * t;

double _lerpHue(double a, double b, double t) {
  final delta = (b - a + 540) % 360 - 180;
  return (a + delta * t + 360) % 360;
}

(Alignment, Alignment) _alignments(ThemeGradientDirection direction) =>
    switch (direction) {
      ThemeGradientDirection.topToBottom => (
        Alignment.topCenter,
        Alignment.bottomCenter,
      ),
      ThemeGradientDirection.bottomToTop => (
        Alignment.bottomCenter,
        Alignment.topCenter,
      ),
      ThemeGradientDirection.leftToRight => (
        Alignment.centerLeft,
        Alignment.centerRight,
      ),
      ThemeGradientDirection.rightToLeft => (
        Alignment.centerRight,
        Alignment.centerLeft,
      ),
      ThemeGradientDirection.topLeftToBottomRight => (
        Alignment.topLeft,
        Alignment.bottomRight,
      ),
      ThemeGradientDirection.topRightToBottomLeft => (
        Alignment.topRight,
        Alignment.bottomLeft,
      ),
      ThemeGradientDirection.bottomLeftToTopRight => (
        Alignment.bottomLeft,
        Alignment.topRight,
      ),
      ThemeGradientDirection.bottomRightToTopLeft => (
        Alignment.bottomRight,
        Alignment.topLeft,
      ),
    };

List<Color> _lerpLists(List<Color> a, List<Color> b, double t) {
  final length = math.max(a.length, b.length);
  return [
    for (var i = 0; i < length; i++)
      Color.lerp(
        _sample(a, length == 1 ? 0 : i / (length - 1)),
        _sample(b, length == 1 ? 0 : i / (length - 1)),
        t,
      )!,
  ];
}
