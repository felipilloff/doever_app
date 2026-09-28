import 'package:flutter/material.dart';

import '../../../app/theme/theme_layer_paint.dart';
import '../../../l10n/app_localizations.dart';
import '../application/focus_player.dart';

class FocusPlayButton extends StatelessWidget {
  const FocusPlayButton({super.key, required this.player});
  final FocusPlayer player;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ThemeLayerPaint(
        role: ThemeLayerRole.accent,
        child: IconButton(
          key: const ValueKey('focus-play'),
          tooltip: player.playing ? s.focusPause : s.focusPlay,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed:
              player.busy ||
                  !(player.mix?.tracks.any((t) => t.enabled) ?? false)
              ? null
              : player.togglePlayback,
          icon: Icon(
            player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
      ),
    );
  }
}

class FocusMaster extends StatelessWidget {
  const FocusMaster({super.key, required this.player, this.compact = false});
  final FocusPlayer player;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: player.muted ? s.focusUnmute : s.focusMute,
          onPressed: player.toggleMute,
          icon: Icon(
            player.muted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
          ),
        ),
        Expanded(
          child: Semantics(
            label: s.focusMaster,
            child: Slider(
              key: const ValueKey('focus-master'),
              value: player.masterVolume,
              label: '${(player.masterVolume * 100).round()}%',
              onChanged: player.setMaster,
            ),
          ),
        ),
        if (!compact)
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(46),
            child: Text('${(player.masterVolume * 100).round()}%'),
          ),
      ],
    );
  }
}
