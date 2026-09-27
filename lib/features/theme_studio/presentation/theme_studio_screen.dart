import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/doever_theme.dart';
import '../../../app/theme/theme_generator.dart';
import '../../../core/logging.dart';
import '../../../core/widgets/feedback.dart';
import '../application/theme_draft.dart';
import '../application/theme_providers.dart';
import '../data/theme_codec.dart';
import '../domain/custom_theme.dart';
import '../domain/theme_presets.dart';
import 'theme_gallery.dart';
import 'theme_layer_editor.dart';
import 'theme_preview.dart';

class ThemeStudioScreen extends ConsumerStatefulWidget {
  const ThemeStudioScreen({super.key});

  @override
  ConsumerState<ThemeStudioScreen> createState() => _ThemeStudioScreenState();
}

class _ThemeStudioScreenState extends ConsumerState<ThemeStudioScreen>
    with WidgetsBindingObserver {
  ThemeDraft? _draft;
  final _name = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _newUnsaved = false;
  int _layer = 0;
  bool _previewInApp = false, _busy = false, _keepContrast = false;
  late final Future<bool> Function() _leaveCheck;
  late final ThemePreview _previewController;
  late final ThemeLeaveGuard _guard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _previewController = ref.read(themePreviewProvider.notifier);
    _guard = ref.read(themeLeaveGuardProvider);
    _leaveCheck = () => _confirmLeave(leaving: true);
    _guard.check = _leaveCheck;
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _confirmLeave(leaving: true)
      ? AppExitResponse.exit
      : AppExitResponse.cancel;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_guard.check == _leaveCheck) _guard.check = null;
    final lastPreview = _previewInApp ? _draft?.current : null;
    scheduleMicrotask(() => _previewController.clearIfCurrent(lastPreview));
    _draft?.removeListener(_changed);
    _draft?.dispose();
    _name.dispose();
    super.dispose();
  }

  void _install(CustomTheme theme) {
    _draft?.removeListener(_changed);
    _draft?.dispose();
    _draft = ThemeDraft(theme)..addListener(_changed);
    _name.text = theme.name;
    _newUnsaved = false;
    _keepContrast = false;
    if (_previewInApp) _syncPreview();
  }

  void _changed() {
    if (!mounted) return;
    if (_name.text != _draft!.current.name) _name.text = _draft!.current.name;
    _keepContrast = false;
    _syncPreview();
    setState(() {});
  }

  void _syncPreview() =>
      _previewController.set(_previewInApp ? _draft?.current : null);

  Future<bool> _confirmLeave({bool leaving = false}) async {
    if (_busy) return false;
    final draft = _draft;
    if (draft == null || (!draft.isDirty && !_newUnsaved)) {
      if (leaving) _previewController.set(null);
      return true;
    }
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved theme changes'),
        content: const Text('Apply your changes before leaving Theme Studio?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _LeaveChoice.continueEditing),
            child: const Text('Continue editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.discard),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.apply),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (choice == _LeaveChoice.apply) {
      final saved = await _apply();
      if (saved && leaving) _previewController.set(null);
      return saved;
    }
    if (choice == _LeaveChoice.discard) {
      draft.reset();
      _newUnsaved = false;
      if (leaving) _previewController.set(null);
      return true;
    }
    return false;
  }

  Future<bool> _apply() async {
    final draft = _draft;
    if (draft == null || _busy) return false;
    if (!(_form.currentState?.validate() ?? true)) return false;
    if (draft.current.name.trim().isEmpty ||
        draft.current.name.trim().length > 200) {
      _error('Give this theme a name of 1–200 characters.');
      return false;
    }
    setState(() => _busy = true);
    try {
      final saved = await ref
          .read(themeActionsProvider)
          .apply(draft.current, modified: draft.isDirty);
      if (!mounted) return true;
      draft.markSaved(saved);
      _newUnsaved = false;
      try {
        await ref.read(themeActionsProvider).rememberColors(_allColors(saved));
      } catch (error, stack) {
        logFailure('theme.recent_colors', error, stack);
      }
      if (!mounted) return true;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Theme applied')));
      return true;
    } catch (error, stack) {
      logFailure('theme.apply', error, stack);
      if (mounted) {
        _error('Couldn’t apply this theme. Your changes are still here.');
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _select(CustomTheme theme) async {
    if (_draft?.current.id == theme.id) return;
    if (!await _confirmLeave() || !mounted) return;
    setState(() => _install(theme));
  }

  Future<void> _newTheme() async {
    if (!await _confirmLeave() || !mounted) return;
    final source = _draft?.current ?? themePresets.first;
    final now = DateTime.now().toUtc();
    setState(() {
      _install(
        source.copyWith(
          id: const Uuid().v4(),
          name: 'Untitled theme',
          createdAt: now,
          updatedAt: now,
        ),
      );
      _newUnsaved = true;
    });
  }

  Future<void> _rename(CustomTheme theme) async {
    final current = _draft?.current.id == theme.id;
    if (current && !await _confirmLeave()) return;
    if (!mounted) return;
    final target = current ? _draft!.current : theme;
    final value = await askText(
      context,
      title: 'Rename theme',
      initial: target.name,
    );
    final name = value?.trim();
    if (name == null || name.isEmpty || name == target.name) return;
    await _run('rename', () async {
      final renamed = await ref.read(themeActionsProvider).rename(target, name);
      if (mounted && _draft?.current.id == target.id) {
        setState(() => _install(renamed));
      }
    });
  }

  Future<void> _duplicate(CustomTheme theme) async {
    final current = _draft?.current.id == theme.id;
    if (!await _confirmLeave() || !mounted) return;
    final target = current ? _draft!.current : theme;
    await _run('duplicate', () async {
      final copy = await ref.read(themeActionsProvider).duplicate(target);
      if (mounted) setState(() => _install(copy));
    });
  }

  Future<void> _delete(CustomTheme theme) async {
    if (_draft?.current.id == theme.id && !await _confirmLeave()) return;
    if (!mounted) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete “${theme.name}”?'),
        content: const Text('This saved theme will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await _run('delete', () async {
      await ref.read(themeActionsProvider).delete(theme.id);
      if (mounted && _draft?.current.id == theme.id) {
        setState(() => _install(themePresets.first));
      }
    });
  }

  Future<void> _import() async {
    if (!await _confirmLeave() || !mounted) return;
    await _run('import', () async {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Doever theme', extensions: ['json']),
        ],
      );
      if (file == null) return;
      if (await file.length() > ThemeCodec.maxFileBytes) {
        _error('That theme file is too large. Choose a file under 64 KB.');
        return;
      }
      final theme = await ref
          .read(themeActionsProvider)
          .importTheme(await file.readAsString());
      if (mounted) setState(() => _install(theme));
    }, message: 'That file isn’t a valid Doever theme.');
  }

  Future<void> _export() async {
    final theme = _draft?.current;
    if (theme == null) return;
    await _run('export', () async {
      final location = await getSaveLocation(
        suggestedName: '${_safeName(theme.name)}.doever-theme.json',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Doever theme', extensions: ['json']),
        ],
      );
      if (location == null) return;
      await XFile.fromData(
        Uint8List.fromList(utf8.encode(ThemeCodec.encode(theme))),
        mimeType: 'application/json',
      ).saveTo(location.path);
    }, message: 'Couldn’t export this theme.');
  }

  Future<void> _run(
    String operation,
    Future<void> Function() action, {
    String message = 'Couldn’t save that change. Please try again.',
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error, stack) {
      logFailure('theme.$operation', error, stack);
      if (mounted) _error(message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _error(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final libraryValue = ref.watch(themeLibraryProvider);
    final ThemeLibrary library =
        libraryValue.asData?.value ??
        ref.watch<ThemeLibrary>(initialThemeLibraryProvider);
    if (_draft == null) {
      final all = [...themePresets, ...library.themes];
      _install(
        all.where((theme) => theme.id == library.activeId).firstOrNull ??
            themePresets.first,
      );
    }
    final draft = _draft!;
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent || _editingText()) {
          return KeyEventResult.ignored;
        }
        final keyboard = HardwareKeyboard.instance;
        if (!keyboard.isControlPressed && !keyboard.isMetaPressed) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          keyboard.isShiftPressed ? _redo() : _undo();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyY) {
          _redo();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back to settings',
            onPressed: _cancel,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Studio'),
              Text(
                'Make Doever feel like yours',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Undo',
              onPressed: !_busy && draft.canUndo ? draft.undo : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Redo',
              onPressed: !_busy && draft.canRedo ? draft.redo : null,
              icon: const Icon(Icons.redo),
            ),
            const SizedBox(width: Space.sm),
            TextButton(
              onPressed: _busy ? null : _cancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: Space.sm),
            FilledButton.icon(
              onPressed: _busy ? null : _apply,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text('Apply'),
            ),
            const SizedBox(width: Space.md),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _busy,
          child: ExcludeFocus(
            excluding: _busy,
            child: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 1120
                  ? _wide(library, draft)
                  : _narrow(library, draft),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wide(ThemeLibrary library, ThemeDraft draft) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        width: 270,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.md),
          child: _gallery(library, draft),
        ),
      ),
      const VerticalDivider(width: 1),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Form(key: _form, child: _controls(library, draft)),
            ),
          ),
        ),
      ),
      const VerticalDivider(width: 1),
      SizedBox(
        width: 430,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.lg),
          child: _preview(draft),
        ),
      ),
    ],
  );

  Widget _narrow(ThemeLibrary library, ThemeDraft draft) => ListView(
    padding: const EdgeInsets.all(Space.md),
    children: [
      Card(
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          title: const Text('Themes'),
          subtitle: Text(draft.current.name),
          leading: const Icon(Icons.palette_outlined),
          childrenPadding: const EdgeInsets.all(Space.md),
          children: [_gallery(library, draft)],
        ),
      ),
      const SizedBox(height: Space.md),
      _preview(draft),
      const SizedBox(height: Space.lg),
      Form(key: _form, child: _controls(library, draft)),
    ],
  );

  Widget _gallery(ThemeLibrary library, ThemeDraft draft) => ThemeGallery(
    presets: themePresets,
    saved: library.themes,
    selectedId: draft.current.id,
    activeId: library.activeId,
    onSelect: _select,
    onNew: _newTheme,
    onRename: _rename,
    onDuplicate: _duplicate,
    onDelete: _delete,
    onImport: _import,
    onExport: _export,
  );

  Widget _preview(ThemeDraft draft) {
    final palette = ThemeGenerator.generate(draft.current);
    final warnings = palette.warnings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Live preview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Tooltip(
              message: 'Preview changes throughout Doever before applying',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Preview in app'),
                  Switch(
                    value: _previewInApp,
                    onChanged: (value) => setState(() {
                      _previewInApp = value;
                      _syncPreview();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        ThemeStudioPreview(theme: draft.current),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            const Icon(Icons.verified_outlined, size: 16),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                warnings.isEmpty
                    ? 'Contrast · Good'
                    : 'Contrast · Readability protected',
              ),
            ),
          ],
        ),
        if (warnings.isNotEmpty && !_keepContrast) ...[
          const SizedBox(height: Space.md),
          _ContrastWarning(
            warnings: warnings,
            autoBalance: draft.current.autoBalance,
            onAutoBalance: (value) =>
                draft.update(draft.current.copyWith(autoBalance: value)),
            onFix: () =>
                draft.update(draft.current.copyWith(autoBalance: true)),
            onKeep: () {
              draft.update(draft.current.copyWith(autoBalance: false));
              setState(() => _keepContrast = true);
            },
          ),
        ],
      ],
    );
  }

  Widget _controls(ThemeLibrary library, ThemeDraft draft) {
    final theme = draft.current;
    final layer = [theme.foundation, theme.surface, theme.accent][_layer];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('theme-name'),
                controller: _name,
                maxLength: 200,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: const InputDecoration(
                  hintText: 'Theme name',
                  counterText: '',
                  isDense: true,
                ),
                onChanged: (value) =>
                    draft.update(draft.current.copyWith(name: value)),
              ),
            ),
            TextButton.icon(
              onPressed: draft.isDirty ? draft.reset : null,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset theme'),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Text('Mode', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: Space.sm),
        SegmentedButton<ThemeBrightnessMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeBrightnessMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeBrightnessMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {theme.baseMode},
          onSelectionChanged: (value) =>
              draft.update(theme.copyWith(baseMode: value.single)),
        ),
        const SizedBox(height: Space.lg),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto Balance'),
          subtitle: const Text(
            'Keep layers distinct and comfortably readable.',
          ),
          value: theme.autoBalance,
          onChanged: (value) =>
              draft.update(theme.copyWith(autoBalance: value)),
        ),
        const SizedBox(height: Space.md),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 0, label: Text('Foundation')),
            ButtonSegment(value: 1, label: Text('Surface')),
            ButtonSegment(value: 2, label: Text('Accent')),
          ],
          selected: {_layer},
          onSelectionChanged: (value) => setState(() => _layer = value.single),
        ),
        const SizedBox(height: Space.md),
        ThemeLayerEditor(
          key: ValueKey('${theme.id}:$_layer'),
          title: const ['Foundation', 'Surface', 'Accent'][_layer],
          description: const [
            'The workspace background and overall atmosphere.',
            'Cards, panels, inputs, and elevated content.',
            'Actions, focus, selection, and personality.',
          ][_layer],
          index: _layer,
          layer: layer,
          draft: draft,
          recentColors: library.recentColors,
          onChanged: (value, {coalesce = false}) =>
              draft.update(switch (_layer) {
                0 => theme.copyWith(foundation: value),
                1 => theme.copyWith(surface: value),
                _ => theme.copyWith(accent: value),
              }, coalesce: coalesce),
        ),
      ],
    );
  }

  void _undo() {
    if (!_busy && !_editingText()) _draft?.undo();
  }

  void _redo() {
    if (!_busy && !_editingText()) _draft?.redo();
  }

  bool _editingText() {
    final focused = FocusManager.instance.primaryFocus?.context;
    return focused?.widget is EditableText ||
        focused?.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  Future<void> _cancel() async {
    if (await _confirmLeave(leaving: true) && mounted) context.pop();
  }
}

class _ContrastWarning extends StatelessWidget {
  const _ContrastWarning({
    required this.warnings,
    required this.autoBalance,
    required this.onAutoBalance,
    required this.onFix,
    required this.onKeep,
  });
  final List<String> warnings;
  final bool autoBalance;
  final ValueChanged<bool> onAutoBalance;
  final VoidCallback onFix, onKeep;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(Layout.radius),
    child: Padding(
      padding: const EdgeInsets.all(Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contrast),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  'Low contrast in selected colors',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(
            warnings.join(' '),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto balance contrast'),
            value: autoBalance,
            onChanged: onAutoBalance,
          ),
          Wrap(
            spacing: Space.sm,
            children: [
              FilledButton(
                onPressed: autoBalance ? null : onFix,
                child: Text(
                  autoBalance ? 'Balanced automatically' : 'Fix automatically',
                ),
              ),
              TextButton(onPressed: onKeep, child: const Text('Keep anyway')),
            ],
          ),
        ],
      ),
    ),
  );
}

enum _LeaveChoice { apply, discard, continueEditing }

List<int> _allColors(CustomTheme theme) => [
  ...theme.foundation.colors,
  ...theme.surface.colors,
  ...theme.accent.colors,
];

String _safeName(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');
