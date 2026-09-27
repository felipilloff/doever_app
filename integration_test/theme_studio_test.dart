import 'dart:io';

import 'package:doever/app/app.dart';
import 'package:doever/app/providers.dart';
import 'package:doever/app/router.dart';
import 'package:doever/app/theme/theme_generator.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/notes/application/notes_providers.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/theme_studio/application/theme_providers.dart';
import 'package:doever/features/theme_studio/data/drift_theme_repository.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/presentation/theme_layer_editor.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_reminders.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'desktop Theme Studio applies every layer, survives restart, and restores default',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final directory = await Directory.systemTemp.createTemp(
        'doever-theme-studio-',
      );
      final file = File('${directory.path}/theme-studio.sqlite');
      SharedPreferences.setMockInitialValues({
        'language': 'en',
        'theme': 'light',
      });
      final preferences = await SharedPreferences.getInstance();

      var database = AppDatabase(NativeDatabase.createInBackground(file));
      var tasks = DriftTaskRepository(database);
      await tasks.initialize();
      var notes = DriftNoteRepository(database);
      var themes = DriftThemeRepository(database);
      var initialThemes = await themes.load();
      var router = createRouter();

      Widget app() => ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(tasks),
          noteRepositoryProvider.overrideWithValue(notes),
          themeRepositoryProvider.overrideWithValue(themes),
          initialThemeLibraryProvider.overrideWithValue(initialThemes),
          preferencesProvider.overrideWithValue(preferences),
          remindersProvider.overrideWithValue(FakeReminders()),
        ],
        child: DoeverApp(router: router),
      );

      try {
        await tester.pumpWidget(app());
        router.go('/settings');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Theme Studio'));
        await tester.tap(find.text('Theme Studio'));
        await tester.pumpAndSettle();
        expect(find.text('Theme Studio'), findsOneWidget);
        await tester.ensureVisible(find.text('Dark'));
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('theme-name')),
          'Desktop Aurora',
        );
        await _setLayerHex(tester, 'Foundation', '#101827');
        await _setLayerHex(tester, 'Surface', '#202A3B');
        await _setLayerHex(tester, 'Accent', '#3B82F6');

        await tester.ensureVisible(find.text('Gradient'));
        await tester.tap(find.text('Gradient'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Color stop 2'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(TextFormField, 'HEX'));
        await tester.tap(find.widgetWithText(TextFormField, 'HEX'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'HEX'),
          '#A855F7',
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<ThemeLayerEditor>(find.byType(ThemeLayerEditor))
              .layer
              .colors,
          [0xff3b82f6, 0xffa855f7],
          reason: 'Editing the second stop must update the draft immediately',
        );
        await tester.ensureVisible(find.text('Advanced'));
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();
        final tone = await _setSlider(
          tester,
          const ValueKey('theme-tone'),
          .66,
        );
        final intensity = await _setSlider(
          tester,
          const ValueKey('theme-intensity'),
          .78,
        );
        final strength = await _setSlider(
          tester,
          const ValueKey('theme-gradient-strength'),
          .72,
        );

        final previewRow = find
            .ancestor(
              of: find.text('Preview in app'),
              matching: find.byType(Row),
            )
            .first;
        await tester.tap(
          find.descendant(of: previewRow, matching: find.byType(Switch)),
        );
        await tester.pumpAndSettle();
        expect(await database.select(database.customThemes).get(), isEmpty);
        expect((await themes.load()).activeId, 'preset:default');

        await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
        await tester.pumpAndSettle();
        expect(find.text('Theme applied'), findsOneWidget);
        final appliedLibrary = await themes.load();
        final applied = appliedLibrary.themes
            .where((theme) => theme.id == appliedLibrary.activeId)
            .single;
        expect(applied.name, 'Desktop Aurora');
        expect(applied.baseMode, ThemeBrightnessMode.dark);
        expect(applied.foundation.colors.single, 0xff101827);
        expect(applied.surface.colors.single, 0xff202a3b);
        expect(applied.accent.mode, ThemeLayerMode.gradient);
        expect(applied.accent.colors, [0xff3b82f6, 0xffa855f7]);
        expect(applied.accent.tone, tone);
        expect(applied.accent.intensity, intensity);
        expect(applied.accent.gradientStrength, strength);
        expect(tone, isNot(50));
        expect(intensity, lessThan(100));
        expect(strength, lessThan(100));

        final expectedPrimary = ThemeGenerator.generate(applied).colors.primary;
        router.go('/');
        await tester.pumpAndSettle();
        expect(find.text('My Day'), findsWidgets);
        expect(
          Theme.of(tester.element(find.text('My Day').last))
              .colorScheme
              .primary,
          expectedPrimary,
        );
        await tester.tap(find.text('Notes'));
        await tester.pumpAndSettle();
        expect(find.text('New page'), findsWidgets);
        expect(
          Theme.of(tester.element(find.text('New page').first))
              .colorScheme
              .primary,
          expectedPrimary,
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        router.dispose();
        await database.close();

        database = AppDatabase(NativeDatabase.createInBackground(file));
        tasks = DriftTaskRepository(database);
        await tasks.initialize();
        notes = DriftNoteRepository(database);
        themes = DriftThemeRepository(database);
        initialThemes = await themes.load();
        router = createRouter();
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();

        final restoredLibrary = await themes.load();
        expect(restoredLibrary.activeId, applied.id);
        expect(
          Theme.of(tester.element(find.text('My Day').last))
              .colorScheme
              .primary,
          expectedPrimary,
        );

        router.go('/settings');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Light'));
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();
        expect((await themes.load()).activeId, 'preset:default');
        expect(
          await database.select(database.customThemes).get(),
          hasLength(1),
        );
        expect(
          Theme.of(tester.element(find.text('Settings'))).colorScheme.primary,
          isNot(expectedPrimary),
        );
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        router.dispose();
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );
}

Future<void> _setLayerHex(
  WidgetTester tester,
  String layer,
  String value,
) async {
  final button = find.descendant(
    of: find.byType(SegmentedButton<int>),
    matching: find.text(layer),
  );
  await tester.ensureVisible(button);
  final selector = tester.widget<SegmentedButton<int>>(
    find.byType(SegmentedButton<int>),
  );
  final index = ['Foundation', 'Surface', 'Accent'].indexOf(layer);
  if (!selector.selected.contains(index)) {
    await tester.tap(button);
  }
  await tester.pumpAndSettle();
  final hex = find.widgetWithText(TextFormField, 'HEX');
  await tester.ensureVisible(hex);
  await tester.enterText(hex, value);
  await tester.pumpAndSettle();
}

Future<double> _setSlider(
  WidgetTester tester,
  ValueKey<String> key,
  double fraction,
) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  final rect = tester.getRect(finder);
  await tester.tapAt(Offset(rect.left + rect.width * fraction, rect.center.dy));
  await tester.pumpAndSettle();
  return tester.widget<Slider>(finder).value;
}
