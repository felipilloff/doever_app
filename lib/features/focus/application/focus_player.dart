import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logging.dart';
import '../domain/audio_engine.dart';
import '../domain/soundscape.dart';

enum FocusFailure { audio, storage, preferences, load }

/// One application-scoped player. Routes only observe it; they never own audio.
class FocusPlayer extends ChangeNotifier {
  FocusPlayer(this.repository, this.engine, FocusPreferences preferences)
    : mix = preferences.mix,
      masterVolume = preferences.masterVolume,
      muted = preferences.muted;
  final FocusRepository repository;
  final AudioEngine engine;
  Soundscape? mix;
  double masterVolume;
  bool muted;
  bool playing = false;
  bool busy = false;
  bool dirty = false;
  FocusFailure? failure;
  bool _loaded = false;
  bool _closed = false;
  int _preferenceRevision = 0;
  int _savedPreferenceRevision = 0;
  Timer? _debounce;
  Future<void> _commands = Future.value();
  Future<void> _writes = Future.value();

  Future<void> _run(
    Future<void> Function() operation, {
    FocusFailure kind = FocusFailure.audio,
  }) {
    if (_closed) return Future.value();
    final next = _commands.then((_) async {
      busy = true;
      if (failure == kind) failure = null;
      notifyListeners();
      try {
        await operation();
      } catch (error, stack) {
        failure = kind;
        logFailure('focus.${kind.name}', error, stack);
      } finally {
        busy = false;
        notifyListeners();
      }
    });
    _commands = next;
    return next;
  }

  Future<void> select(Soundscape value) => _run(() async {
    if (playing && value.tracks.any((t) => t.enabled)) {
      await engine.play(value.tracks);
      _loaded = true;
    } else if (_loaded) {
      await engine.stop();
      _loaded = false;
      playing = false;
    }
    mix = value;
    dirty = false;
    engine.setMasterVolume(muted ? 0 : masterVolume);
    _remember();
  });

  Future<void> togglePlayback() => _run(() async {
    if (playing) {
      await engine.pause();
      playing = false;
    } else if (mix != null && mix!.tracks.any((t) => t.enabled)) {
      engine.setMasterVolume(muted ? 0 : masterVolume);
      if (_loaded) {
        await engine.resume();
      } else {
        await engine.play(mix!.tracks);
        _loaded = true;
      }
      playing = true;
    }
  });

  Future<void> reloadPreferences() => _run(() async {
    final preferences = await repository.loadPreferences();
    mix = preferences.mix;
    masterVolume = preferences.masterVolume;
    muted = preferences.muted;
    dirty = false;
  }, kind: FocusFailure.load);

  Future<void> stop() => _run(() async {
    await engine.stop();
    playing = false;
    _loaded = false;
  });

  void setMaster(double volume) {
    masterVolume = validVolume(volume);
    _volume();
    _remember();
    notifyListeners();
  }

  void toggleMute() {
    muted = !muted;
    _volume();
    _remember();
    notifyListeners();
  }

  void _volume() {
    try {
      engine.setMasterVolume(muted ? 0 : masterVolume);
    } catch (error, stack) {
      failure = FocusFailure.audio;
      logFailure('focus.volume', error, stack);
    }
  }

  Future<void> add(FocusSound sound) => _edit((tracks) {
    if (tracks.any((t) => t.sound == sound) ||
        tracks.length >= Soundscape.maxTracks) {
      return tracks;
    }
    return [...tracks, SoundscapeTrack(sound: sound)];
  });
  Future<void> remove(FocusSound sound) =>
      _edit((tracks) => tracks.where((t) => t.sound != sound).toList());
  Future<void> enable(FocusSound sound, bool enabled) => _edit(
    (tracks) => [
      for (final t in tracks)
        t.sound == sound ? t.copyWith(enabled: enabled) : t,
    ],
  );

  Future<void> _edit(
    List<SoundscapeTrack> Function(List<SoundscapeTrack>) edit,
  ) => _run(() async {
    final current = mix;
    if (current == null) return;
    final tracks = edit(current.tracks);
    if (playing && tracks.any((t) => t.enabled)) {
      await engine.play(tracks);
      _loaded = true;
    } else if (_loaded) {
      await engine.stop();
      _loaded = false;
      playing = false;
    }
    mix = current.copyWith(tracks: tracks, updatedAt: DateTime.now().toUtc());
    dirty = true;
    _remember();
  });

  void update(SoundscapeTrack track) {
    if (busy ||
        mix == null ||
        !mix!.tracks.any((t) => t.sound == track.sound)) {
      return;
    }
    mix = mix!.copyWith(
      tracks: [for (final t in mix!.tracks) t.sound == track.sound ? track : t],
      updatedAt: DateTime.now().toUtc(),
    );
    dirty = true;
    try {
      engine.updateTrack(track);
    } catch (error, stack) {
      failure = FocusFailure.audio;
      logFailure('focus.track', error, stack);
    }
    _remember();
    notifyListeners();
  }

  Future<void> save(String name, {bool duplicate = false}) => _run(() async {
    final current = mix;
    if (current == null) return;
    final now = DateTime.now().toUtc();
    final copy = duplicate || current.isBuiltIn;
    final saved = current.copyWith(
      id: copy ? const Uuid().v4() : current.id,
      name: name,
      isBuiltIn: false,
      createdAt: copy ? now : current.createdAt,
      updatedAt: now,
    );
    await repository.save(saved);
    mix = saved;
    dirty = false;
    _remember();
    await flush();
  }, kind: FocusFailure.storage);

  Future<void> create(String name) => _run(() async {
    final now = DateTime.now().toUtc();
    final created = Soundscape(
      id: const Uuid().v4(),
      name: name,
      tracks: [],
      createdAt: now,
      updatedAt: now,
    );
    await repository.save(created);
    await engine.stop();
    playing = false;
    _loaded = false;
    mix = created;
    dirty = false;
    _remember();
    await flush();
  }, kind: FocusFailure.storage);

  Future<void> deleteCurrent() => _run(() async {
    if (mix == null || mix!.isBuiltIn) return;
    await repository.delete(mix!.id);
    await engine.stop();
    playing = false;
    _loaded = false;
    mix = null;
    dirty = false;
    _remember();
    await flush();
  }, kind: FocusFailure.storage);

  void _remember() {
    _preferenceRevision++;
    if (failure == FocusFailure.load) failure = null;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), flush);
  }

  Future<void> flush() {
    _debounce?.cancel();
    if (_preferenceRevision == _savedPreferenceRevision) return _writes;
    final revision = _preferenceRevision;
    final snapshot = FocusPreferences(
      mix: mix,
      masterVolume: masterVolume,
      muted: muted,
    );
    _writes = _writes.then((_) async {
      try {
        await repository.savePreferences(snapshot);
        _savedPreferenceRevision = revision;
        if (failure == FocusFailure.preferences) {
          failure = null;
          if (!_closed) notifyListeners();
        }
      } catch (error, stack) {
        failure = FocusFailure.preferences;
        logFailure('focus.preferences', error, stack);
        if (!_closed) notifyListeners();
      }
    });
    return _writes;
  }

  Future<void>? _shutdown;
  Future<void> shutdown() => _shutdown ??= _shutdownPlayer();

  Future<void> _shutdownPlayer() async {
    _closed = true;
    _debounce?.cancel();
    await _commands;
    await flush();
    try {
      await engine.dispose();
    } catch (error, stack) {
      logFailure('focus.shutdown', error, stack);
    } finally {
      super.dispose();
    }
  }
}
