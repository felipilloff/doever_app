import 'dart:async';

import 'package:doever/database/app_database.dart';
import 'package:doever/features/notes/application/note_editor.dart';
import 'package:doever/features/notes/data/drift_note_repository.dart';
import 'package:doever/features/notes/domain/note.dart';
import 'package:doever/features/notes/domain/note_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledRepository implements NoteRepository {
  ControlledRepository(this.delegate);
  final NoteRepository delegate;
  bool fail = false;
  Completer<void>? gate;
  int writes = 0, concurrent = 0, maxConcurrent = 0;
  @override
  Future<void> save(String id, String title, List<NoteBlock> blocks) async {
    writes++;
    concurrent++;
    if (concurrent > maxConcurrent) maxConcurrent = concurrent;
    try {
      await gate?.future;
      if (fail) throw StateError('simulated write failure');
      await delegate.save(id, title, blocks);
    } finally {
      concurrent--;
    }
  }

  @override
  Future<NotePage> createPage() => delegate.createPage();
  @override
  Future<void> deletePage(String id) => delegate.deletePage(id);
  @override
  Future<void> restorePage(String id) => delegate.restorePage(id);
  @override
  Future<void> movePage(String id, int target) => delegate.movePage(id, target);
  @override
  Future<NoteDocument> load(String id) => delegate.load(id);
  @override
  Stream<List<NotePage>> watchPages({String search = ''}) =>
      delegate.watchPages(search: search);
  @override
  Stream<List<NoteBlock>> watchBlocks(String id) => delegate.watchBlocks(id);
}

void main() {
  test('autosave serializes rapid edits, retains failed drafts and retries latest state', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ControlledRepository(DriftNoteRepository(db));
    final page = await repo.createPage();
    final editor = NoteEditor(repo, await repo.load(page.id));
    for (var i = 0; i < 20; i++) {
      editor.edit(editor.blocks.single.copyWith(content: 'Draft $i'));
    }
    expect(repo.writes, 0);
    repo.gate = Completer<void>();
    final first = editor.flush();
    editor.insert(1);
    editor.move(1, 0);
    editor.edit(editor.blocks.last.copyWith(content: 'Latest'));
    final finalFlush = editor.flush();
    repo.gate!.complete();
    expect(await first, true);
    expect(await finalFlush, true);
    expect(repo.maxConcurrent, 1);
    expect((await repo.load(page.id)).blocks.last.content, 'Latest');
    repo.gate = null;
    repo.fail = true;
    editor.rename('Keep unsaved title');
    expect(await editor.flush(), false);
    expect(editor.failed, true);
    expect(editor.dirty, true);
    expect(editor.title, 'Keep unsaved title');
    repo.fail = false;
    expect(await editor.flush(), true);
    expect(editor.failed, false);
    expect((await repo.load(page.id)).page.title, 'Keep unsaved title');
    editor.undo();
    await editor.flush();
    expect(editor.title, '');
    editor.redo();
    await editor.flush();
    expect(editor.title, 'Keep unsaved title');
    editor.dispose();
    await db.close();
  });
}
