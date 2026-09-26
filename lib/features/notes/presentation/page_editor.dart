import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../application/note_editor.dart';
import '../domain/note.dart';
import 'block_editor.dart';
import 'block_registry.dart';

class PageEditor extends StatefulWidget {
  const PageEditor({super.key, required this.editor});
  final NoteEditor editor;
  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  late final _title = TextEditingController(text: widget.editor.title);
  final _scroll = ScrollController(), _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _keys = <String, GlobalKey<BlockEditorState>>{};
  bool _finding = false;
  int _match = 0;
  NoteEditor get editor => widget.editor;
  List<NoteBlock> get matches => _search.text.isEmpty
      ? []
      : editor.blocks
            .where(
              (b) => b.searchable.toLowerCase().contains(
                _search.text.toLowerCase(),
              ),
            )
            .toList();
  @override
  void initState() {
    super.initState();
    editor.addListener(_update);
  }

  void _update() {
    if (!mounted) return;
    if (_title.text != editor.title) {
      _title.value = TextEditingValue(
        text: editor.title,
        selection: TextSelection.collapsed(offset: editor.title.length),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    editor.removeListener(_update);
    _title.dispose();
    _scroll.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _focusBlock(String id, {bool end = false}) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    // Walk the lazy viewport until the requested row exists; heights may vary.
    for (
      var attempt = 0;
      attempt < editor.blocks.length + 2 && mounted;
      attempt++
    ) {
      final key = _keys[id];
      if (key?.currentContext != null) {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          alignment: .35,
          duration: const Duration(milliseconds: 100),
        );
        key.currentState?.focus(end: end);
        return;
      }
      if (!_scroll.hasClients) return;
      final target = editor.blocks.indexWhere((b) => b.id == id);
      if (target < 0) return;
      final rendered = [
        for (var i = 0; i < editor.blocks.length; i++)
          if (_keys[editor.blocks[i].id]?.currentContext != null) i,
      ];
      final direction = rendered.isEmpty || target > rendered.last ? 1 : -1;
      final next =
          (_scroll.offset + direction * _scroll.position.viewportDimension * .8)
              .clamp(0.0, _scroll.position.maxScrollExtent);
      if (next == _scroll.offset) return;
      _scroll.jumpTo(next);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _find() {
    setState(() => _finding = true);
    _searchFocus.requestFocus();
  }

  void _closeFind() {
    setState(() {
      _finding = false;
      _search.clear();
    });
  }

  Future<void> _goMatch(int offset) async {
    if (matches.isEmpty) return;
    setState(() => _match = (_match + offset) % matches.length);
    final block = matches[_match];
    if (block.type == NoteBlockType.toggle && !block.expanded) {
      editor.edit(block.copyWith(expanded: true), structural: true);
    }
    await _focusBlock(block.id);
    _keys[block.id]?.currentState?.selectMatch(_search.text);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final results = matches;
    final selected = results.isEmpty
        ? null
        : results[_match.clamp(0, results.length - 1)].id;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): _find,
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            editor.undo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): editor.redo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            editor.redo,
        const SingleActivator(LogicalKeyboardKey.escape): _closeFind,
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    editor.failed
                        ? s.noteSaveFailed
                        : editor.dirty
                        ? s.noteSaving
                        : s.noteSaved,
                    style: TextStyle(
                      color: editor.failed
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (editor.failed)
                  TextButton(onPressed: editor.flush, child: Text(s.retry)),
                IconButton(
                  tooltip: s.undo,
                  onPressed: editor.canUndo ? editor.undo : null,
                  icon: const Icon(Icons.undo),
                ),
                IconButton(
                  tooltip: s.noteRedo,
                  onPressed: editor.canRedo ? editor.redo : null,
                  icon: const Icon(Icons.redo),
                ),
                IconButton(
                  tooltip: s.searchPage,
                  onPressed: _find,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (_finding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(hintText: s.searchPage),
                      onChanged: (_) => setState(() => _match = 0),
                      onSubmitted: (_) => _goMatch(0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${results.isEmpty ? 0 : _match.clamp(0, results.length - 1) + 1} / ${results.length}',
                    ),
                  ),
                  IconButton(
                    tooltip: s.previousMatch,
                    onPressed: results.isEmpty ? null : () => _goMatch(-1),
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: s.nextMatch,
                    onPressed: results.isEmpty ? null : () => _goMatch(1),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  IconButton(
                    tooltip: s.cancel,
                    onPressed: _closeFind,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scroll,
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              header: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextField(
                  key: const ValueKey('note-title'),
                  controller: _title,
                  autofocus: editor.title.isEmpty,
                  maxLength: 500,
                  maxLines: null,
                  style: Theme.of(context).textTheme.headlineLarge,
                  onChanged: editor.rename,
                  decoration: InputDecoration(
                    hintText: s.untitledPage,
                    counterText: '',
                    filled: false,
                    border: InputBorder.none,
                  ),
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PopupMenuButton<NoteBlockType>(
                    tooltip: s.addBlock,
                    onSelected: (type) => _focusBlock(
                      editor.insert(editor.blocks.length, type: type),
                    ),
                    itemBuilder: (_) => [
                      for (final type in NoteBlockType.values)
                        PopupMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon),
                              const SizedBox(width: 12),
                              Text(type.label(s)),
                            ],
                          ),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add),
                          const SizedBox(width: 8),
                          Text(s.addBlock),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              itemCount: editor.blocks.length,
              onReorderItem: editor.move,
              itemBuilder: (_, index) {
                final block = editor.blocks[index];
                var number = 1;
                if (block.type == NoteBlockType.numbered) {
                  for (
                    var i = index - 1;
                    i >= 0 && editor.blocks[i].type == NoteBlockType.numbered;
                    i--
                  ) {
                    number++;
                  }
                }
                return BlockEditor(
                  key: _keys.putIfAbsent(
                    block.id,
                    () => GlobalKey<BlockEditorState>(),
                  ),
                  block: block,
                  editor: editor,
                  index: index,
                  number: number,
                  highlight: _finding && block.id == selected,
                  onFocusBlock: _focusBlock,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
