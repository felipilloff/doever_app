import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/task.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onOpen,
    this.selected = false,
  });
  final Task task;
  final VoidCallback onOpen;
  final bool selected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final repo = ref.read(repositoryProvider);
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: Space.sm),
      color: selected ? colors.secondaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.xs,
        ),
        leading: Tooltip(
          message: task.isCompleted ? s.uncompleteTask : s.completeTask,
          child: Checkbox(
            shape: const CircleBorder(),
            value: task.isCompleted,
            semanticLabel:
                '${task.isCompleted ? s.uncompleteTask : s.completeTask}: ${task.title}',
            onChanged: (v) =>
                perform(context, () => repo.completeTask(task.id, v!)),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? colors.onSurfaceVariant
                : colors.onSurface,
          ),
        ),
        subtitle:
            task.dueDate != null ||
                task.notes.isNotEmpty ||
                task.recurrenceRule != null
            ? Padding(
                padding: const EdgeInsets.only(top: Space.xs),
                child: Wrap(
                  spacing: Space.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (task.dueDate != null)
                      Text(
                        s.dueOn(
                          DateFormat.MMMd(s.localeName)
                              .format(task.dueDate!.value),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (task.notes.isNotEmpty)
                      Icon(
                        Icons.notes_outlined,
                        size: 16,
                        semanticLabel: s.notes,
                      ),
                    if (task.recurrenceRule != null)
                      Icon(Icons.repeat, size: 16, semanticLabel: s.repeat),
                  ],
                ),
              )
            : null,
        trailing: IconButton(
          tooltip: task.isImportant ? s.unmarkImportant : s.markImportant,
          icon: Icon(
            task.isImportant ? Icons.star_rounded : Icons.star_outline_rounded,
            color: task.isImportant ? colors.primary : colors.onSurfaceVariant,
          ),
          onPressed: () => perform(
            context,
            () => repo.updateTask(
              task.id,
              TaskPatch(isImportant: !task.isImportant),
            ),
          ),
        ),
        onTap: onOpen,
      ),
    );
  }
}
