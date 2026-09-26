import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logging.dart';
import '../../../core/errors.dart';
import '../../tasks/domain/task_repository.dart';
import '../domain/note.dart';
import '../domain/note_repository.dart';

typedef NoteDraft = ({String title, List<NoteBlock> blocks});

/// Session-only drafts/history. SQLite remains the persisted source of truth.
class NoteEditor extends ChangeNotifier {
  NoteEditor(this.repository, NoteDocument document)
    : pageId = document.page.id,
      title = document.page.title,
      blocks = List.of(document.blocks);
  final NoteRepository repository;
  final String pageId;
  String title;
  List<NoteBlock> blocks;
  final _undo = <NoteDraft>[], _redo = <NoteDraft>[];
  Timer? _timer;
  Future<bool>? _saving;
  bool dirty = false, failed = false, _textBatch = false, _disposed = false;
  int _revision = 0;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  NoteDraft get _snapshot => (title: title, blocks: List.of(blocks));
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _remember({bool text = false}) {
    if (!text || !_textBatch) {
      _undo.add(_snapshot);
      if (_undo.length > 100) _undo.removeAt(0);
      _redo.clear();
    }
    _textBatch = text;
  }

  void _changed({required bool structural}) {
    final wasDirty = dirty;
    dirty = true;
    _revision++;
    _timer?.cancel();
    if (structural) {
      _textBatch = false;
      _notify();
      unawaited(flush());
    } else {
      if (!wasDirty) _notify();
      _timer = Timer(const Duration(milliseconds: 450), flush);
    }
  }

  void rename(String text) {
    if (text == title) return;
    _remember(text: true);
    title = text;
    _changed(structural: false);
  }

  void edit(NoteBlock value, {bool structural = false}) {
    final index = blocks.indexWhere((b) => b.id == value.id);
    if (index < 0 || blocks[index].sameContent(value)) return;
    _remember(text: !structural);
    blocks = [...blocks]..[index] = value;
    _changed(structural: structural);
  }

  String insert(
    int index, {
    NoteBlockType type = NoteBlockType.text,
    NoteBlock? copy,
  }) {
    _remember();
    final id = const Uuid().v4();
    final time = DateTime.now().toUtc();
    final block =
        copy?.copyWith(id: id) ??
        NoteBlock(
          id: id,
          pageId: pageId,
          type: type,
          sortOrder: 0,
          createdAt: time,
          updatedAt: time,
        );
    blocks = [...blocks]..insert(index, block);
    _position(index);
    _changed(structural: true);
    return id;
  }

  void remove(String id) {
    if (!blocks.any((b) => b.id == id)) return;
    _remember();
    blocks = blocks.where((b) => b.id != id).toList();
    _changed(structural: true);
  }

  void restoreBlock(NoteBlock value, int index) {
    if (blocks.any((b) => b.id == value.id)) return;
    _remember();
    final target = index.clamp(0, blocks.length);
    blocks = [...blocks]..insert(target, value);
    _position(target);
    _changed(structural: true);
  }

  void move(int from, int to) {
    if (from == to || to < 0 || to >= blocks.length) return;
    _remember();
    blocks = [...blocks];
    blocks.insert(to, blocks.removeAt(from));
    _position(to);
    _changed(structural: true);
  }

  void _position(int index) {
    final before = index == 0
        ? (blocks.length > 1 ? blocks[1].sortOrder - 2048 : 0.0)
        : blocks[index - 1].sortOrder;
    final after = index == blocks.length - 1
        ? before + 2048
        : blocks[index + 1].sortOrder;
    if (after - before > .000001) {
      blocks[index] = blocks[index].copyWith(sortOrder: (before + after) / 2);
    } else {
      blocks = [
        for (var i = 0; i < blocks.length; i++)
          blocks[i].copyWith(sortOrder: (i + 1) * 1024.0),
      ];
    }
  }

  void undo() => _history(_undo, _redo);
  void redo() => _history(_redo, _undo);
  void _history(List<NoteDraft> from, List<NoteDraft> to) {
    if (from.isEmpty) return;
    to.add(_snapshot);
    final snapshot = from.removeLast();
    title = snapshot.title;
    blocks = List.of(snapshot.blocks);
    _changed(structural: true);
  }

  Future<bool> flush() async {
    _timer?.cancel();
    _textBatch = false;
    if (_saving != null) {
      final ok = await _saving!;
      if (!ok) return false;
      if (!dirty) return true;
    }
    if (!dirty) return true;
    final pending = _persist();
    _saving = pending;
    try {
      return await pending;
    } finally {
      if (identical(_saving, pending)) _saving = null;
    }
  }

  Future<bool> _persist() async {
    try {
      while (dirty) {
        final version = _revision;
        await repository.save(pageId, title, List.of(blocks));
        if (version == _revision) dirty = false;
      }
      failed = false;
      _notify();
      return true;
    } catch (error, stack) {
      failed = true;
      _notify();
      logFailure('notes.autosave', error, stack);
      return false;
    }
  }

  Future<String> createTask(String blockId, TaskRepository tasks) async {
    final block = blocks.firstWhere((b) => b.id == blockId);
    if (block.type != NoteBlockType.todo) {
      throw const AppFailure(FailureKind.validation);
    }
    // TaskRepository owns title validation and Inbox defaults. No persistent coupling.
    return tasks.createTask(block.content);
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
