import 'dart:ui' show PointerDeviceKind;

import 'package:doever/features/notes/application/note_editor.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/notes/presentation/block_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets(
    'drag pages and blocks, menu move, shortcuts and empty-list exit',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = AppHarness();
      await tester.runAsync(h.initialize);
      final repo = DriftNoteRepository(h.database);
      final first = await repo.createPage();
      final second = await repo.createPage();
      final e = NoteEditor(repo, await repo.load(first.id));
      e.rename('First page');
      e.edit(e.blocks.first.copyWith(content: 'First block'));
      e.insert(1);
      e.edit(e.blocks.last.copyWith(content: 'Second block'));
      await e.flush();
      e.dispose();
      await repo.save(
        second.id,
        'Second page',
        (await repo.load(second.id)).blocks,
      );
      await tester.pumpWidget(h.app());
      h.router.go('/notes');
      await tester.pumpAndSettle();
      Future<void> dragHandle(Finder handle, double distance) async {
        final gesture = await tester.startGesture(
          tester.getCenter(handle),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.moveBy(const Offset(0, 25));
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.moveBy(Offset(0, distance - 25));
        await tester.pump(const Duration(milliseconds: 400));
        await gesture.moveBy(const Offset(0, 30));
        await tester.pump(const Duration(milliseconds: 400));
        await gesture.up();
        await tester.pumpAndSettle();
      }

      final pages = find.byType(ReorderableDragStartListener);
      await dragHandle(pages.first, 85);
      await tester.pumpAndSettle();
      final sortedPages = await h.database.select(h.database.notePages).get();
      sortedPages.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      expect(sortedPages.first.id, second.id);
      await tester.tap(find.text('First page'));
      await tester.pumpAndSettle();
      final handles = find.descendant(
        of: find.byType(BlockEditor),
        matching: find.byType(ReorderableDragStartListener),
      );
      await dragHandle(handles.first, 95);
      await tester.pumpAndSettle();
      expect((await repo.load(first.id)).blocks.first.content, 'Second block');
      await tester.tap(find.byTooltip('Block actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move up'));
      await tester.pumpAndSettle();
      expect((await repo.load(first.id)).blocks.first.content, 'First block');
      Finder content() => find.descendant(
        of: find.byType(BlockEditor),
        matching: find.byType(TextField),
      );
      await tester.enterText(content().last, '- ');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(BlockEditor), findsNWidgets(2));
      await tester.enterText(content().last, 'Latest edit');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(content().last).controller!.text, '');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(content().last).controller!.text,
        'Latest edit',
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Find in page'), findsOneWidget);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect((await h.database.select(h.database.notePages).get()).length, 3);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await h.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
