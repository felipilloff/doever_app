import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:doever/app/providers.dart';
import 'package:doever/app/theme/theme_generator.dart';
import 'package:doever/app/theme/theme_layer_paint.dart';
import 'package:doever/features/settings/background/background_canvas.dart';
import 'package:doever/features/settings/background/background_preference.dart';
import 'package:doever/features/settings/background/background_theme_preview.dart';
import 'package:doever/features/theme_studio/data/drift_theme_repository.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:doever/features/theme_studio/presentation/theme_labels.dart';
import 'package:doever/features/theme_studio/presentation/theme_layer_editor.dart';
import 'package:doever/features/theme_studio/presentation/theme_studio_screen.dart';
import 'package:doever/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  for (final width in [600.0, 1440.0]) {
    for (final (code, language, foundation) in const [
      ('en', 'English', 'Foundation'),
      ('es', 'Español', 'Base'),
      ('zh', '中文', '基础'),
      ('hi', 'हिन्दी', 'आधार'),
      ('ar', 'العربية', 'الخلفية'),
    ]) {
      testWidgets('Theme Studio follows Settings language $code at $width', (
        tester,
      ) async {
        await _withApp(tester, width, (h) async {
          await tester.scrollUntilVisible(
            find.text(language),
            250,
            scrollable: find.byType(Scrollable).last,
          );
          await _reveal(tester, find.text(language));
          await tester.tap(find.text(language));
          await tester.pumpAndSettle();
          final s = await AppLocalizations.delegate.load(Locale(code));
          await _reveal(tester, find.text(s.themeStudio));
          await tester.tap(find.text(s.themeStudio));
          await tester.pumpAndSettle();
          expect(find.text(s.themeStudio), findsOneWidget);
          expect(find.text(s.themeApply), findsOneWidget);
          await _reveal(tester, find.byType(SegmentedButton<int>));
          expect(find.text(foundation), findsWidgets);
          final editor = tester.widget<ThemeLayerEditor>(
            find.byType(ThemeLayerEditor),
          );
          expect(editor.title, foundation);
          expect(editor.description, s.themeFoundationDescription);
          await _reveal(tester, find.widgetWithText(TextFormField, 'HEX'));
          await tester.enterText(
            find.widgetWithText(TextFormField, 'HEX'),
            '#12',
          );
          await tester.pumpAndSettle();
          expect(find.text(s.themeHexInvalid), findsOneWidget);
          await tester.enterText(
            find.widgetWithText(TextFormField, 'HEX'),
            '#123456',
          );
          await tester.pumpAndSettle();
          await _reveal(tester, find.text(s.themeGradient));
          await tester.tap(find.text(s.themeGradient));
          await tester.pumpAndSettle();
          await _reveal(tester, find.text(s.themeAdvanced));
          await tester.tap(find.text(s.themeAdvanced));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('theme-tone')), findsOneWidget);
          expect(find.text(s.themeIntensity), findsOneWidget);
          expect(
            find.byType(DropdownButtonFormField<ThemeGradientDirection>),
            findsOneWidget,
          );
          await tester.tap(find.widgetWithText(TextButton, s.cancel));
          await tester.pumpAndSettle();
          expect(find.text(s.themeUnsaved), findsOneWidget);
          expect(find.text(s.themeLeavePrompt), findsOneWidget);
          await tester.tap(find.text(s.themeDiscard));
          await tester.pumpAndSettle();
          expect(find.text(s.settings), findsOneWidget);
          expect(h.preferences.getString('language'), code);
          expect(tester.takeException(), isNull);
        });
      }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
    }
  }

  testWidgets(
    'switching language preserves a custom draft and translates warnings and preset labels',
    (tester) async {
      await _withApp(tester, 1440, (h) async {
        await _reveal(tester, find.text('Theme Studio'));
        await tester.tap(find.text('Theme Studio'));
        await tester.pumpAndSettle();
        final name = find.byKey(const ValueKey('theme-name'));
        await _reveal(tester, name);
        await tester.enterText(name, 'My own theme');
        await tester.pumpAndSettle();
        final before = tester
            .widget<ThemeLayerEditor>(find.byType(ThemeLayerEditor))
            .draft;
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ThemeStudioScreen)),
        );
        await container.read(localeProvider.notifier).set(const Locale('es'));
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(name).controller!.text, 'My own theme');
        expect(
          identical(
            before,
            tester
                .widget<ThemeLayerEditor>(find.byType(ThemeLayerEditor))
                .draft,
          ),
          isTrue,
        );
        expect(find.text('Estudio de temas'), findsOneWidget);
        expect(find.text('Océano'), findsOneWidget);
        final s = AppLocalizations.of(
          tester.element(find.byType(ThemeStudioScreen)),
        );
        for (final warning in ThemeContrastWarning.values) {
          expect(
            themeWarningText(warning, s),
            isNot(
              themeWarningText(
                warning,
                await AppLocalizations.delegate.load(const Locale('en')),
              ),
            ),
          );
        }
        expect(
          themeDisplayName(
            themePresets[3].copyWith(id: 'custom', name: 'Ocean'),
            s,
          ),
          'Ocean',
        );
        expect(tester.takeException(), isNull);
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  for (final mode in ThemeBrightnessMode.values) {
    testWidgets(
      'wallpaper preview inherits all active $mode theme layers with and without a photo',
      (tester) async {
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(Colors.teal, BlendMode.src);
        final picture = recorder.endRecording();
        final image = await tester.runAsync(() => picture.toImage(2, 2));
        final data = await tester.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.png),
        );
        image!.dispose();
        picture.dispose();
        final pixels = data!.buffer.asUint8List();
        await _withApp(tester, 1000, (h) async {
          final repository = DriftThemeRepository(h.database);
          final theme = themePresets[3].copyWith(
            id: '12345678-1234-4123-8123-123456789abc',
            name: 'Preview custom',
            baseMode: mode,
            foundation: LayerTheme(
              colors: [0xff122233, 0xff303950],
              mode: ThemeLayerMode.gradient,
            ),
            surface: LayerTheme(
              colors: [0xff315543, 0xff524563],
              mode: ThemeLayerMode.gradient,
              direction: ThemeGradientDirection.bottomToTop,
            ),
            accent: LayerTheme(
              colors: [0xffbe75ff, 0xff45cbd0],
              mode: ThemeLayerMode.gradient,
              direction: ThemeGradientDirection.rightToLeft,
            ),
          );
          await tester.runAsync(() => repository.save(theme, apply: true));
          await tester.pumpAndSettle();
          final preview = find.byType(BackgroundThemePreview);
          final palette = ThemeGenerator.generate(theme);
          expect(
            Theme.of(tester.element(preview))
                .extension<DoeverPalette>()!
                .accent,
            palette.accent,
          );
          for (final role in [
            ThemeLayerRole.foundation,
            ThemeLayerRole.surface,
          ]) {
            final paint = find.descendant(
              of: preview,
              matching: find.byWidgetPredicate(
                (w) => w is ThemeLayerPaint && w.role == role,
              ),
            );
            final ink = tester.widget<Ink>(
              find.descendant(of: paint, matching: find.byType(Ink)).first,
            );
            expect(
              (ink.decoration! as BoxDecoration).gradient,
              role == ThemeLayerRole.foundation
                  ? palette.foundationGradient
                  : palette.surfaceGradient,
            );
          }
          final button = find.descendant(
            of: preview,
            matching: find.byType(FilledButton),
          );
          expect(
            Theme.of(tester.element(button))
                .filledButtonTheme
                .style!
                .backgroundBuilder,
            isNotNull,
          );
          final container = ProviderScope.containerOf(tester.element(preview));
          (container.read(backgroundProvider.notifier) as _PhotoBackground)
              .show(pixels);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<BackgroundCanvas>(
                  find.descendant(
                    of: preview,
                    matching: find.byType(BackgroundCanvas),
                  ),
                )
                .image,
            pixels,
          );
          expect(
            Theme.of(tester.element(button)).extension<DoeverPalette>()!.accent,
            palette.accent,
          );
          expect(
            find.descendant(of: preview, matching: find.byType(Image)),
            findsOneWidget,
          );
          await tester.runAsync(() => repository.select('preset:default'));
          await tester.pumpAndSettle();
          expect(
            Theme.of(tester.element(preview)).extension<DoeverPalette>(),
            isNull,
          );
          expect(tester.takeException(), isNull);
        });
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  }
}

class _PhotoBackground extends BackgroundPreference {
  _PhotoBackground(this.pixels);
  final Uint8List? pixels;
  @override
  Future<Uint8List?> build() async => pixels;
  void show(Uint8List value) => state = AsyncData(value);
}

Future<void> _withApp(
  WidgetTester tester,
  double width,
  Future<void> Function(AppHarness) action,
) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final h = AppHarness();
  await tester.runAsync(h.initialize);
  try {
    final app = h.app() as ProviderScope;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...app.overrides,
          backgroundProvider.overrideWith(() => _PhotoBackground(null)),
        ],
        child: app.child,
      ),
    );
    h.router.go('/settings');
    await tester.pumpAndSettle();
    await action(h);
  } finally {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(h.dispose);
  }
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
}
