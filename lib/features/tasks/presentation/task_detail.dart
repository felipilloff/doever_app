import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/calendar_date.dart';
import '../domain/recurrence.dart';
import '../domain/task.dart';
import 'editable_text.dart';
import 'steps_editor.dart';

class TaskDetail extends ConsumerWidget {
  const TaskDetail({super.key, required this.id, this.onClose});
  final String id;
  final VoidCallback? onClose;
  void _close(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Row(
                children: [
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      s.taskDetails,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: s.closeDetails,
                    onPressed: () => _close(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ref
                  .watch(taskProvider(id))
                  .when(
                    data: (task) => task == null
                        ? Center(child: Text(s.taskUnavailable))
                        : _content(context, ref, task),
                    error: (_, _) => Center(child: Text(s.loadError)),
                    loading: () => const SizedBox.shrink(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, Task task) {
    final s = AppLocalizations.of(context);
    final repo = ref.read(repositoryProvider);
    final today = ref.watch(todayProvider);
    final lists = ref.watch(listsProvider).asData?.value ?? [];
    void patch(TaskPatch patch) {
      perform(context, () => repo.updateTask(id, patch));
    }

    final inDay = task.myDayDate == today;
    return ListView(
      padding: const EdgeInsets.all(Space.md),
      children: [
        Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              semanticLabel: task.isCompleted
                  ? s.uncompleteTask
                  : s.completeTask,
              onChanged: (v) =>
                  perform(context, () => repo.completeTask(id, v!)),
            ),
            Expanded(
              child: Text(
                task.isCompleted ? s.completed : s.taskTitle,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            IconButton(
              tooltip: task.isImportant ? s.unmarkImportant : s.markImportant,
              onPressed: () => patch(TaskPatch(isImportant: !task.isImportant)),
              icon: Icon(
                task.isImportant
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
              ),
            ),
          ],
        ),
        SavedTextField(
          key: ValueKey('title-$id'),
          value: task.title,
          label: s.taskTitle,
          onSave: (v) => repo.updateTask(id, TaskPatch(title: v)),
        ),
        const SizedBox(height: Space.md),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.wb_sunny_outlined),
          title: Text(inDay ? s.removeFromMyDay : s.addToMyDay),
          trailing: inDay ? const Icon(Icons.check) : null,
          onTap: () =>
              patch(TaskPatch(myDayDate: Change(inDay ? null : today))),
        ),
        const Divider(height: Space.lg),
        StepsEditor(taskId: id),
        const Divider(height: Space.xl),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(
            task.dueDate == null
                ? s.dueDate
                : s.dueOn(
                    DateFormat.yMMMd(s.localeName).format(task.dueDate!.value),
                  ),
          ),
          trailing: task.dueDate == null
              ? null
              : IconButton(
                  tooltip: s.removeDate,
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      patch(const TaskPatch(dueDate: Change(null))),
                ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: task.dueDate?.local ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(9999),
            );
            if (date != null) {
              patch(TaskPatch(dueDate: Change(CalendarDate.fromLocal(date))));
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_none_rounded),
          title: Text(
            task.reminderAt == null
                ? s.reminder
                : s.remindOn(
                    DateFormat.yMMMd(s.localeName)
                        .add_jm()
                        .format(task.reminderAt!.toLocal()),
                  ),
          ),
          subtitle: !ref.read(remindersProvider).supported
              ? Text(s.remindersUnsupported)
              : null,
          trailing: task.reminderAt == null
              ? null
              : IconButton(
                  tooltip: s.removeReminder,
                  icon: const Icon(Icons.close),
                  onPressed: () => perform(
                    context,
                    () => ref.read(actionsProvider).setReminder(id, null),
                  ),
                ),
          onTap: ref.read(remindersProvider).supported
              ? () => _reminder(context, ref)
              : null,
        ),
        const SizedBox(height: Space.sm),
        DropdownButtonFormField<String>(
          initialValue: task.recurrenceRule ?? '',
          isExpanded: true,
          decoration: InputDecoration(
            labelText: s.repeat,
            prefixIcon: const Icon(Icons.repeat),
          ),
          items: [
            DropdownMenuItem(value: '', child: Text(s.never)),
            for (final recurrence in Recurrence.values)
              DropdownMenuItem(
                value: recurrence.rule,
                child: Text(switch (recurrence) {
                  Recurrence.daily => s.daily,
                  Recurrence.weekdays => s.weekdays,
                  Recurrence.weekly => s.weekly,
                  Recurrence.monthly => s.monthly,
                  Recurrence.yearly => s.yearly,
                }),
              ),
          ],
          onChanged: (v) =>
              patch(TaskPatch(recurrenceRule: Change(v == '' ? null : v))),
        ),
        if (task.recurrenceRule != null)
          Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Text(
              s.recurrenceHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: Space.md),
        if (lists.any((l) => l.id == task.listId))
          DropdownButtonFormField<String>(
            key: ValueKey('list-${task.listId}'),
            initialValue: task.listId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: s.moveTo,
              prefixIcon: const Icon(Icons.folder_outlined),
            ),
            items: lists
                .map(
                  (l) => DropdownMenuItem(
                    value: l.id,
                    child: Text(
                      l.id == inboxId ? s.tasks : l.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) patch(TaskPatch(listId: v));
            },
          ),
        const SizedBox(height: Space.lg),
        SavedTextField(
          key: ValueKey('notes-$id'),
          value: task.notes,
          label: s.notes,
          multiline: true,
          maxLength: 100000,
          onSave: (v) => repo.updateTask(id, TaskPatch(notes: v)),
        ),
        const SizedBox(height: Space.lg),
        TextButton.icon(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final ok = await perform(context, () => repo.deleteTask(id));
            if (ok && context.mounted) {
              _close(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(s.taskDeleted),
                  action: SnackBarAction(
                    label: s.undo,
                    onPressed: () =>
                        perform(messenger.context, () => repo.restoreTask(id)),
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: Text(s.deleteTask),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Future<void> _reminder(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(9999),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || !context.mounted) return;
    await perform(
      context,
      () => ref
          .read(actionsProvider)
          .setReminder(
            id,
            DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            ).toUtc(),
          ),
    );
  }
}
