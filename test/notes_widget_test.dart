import 'package:doever/features/notes/presentation/block_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets(
    'Notes: page title, slash keyboard, markdown, todo/task, duplicate/delete, search and undo',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final harness = AppHarness();
      await tester.runAsync(harness.initialize);
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New page').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('note-title')),
        'Project plan',
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      Finder content() => find.descendant(
        of: find.byType(BlockEditor),
        matching: find.byType(TextField),
      );
      await tester.enterText(content().first, '/hea');
      await tester.pumpAndSettle();
      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.enterText(content().first, 'Milestones');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(BlockEditor), findsNWidgets(2));
      await tester.enterText(content().last, '[] ');
      await tester.pumpAndSettle();
      await tester.enterText(content().last, 'Ship Notes');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);
      await tester.tap(find.byTooltip('Block actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Doever Task'));
      await tester.pumpAndSettle();
      expect(
        (await harness.database.select(harness.database.tasks).get())
            .single
            .title,
        'Ship Notes',
      );
      await tester.tap(find.byTooltip('Block actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(find.byType(BlockEditor), findsNWidgets(3));
      await tester.tap(find.byTooltip('Block actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.byType(BlockEditor), findsNWidgets(2));
      await tester.tap(find.byTooltip('Undo'));
      await tester.pumpAndSettle();
      expect(find.byType(BlockEditor), findsNWidgets(3));
      await tester.tap(find.byTooltip('Redo'));
      await tester.pumpAndSettle();
      expect(find.byType(BlockEditor), findsNWidgets(2));
      await tester.tap(find.byTooltip('Find in page'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Find in page'),
        'ship',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 / 1'), findsOneWidget);
      await tester.tap(find.byTooltip('Next match'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.enterText(content().last, 'Final task text');
      await tester.tap(find.byTooltip('Tasks'));
      await tester.pumpAndSettle();
      final pages = await harness.database
          .select(harness.database.notePages)
          .get();
      expect(pages.single.title, 'Project plan');
      expect(
        (await harness.database.select(harness.database.noteBlocks).get()).any(
          (b) => b.content == 'Final task text' && b.deletedAt == null,
        ),
        true,
      );
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Search pages'),
        'missing',
      );
      await tester.pumpAndSettle();
      expect(find.text('Project plan'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Search pages'),
        'Project',
      );
      await tester.pumpAndSettle();
      expect(find.text('Project plan'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await harness.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );
  testWidgets('mobile neither exposes Notes nor allows its route', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final harness = AppHarness();
    await tester.runAsync(harness.initialize);
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    expect(find.text('Notes'), findsNothing);
    harness.router.go('/notes');
    await tester.pumpAndSettle();
    expect(find.text('New page'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await harness.dispose();
    debugDefaultTargetPlatformOverride = null;
  });
}
