import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme_layer_paint.dart';
import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/session_providers.dart';
import '../application/focus_providers.dart';
import '../domain/focus_session.dart';
import 'focus_labels.dart';
import 'session_setup.dart';

String phaseLabel(SessionType type) => switch (type) {
  SessionType.focus => 'Focus',
  SessionType.shortBreak => 'Short break',
  SessionType.longBreak => 'Long break',
};
String timerLabel(Duration duration) {
  final seconds = (duration.inMilliseconds / 1000).ceil();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(focusSessionProvider);
    if (controller == null) {
      return const Scaffold(body: Center(child: Text('Focus unavailable')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/focus'),
            icon: const Icon(Icons.tune),
            label: const Text('Open mixer'),
          ),
        ],
      ),
      body: ThemeLayerPaint(
        role: ThemeLayerRole.foundation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    final session = controller.session;
                    if (session == null && controller.recoveryFailed) {
                      return TextButton(
                        onPressed: controller.busy ? null : controller.restore,
                        child: const Text(
                          'Could not restore the session. Retry',
                        ),
                      );
                    }
                    if (session == null) {
                      return FilledButton(
                        onPressed: () => showFocusSetup(context),
                        child: const Text('Start Focus'),
                      );
                    }
                    final running =
                        session.completionState == SessionState.running;
                    return Focus(
                      autofocus: true,
                      onKeyEvent: (node, event) {
                        if (node.hasPrimaryFocus &&
                            event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.space &&
                            controller.active &&
                            !controller.busy) {
                          running ? controller.pause() : controller.resume();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            session.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${phaseLabel(session.sessionType)} · ${session.completionState.name}',
                          ),
                          const SizedBox(height: 16),
                          Semantics(
                            label:
                                '${phaseLabel(session.sessionType)}, ${timerLabel(controller.remaining)} remaining',
                            child: ExcludeSemantics(
                              child: FittedBox(
                                child: Text(
                                  timerLabel(controller.remaining),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 88),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ThemeLayerPaint(
                              role: ThemeLayerRole.surface,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: FractionallySizedBox(
                                  widthFactor:
                                      (controller.elapsed.inMilliseconds /
                                              session
                                                  .plannedDuration
                                                  .inMilliseconds)
                                          .clamp(0, 1),
                                  child: const ThemeLayerPaint(
                                    role: ThemeLayerRole.accent,
                                    child: SizedBox(height: 6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('${timerLabel(controller.elapsed)} elapsed'),
                          if (ref.watch(focusPlayerProvider) case final player?)
                            ListenableBuilder(
                              listenable: player,
                              builder: (context, _) => Text(
                                '${player.mix == null ? 'No soundscape' : mixLabel(AppLocalizations.of(context), player.mix!)} · ${player.playing
                                    ? player.muted
                                          ? 'muted'
                                          : 'playing'
                                    : 'audio paused'}',
                              ),
                            ),
                          if (session.completionState ==
                              SessionState.interrupted)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Your session was interrupted. Unmeasured time was not counted. Resume or finish when ready.',
                              ),
                            ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              if (controller.active) ...[
                                FilledButton(
                                  onPressed: controller.busy
                                      ? null
                                      : running
                                      ? controller.pause
                                      : controller.resume,
                                  child: Text(running ? 'Pause' : 'Resume'),
                                ),
                                OutlinedButton(
                                  onPressed: controller.busy
                                      ? null
                                      : controller.finish,
                                  child: const Text('Finish Session'),
                                ),
                                TextButton(
                                  onPressed: controller.busy
                                      ? null
                                      : () =>
                                            controller.finish(cancelled: true),
                                  child: const Text('Cancel session'),
                                ),
                              ] else ...[
                                if (controller.nextType case final next?)
                                  FilledButton(
                                    onPressed: controller.busy
                                        ? null
                                        : controller.next,
                                    child: Text('Start ${phaseLabel(next)}'),
                                  ),
                                OutlinedButton(
                                  onPressed: () => showFocusSetup(context),
                                  child: const Text('New session'),
                                ),
                              ],
                            ],
                          ),
                          if (controller.completedFocus?.linkedTaskId != null)
                            ref
                                .watch(
                                  taskProvider(
                                    controller.completedFocus!.linkedTaskId!,
                                  ),
                                )
                                .when(
                                  data: (task) =>
                                      task == null || task.isCompleted
                                      ? const SizedBox.shrink()
                                      : TextButton(
                                          onPressed: controller.busy
                                              ? null
                                              : controller.completeTask,
                                          child: const Text('Complete Task'),
                                        ),
                                  error: (_, _) =>
                                      const Text('Task unavailable'),
                                  loading: () => const SizedBox.shrink(),
                                ),
                          if (controller.error != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(controller.error!),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                Text(
                  'Local history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ref
                    .watch(focusHistoryProvider)
                    .when(
                      data: (sessions) => Column(
                        children: [
                          if (sessions.isEmpty)
                            const ListTile(
                              title: Text(
                                'Your completed sessions will appear here.',
                              ),
                            ),
                          for (final session in sessions)
                            ListTile(
                              title: Text(session.title),
                              subtitle: Text(
                                '${DateFormat.yMMMd().add_jm().format(session.startedAt.toLocal())} · ${phaseLabel(session.sessionType)} · ${session.completionState.name}',
                              ),
                              trailing: Text(
                                timerLabel(session.actualDuration),
                              ),
                            ),
                        ],
                      ),
                      error: (_, _) => TextButton(
                        onPressed: () => ref.invalidate(focusHistoryProvider),
                        child: const Text('Retry loading history'),
                      ),
                      loading: () => const LinearProgressIndicator(),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
