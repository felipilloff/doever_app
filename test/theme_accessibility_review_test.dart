import 'dart:math';

import 'package:doever/app/theme/theme_generator.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (max(first, second) + .05) / (min(first, second) + .05);
}

Iterable<Color> samples(List<Color> stops) sync* {
  if (stops.length == 1) {
    yield stops.single;
    return;
  }
  for (var i = 0; i < stops.length - 1; i++) {
    for (var step = 0; step <= 20; step++) {
      yield Color.lerp(stops[i], stops[i + 1], step / 20)!;
    }
  }
}

void main() {
  test(
    'independent review: authored extremes keep text and controls readable',
    () {
      final random = Random(4817);
      final cases = <CustomTheme>[...themePresets];
      for (final mode in ThemeBrightnessMode.values) {
        for (final balance in [false, true]) {
          for (var i = 0; i < 16; i++) {
            LayerTheme layer() => LayerTheme(
              colors: [
                i == 0 ? 0xff000000 : 0xff000000 | random.nextInt(0x1000000),
                i == 0 ? 0xffffffff : 0xff000000 | random.nextInt(0x1000000),
                0xff000000 | random.nextInt(0x1000000),
              ],
              mode: ThemeLayerMode.gradient,
            );
            cases.add(
              themePresets.first.copyWith(
                baseMode: mode,
                autoBalance: balance,
                foundation: layer(),
                surface: layer(),
                accent: layer(),
              ),
            );
          }
        }
      }
      for (var index = 0; index < cases.length; index++) {
        final palette = ThemeGenerator.generate(cases[index]);
        for (final background in [
          ...samples(palette.foundation),
          ...samples(palette.surface),
          palette.inputBackground,
          palette.selected,
        ]) {
          expect(
            contrast(palette.textPrimary, background),
            greaterThanOrEqualTo(4.5),
            reason: 'Primary text, case $index',
          );
          expect(
            contrast(palette.colors.onSurfaceVariant, background),
            greaterThanOrEqualTo(4.5),
            reason: 'Secondary text, case $index',
          );
          expect(
            contrast(palette.focus, background),
            greaterThanOrEqualTo(3),
            reason: 'Focus indicator, case $index',
          );
          expect(
            contrast(palette.colors.primary, background),
            greaterThanOrEqualTo(4.5),
            reason: 'Primary links, case $index',
          );
        }
        expect(
          contrast(palette.colors.onSecondaryContainer, palette.selected),
          greaterThanOrEqualTo(4.5),
          reason: 'Selected control, case $index',
        );
        for (final background in samples(palette.accent)) {
          expect(
            contrast(palette.onAccent, background),
            greaterThanOrEqualTo(4.5),
            reason: 'Accent button gradient, case $index',
          );
        }
      }
    },
  );
}
