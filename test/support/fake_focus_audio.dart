import 'package:doever/features/focus/domain/audio_engine.dart';
import 'package:doever/features/focus/domain/soundscape.dart';

class FakeFocusAudio implements AudioEngine {
  final calls = <String>[];
  List<SoundscapeTrack> tracks = [];
  bool playing = false;
  double master = .5;
  bool failNext = false;
  @override
  Future<void> play(List<SoundscapeTrack> tracks) async {
    if (failNext) {
      failNext = false;
      throw StateError('Device unavailable');
    }
    calls.add('play');
    this.tracks = List.of(tracks);
    playing = true;
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    playing = false;
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
    playing = true;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    tracks = [];
    playing = false;
  }

  @override
  void updateTrack(SoundscapeTrack track) {
    calls.add('volume');
    tracks = [for (final t in tracks) t.sound == track.sound ? track : t];
  }

  @override
  void setMasterVolume(double volume) {
    master = volume;
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    playing = false;
  }
}
