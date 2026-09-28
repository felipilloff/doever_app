enum SoundCategory { noise, weather, nature, cozy, urban, workspace }

enum FocusSound {
  white(SoundCategory.noise),
  pink(SoundCategory.noise),
  brown(SoundCategory.noise),
  grey(SoundCategory.noise),
  lightRain(SoundCategory.weather),
  heavyRain(SoundCategory.weather),
  thunder(SoundCategory.weather),
  wind(SoundCategory.weather),
  ocean(SoundCategory.nature),
  stream(SoundCategory.nature),
  birds(SoundCategory.nature),
  crickets(SoundCategory.nature),
  fireplace(SoundCategory.cozy),
  vinyl(SoundCategory.cozy),
  cafe(SoundCategory.urban),
  train(SoundCategory.urban),
  keyboard(SoundCategory.workspace),
  office(SoundCategory.workspace);

  const FocusSound(this.category);
  final SoundCategory category;
  bool get isNoise => category == SoundCategory.noise;
  bool get supportsDynamics => !isNoise;
}

double validVolume(double value) {
  if (!value.isFinite || value < 0 || value > 1) {
    throw ArgumentError.value(value, 'volume', 'Must be between zero and one');
  }
  return value;
}

final class SoundscapeTrack {
  SoundscapeTrack({
    required this.sound,
    double volume = .35,
    this.enabled = true,
    bool dynamic = false,
  }) : volume = validVolume(volume),
       dynamic = dynamic && sound.supportsDynamics;

  final FocusSound sound;
  final double volume;
  final bool enabled;
  final bool dynamic;
  SoundscapeTrack copyWith({double? volume, bool? enabled, bool? dynamic}) =>
      SoundscapeTrack(
        sound: sound,
        volume: volume ?? this.volume,
        enabled: enabled ?? this.enabled,
        dynamic: dynamic ?? this.dynamic,
      );

  /// Native oscillation stays inside this range; no per-frame UI work.
  (double, double) get dynamicBounds =>
      ((volume * .88).clamp(0, 1), (volume * 1.12).clamp(0, 1));
}

final class Soundscape {
  Soundscape({
    required this.id,
    required String name,
    required List<SoundscapeTrack> tracks,
    required this.createdAt,
    required this.updatedAt,
    this.isBuiltIn = false,
  }) : name = name.trim(),
       tracks = List.unmodifiable(tracks) {
    if (this.name.isEmpty || this.name.length > 100) {
      throw ArgumentError('Soundscape name must contain 1–100 characters');
    }
    if (tracks.length > maxTracks ||
        tracks.map((t) => t.sound).toSet().length != tracks.length) {
      throw ArgumentError('A mix supports eight distinct sounds');
    }
  }
  static const maxTracks = 8;
  final String id;
  final String name;
  final List<SoundscapeTrack> tracks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBuiltIn;
  Soundscape copyWith({
    String? id,
    String? name,
    List<SoundscapeTrack>? tracks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBuiltIn,
  }) => Soundscape(
    id: id ?? this.id,
    name: name ?? this.name,
    tracks: tracks ?? this.tracks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
}

final class FocusPreferences {
  FocusPreferences({this.mix, double masterVolume = .5, this.muted = false})
    : masterVolume = validVolume(masterVolume);
  final Soundscape? mix;
  final double masterVolume;
  final bool muted;
}

final focusPresets = List<Soundscape>.unmodifiable([
  _preset('deep', [(FocusSound.brown, .65), (FocusSound.lightRain, .3)]),
  _preset('cafe', [
    (FocusSound.cafe, .5),
    (FocusSound.lightRain, .55),
    (FocusSound.vinyl, .12),
  ]),
  _preset('night', [
    (FocusSound.brown, .45),
    (FocusSound.crickets, .25),
    (FocusSound.keyboard, .15),
  ]),
  _preset('forest', [
    (FocusSound.stream, .45),
    (FocusSound.wind, .2),
    (FocusSound.birds, .3),
  ]),
  _preset('storm', [
    (FocusSound.heavyRain, .6),
    (FocusSound.thunder, .35),
    (FocusSound.fireplace, .2),
  ]),
  _preset('journey', [(FocusSound.train, .45), (FocusSound.pink, .2)]),
]);

Soundscape _preset(String id, List<(FocusSound, double)> tracks) => Soundscape(
  id: 'preset:$id',
  name: id,
  isBuiltIn: true,
  tracks: tracks
      .map((t) => SoundscapeTrack(sound: t.$1, volume: t.$2))
      .toList(),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
