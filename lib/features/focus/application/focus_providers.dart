import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/soundscape.dart';
import 'focus_player.dart';

bool get supportsFocus =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

// Bootstrap owns shutdown ordering (player, then database).
final focusPlayerProvider = Provider<FocusPlayer?>((ref) => null);
final customSoundscapesProvider = StreamProvider<List<Soundscape>>((ref) {
  return ref.watch(focusPlayerProvider)?.repository.watchSoundscapes() ??
      Stream.value([]);
});
