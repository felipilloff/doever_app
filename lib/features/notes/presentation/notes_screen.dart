import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../application/note_editor.dart';
import '../application/notes_providers.dart';
import '../domain/note.dart';
import 'page_editor.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});
  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();
  String _query = '';
  NoteEditor? _editor;
  bool _busy = false;
  late final AppLifecycleListener _lifecycle;
  late final NoteLeaveGuard _guard;
  @override
  void initState() {
    super.initState();
    _guard = ref.read(noteLeaveGuardProvider)..save = _flush;
    _lifecycle = AppLifecycleListener(
      onInactive: () => unawaited(_flush()),
      onExitRequested: () async =>
          await _flush() ? AppExitResponse.exit : AppExitResponse.cancel,
    );
  }

  Future<bool> _flush() async => await _editor?.flush() ?? true;
  @override
  void dispose() {
    _guard.save = null;
    _lifecycle.dispose();
    _editor?.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(String id) async {
    if (_busy || _editor?.pageId == id) {
      _scaffold.currentState?.closeDrawer();
      return;
    }
    setState(() => _busy = true);
    if (!await _flush()) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (!mounted) return;
    await perform(context, () async {
      final document = await ref.read(noteRepositoryProvider).load(id);
      if (!mounted) return;
      _editor?.dispose();
      setState(
        () => _editor = NoteEditor(ref.read(noteRepositoryProvider), document),
      );
      _scaffold.currentState?.closeDrawer();
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _create() async {
    if (_busy || !await _flush() || !mounted) return;
    setState(() => _busy = true);
    String? id;
    await perform(context, () async {
      id = (await ref.read(noteRepositoryProvider).createPage()).id;
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _query = '';
      _search.clear();
    });
    if (id != null) await _open(id!);
  }

  Future<void> _delete(NotePage page) async {
    if (_busy || !await _flush() || !mounted) return;
    final s = AppLocalizations.of(context);
    final repo = ref.read(noteRepositoryProvider);
    final ok = await perform(context, () => repo.deletePage(page.id));
    if (!ok || !mounted) return;
    if (_editor?.pageId == page.id) {
      _editor?.dispose();
      setState(() => _editor = null);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.pageDeleted),
        action: SnackBarAction(
          label: s.undo,
          onPressed: () => perform(context, () => repo.restorePage(page.id)),
        ),
      ),
    );
  }

  Widget _navigation() {
    final s = AppLocalizations.of(context);
    final pages = ref.watch(notePagesProvider(_query));
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: s.searchPages,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _create,
                icon: const Icon(Icons.add),
                label: Text(s.newPage),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: pages.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(child: Text(s.loadError)),
                  data: (items) => ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    onReorderItem: (from, to) {
                      if (_query.isEmpty) {
                        perform(
                          context,
                          () => ref
                              .read(noteRepositoryProvider)
                              .movePage(items[from].id, to),
                        );
                      }
                    },
                    itemBuilder: (_, index) {
                      final page = items[index];
                      return ListTile(
                        key: ValueKey(page.id),
                        selected: _editor?.pageId == page.id,
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        leading: _query.isEmpty
                            ? ReorderableDragStartListener(
                                index: index,
                                child: Icon(
                                  Icons.drag_indicator,
                                  semanticLabel: s.reorder,
                                ),
                              )
                            : const Icon(Icons.description_outlined),
                        title: Text(
                          page.title.trim().isEmpty
                              ? s.untitledPage
                              : page.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _open(page.id),
                        trailing: PopupMenuButton<String>(
                          tooltip: s.settings,
                          onSelected: (action) {
                            if (action == 'delete') {
                              _delete(page);
                            } else {
                              perform(
                                context,
                                () => ref
                                    .read(noteRepositoryProvider)
                                    .movePage(
                                      page.id,
                                      index + (action == 'up' ? -1 : 1),
                                    ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            if (_query.isEmpty && index > 0)
                              PopupMenuItem(value: 'up', child: Text(s.moveUp)),
                            if (_query.isEmpty && index < items.length - 1)
                              PopupMenuItem(
                                value: 'down',
                                child: Text(s.moveDown),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(s.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(s.allLocal, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final hasPages =
        ref.watch(notePagesProvider('')).asData?.value.isNotEmpty ?? false;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _create,
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= Layout.medium;
          return Scaffold(
            key: _scaffold,
            appBar: AppBar(
              leading: IconButton(
                tooltip: s.tasks,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              title: Text(s.notesLabel),
              actions: [
                if (!wide)
                  IconButton(
                    tooltip: s.openNavigation,
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffold.currentState?.openDrawer(),
                  ),
              ],
            ),
            drawer: wide ? null : Drawer(child: _navigation()),
            body: Row(
              children: [
                if (wide) SizedBox(width: 280, child: _navigation()),
                Expanded(
                  child: _editor == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 44,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  hasPages ? s.noteChoosePage : s.noNotes,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _busy ? null : _create,
                                  icon: const Icon(Icons.add),
                                  label: Text(s.newPage),
                                ),
                              ],
                            ),
                          ),
                        )
                      : PageEditor(
                          key: ValueKey(_editor!.pageId),
                          editor: _editor!,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
