import '../../../app/theme/doever_theme.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/theme_layer_paint.dart';
import '../../../l10n/app_localizations.dart';
import '../../tasks/domain/task.dart';
import '../application/focus_providers.dart';
import '../application/session_providers.dart';
import '../domain/focus_session.dart';
import '../domain/soundscape.dart';
import 'focus_labels.dart';

Future<void> showFocusSetup(BuildContext context, {Task? task}) async {
  final container = ProviderScope.containerOf(context);
  if (!supportsFocus || container.read(focusSessionProvider) == null) return;
  final router = GoRouter.of(context);
  if ((container.read(focusSessionProvider)!.active ||
      container.read(focusSessionProvider)!.recoveryFailed)) {
    await router.push<void>('/focus/session');
    return;
  }
  final started = await showDialog<bool>(
    context: context,
    builder: (_) => SessionSetup(task: task),
  );
  if (started == true && context.mounted) {
    await router.push<void>('/focus/session');
  }
}

class SessionSetup extends ConsumerStatefulWidget {
  const SessionSetup({super.key, this.task});
  final Task? task;
  @override
  ConsumerState<SessionSetup> createState() => _SessionSetupState();
}

class _SessionSetupState extends ConsumerState<SessionSetup> {
  final _form = GlobalKey<FormState>();
  final _label = TextEditingController();
  late final TextEditingController _duration, _short, _long, _interval;
  TimerMode _mode = TimerMode.simple;
  Task? _task;
  String _search = '';
  String? _mixId;
  bool _autoShort = false,
      _autoLong = false,
      _autoFocus = false,
      _notifications = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _task = widget.task;
    final prefs = ref.read(preferencesProvider);
    var config = const PomodoroConfig();
    try {
      final saved = prefs.getString('focus.session.config');
      if (saved != null) {
        config = PomodoroConfig.fromJson(
          jsonDecode(saved) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      /* Invalid preferences use the safe defaults. */
    }
    _duration = TextEditingController(text: '${config.focusMinutes}');
    _short = TextEditingController(text: '${config.shortMinutes}');
    _long = TextEditingController(text: '${config.longMinutes}');
    _interval = TextEditingController(text: '${config.interval}');
    _autoShort = config.autoShort;
    _autoLong = config.autoLong;
    _autoFocus = config.autoFocus;
    _notifications = config.notifications;
    _mixId = prefs.getString('focus.session.soundscape');
  }

  @override
  void dispose() {
    for (final c in [_label, _duration, _short, _long, _interval]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _number(
    String label,
    TextEditingController controller, {
    int max = 180,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        return n == null || n < 1 || n > max ? 'Enter 1–$max' : null;
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(focusSessionProvider)!;
    final mixes = [
      ...focusPresets,
      ...?ref.watch(customSoundscapesProvider).asData?.value,
    ];
    final selected = mixes.where((m) => m.id == _mixId).firstOrNull;
    final results = ref.watch(
      tasksProvider(
        TaskQuery(
          view: TaskView.search,
          search: _search,
          today: ref.watch(todayProvider),
          showCompleted: false,
        ),
      ),
    );
    final strings = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Layout.radius),
          child: ThemeLayerPaint(
            role: ThemeLayerRole.surface,
            child: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Start Focus',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (_task != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_task!.title),
                          trailing: IconButton(
                            tooltip: 'Focus without task',
                            onPressed: () => setState(() => _task = null),
                            icon: const Icon(Icons.close),
                          ),
                        )
                      else ...[
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search active tasks',
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                        results.when(
                          data: (tasks) {
                            final sorted = [...tasks]
                              ..sort((a, b) {
                                final day = ref.read(todayProvider);
                                int rank(Task t) => t.isInMyDay(day)
                                    ? 0
                                    : t.isImportant
                                    ? 1
                                    : 2;
                                return rank(a).compareTo(rank(b));
                              });
                            return Column(
                              children: [
                                for (final t in sorted.take(3))
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      t.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => setState(() => _task = t),
                                  ),
                              ],
                            );
                          },
                          error: (_, _) => const Text('Could not load tasks.'),
                          loading: () => const LinearProgressIndicator(),
                        ),
                        TextField(
                          controller: _label,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Focus without task — optional label',
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SegmentedButton<TimerMode>(
                        segments: const [
                          ButtonSegment(
                            value: TimerMode.simple,
                            label: Text('Simple timer'),
                          ),
                          ButtonSegment(
                            value: TimerMode.pomodoro,
                            label: Text('Pomodoro'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (v) =>
                            setState(() => _mode = v.first),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final minutes in [15, 25, 45, 60, 90])
                            ActionChip(
                              label: Text('$minutes min'),
                              onPressed: () => _duration.text = '$minutes',
                            ),
                        ],
                      ),
                      _number('Focus minutes', _duration),
                      if (_mode == TimerMode.pomodoro) ...[
                        _number('Short break minutes', _short),
                        _number('Long break minutes', _long),
                        _number(
                          'Focus blocks before long break',
                          _interval,
                          max: 12,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Auto-start short breaks'),
                          value: _autoShort,
                          onChanged: (v) => setState(() => _autoShort = v!),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Auto-start long breaks'),
                          value: _autoLong,
                          onChanged: (v) => setState(() => _autoLong = v!),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Auto-start next Focus'),
                          value: _autoFocus,
                          onChanged: (v) => setState(() => _autoFocus = v!),
                        ),
                      ],
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: ValueKey(selected?.id),
                        initialValue: selected?.id ?? '',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Soundscape',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Keep audio as it is'),
                          ),
                          for (final mix in mixes)
                            DropdownMenuItem(
                              value: mix.id,
                              child: Text(mixLabel(strings, mix)),
                            ),
                        ],
                        onChanged: (v) => setState(() => _mixId = v),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Completion notification'),
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v!),
                      ),
                      const Text(
                        'Timer pauses keep ambience playing. Breaks reuse the current soundscape.',
                      ),
                      if (_error != null || controller.error != null)
                        Text(_error ?? controller.error!),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: controller.busy
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(strings.cancel),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: controller.busy
                                ? null
                                : () async {
                                    if (!_form.currentState!.validate()) return;
                                    final config = PomodoroConfig(
                                      focusMinutes: int.parse(_duration.text),
                                      shortMinutes: int.parse(_short.text),
                                      longMinutes: int.parse(_long.text),
                                      interval: int.parse(_interval.text),
                                      autoShort: _autoShort,
                                      autoLong: _autoLong,
                                      autoFocus: _autoFocus,
                                      notifications: _notifications,
                                    );
                                    try {
                                      final prefs = ref.read(
                                        preferencesProvider,
                                      );
                                      await prefs.setString(
                                        'focus.session.config',
                                        jsonEncode(config.toJson()),
                                      );
                                      await prefs.setString(
                                        'focus.session.soundscape',
                                        selected?.id ?? '',
                                      );
                                      await controller.start(
                                        duration: config.duration(
                                          SessionType.focus,
                                        ),
                                        taskId: _task?.id,
                                        label: _label.text,
                                        soundscape: selected,
                                        mode: _mode,
                                        config: config,
                                      );
                                      if (context.mounted &&
                                          controller.active) {
                                        Navigator.pop(context, true);
                                      }
                                    } catch (_) {
                                      if (mounted) {
                                        setState(
                                          () => _error = 'Could not save settings. Please retry.',
                                        );
                                      }
                                    }
                                  },
                            child: const Text('Start'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
