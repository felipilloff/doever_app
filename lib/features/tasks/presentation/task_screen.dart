import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../lists/presentation/sidebar.dart';
import '../../settings/background/background_canvas.dart';
import '../../settings/background/background_preference.dart';
import '../domain/task.dart';
import 'task_detail.dart';
import 'task_tile.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});
  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with WidgetsBindingObserver {
  TaskView _view = TaskView.myDay;
  String _listId = inboxId;
  String? _selected;
  bool _searching = false, _creating = false;
  final _title = TextEditingController(), _search = TextEditingController();
  final _addFocus = FocusNode(), _searchFocus = FocusNode();
  final _scaffold = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(todayProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _title.dispose();
    _search.dispose();
    _addFocus.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _select(TaskView view, String listId) {
    if (!mounted) return;
    setState(() {
      _view = view;
      _listId = listId;
      _searching = false;
      _search.clear();
      _selected = null;
    });
    _scaffold.currentState?.closeDrawer();
  }

  void _openSearch() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  Future<void> _create() async {
    if (_creating || _title.text.trim().isEmpty) return;
    setState(() => _creating = true);
    final today = ref.read(todayProvider);
    final text = _title.text;
    final ok = await perform(context, () async {
      await ref
          .read(repositoryProvider)
          .createTask(
            text,
            listId: _view == TaskView.list ? _listId : inboxId,
            patch: TaskPatch(
              myDayDate: _view == TaskView.myDay ? Change(today) : null,
              isImportant: _view == TaskView.important ? true : null,
              dueDate: _view == TaskView.planned ? Change(today) : null,
            ),
          );
    });
    if (mounted) {
      setState(() => _creating = false);
      if (ok) _title.clear();
      _addFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final background = ref.watch(backgroundProvider).asData?.value;
    final today = ref.watch(todayProvider);
    final lists = ref.watch(listsProvider).asData?.value ?? [];
    final query = TaskQuery(
      view: _searching ? TaskView.search : _view,
      listId: _listId,
      search: _search.text,
      today: today,
      showCompleted: ref.watch(completedPreferenceProvider),
    );
    final tasks = ref.watch(tasksProvider(query));
    final title = _searching
        ? s.search
        : switch (_view) {
            TaskView.myDay => s.myDay,
            TaskView.important => s.important,
            TaskView.planned => s.planned,
            TaskView.search => s.search,
            TaskView.list =>
              _listId == inboxId
                  ? s.tasks
                  : lists.where((l) => l.id == _listId).firstOrNull?.name ??
                        s.tasks,
          };
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Layout.medium;
        final expanded = constraints.maxWidth >= Layout.expanded;
        void open(Task task) {
          if (expanded) {
            setState(() => _selected = task.id);
          } else {
            context.push('/task/${task.id}');
          }
        }

        final sidebar = Sidebar(
          view: _view,
          listId: _listId,
          onSelect: _select,
        );
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                _addFocus.requestFocus,
            const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
                _addFocus.requestFocus,
            const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                _openSearch,
            const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
                _openSearch,
            const SingleActivator(LogicalKeyboardKey.escape): () {
              setState(() {
                _selected = null;
                _searching = false;
                _search.clear();
              });
              _addFocus.requestFocus();
            },
          },
          child: Scaffold(
            key: _scaffold,
            drawer: wide ? null : Drawer(child: sidebar),
            body: SafeArea(
              child: Row(
                children: [
                  if (wide) SizedBox(width: Layout.sidebar, child: sidebar),
                  Expanded(
                    child: BackgroundCanvas(
                      image: background,
                      child: Padding(
                        padding: EdgeInsets.all(wide ? Space.xl : Space.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!wide)
                                  IconButton(
                                    color: background == null
                                        ? null
                                        : Colors.white,
                                    tooltip: s.openNavigation,
                                    onPressed: () =>
                                        _scaffold.currentState?.openDrawer(),
                                    icon: const Icon(Icons.menu),
                                  ),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: background == null
                                              ? null
                                              : Colors.white,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  color: background == null
                                      ? null
                                      : Colors.white,
                                  tooltip: s.searchShortcutHint,
                                  onPressed: _openSearch,
                                  icon: const Icon(Icons.search),
                                ),
                              ],
                            ),
                            const SizedBox(height: Space.sm),
                            Text(
                              _view == TaskView.myDay && !_searching
                                  ? DateFormat.yMMMMEEEEd(s.localeName)
                                        .format(today.value)
                                  : s.tagline,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: background == null
                                        ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                        : Colors.white,
                                  ),
                            ),
                            const SizedBox(height: Space.lg),
                            if (_searching)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: Space.md,
                                ),
                                child: TextField(
                                  controller: _search,
                                  focusNode: _searchFocus,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: s.searchHint,
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: IconButton(
                                      tooltip: s.clearSearch,
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _search.clear();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: tasks.when(
                                skipLoadingOnReload: true,
                                data: (items) => items.isEmpty
                                    ? _empty(context, background != null)
                                    : ListView.builder(
                                        itemCount: items.length,
                                        itemBuilder: (context, index) =>
                                            TaskTile(
                                              key: ValueKey(items[index].id),
                                              task: items[index],
                                              selected:
                                                  _selected == items[index].id,
                                              onOpen: () => open(items[index]),
                                            ),
                                      ),
                                error: (_, _) => Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(s.loadError),
                                      TextButton(
                                        onPressed: () => ref.invalidate(
                                          tasksProvider(query),
                                        ),
                                        child: Text(s.retry),
                                      ),
                                    ],
                                  ),
                                ),
                                loading: () => const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: Space.md),
                            TextField(
                              key: const ValueKey('add-task'),
                              controller: _title,
                              focusNode: _addFocus,
                              maxLength: 500,
                              enabled: !_creating,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _create(),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: s.addTask,
                                prefixIcon: const Icon(Icons.add),
                                suffixIcon: IconButton(
                                  tooltip: s.addTask,
                                  onPressed: _create,
                                  icon: const Icon(Icons.arrow_upward_rounded),
                                ),
                              ),
                            ),
                            if (wide)
                              Padding(
                                padding: const EdgeInsets.only(top: Space.sm),
                                child: Text(
                                  s.quickAddHint,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: background == null
                                            ? null
                                            : Colors.white,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (expanded && _selected != null)
                    SizedBox(
                      width: Layout.details,
                      child: TaskDetail(
                        key: ValueKey(_selected),
                        id: _selected!,
                        onClose: () => setState(() => _selected = null),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context, bool hasBackground) {
    final s = AppLocalizations.of(context);
    final (title, hint, icon) = _searching
        ? (s.emptySearch, s.emptySearchHint, Icons.search)
        : switch (_view) {
            TaskView.myDay => (
              s.emptyDay,
              s.emptyDayHint,
              Icons.wb_sunny_outlined,
            ),
            TaskView.important => (
              s.emptyImportant,
              s.emptyImportantHint,
              Icons.star_outline_rounded,
            ),
            TaskView.planned => (
              s.emptyPlanned,
              s.emptyPlannedHint,
              Icons.event_outlined,
            ),
            _ => (
              s.emptyTasks,
              s.emptyTasksHint,
              Icons.check_circle_outline_rounded,
            ),
          };
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: hasBackground
              ? const BoxConstraints(maxWidth: 440)
              : null,
          decoration: hasBackground
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(Layout.radius),
                )
              : null,
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(Space.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: Space.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: Space.sm),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
