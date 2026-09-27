import 'dart:io';
import 'dart:ui' as ui;

import 'package:doever/features/theme_studio/presentation/theme_studio_screen.dart';
import 'package:doever/features/theme_studio/presentation/theme_layer_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  for (final width in [1440.0, 900.0, 600.0]) {
    testWidgets(
      'Theme Studio fits a $width desktop and exposes editable layers',
      (tester) async {
        tester.view.physicalSize = Size(width, 950);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final h = AppHarness();
        addTearDown(h.dispose);
        await tester.runAsync(h.initialize);
        final boundary = GlobalKey();
        await tester.pumpWidget(
          h.app(
            wrap: (child) => RepaintBoundary(key: boundary, child: child),
          ),
        );
        await tester.pumpAndSettle();
        h.router.go('/settings/theme-studio');
        await tester.pumpAndSettle();
        expect(find.byType(ThemeStudioScreen), findsOneWidget);
        if (width < 1120) {
          await tester.scrollUntilVisible(
            find.byType(ThemeLayerEditor),
            300,
            scrollable: find.byType(Scrollable).last,
          );
        } else {
          await tester.ensureVisible(find.byType(ThemeLayerEditor));
        }
        await tester.pumpAndSettle();
        expect(find.text('Foundation'), findsWidgets);
        expect(tester.takeException(), isNull);
        const directory = String.fromEnvironment('DOEVER_THEME_SCREENSHOTS');
        if (directory.isNotEmpty) {
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await render.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('$directory/studio-${width.round()}.png')
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  }
}
