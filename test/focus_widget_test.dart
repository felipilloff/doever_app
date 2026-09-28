import 'package:doever/app/theme/doever_theme.dart';
import 'package:doever/app/theme/theme_generator.dart';
import 'package:doever/features/focus/application/focus_player.dart';
import 'package:doever/features/focus/data/drift_focus_repository.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:doever/features/focus/presentation/focus_screen.dart';
import 'package:doever/features/focus/presentation/focus_controls.dart';
import 'package:doever/features/theme_studio/data/drift_theme_repository.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fake_focus_audio.dart';

void main() {
  testWidgets(
    'unsupported platforms hide Focus and redirect its route without audio',
    (tester) async {
      final h = AppHarness();
      await tester.runAsync(h.initialize);
      final audio = FakeFocusAudio();
      final player = FocusPlayer(
        DriftFocusRepository(h.database),
        audio,
        FocusPreferences(mix: focusPresets.first),
      );
      await tester.pumpWidget(h.app(focusPlayer: player));
      await tester.pumpAndSettle();
      expect(find.text('Focus'), findsNothing);
      expect(find.byType(FocusPlayButton), findsNothing);
      h.router.go('/focus');
      await tester.pumpAndSettle();
      expect(h.router.routeInformationProvider.value.uri.path, '/');
      expect(find.byType(FocusScreen), findsNothing);
      expect(audio.calls, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await player.shutdown();
        await h.dispose();
      });
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }),
  );
  testWidgets(
    'Focus mix edits, save, mini-player and navigation retain playback',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = AppHarness();
      await h.initialize();
      final audio = FakeFocusAudio();
      final player = FocusPlayer(
        DriftFocusRepository(h.database),
        audio,
        FocusPreferences(),
      );
      await tester.pumpWidget(h.app(focusPlayer: player));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();
      expect(find.byType(FocusScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Rainy café'));
      await tester.tap(find.text('Rainy café'));
      await tester.pumpAndSettle();
      expect(audio.playing, false);
      final play = find.byType(FocusPlayButton).first;
      await tester.ensureVisible(play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(audio.playing, true);
      final rain = find.byKey(const ValueKey('volume-lightRain'));
      await tester.ensureVisible(rain);
      final rect = tester.getRect(rain);
      await tester.tapAt(Offset(rect.left + rect.width * .25, rect.center.dy));
      await tester.pumpAndSettle();
      expect(
        player.mix!.tracks
            .firstWhere((t) => t.sound == FocusSound.lightRain)
            .volume,
        lessThan(.4),
      );
      final brownRow = find.ancestor(
        of: find.text('Brown noise'),
        matching: find.byType(ListTile),
      );
      final add = find.descendant(
        of: brownRow,
        matching: find.byType(IconButton),
      );
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(player.mix!.tracks, hasLength(4));
      final removeVinyl = find.byTooltip('Remove sound: Vinyl crackle');
      await tester.ensureVisible(removeVinyl);
      await tester.tap(removeVinyl);
      await tester.pumpAndSettle();
      expect(player.mix!.tracks.any((t) => t.sound == FocusSound.vinyl), false);
      await tester.ensureVisible(find.text('Dynamic ambience').first);
      await tester.tap(find.text('Dynamic ambience').first);
      await tester.pumpAndSettle();
      expect(player.mix!.tracks.first.dynamic, true);
      await tester.ensureVisible(find.text('Save soundscape'));
      await tester.tap(find.text('Save soundscape'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My quiet café');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(player.mix!.isBuiltIn, false);
      expect(
        (await tester.runAsync(
          () => player.repository.watchSoundscapes().first,
        ))!.single.name,
        'My quiet café',
      );
      final playCalls = audio.calls.where((c) => c == 'play').length;
      h.router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('My quiet café'), findsOneWidget);
      expect(audio.playing, true);
      h.router.go('/notes');
      await tester.pumpAndSettle();
      expect(audio.playing, true);
      h.router.go('/settings');
      await tester.pumpAndSettle();
      expect(audio.calls.where((c) => c == 'play').length, playCalls);
      await tester.tap(find.byTooltip('Your mix'));
      await tester.pumpAndSettle();
      expect(find.byType(FocusScreen), findsOneWidget);
      await tester.tap(find.byType(FocusPlayButton).last);
      await tester.pumpAndSettle();
      expect(audio.playing, false);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await player.shutdown();
        await h.dispose();
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'Focus follows custom semantic themes and remains usable in narrow translated layouts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(620, 850);
      addTearDown(tester.view.resetPhysicalSize);
      final h = AppHarness();
      await h.initialize();
      final player = FocusPlayer(
        DriftFocusRepository(h.database),
        FakeFocusAudio(),
        FocusPreferences(),
      );
      await player.select(focusPresets.first);
      await tester.pumpWidget(h.app(focusPlayer: player));
      h.router.go('/focus');
      await tester.pumpAndSettle();
      final repository = DriftThemeRepository(h.database);
      for (final preset in themePresets) {
        await tester.runAsync(() => repository.select(preset.id));
        await tester.pumpAndSettle();
        if (preset.id != 'preset:default') {
          expect(
            Theme.of(tester.element(find.byType(FocusScreen)))
                .colorScheme
                .primary,
            ThemeGenerator.generate(preset).colors.primary,
          );
        }
        expect(tester.takeException(), isNull, reason: preset.name);
      }
      expect(find.byType(Slider), findsWidgets);
      expect(DoeverTheme.build(Brightness.dark).brightness, Brightness.dark);
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
