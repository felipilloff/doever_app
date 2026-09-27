import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

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
import 'theme_labels.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_draft != null) _updateName();
  }

  void _updateName() {
    final name = themeDisplayName(
      _draft!.current,
      AppLocalizations.of(context),
    );
    if (_name.text != name) _name.text = name;
  }

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
    _updateName();
    _newUnsaved = false;
    _keepContrast = false;
    if (_previewInApp) _syncPreview();
  }

  void _changed() {
    if (!mounted) return;
    _updateName();
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
        title: Text(AppLocalizations.of(context).themeUnsaved),
        content: Text(AppLocalizations.of(context).themeLeavePrompt),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _LeaveChoice.continueEditing),
            child: Text(AppLocalizations.of(context).themeContinueEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.discard),
            child: Text(AppLocalizations.of(context).themeDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.apply),
            child: Text(AppLocalizations.of(context).themeApply),
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
      _error(AppLocalizations.of(context).themeNameInvalid);
      return false;
    }
    setState(() => _busy = true);
    try {
      final saved = await ref
          .read(themeActionsProvider)
          .apply(
            draft.current,
            modified: draft.isDirty,
            copyName: _copyName(draft.current),
          );
      if (!mounted) return true;
      draft.markSaved(saved);
      _newUnsaved = false;
      try {
        await ref.read(themeActionsProvider).rememberColors(_allColors(saved));
      } catch (error, stack) {
        logFailure('theme.recent_colors', error, stack);
      }
      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).themeApplied)),
      );
      return true;
    } catch (error, stack) {
      logFailure('theme.apply', error, stack);
      if (mounted) {
        _error(AppLocalizations.of(context).themeApplyFailed);
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
          name: AppLocalizations.of(context).themeUntitled,
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
      title: AppLocalizations.of(context).themeRename,
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
      final copy = await ref
          .read(themeActionsProvider)
          .duplicate(target, name: _copyName(target));
      if (mounted) setState(() => _install(copy));
    });
  }

  Future<void> _delete(CustomTheme theme) async {
    if (_draft?.current.id == theme.id && !await _confirmLeave()) return;
    if (!mounted) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).themeDeleteTitle(
            themeDisplayName(theme, AppLocalizations.of(context)),
          ),
        ),
        content: Text(AppLocalizations.of(context).themeDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).delete),
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
    final s = AppLocalizations.of(context);
    await _run('import', () async {
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: AppLocalizations.of(context).themeFile,
            extensions: ['json'],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > ThemeCodec.maxFileBytes) {
        if (mounted) _error(s.themeFileTooLarge);
        return;
      }
      final theme = await ref
          .read(themeActionsProvider)
          .importTheme(await file.readAsString());
      if (mounted) setState(() => _install(theme));
    }, message: AppLocalizations.of(context).themeFileInvalid);
  }

  Future<void> _export() async {
    final theme = _draft?.current;
    if (theme == null) return;
    await _run('export', () async {
      final location = await getSaveLocation(
        suggestedName: '${_safeName(theme.name)}.doever-theme.json',
        acceptedTypeGroups: [
          XTypeGroup(
            label: AppLocalizations.of(context).themeFile,
            extensions: ['json'],
          ),
        ],
      );
      if (location == null) return;
      await XFile.fromData(
        Uint8List.fromList(utf8.encode(ThemeCodec.encode(theme))),
        mimeType: 'application/json',
      ).saveTo(location.path);
    }, message: AppLocalizations.of(context).themeExportFailed);
  }

  Future<void> _run(
    String operation,
    Future<void> Function() action, {
    String? message,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error, stack) {
      logFailure('theme.$operation', error, stack);
      if (mounted) {
        _error(message ?? AppLocalizations.of(context).themeSaveFailed);
      }
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
            tooltip: AppLocalizations.of(context).themeBack,
            onPressed: _cancel,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).themeStudio),
              Text(
                AppLocalizations.of(context).themeStudioSubtitle,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: AppLocalizations.of(context).undo,
              onPressed: !_busy && draft.canUndo ? draft.undo : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).themeRedo,
              onPressed: !_busy && draft.canRedo ? draft.redo : null,
              icon: const Icon(Icons.redo),
            ),
            const SizedBox(width: Space.sm),
            TextButton(
              onPressed: _busy ? null : _cancel,
              child: Text(AppLocalizations.of(context).cancel),
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
              label: Text(AppLocalizations.of(context).themeApply),
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
          title: Text(AppLocalizations.of(context).themeThemes),
          subtitle: Text(
            themeDisplayName(draft.current, AppLocalizations.of(context)),
          ),
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
                AppLocalizations.of(context).themeLivePreview,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context).themePreviewHint,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).themePreviewInApp),
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
                    ? AppLocalizations.of(context).themeContrastGood
                    : AppLocalizations.of(context).themeContrastProtected,
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
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).themeName,
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
              label: Text(AppLocalizations.of(context).themeReset),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Text(
          AppLocalizations.of(context).themeMode,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: Space.sm),
        SegmentedButton<ThemeBrightnessMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: ThemeBrightnessMode.light,
              label: Text(AppLocalizations.of(context).lightTheme),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeBrightnessMode.dark,
              label: Text(AppLocalizations.of(context).darkTheme),
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
          title: Text(AppLocalizations.of(context).themeAutoBalance),
          subtitle: Text(
            AppLocalizations.of(context).themeAutoBalanceDescription,
          ),
          value: theme.autoBalance,
          onChanged: (value) =>
              draft.update(theme.copyWith(autoBalance: value)),
        ),
        const SizedBox(height: Space.md),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: 0,
              label: Text(AppLocalizations.of(context).themeFoundation),
            ),
            ButtonSegment(
              value: 1,
              label: Text(AppLocalizations.of(context).themeSurface),
            ),
            ButtonSegment(
              value: 2,
              label: Text(AppLocalizations.of(context).themeAccent),
            ),
          ],
          selected: {_layer},
          onSelectionChanged: (value) => setState(() => _layer = value.single),
        ),
        const SizedBox(height: Space.md),
        ThemeLayerEditor(
          key: ValueKey('${theme.id}:$_layer'),
          title: [
            AppLocalizations.of(context).themeFoundation,
            AppLocalizations.of(context).themeSurface,
            AppLocalizations.of(context).themeAccent,
          ][_layer],
          description: [
            AppLocalizations.of(context).themeFoundationDescription,
            AppLocalizations.of(context).themeSurfaceDescription,
            AppLocalizations.of(context).themeAccentDescription,
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

  String _copyName(CustomTheme theme) {
    final s = AppLocalizations.of(context);
    final name = s.themeCopyName(themeDisplayName(theme, s));
    return name.substring(0, name.length.clamp(0, 200));
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
  final List<ThemeContrastWarning> warnings;
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
                  AppLocalizations.of(context).themeLowContrast,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(
            warnings
                .map(
                  (warning) =>
                      themeWarningText(warning, AppLocalizations.of(context)),
                )
                .toSet()
                .join(' '),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context).themeBalanceContrast),
            value: autoBalance,
            onChanged: onAutoBalance,
          ),
          Wrap(
            spacing: Space.sm,
            children: [
              FilledButton(
                onPressed: autoBalance ? null : onFix,
                child: Text(
                  autoBalance
                      ? AppLocalizations.of(context).themeBalanced
                      : AppLocalizations.of(context).themeFix,
                ),
              ),
              TextButton(
                onPressed: onKeep,
                child: Text(AppLocalizations.of(context).themeKeep),
              ),
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
