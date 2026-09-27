import 'package:doever/features/notes/application/notes_providers.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/notes/presentation/block_editor.dart';
import 'package:doever/features/theme_studio/application/theme_providers.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets(
    'temporary theme changes preserve the active Notes editor and draft',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = AppHarness();
      await tester.runAsync(h.initialize);
      try {
        final notes = DriftNoteRepository(h.database);
        await tester.runAsync(notes.createPage);
        await tester.pumpWidget(h.app());
        await tester.pumpAndSettle();
        h.router.go('/notes');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Untitled'));
        await tester.pumpAndSettle();
        final field = find
            .descendant(
              of: find.byType(BlockEditor),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(field, 'Keep my unfinished thought');
        final before = tester.state(find.byType(BlockEditor).first);
        final container = ProviderScope.containerOf(tester.element(field));
        container.read(themePreviewProvider.notifier).set(themePresets[1]);
        await tester.pumpAndSettle();
        expect(h.router.routeInformationProvider.value.uri.path, '/notes');
        expect(tester.state(find.byType(BlockEditor).first), same(before));
        expect(
          tester.widget<TextField>(field).controller!.text,
          'Keep my unfinished thought',
        );
        container.read(themePreviewProvider.notifier).set(null);
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(BlockEditor).first), same(before));
        expect(
          tester.widget<TextField>(field).controller!.text,
          'Keep my unfinished thought',
        );
        await tester.runAsync(
          () => container.read(noteLeaveGuardProvider).flush(),
        );
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await tester.runAsync(h.dispose);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
