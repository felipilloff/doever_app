import 'package:go_router/go_router.dart';

import '../application/session_providers.dart';
import 'session_setup.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_layer_paint.dart';
import '../../../core/widgets/feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../application/focus_player.dart';
import '../application/focus_providers.dart';
import '../domain/soundscape.dart';
import 'focus_controls.dart';
import 'focus_labels.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final player = ref.watch(focusPlayerProvider);
    final library = ref.watch(customSoundscapesProvider);
    if (player == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.focusLabel)),
        body: Center(child: Text(s.focusLoadError)),
      );
    }
    return ListenableBuilder(
      listenable: player,
      builder: (context, _) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent ||
              player.busy ||
              FocusManager.instance.primaryFocus?.context
                      ?.findAncestorWidgetOfExactType<EditableText>() !=
                  null ||
              FocusManager.instance.primaryFocus?.context?.widget
                  is EditableText) {
            return KeyEventResult.ignored;
          }
          // Only the page's bare focus handles Space; buttons/sliders keep their
          // native activation and arrow-key behavior.
          if (node.hasPrimaryFocus &&
              event.logicalKey == LogicalKeyboardKey.space) {
            player.togglePlayback();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyM &&
              !HardwareKeyboard.instance.isControlPressed) {
            player.toggleMute();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(s.focusLabel),
            actions: [
              if (ref.watch(focusSessionProvider) != null) ...[
                TextButton.icon(
                  onPressed: () => showFocusSetup(context),
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Start Focus'),
                ),
                TextButton(
                  onPressed: () => context.push('/focus/session'),
                  child: const Text('Sessions'),
                ),
              ],
              TextButton.icon(
                onPressed: player.busy
                    ? null
                    : () => _name(context, player, create: true),
                icon: const Icon(Icons.add),
                label: Text(s.focusNew),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: ThemeLayerPaint(
            role: ThemeLayerRole.foundation,
            child: LayoutBuilder(
              builder: (context, size) => SingleChildScrollView(
                padding: EdgeInsets.all(size.maxWidth > 800 ? 32 : 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.focusTagline,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(s.focusLocal),
                        const SizedBox(height: 28),
                        if (player.failure != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(Icons.error_outline),
                                const SizedBox(width: 8),
                                Text(
                                  player.failure == FocusFailure.audio
                                      ? s.focusAudioError
                                      : player.failure == FocusFailure.load
                                      ? s.focusLoadError
                                      : s.focusStorageError,
                                ),
                                TextButton(
                                  onPressed: player.busy
                                      ? null
                                      : () async {
                                          if (player.failure ==
                                              FocusFailure.load) {
                                            await player.reloadPreferences();
                                          } else if (player.failure ==
                                              FocusFailure.preferences) {
                                            await player.flush();
                                          } else if (player.failure ==
                                              FocusFailure.storage) {
                                            await _name(context, player);
                                          } else {
                                            await player.togglePlayback();
                                          }
                                        },
                                  child: Text(s.retry),
                                ),
                              ],
                            ),
                          ),
                        if (size.maxWidth >= 1040)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _Mixer(player: player)),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 4,
                                child: _Library(player: player),
                              ),
                            ],
                          )
                        else ...[
                          _Mixer(player: player),
                          const SizedBox(height: 24),
                          _Library(player: player),
                        ],
                        const SizedBox(height: 32),
                        Text(
                          s.focusPresets,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _MixGallery(mixes: focusPresets, player: player),
                        const SizedBox(height: 28),
                        Text(
                          s.focusCustom,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        library.when(
                          data: (mixes) => mixes.isEmpty
                              ? Text(s.focusEmpty)
                              : _MixGallery(mixes: mixes, player: player),
                          error: (_, _) => Text(s.focusLoadError),
                          loading: () => const LinearProgressIndicator(),
                        ),
                      ],
                    ),
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

Future<void> _name(
  BuildContext context,
  FocusPlayer player, {
  bool create = false,
  bool copy = false,
}) async {
  final s = AppLocalizations.of(context);
  final name = await askText(
    context,
    title: create
        ? s.focusNew
        : copy
        ? s.focusCopy
        : s.focusSave,
    initial: create || player.mix == null ? '' : mixLabel(s, player.mix!),
    maxLength: 100,
  );
  if (name != null) {
    if (create) {
      await player.create(name);
    } else {
      await player.save(name, duplicate: copy);
    }
  }
}

class _Mixer extends StatelessWidget {
  const _Mixer({required this.player});
  final FocusPlayer player;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final mix = player.mix;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ThemeLayerPaint(
        role: ThemeLayerRole.surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.focusMixer, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mix == null ? s.focusEmpty : mixLabel(s, mix),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (mix != null)
                    PopupMenuButton<String>(
                      tooltip: s.settings,
                      enabled: !player.busy,
                      onSelected: (action) async {
                        if (action == 'delete') {
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(s.focusDelete),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(s.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(s.delete),
                                ),
                              ],
                            ),
                          );
                          if (yes == true) await player.deleteCurrent();
                        } else {
                          await _name(context, player, copy: action == 'copy');
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'copy', child: Text(s.focusCopy)),
                        if (!mix.isBuiltIn)
                          PopupMenuItem(value: 'rename', child: Text(s.rename)),
                        if (!mix.isBuiltIn)
                          PopupMenuItem(value: 'delete', child: Text(s.delete)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FocusPlayButton(player: player),
                  IconButton(
                    tooltip: s.focusStop,
                    onPressed: player.busy ? null : player.stop,
                    icon: const Icon(Icons.stop_rounded),
                  ),
                  Expanded(child: FocusMaster(player: player, compact: true)),
                ],
              ),
              if (player.busy) const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 16),
              if (mix == null || mix.tracks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(s.focusAddHint),
                ),
              if (mix != null)
                for (final track in mix.tracks)
                  _TrackRow(player: player, track: track),
              const SizedBox(height: 8),
              if (player.dirty)
                Text(
                  s.focusUnsaved,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              if (mix != null)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: player.busy
                        ? null
                        : () => _name(context, player),
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(s.focusSave),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.player, required this.track});
  final FocusPlayer player;
  final SoundscapeTrack track;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final label = soundLabel(s, track.sound);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(soundIcon(track.sound)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Semantics(
                label: label,
                child: Switch(
                  value: track.enabled,
                  onChanged: player.busy
                      ? null
                      : (value) => player.enable(track.sound, value),
                ),
              ),
              IconButton(
                tooltip: '${s.focusRemove}: $label',
                onPressed: player.busy
                    ? null
                    : () => player.remove(track.sound),
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: label,
                  child: Slider(
                    key: ValueKey('volume-${track.sound.name}'),
                    value: track.volume,
                    label: '${(track.volume * 100).round()}%',
                    onChanged: player.busy
                        ? null
                        : (v) => player.update(track.copyWith(volume: v)),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.textScalerOf(context).scale(42),
                child: Text('${(track.volume * 100).round()}%'),
              ),
            ],
          ),
          if (track.sound.supportsDynamics)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tooltip(
                message: s.focusDynamicHint,
                child: FilterChip(
                  label: Text(s.focusDynamic),
                  selected: track.dynamic,
                  onSelected: player.busy
                      ? null
                      : (v) => player.update(track.copyWith(dynamic: v)),
                ),
              ),
            ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class _Library extends StatefulWidget {
  const _Library({required this.player});
  final FocusPlayer player;
  @override
  State<_Library> createState() => _LibraryState();
}

