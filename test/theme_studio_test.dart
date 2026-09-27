import 'package:doever/features/theme_studio/data/drift_theme_repository.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  for (final width in [600.0, 900.0]) {
    testWidgets('all layers and advanced controls work at width $width', (
      tester,
    ) async {
      await studio(tester, width, (h) async {
        for (final layer in ['Foundation', 'Surface', 'Accent']) {
          final segments = find.byType(SegmentedButton<int>);
          await reveal(tester, segments);
          await tester.tap(
            find.descendant(of: segments, matching: find.text(layer)),
          );
          await tester.pumpAndSettle();
          await reveal(tester, find.widgetWithText(TextFormField, 'HEX'));
          expect(find.widgetWithText(TextFormField, 'HEX'), findsOneWidget);
        }
        await reveal(tester, find.text('Advanced'));
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('theme-tone')), findsOneWidget);
        expect(find.byKey(const ValueKey('theme-intensity')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }

  testWidgets(
    'invalid HEX blocks Apply, reset and Cancel preserve stored selection',
    (tester) async {
      await studio(tester, 900, (h) async {
        final hex = find.widgetWithText(TextFormField, 'HEX');
        await reveal(tester, hex);
        await tester.enterText(hex, '#12');
        await tester.pumpAndSettle();
        expect(find.text('Use #RRGGBB'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
        await tester.pumpAndSettle();
        expect(find.text('Theme applied'), findsNothing);
        await tester.enterText(hex, '#123456');
        await tester.pumpAndSettle();
        await reveal(tester, find.text('Reset theme'));
        await tester.tap(find.text('Reset theme'));
        await tester.pumpAndSettle();
        await reveal(tester, hex);
        expect(tester.widget<TextFormField>(hex).controller!.text, '#F8F9F5');
        await tester.enterText(hex, '#234567');
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Discard'));
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
        final library = await tester.runAsync(
          () => DriftThemeRepository(h.database).load(),
        );
        expect(library!.themes, isEmpty);
        expect(library.activeId, 'preset:default');
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'temporary preview and renaming an inactive theme do not change selection',
    (tester) async {
      await studio(tester, 1440, (h) async {
        final repository = DriftThemeRepository(h.database);
        final saved = themePresets[3].copyWith(
          id: '12345678-1234-4123-8123-123456789abc',
          name: 'Quiet Ocean',
        );
        await tester.runAsync(() => repository.save(saved));
        await tester.pumpAndSettle();
        await reveal(tester, find.byKey(const ValueKey('theme-name')));
        await tester.enterText(
          find.byKey(const ValueKey('theme-name')),
          'Preview only',
        );
        await tester.pumpAndSettle();
        final row = find
            .ancestor(
              of: find.text('Preview in app'),
              matching: find.byType(Row),
            )
            .first;
        await tester.tap(
          find.descendant(of: row, matching: find.byType(Switch)),
        );
        await tester.pumpAndSettle();
        await reveal(tester, find.byTooltip('Quiet Ocean actions'));
        await tester.tap(find.byTooltip('Quiet Ocean actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Rename'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Rename theme'),
          'Still Water',
        );
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();
        final after = await tester.runAsync(repository.load);
        expect(after!.activeId, 'preset:default');
        expect(after.themes.single.name, 'Still Water');
        expect(tester.takeException(), isNull);
      });
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}

Future<void> studio(
  WidgetTester tester,
  double width,
  Future<void> Function(AppHarness) action,
) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final h = AppHarness();
  await tester.runAsync(h.initialize);
  try {
    await tester.pumpWidget(h.app());
    h.router.go('/settings');
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Theme Studio'));
    await tester.tap(find.text('Theme Studio'));
    await tester.pumpAndSettle();
    await action(h);
  } finally {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(h.dispose);
  }
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
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
