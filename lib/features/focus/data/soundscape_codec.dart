import 'dart:convert';

import '../domain/soundscape.dart';

abstract final class SoundscapeCodec {
  static String encode(Soundscape mix) => jsonEncode({
    'id': mix.id,
    'name': mix.name,
    'createdAt': mix.createdAt.toIso8601String(),
    'updatedAt': mix.updatedAt.toIso8601String(),
    'builtIn': mix.isBuiltIn,
    'tracks': [
      for (final t in mix.tracks)
        {
          'sound': t.sound.name,
          'volume': t.volume,
          'enabled': t.enabled,
          'dynamic': t.dynamic,
        },
    ],
  });
  static Soundscape decode(String document) {
    final json = jsonDecode(document) as Map<String, dynamic>;
    return Soundscape(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isBuiltIn: json['builtIn'] as bool,
      tracks: (json['tracks'] as List).map((item) {
        final t = item as Map<String, dynamic>;
        return SoundscapeTrack(
          sound: FocusSound.values.byName(t['sound'] as String),
          volume: (t['volume'] as num).toDouble(),
          enabled: t['enabled'] as bool,
          dynamic: t['dynamic'] as bool,
        );
      }).toList(),
    );
  }
}
