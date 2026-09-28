import 'dart:io';
import 'dart:ui' as ui;

import 'package:doever/app/providers.dart';
import 'package:doever/app/theme/theme_generator.dart';
import 'package:doever/features/focus/application/focus_player.dart';
import 'package:doever/features/focus/data/drift_focus_repository.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:doever/features/focus/presentation/focus_screen.dart';
import 'package:doever/features/focus/presentation/focus_labels.dart';
import 'package:doever/features/theme_studio/application/theme_providers.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:doever/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fake_focus_audio.dart';

void main() {
  testWidgets(
    'Focus gradients, extreme themes, five languages and scaled narrow layout',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 1100);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final h = AppHarness();
      await tester.runAsync(h.initialize);
      final player = FocusPlayer(
        DriftFocusRepository(h.database),
        FakeFocusAudio(),
        FocusPreferences(),
      );
      await player.select(focusPresets[1]);
      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('focus-capture'),
          child: h.app(focusPlayer: player),
        ),
      );
      h.router.go('/focus');
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FocusScreen)),
      );
      Future<void> capture(String name) async {
        if (!const bool.fromEnvironment('focusScreenshots')) return;
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('focus-capture')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('build/focus-$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('default');
      final seed = themePresets[1];
      final extremes = [
        seed.copyWith(
          foundation: LayerTheme(colors: [0xff050509]),
          surface: LayerTheme(colors: [0xff181818]),
          accent: LayerTheme(colors: [0xffcccccc]),
        ),
        seed.copyWith(
          baseMode: ThemeBrightnessMode.light,
          foundation: LayerTheme(colors: [0xffffffff]),
          surface: LayerTheme(colors: [0xfff3f3f3]),
          accent: LayerTheme(colors: [0xffff00ff]),
        ),
        seed.copyWith(
          foundation: LayerTheme(
            colors: [0xff111a2d, 0xff202521],
            mode: ThemeLayerMode.gradient,
          ),
          surface: LayerTheme(
            colors: [0xff25314b, 0xff22262d],
            mode: ThemeLayerMode.gradient,
          ),
          accent: LayerTheme(
            colors: [0xff858cfe, 0xff37bcac],
            mode: ThemeLayerMode.gradient,
          ),
        ),
      ];
      for (var i = 0; i < extremes.length; i++) {
        container.read(themePreviewProvider.notifier).set(extremes[i]);
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.byType(FocusScreen)))
              .colorScheme
              .primary,
          ThemeGenerator.generate(extremes[i]).colors.primary,
        );
        expect(tester.takeException(), isNull);
        await capture('theme-$i');
      }
      tester.view.physicalSize = const Size(620, 850);
      tester.platformDispatcher.textScaleFactorTestValue = 1.7;
      for (final locale in AppLocalizations.supportedLocales) {
        await container.read(localeProvider.notifier).set(locale);
        await tester.pumpAndSettle();
        final s = AppLocalizations.of(tester.element(find.byType(FocusScreen)));
        expect(find.text(s.focusTagline), findsOneWidget);
        expect(find.text(soundLabel(s, FocusSound.lightRain)), findsWidgets);
        expect(tester.takeException(), isNull, reason: locale.languageCode);
        if (locale.languageCode == 'ar') await capture('arabic-narrow');
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await player.shutdown();
        await h.dispose();
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
