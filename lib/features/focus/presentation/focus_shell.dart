import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_layer_paint.dart';
import '../../../l10n/app_localizations.dart';
import '../application/focus_providers.dart';
import '../application/focus_player.dart';
import 'focus_controls.dart';
import 'focus_labels.dart';

/// Remains above the router, retaining its child identity during playback.
class FocusShell extends ConsumerStatefulWidget {
  const FocusShell({super.key, required this.child, required this.openFocus});
  final Widget child;
  final VoidCallback openFocus;
  @override
  ConsumerState<FocusShell> createState() => _FocusShellState();
}

class _FocusShellState extends ConsumerState<FocusShell> {
  late final AppLifecycleListener _lifecycle;
  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onDetach: () => unawaited(ref.read(focusPlayerProvider)?.shutdown()),
      onInactive: () => unawaited(ref.read(focusPlayerProvider)?.flush()),
      onExitRequested: () async {
        await ref.read(focusPlayerProvider)?.flush();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(focusPlayerProvider);
    if (!supportsFocus || player == null) return widget.child;
    return Overlay.wrap(
      child: Column(
        children: [
          Expanded(child: widget.child),
          ListenableBuilder(
            listenable: player,
            builder: (context, _) {
              final mix = player.mix;
              if (mix == null) return const SizedBox.shrink();
              final s = AppLocalizations.of(context);
              return ThemeLayerPaint(
                role: ThemeLayerRole.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) => Row(
                        children: [
                          FocusPlayButton(player: player),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: widget.openFocus,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  mixLabel(s, mix),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          if (constraints.maxWidth > 560)
                            SizedBox(
                              width: 200,
                              child: FocusMaster(player: player, compact: true),
                            )
                          else
                            IconButton(
                              tooltip: player.muted
                                  ? s.focusUnmute
                                  : s.focusMute,
                              onPressed: player.toggleMute,
                              icon: Icon(
                                player.muted
                                    ? Icons.volume_off_outlined
                                    : Icons.volume_up_outlined,
                              ),
                            ),
                          if (player.failure != null)
                            IconButton(
                              tooltip: player.failure == FocusFailure.audio
                                  ? s.focusAudioError
                                  : s.focusStorageError,
                              onPressed: widget.openFocus,
                              icon: const Icon(Icons.error_outline),
                            ),
                          IconButton(
                            tooltip: s.focusMixer,
                            onPressed: widget.openFocus,
                            icon: const Icon(Icons.tune),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
