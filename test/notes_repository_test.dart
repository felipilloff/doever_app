import 'dart:io';

import 'package:doever/database/app_database.dart';
import 'package:doever/core/errors.dart';
import 'package:doever/features/notes/application/note_editor.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/notes/domain/note.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('page/block CRUD, ordering, conversion, history, tombstones and independent task persist', () async {
    final dir = await Directory.systemTemp.createTemp('notes-repository-');
    final file = File('${dir.path}/notes.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var repo = DriftNoteRepository(db);
    final tasks = DriftTaskRepository(db);
    await tasks.initialize();
    final page = await repo.createPage();
    final second = await repo.createPage();
    await repo.movePage(second.id, 0);
    expect((await repo.watchPages().first).first.id, second.id);
    final editor = NoteEditor(repo, await repo.load(page.id));
    editor.rename('Architecture 100%');
    final original = editor.blocks.single;
    editor.edit(
      original.copyWith(content: 'Draft', type: NoteBlockType.heading1),
    );
    final todoId = editor.insert(1, type: NoteBlockType.todo);
    editor.edit(
      editor.blocks.last.copyWith(content: 'Ship the notes', checked: true),
    );
    final taskId = await editor.createTask(todoId, tasks);
    expect((await tasks.getTask(taskId))!.title, 'Ship the notes');
    expect((await tasks.getTask(taskId))!.isCompleted, false);
    final duplicate = editor.insert(2, copy: editor.blocks.last);
    expect(duplicate, isNot(todoId));
    expect(editor.blocks.last.checked, true);
    editor.move(2, 0);
    editor.edit(
      editor.blocks[1].convert(NoteBlockType.quote),
      structural: true,
    );
    editor.remove(todoId);
    await editor.flush();
    expect(
      (await db.select(db.noteBlocks).get())
          .where((b) => b.deletedAt != null)
          .length,
      1,
    );
    editor.undo();
    await editor.flush();
    expect(editor.blocks.any((b) => b.id == todoId), true);
    editor.redo();
    await editor.flush();
    expect(editor.blocks.any((b) => b.id == todoId), false);
    expect(
      (await repo.watchPages(search: '%').first).single.title,
      'Architecture 100%',
    );
    final expected = editor.blocks.map((b) => b.id).toList();
    editor.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    repo = DriftNoteRepository(db);
    final reopened = await repo.load(page.id);
    expect(reopened.page.title, 'Architecture 100%');
    expect(reopened.blocks.map((b) => b.id), expected);
    expect(reopened.blocks.last.type, NoteBlockType.quote);
    await repo.deletePage(page.id);
    expect(await repo.watchBlocks(page.id).first, isEmpty);
    expect((await repo.watchPages().first).length, 1);
    expect(
      (await DriftTaskRepository(db).getTask(taskId))!.title,
      'Ship the notes',
    );
    await repo.restorePage(page.id);
    expect((await repo.load(page.id)).blocks.length, 2);
    await expectLater(
      repo.save(second.id, '', reopened.blocks),
      throwsA(isA<AppFailure>()),
    );
    expect((await repo.load(second.id)).blocks.length, 1);
    await db.close();
    await dir.delete(recursive: true);
  });
  test(
    'markdown and links validate intent without destructive conversions',
    () {
      expect(markdownBlock('# '), NoteBlockType.heading1);
      expect(markdownBlock('## '), NoteBlockType.heading2);
      expect(markdownBlock('### '), NoteBlockType.heading3);
      expect(markdownBlock('- '), NoteBlockType.bullet);
      expect(markdownBlock('1. '), NoteBlockType.numbered);
      expect(markdownBlock('[] '), NoteBlockType.todo);
      expect(markdownBlock('> '), NoteBlockType.quote);
      expect(markdownBlock('``` '), NoteBlockType.code);
      expect(markdownBlock('--- '), NoteBlockType.divider);
      expect(markdownBlock('# existing text'), isNull);
      expect(validNoteUrl('https://example.com/a?x=1'), true);
      for (final url in [
        'javascript:alert(1)',
        'file:///etc/passwd',
        'https://',
        'https://user:pass@example.com',
        'http://bad host',
      ]) {
        expect(validNoteUrl(url), false);
      }
      final block = NoteBlock(
        id: 'a',
        pageId: 'p',
        type: NoteBlockType.image,
        content: 'caption',
        imageName: 'image.png',
        sortOrder: 1,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(
        () => block.convert(NoteBlockType.text),
        throwsA(isA<AppFailure>()),
      );
    },
  );
}
