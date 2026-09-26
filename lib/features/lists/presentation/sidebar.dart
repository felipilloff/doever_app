import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../tasks/domain/task.dart';
import '../domain/task_list.dart';
import '../../notes/application/notes_providers.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({
    super.key,
    required this.view,
    required this.listId,
    required this.onSelect,
  });
  final TaskView view;
  final String listId;
  final void Function(TaskView, String) onSelect;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final lists = ref.watch(listsProvider);
    final repo = ref.read(repositoryProvider);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.sm,
                  vertical: Space.lg,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                    const SizedBox(width: Space.sm),
                    Text(
                      s.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              for (final item in [
                (TaskView.myDay, s.myDay, Icons.wb_sunny_outlined),
                (TaskView.important, s.important, Icons.star_outline_rounded),
                (TaskView.planned, s.planned, Icons.event_outlined),
                (TaskView.list, s.tasks, Icons.inbox_outlined),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: ListTile(
                    leading: Icon(item.$3),
                    title: Text(item.$2),
                    selected:
                        view == item.$1 &&
                        (item.$1 != TaskView.list || listId == inboxId),
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer,
                    onTap: () => onSelect(item.$1, inboxId),
                  ),
                ),
              if (supportsNotes)
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(s.notesLabel),
                  onTap: () => context.push('/notes'),
                ),
              const SizedBox(height: Space.lg),
              Padding(
                padding: const EdgeInsets.all(Space.sm),
                child: Text(
                  s.lists,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Expanded(
                child: lists.when(
                  data: (all) {
                    final custom = all.where((l) => l.id != inboxId).toList();
                    return ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: custom.length,
                      onReorderItem: (old, target) {
                        final order = [...custom];
                        final moved = order.removeAt(old);
                        order.insert(target, moved);
                        perform(
                          context,
                          () => repo.reorderList(
                            moved.id,
                            beforeId: target + 1 < order.length
                                ? order[target + 1].id
                                : null,
                            afterId: target > 0 ? order[target - 1].id : null,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final list = custom[index];
                        return ListTile(
                          key: ValueKey(list.id),
                          selected: view == TaskView.list && listId == list.id,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          leading: ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_indicator,
                              semanticLabel: s.reorder,
                            ),
                          ),
                          title: Text(
                            list.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(s.taskCount(list.taskCount)),
                          trailing: PopupMenuButton<String>(
                            tooltip: s.settings,
                            onSelected: (action) async {
                              if (action == 'rename') {
                                final name = await askText(
                                  context,
                                  title: s.renameList,
                                  initial: list.name,
                                );
                                if (name != null && context.mounted) {
                                  await perform(
                                    context,
                                    () => repo.renameList(list.id, name),
                                  );
                                }
                              } else if (action == 'delete') {
                                final yes = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(s.deleteList),
                                    content: Text(s.deleteListMessage),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(s.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(s.delete),
                                      ),
                                    ],
                                  ),
                                );
                                if (yes == true && context.mounted) {
                                  final ok = await perform(
                                    context,
                                    () => repo.deleteList(list.id),
                                  );
                                  if (ok) onSelect(TaskView.list, inboxId);
                                }
                              } else {
                                final target = action == 'up'
                                    ? index - 1
                                    : index + 1;
                                await _move(
                                  context,
                                  ref,
                                  custom,
                                  index,
                                  target,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(s.rename),
                              ),
                              if (index > 0)
                                PopupMenuItem(
                                  value: 'up',
                                  child: Text(s.moveUp),
                                ),
                              if (index < custom.length - 1)
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
                          onTap: () => onSelect(TaskView.list, list.id),
                        );
                      },
                    );
                  },
                  error: (_, _) => Text(s.loadError),
                  loading: () => const SizedBox.shrink(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(s.newList),
                onTap: () async {
                  final name = await askText(context, title: s.newList);
                  if (name != null && context.mounted) {
                    await perform(context, () async {
                      final id = await repo.createList(name);
                      onSelect(TaskView.list, id);
                    });
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(s.settings),
                onTap: () => context.push('/settings'),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.sm),
                child: Text(
                  s.allLocal,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    List<TaskList> lists,
    int from,
    int to,
  ) async {
    final order = [...lists];
    final moved = order.removeAt(from);
    order.insert(to, moved);
    await perform(
      context,
      () => ref
          .read(repositoryProvider)
          .reorderList(
            moved.id,
            beforeId: to + 1 < order.length ? order[to + 1].id : null,
            afterId: to > 0 ? order[to - 1].id : null,
          ),
    );
  }
}