class _LibraryState extends State<_Library> {
  SoundCategory category = SoundCategory.noise;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final player = widget.player;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.focusLibrary, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(s.focusLimit),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in SoundCategory.values)
              ChoiceChip(
                label: Text(categoryLabel(s, c)),
                selected: c == category,
                onSelected: (_) => setState(() => category = c),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final sound in FocusSound.values.where(
          (sound) => sound.category == category,
        ))
          Builder(
            builder: (context) {
              final added =
                  player.mix?.tracks.any((t) => t.sound == sound) ?? false;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(soundIcon(sound)),
                title: Text(soundLabel(s, sound)),
                trailing: IconButton(
                  tooltip: added ? s.focusRemove : s.focusAdd,
                  icon: Icon(
                    added
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                  ),
                  onPressed:
                      player.busy ||
                          (!added &&
                              (player.mix?.tracks.length ?? 0) >=
                                  Soundscape.maxTracks)
                      ? null
                      : () async {
                          if (player.mix == null) {
                            final now = DateTime.now().toUtc();
                            await player.select(
                              Soundscape(
                                id: 'preset:draft',
                                name: s.focusNew,
                                tracks: [],
                                createdAt: now,
                                updatedAt: now,
                                isBuiltIn: true,
                              ),
                            );
                          }
                          if (added) {
                            await player.remove(sound);
                          } else {
                            await player.add(sound);
                          }
                        },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _MixGallery extends StatelessWidget {
  const _MixGallery({required this.mixes, required this.player});
  final List<Soundscape> mixes;
  final FocusPlayer player;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final mix in mixes)
          Tooltip(
            message: mix.tracks.map((t) => soundLabel(s, t.sound)).join(' · '),
            child: ChoiceChip(
              showCheckmark: false,
              avatar: Icon(
                player.mix?.id == mix.id
                    ? Icons.check_circle_outline
                    : mix.tracks.isEmpty
                    ? Icons.headphones_outlined
                    : soundIcon(mix.tracks.first.sound),
                size: 18,
              ),
              label: Text(mixLabel(s, mix)),
              selected: player.mix?.id == mix.id,
              onSelected: player.busy ? null : (_) => player.select(mix),
            ),
          ),
      ],
    );
  }
}
