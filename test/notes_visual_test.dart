import 'dart:io';
import 'dart:ui' as ui;

import 'package:doever/features/notes/application/note_editor.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/notes/domain/note.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'Notes all block types, ${dark ? 'dark' : 'light'}, narrow and scaled layout',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        tester.view.physicalSize = const Size(1440, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final h = AppHarness();
        await tester.runAsync(
          () => h.initialize(theme: dark ? 'dark' : 'light'),
        );
        final repo = DriftNoteRepository(h.database);
        final page = await repo.createPage();
        final editor = NoteEditor(repo, await repo.load(page.id));
        editor.rename('A little room to think');
        editor.edit(
          editor.blocks.first.copyWith(
            content: 'Collect the ideas worth coming back to. One quiet space for plans, decisions and the next small step.',
          ),
        );
        for (final (type, text) in [
          (NoteBlockType.heading1, 'Make space for what matters'),
          (NoteBlockType.todo, 'Sketch the first version'),
          (NoteBlockType.bullet, 'Keep the useful parts simple'),
          (NoteBlockType.callout, 'A good plan leaves room for discovery.'),
          (NoteBlockType.quote, 'Start where you are. Use what you have.'),
          (NoteBlockType.toggle, 'Decisions and open questions'),
          (
            NoteBlockType.code,
            'final nextStep = "keep going";\n  // Preserve indentation',
          ),
          (NoteBlockType.heading2, 'Details'),
          (NoteBlockType.heading3, 'Next week'),
          (NoteBlockType.numbered, 'Review'),
          (NoteBlockType.divider, ''),
          (NoteBlockType.link, 'Reference'),
          (NoteBlockType.image, ''),
        ]) {
          editor.insert(editor.blocks.length, type: type);
          editor.edit(
            editor.blocks.last.copyWith(
              content: text,
              detail: type == NoteBlockType.toggle
                  ? 'What can we make clearer?'
                  : '',
              url: type == NoteBlockType.link ? 'https://example.com' : '',
            ),
          );
        }
        await editor.flush();
        editor.dispose();
        await tester.pumpWidget(
          RepaintBoundary(key: const ValueKey('notes-capture'), child: h.app()),
        );
        h.router.go('/notes');
        await tester.pumpAndSettle();
        await tester.tap(find.text('A little room to think'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('notesScreenshots')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('notes-capture')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('build/notes-${dark ? 'dark' : 'light'}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.drag(
          find.byType(ReorderableListView).last,
          const Offset(0, -700),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.physicalSize = const Size(600, 900);
        await tester.pumpAndSettle();
        expect(find.byTooltip('Open navigation'), findsOneWidget);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await h.dispose();
        debugDefaultTargetPlatformOverride = null;
      },
    );
  }
}
