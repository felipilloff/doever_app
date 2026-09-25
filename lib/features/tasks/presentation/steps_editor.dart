import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/doever_theme.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/task.dart';

class StepsEditor extends ConsumerStatefulWidget {
  const StepsEditor({super.key, required this.taskId});
  final String taskId;
  @override
  ConsumerState<StepsEditor> createState() => _StepsEditorState();
}

class _StepsEditorState extends ConsumerState<StepsEditor> {
  final _text = TextEditingController();
  bool _adding = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_adding || _text.text.trim().isEmpty) return;
    setState(() => _adding = true);
    final ok = await perform(
      context,
      () => ref.read(repositoryProvider).addStep(widget.taskId, _text.text),
    );
    if (mounted) {
      setState(() => _adding = false);
      if (ok) _text.clear();
    }
  }

  Future<void> _move(List<TaskStep> steps, int from, int to) async {
    final order = [...steps];
    final moved = order.removeAt(from);
    order.insert(to, moved);
    await perform(
      context,
      () => ref
          .read(repositoryProvider)
          .reorderStep(
            moved.id,
            beforeId: to + 1 < order.length ? order[to + 1].id : null,
            afterId: to > 0 ? order[to - 1].id : null,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final repo = ref.read(repositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.steps, style: Theme.of(context).textTheme.titleSmall),
        ref
            .watch(stepsProvider(widget.taskId))
            .when(
              data: (steps) => ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: steps.length,
                onReorderItem: (old, target) {
                  _move(steps, old, target);
                },
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return ListTile(
                    key: ValueKey(step.id),
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: step.isCompleted,
                      semanticLabel:
                          '${step.isCompleted ? s.uncompleteStep : s.completeStep}: ${step.title}',
                      onChanged: (v) => perform(
                        context,
                        () => repo.updateStep(step.id, completed: v),
                      ),
                    ),
                    title: Text(
                      step.title,
                      style: TextStyle(
                        decoration: step.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    onTap: () async {
                      final name = await askText(
                        context,
                        title: s.renameStep,
                        initial: step.title,
                        maxLength: 500,
                      );
                      if (name != null && context.mounted) {
                        await perform(
                          context,
                          () => repo.updateStep(step.id, title: name),
                        );
                      }
                    },
                    trailing: PopupMenuButton<String>(
                      tooltip: s.settings,
                      onSelected: (action) {
                        if (action == 'delete') {
                          perform(context, () => repo.deleteStep(step.id));
                        } else {
                          _move(
                            steps,
                            index,
                            action == 'up' ? index - 1 : index + 1,
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        if (index > 0)
                          PopupMenuItem(value: 'up', child: Text(s.moveUp)),
                        if (index < steps.length - 1)
                          PopupMenuItem(value: 'down', child: Text(s.moveDown)),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(s.deleteStep),
                        ),
                      ],
                    ),
                  );
                },
              ),
              error: (_, _) => Text(s.loadError),
              loading: () => const SizedBox.shrink(),
            ),
        const SizedBox(height: Space.sm),
        TextField(
          controller: _text,
          maxLength: 500,
          enabled: !_adding,
          onSubmitted: (_) => _add(),
          decoration: InputDecoration(
            counterText: '',
            hintText: s.addStep,
            suffixIcon: IconButton(
              tooltip: s.addStep,
              onPressed: _add,
              icon: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
