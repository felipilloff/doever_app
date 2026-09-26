import 'dart:io';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../core/errors.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../application/note_editor.dart';
import '../data/note_images.dart';
import '../domain/note.dart';
import 'block_registry.dart';

class BlockEditor extends ConsumerStatefulWidget {
  const BlockEditor({
    super.key,
    required this.block,
    required this.editor,
    required this.index,
    required this.number,
    required this.onFocusBlock,
    this.highlight = false,
  });
  final NoteBlock block;
  final NoteEditor editor;
  final int index, number;
  final bool highlight;
  final void Function(String id, {bool end}) onFocusBlock;
  @override
  ConsumerState<BlockEditor> createState() => BlockEditorState();
}

class BlockEditorState extends ConsumerState<BlockEditor> {
  late final _text = TextEditingController(text: widget.block.content);
  late final _detail = TextEditingController(text: widget.block.detail);
  final _focus = FocusNode();
  final _rowFocus = FocusNode();
  final _menuScroll = ScrollController();
  bool _hover = false,
      _focused = false,
      _slashClosed = false,
      _importing = false;
  int _command = 0;
  Future<File>? _image;
  NoteBlock get block => widget.editor.blocks.firstWhere(
    (b) => b.id == widget.block.id,
    orElse: () => widget.block,
  );
  List<NoteBlockType> get _commands =>
      _slashClosed ||
          !_text.text.startsWith('/') ||
          _text.text.contains('\n') ||
          block.type != NoteBlockType.text
      ? []
      : NoteBlockType.values
            .where(
              (t) => t.matches(
                _text.text.substring(1),
                AppLocalizations.of(context),
              ),
            )
            .toList();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    _image = widget.block.imageName.isEmpty
        ? null
        : ref.read(noteImagesProvider).file(widget.block.imageName);
  }

  @override
  void didUpdateWidget(covariant BlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_text.text != widget.block.content) {
      _text.value = TextEditingValue(
        text: widget.block.content,
        selection: TextSelection.collapsed(offset: widget.block.content.length),
      );
    }
    if (_detail.text != widget.block.detail) _detail.text = widget.block.detail;
    if (oldWidget.block.imageName != widget.block.imageName) _loadImage();
  }

  @override
  void dispose() {
    _text.dispose();
    _detail.dispose();
    _focus.dispose();
    _rowFocus.dispose();
    _menuScroll.dispose();
    super.dispose();
  }

  void focus({bool end = false}) {
    if (block.type == NoteBlockType.divider) {
      _rowFocus.requestFocus();
      return;
    }
    _focus.requestFocus();
    _text.selection = TextSelection.collapsed(
      offset: end ? _text.text.length : 0,
    );
  }

  void selectMatch(String query) {
    focus();
    final offset = _text.text.toLowerCase().indexOf(query.toLowerCase());
    if (offset >= 0) {
      _text.selection = TextSelection(
        baseOffset: offset,
        extentOffset: offset + query.length,
      );
    }
  }

  void _change(String text) {
    final shortcut =
        block.type == NoteBlockType.text && !_text.value.composing.isValid
        ? markdownBlock(text)
        : null;
    if (shortcut != null) {
      _text.clear();
      widget.editor.edit(
        block.copyWith(type: shortcut, content: ''),
        structural: true,
      );
      return;
    }
    widget.editor.edit(block.copyWith(content: text));
    if (text.startsWith('/') ||
        _slashClosed ||
        block.type == NoteBlockType.code) {
      setState(() {
        _slashClosed = false;
        _command = 0;
      });
    }
  }

  void _next() {
    if (block.type.isList && _text.text.isEmpty) {
      widget.editor.edit(block.convert(NoteBlockType.text), structural: true);
      return;
    }
    final id = widget.editor.insert(
      widget.index + 1,
      type: block.type.isList ? block.type : NoteBlockType.text,
    );
    widget.onFocusBlock(id);
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final commands = _commands;
    if (_focus.hasFocus && commands.isNotEmpty) {
      if (key == LogicalKeyboardKey.escape) {
        setState(() => _slashClosed = true);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowUp) {
        setState(
          () => _command =
              (_command + (key == LogicalKeyboardKey.arrowDown ? 1 : -1)) %
              commands.length,
        );
        if (_menuScroll.hasClients) {
          _menuScroll.jumpTo(
            (_command * 48.0 - 96).clamp(
              0,
              _menuScroll.position.maxScrollExtent,
            ),
          );
        }
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.enter) {
        _choose(commands[_command.clamp(0, commands.length - 1)]);
        return KeyEventResult.handled;
      }
    }
    if (_focus.hasFocus &&
        key == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed &&
        !_text.value.composing.isValid &&
        _text.selection.isCollapsed &&
        _text.selection.end == _text.text.length &&
        block.type != NoteBlockType.code) {
      _next();
      return KeyEventResult.handled;
    }
    if (_focus.hasFocus &&
        key == LogicalKeyboardKey.backspace &&
        _text.text.isEmpty &&
        block.detail.isEmpty &&
        block.url.isEmpty &&
        block.imageName.isEmpty &&
        widget.index > 0) {
      final previous = widget.editor.blocks[widget.index - 1].id;
      widget.editor.remove(block.id);
      widget.onFocusBlock(previous, end: true);
      return KeyEventResult.handled;
    }
    if (_focus.hasFocus &&
        _text.selection.isCollapsed &&
        ((key == LogicalKeyboardKey.arrowUp && _text.selection.start == 0) ||
            (key == LogicalKeyboardKey.arrowDown &&
                _text.selection.end == _text.text.length))) {
      final target =
          widget.index + (key == LogicalKeyboardKey.arrowUp ? -1 : 1);
      if (target >= 0 && target < widget.editor.blocks.length) {
        widget.onFocusBlock(
          widget.editor.blocks[target].id,
          end: key == LogicalKeyboardKey.arrowUp,
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _choose(NoteBlockType type) async {
    setState(() => _slashClosed = true);
    widget.editor.edit(
      block.copyWith(type: type, content: ''),
      structural: true,
    );
    _text.clear();
    _focus.requestFocus();
    if (type == NoteBlockType.image) await _pickImage();
    if (type == NoteBlockType.link && mounted) await _editUrl();
  }

  Future<void> _pickImage() async {
    if (_importing) return;
    setState(() => _importing = true);
    await perform(context, () async {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Images',
            extensions: ['png', 'jpg', 'jpeg', 'webp'],
          ),
        ],
      );
      if (file == null || !mounted) return;
      final name = await ref.read(noteImagesProvider).import(file);
      if (mounted) {
        widget.editor.edit(block.copyWith(imageName: name), structural: true);
      }
    });
    if (mounted) setState(() => _importing = false);
  }

  Future<void> _editUrl() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _UrlDialog(initial: block.url),
    );
    if (value != null && mounted) {
      widget.editor.edit(block.copyWith(url: value), structural: true);
    }
    if (mounted) _focus.requestFocus();
  }

  Future<void> _action(String action) async {
    final editor = widget.editor;
    final s = AppLocalizations.of(context);
    switch (action) {
      case 'duplicate':
        widget.onFocusBlock(editor.insert(widget.index + 1, copy: block));
      case 'up':
        editor.move(widget.index, widget.index - 1);
      case 'down':
        editor.move(widget.index, widget.index + 1);
      case 'delete':
        final removed = block;
        final removedIndex = widget.index;
        final target = editor.blocks.length > 1
            ? editor.blocks[widget.index > 0 ? widget.index - 1 : 1].id
            : null;
        editor.remove(block.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.blockDeleted),
            action: SnackBarAction(
              label: s.undo,
              onPressed: () => editor.restoreBlock(removed, removedIndex),
            ),
          ),
        );
        if (target != null) widget.onFocusBlock(target);
      case 'clearIcon':
        widget.editor.edit(block.copyWith(icon: ''), structural: true);
      case 'task':
        final ok = await perform(context, () async {
          await editor.createTask(block.id, ref.read(repositoryProvider));
        });
        if (ok && mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.noteTaskCreated)));
        }
      default:
        editor.edit(
          block.convert(NoteBlockType.values.byName(action)),
          structural: true,
        );
        _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final b = block;
    final commands = _commands;
    final style = switch (b.type) {
      NoteBlockType.heading1 => Theme.of(context).textTheme.headlineMedium,
      NoteBlockType.heading2 => Theme.of(context).textTheme.headlineSmall,
      NoteBlockType.heading3 => Theme.of(context).textTheme.titleLarge,
      NoteBlockType.code => TextStyle(
        fontFamily: 'DoeverMono',
        fontSize: 14,
        color: colors.onSurface,
      ),
      _ => Theme.of(context).textTheme.bodyLarge,
    };
    Widget textField = TextField(
      key: ValueKey('block-text-${b.id}'),
      controller: _text,
      focusNode: _focus,
      style: style,
      maxLines: null,
      maxLength: 1000000,
      onChanged: _change,
      decoration: InputDecoration(
        hintText: b.type == NoteBlockType.text ? s.noteHint : b.type.label(s),
        counterText: '',
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
    if (b.type == NoteBlockType.code) {
      textField = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(
              constraints.maxWidth,
              _text.text
                          .split('\n')
                          .fold<int>(0, (n, line) => math.max(n, line.length)) *
                      8.5 +
                  40,
            ),
            child: TextField(
              key: ValueKey('block-text-${b.id}'),
              controller: _text,
              focusNode: _focus,
              style: style,
              maxLines: null,
              maxLength: 1000000,
              onChanged: _change,
              decoration: InputDecoration(
                hintText: s.noteCode,
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      );
    }
    Widget content = switch (b.type) {
      NoteBlockType.divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(),
      ),
      NoteBlockType.todo => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: b.checked,
            semanticLabel: s.noteTodo,
            onChanged: (v) => widget.editor.edit(
              block.copyWith(checked: v),
              structural: true,
            ),
          ),
          Expanded(child: textField),
        ],
      ),
      NoteBlockType.bullet || NoteBlockType.numbered => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 13, left: 8),
            child: Text(
              b.type == NoteBlockType.bullet ? '•' : '${widget.number}.',
            ),
          ),
          Expanded(child: textField),
        ],
      ),
      NoteBlockType.quote => Container(
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: colors.primary, width: 3),
          ),
        ),
        child: textField,
      ),
      NoteBlockType.callout => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: s.noteIcon,
              icon: b.icon.isEmpty
                  ? const Icon(Icons.info_outline)
                  : Text(b.icon),
              onPressed: () async {
                final icon = await askText(
                  context,
                  title: s.noteIcon,
                  initial: b.icon,
                  maxLength: 32,
                );
                if (icon != null && mounted) {
                  widget.editor.edit(
                    block.copyWith(icon: icon),
                    structural: true,
                  );
                }
              },
            ),
            Expanded(child: textField),
          ],
        ),
      ),
      NoteBlockType.image => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_image != null)
            FutureBuilder<File>(
              future: _image,
              builder: (_, snapshot) => snapshot.hasData
                  ? Image.file(
                      snapshot.data!,
                      height: 280,
                      fit: BoxFit.contain,
                      cacheWidth: 1280,
                      errorBuilder: (_, _, _) => Text(s.noteImageError),
                      semanticLabel: b.content,
                    )
                  : Text(snapshot.hasError ? s.noteImageError : s.noteSaving),
            ),
          TextButton.icon(
            onPressed: _importing ? null : _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(s.noteImage),
          ),
          textField,
        ],
      ),
      NoteBlockType.link => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField,
          Wrap(
            children: [
              TextButton(
                onPressed: _editUrl,
                child: Text(b.url.isEmpty ? s.noteUrl : b.url),
              ),
              IconButton(
                tooltip: s.noteOpenLink,
                icon: const Icon(Icons.open_in_new),
                onPressed: validNoteUrl(b.url)
                    ? () => perform(context, () async {
                        if (!await launchUrl(
                          Uri.parse(b.url),
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw const AppFailure(FailureKind.unexpected);
                        }
                      })
                    : null,
              ),
            ],
          ),
        ],
      ),
      NoteBlockType.toggle => Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: s.noteToggle,
                icon: Icon(
                  b.expanded ? Icons.expand_more : Icons.chevron_right,
                ),
                onPressed: () => widget.editor.edit(
                  block.copyWith(expanded: !block.expanded),
                  structural: true,
                ),
              ),
              Expanded(child: textField),
            ],
          ),
          if (b.expanded)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 40),
              child: TextField(
                key: ValueKey('block-detail-${b.id}'),
                controller: _detail,
                maxLines: null,
                maxLength: 1000000,
                decoration: InputDecoration(
                  hintText: s.noteToggleBody,
                  counterText: '',
                ),
                onChanged: (v) => widget.editor.edit(block.copyWith(detail: v)),
              ),
            ),
        ],
      ),
      _ => textField,
    };
    if (b.type == NoteBlockType.code) {
      content = Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Focus(
        focusNode: _rowFocus,
        onKeyEvent: _key,
        onFocusChange: (value) => setState(() => _focused = value),
        child: Semantics(
          container: true,
          label: b.type.label(s),
          child: Container(
            decoration: BoxDecoration(
              color: widget.highlight ? colors.secondaryContainer : null,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: _hover || _focused ? 1 : .35,
                  child: ReorderableDragStartListener(
                    index: widget.index,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 18,
                        semanticLabel: s.reorder,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      content,
                      if (_focused && commands.isNotEmpty)
                        Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(12),
                          color: colors.surfaceContainer,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 240),
                            child: ListView(
                              controller: _menuScroll,
                              shrinkWrap: true,
                              children: [
                                for (var i = 0; i < commands.length; i++)
                                  ListTile(
                                    dense: true,
                                    selected: i == _command,
                                    leading: Icon(commands[i].icon),
                                    title: Text(commands[i].label(s)),
                                    onTap: () => _choose(commands[i]),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: s.blockActions,
                  icon: Icon(
                    Icons.more_horiz,
                    color: (_hover || _focused)
                        ? colors.onSurface
                        : colors.outline,
                  ),
                  onSelected: _action,
                  itemBuilder: (_) => [
                    if (b.type.canConvert) ...[
                      PopupMenuItem(enabled: false, child: Text(s.changeBlock)),
                      for (final type in NoteBlockType.values.where(
                        (t) => t.canConvert && t != b.type,
                      ))
                        PopupMenuItem(
                          value: type.name,
                          child: Text(type.label(s)),
                        ),
                      const PopupMenuDivider(),
                    ],
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(s.duplicateBlock),
                    ),
                    if (widget.index > 0)
                      PopupMenuItem(value: 'up', child: Text(s.moveUp)),
                    if (widget.index < widget.editor.blocks.length - 1)
                      PopupMenuItem(value: 'down', child: Text(s.moveDown)),
                    if (b.type == NoteBlockType.callout && b.icon.isNotEmpty)
                      PopupMenuItem(
                        value: 'clearIcon',
                        child: Text('${s.delete}: ${s.noteIcon}'),
                      ),
                    if (b.type == NoteBlockType.todo)
                      PopupMenuItem(
                        value: 'task',
                        child: Text(s.createNoteTask),
                      ),
                    PopupMenuItem(value: 'delete', child: Text(s.delete)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UrlDialog extends StatefulWidget {
  const _UrlDialog({required this.initial});
  final String initial;
  @override
  State<_UrlDialog> createState() => _UrlDialogState();
}

class _UrlDialogState extends State<_UrlDialog> {
  late final controller = TextEditingController(text: widget.initial);
  bool invalid = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final value = controller.text.trim();
    if (value.isEmpty || validNoteUrl(value)) {
      Navigator.pop(context, value);
    } else {
      setState(() => invalid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(s.noteUrl),
      content: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(
          errorText: invalid ? s.noteInvalidUrl : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(onPressed: submit, child: Text(s.confirm)),
      ],
    );
  }
}
