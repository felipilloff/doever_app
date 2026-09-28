import 'dart:isolate';

import 'package:flutter_soloud/flutter_soloud.dart';

import '../domain/audio_engine.dart';
import '../domain/soundscape.dart';
import 'noise_generator.dart';

class SoloudAudioEngine implements AudioEngine {
  final _audio = SoLoud.instance;
  final _sources = <FocusSound, AudioSource>{};
  final _voices = <FocusSound, SoundHandle>{};
  final _tracks = <FocusSound, SoundscapeTrack>{};
  static const fade = Duration(milliseconds: 600);
  // 16 voices during crossfade × .09 × .65 peak < 1, even at full volume.
  static const headroom = .09;
  double _master = .5;
  bool _paused = false;

  Future<void> _initialize() async {
    if (!_audio.isInitialized) {
      await _audio.init();
      _audio.setMaxActiveVoiceCount(16);
      _audio.setGlobalVolume(_master);
    }
  }

  Future<AudioSource> _load(FocusSound sound) async {
    if (_sources[sound] case final source?) return source;
    final source = sound.isNoise
        ? await _audio.loadMem(
            'focus-${sound.name}.wav',
            await Isolate.run(() => generateNoise(sound)),
          )
        : await _audio.loadAsset('assets/audio/ambience/${sound.name}.wav');
    _sources[sound] = source;
    return source;
  }

  @override
  Future<void> play(List<SoundscapeTrack> tracks) async {
    if (tracks.length > Soundscape.maxTracks) {
      throw ArgumentError('Too many tracks');
    }
    await _initialize();
    final wanted = tracks.where((t) => t.enabled).toList();
    // Load first: the previous mix remains audible if a load fails.
    final old = _voices.values.toList();
    final next = <FocusSound, SoundHandle>{};
    try {
      for (final track in wanted) {
        await _load(track.sound);
      }
      for (final track in wanted) {
        next[track.sound] = _audio.play(
          _sources[track.sound]!,
          volume: 0,
          looping: true,
        );
      }
    } catch (_) {
      for (final voice in next.values) {
        await _audio.stop(voice);
      }
      for (final sound in _sources.keys.toList()) {
        if (!_voices.containsKey(sound)) {
          await _audio.disposeSource(_sources.remove(sound)!);
        }
      }
      rethrow;
    }
    _voices
      ..clear()
      ..addAll(next);
    _tracks
      ..clear()
      ..addEntries(wanted.map((t) => MapEntry(t.sound, t)));
    _paused = false;
    _audio.fadeGlobalVolume(_master, fade);
    for (final track in wanted) {
      _audio.fadeVolume(_voices[track.sound]!, track.volume * headroom, fade);
    }
    for (final voice in old) {
      _audio.fadeVolume(voice, 0, fade);
    }
    await Future<void>.delayed(fade);
    for (final voice in old) {
      await _audio.stop(voice);
    }
    for (final track in _tracks.values) {
      updateTrack(track);
    }
    for (final sound in _sources.keys.toList()) {
      if (!_voices.containsKey(sound)) {
        await _audio.disposeSource(_sources.remove(sound)!);
      }
    }
  }

  @override
  void updateTrack(SoundscapeTrack track) {
    _tracks[track.sound] = track;
    final voice = _voices[track.sound];
    if (voice == null || !_audio.isInitialized || _paused) return;
    if (track.dynamic) {
      final bounds = track.dynamicBounds;
      _audio.oscillateVolume(
        voice,
        bounds.$1 * headroom,
        bounds.$2 * headroom,
        Duration(seconds: 19 + track.sound.index),
      );
    } else {
      _audio.fadeVolume(
        voice,
        track.volume * headroom,
        const Duration(milliseconds: 100),
      );
    }
  }

  @override
  void setMasterVolume(double volume) {
    _master = validVolume(volume);
    if (_audio.isInitialized) {
      _audio.fadeGlobalVolume(
        _paused ? 0 : _master,
        const Duration(milliseconds: 100),
      );
    }
  }

  @override
  Future<void> pause() async {
    if (!_audio.isInitialized) return;
    _paused = true;
    _audio.fadeGlobalVolume(0, fade);
    await Future<void>.delayed(fade);
    for (final voice in _voices.values) {
      _audio.setPause(voice, true);
    }
  }

  @override
  Future<void> resume() async {
    if (!_audio.isInitialized) return;
    _paused = false;
    for (final voice in _voices.values) {
      _audio.setPause(voice, false);
    }
    _audio.fadeGlobalVolume(_master, fade);
    for (final track in _tracks.values) {
      updateTrack(track);
    }
  }

  @override
  Future<void> stop() async {
    if (!_audio.isInitialized) return;
    await pause();
    for (final source in _sources.values) {
      await _audio.disposeSource(source);
    }
    _sources.clear();
    _voices.clear();
    _tracks.clear();
  }

  @override
  Future<void> dispose() async {
    if (_audio.isInitialized) {
      try {
        await stop();
      } finally {
        await _audio.deinitAsync();
      }
    }
  }
}
