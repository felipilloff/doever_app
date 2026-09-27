import 'package:doever/app/theme/doever_theme.dart';
import 'package:doever/app/theme/theme_generator.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

void main() {
  test('built-in preset registry is stable and complete', () {
    expect(themePresets.map((theme) => theme.id), [
      'preset:default',
      'preset:midnight',
      'preset:graphite',
      'preset:ocean',
      'preset:aurora',
      'preset:ember',
      'preset:forest',
      'preset:sand',
    ]);
    expect(themePresetById('preset:ocean')?.name, 'Ocean');
    expect(isThemePresetId('user:ocean'), isFalse);
  });

  test('default theme remains on the original exact path', () {
    final theme = DoeverTheme.build(Brightness.light);
    expect(theme.colorScheme.surface, const Color(0xfff8f9f5));
    expect(theme.extension<DoeverPalette>(), isNull);
  });

  test('relative tone, intensity, and gradient strength are deterministic', () {
    final base = _theme(
      accent: LayerTheme(
        colors: const [0xff123b60, 0xff4f2354],
        mode: ThemeLayerMode.gradient,
        tone: 50,
      ),
    );
    final shifted = ThemeGenerator.generate(
      base.copyWith(accent: base.accent.copyWith(tone: 60)),
    );
    final original = ThemeGenerator.generate(base);
    expect(
      _tone(shifted.accent.first),
      closeTo(_tone(original.accent.first) + 10, 1.5),
    );

    final gray = ThemeGenerator.generate(
      base.copyWith(accent: base.accent.copyWith(intensity: 0)),
    );
    expect(Hct.fromInt(gray.accent.first.toARGB32()).chroma, lessThan(2));

    final flat = ThemeGenerator.generate(
      base.copyWith(accent: base.accent.copyWith(gradientStrength: 0)),
    );
    expect(flat.accent.toSet().length, 1);
  });

  test(
    'opposite Foundation and Surface are balanced without mutating input',
    () {
      final theme = _theme(
        foundation: LayerTheme(colors: const [0xfffafafa]),
        surface: LayerTheme(colors: const [0xff151515]),
      );
      final palette = ThemeGenerator.generate(theme);
      expect(theme.surface.colors.single, 0xff151515);
      expect(
        _tone(palette.surface.first),
        greaterThan(_tone(palette.foundation.first)),
      );
      expect(palette.warnings, isNotEmpty);
      for (final background in [...palette.foundation, ...palette.surface]) {
        expect(
          _contrast(palette.textPrimary, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(palette.colors.primary, background),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );

  test('all presets expose safe sampled foregrounds and usable schemes', () {
    for (final preset in themePresets) {
      final palette = ThemeGenerator.generate(preset);
      final backgrounds = [
        ..._samples(palette.foundation),
        ..._samples(palette.surface),
      ];
      for (final background in backgrounds) {
        expect(
          _contrast(palette.textPrimary, background),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.id} text',
        );
        expect(
          _contrast(palette.colors.primary, background),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.id} primary',
        );
        expect(
          _contrast(palette.focus, background),
          greaterThanOrEqualTo(3),
          reason: '${preset.id} focus',
        );
      }
      for (final background in _samples(palette.accent)) {
        expect(
          _contrast(palette.onAccent, background),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.id} accent',
        );
      }
      final theme = DoeverTheme.build(
        preset.baseMode == ThemeBrightnessMode.light
            ? Brightness.light
            : Brightness.dark,
        custom: preset,
      );
      expect(theme.extension<DoeverPalette>(), isNotNull);
      expect(theme.colorScheme.brightness, palette.colors.brightness);
    }
  });
}

CustomTheme _theme({
  LayerTheme? foundation,
  LayerTheme? surface,
  LayerTheme? accent,
}) => CustomTheme(
  id: 'test',
  name: 'Test',
  baseMode: ThemeBrightnessMode.light,
  foundation: foundation ?? LayerTheme(colors: const [0xfff4f6f2]),
  surface: surface ?? LayerTheme(colors: const [0xfffcfdf9]),
  accent: accent ?? LayerTheme(colors: const [0xff426b59]),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  autoBalance: true,
);

double _tone(Color color) => Hct.fromInt(color.toARGB32()).tone;

double _contrast(Color a, Color b) => Contrast.ratioOfTones(_tone(a), _tone(b));

List<Color> _samples(List<Color> colors) => [
  for (var i = 0; i <= 20; i++) _sample(colors, i / 20),
];

Color _sample(List<Color> colors, double t) {
  if (colors.length == 1) return colors.first;
  final position = t * (colors.length - 1);
  final start = position.floor().clamp(0, colors.length - 2);
  return Color.lerp(colors[start], colors[start + 1], position - start)!;
}
