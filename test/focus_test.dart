import 'dart:io';
import 'dart:typed_data';

import 'package:doever/database/app_database.dart';
import 'package:doever/features/focus/application/focus_player.dart';
import 'package:doever/features/focus/data/drift_focus_repository.dart';
import 'package:doever/features/focus/data/noise_generator.dart';
import 'package:doever/features/focus/data/soundscape_codec.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:doever/features/focus/domain/audio_engine.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_focus_audio.dart';

void main() {
  test('preferences failures remain visible and retries preserve unsaved custom edits', () async {
    final repository = _FailingRepository();
    final player = FocusPlayer(
      repository,
      FakeFocusAudio(),
      FocusPreferences(),
    );
    await player.reloadPreferences();
    expect(player.failure, FocusFailure.load);
    await player.flush();
    expect(
      repository.writes,
      0,
      reason: 'Failed loads are never overwritten on startup/inactive',
    );
    repository.failLoad = false;
    await player.reloadPreferences();
    expect(player.failure, isNull);
    await player.select(focusPresets.first);
    repository.failPreferences = true;
    await player.flush();
    expect(player.failure, FocusFailure.preferences);
    await player.togglePlayback();
    expect(player.failure, FocusFailure.preferences);
    repository.failPreferences = false;
    await player.flush();
    expect(player.failure, isNull);
    player.update(player.mix!.tracks.first.copyWith(volume: .11));
    repository.failSave = true;
    await player.save('Keep this mix');
    expect(player.failure, FocusFailure.storage);
    expect(player.dirty, true);
    await player.flush();
    expect(
      player.failure,
      FocusFailure.storage,
      reason: 'Saving preferences is not saving the library',
    );
    repository.failSave = false;
    await player.save('Keep this mix');
    expect(player.failure, isNull);
    expect(player.dirty, false);
    expect(repository.saved!.tracks.first.volume, .11);
    await Future.wait([player.shutdown(), player.shutdown()]);
  });

  test('all environmental assets are valid normalized PCM loops', () async {
    for (final sound in FocusSound.values.where((s) => !s.isNoise)) {
      final bytes = await File('assets/audio/ambience/${sound.name}.wav')
          .readAsBytes();
      final data = ByteData.sublistView(bytes);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(data.getUint16(22, Endian.little), 1);
      expect(data.getUint32(24, Endian.little), 44100);
      expect(data.getUint16(34, Endian.little), 16);
      expect(bytes.length, 44 + 44100 * 24 * 2);
      var peak = 0;
      for (var i = 44; i < bytes.length; i += 2) {
        final value = data.getInt16(i, Endian.little).abs();
        if (value > peak) peak = value;
      }
      expect(peak / 32767, closeTo(.65, .0001), reason: sound.name);
    }
  });
  test('models reject invalid gains, duplicates and overfull mixes; presets are immutable', () {
    for (final volume in [double.nan, double.infinity, -.1, 1.1]) {
      expect(
        () => SoundscapeTrack(sound: FocusSound.white, volume: volume),
        throwsArgumentError,
      );
    }
    final preset = focusPresets.first;
    expect(
      () => preset.tracks.add(SoundscapeTrack(sound: FocusSound.grey)),
      throwsUnsupportedError,
    );
    expect(
      () => preset.copyWith(tracks: List.filled(2, preset.tracks.first)),
      throwsArgumentError,
    );
    expect(
      () => preset.copyWith(
        tracks: FocusSound.values
            .take(9)
            .map((s) => SoundscapeTrack(sound: s))
            .toList(),
      ),
      throwsArgumentError,
    );
    expect(() => preset.copyWith(name: ' '), throwsArgumentError);
    final decoded = SoundscapeCodec.decode(SoundscapeCodec.encode(preset));
    expect(decoded.id, preset.id);
    expect(
      decoded.tracks.map((t) => t.volume),
      preset.tracks.map((t) => t.volume),
    );
    for (var i = 0; i <= 100; i++) {
      final track = SoundscapeTrack(
        sound: FocusSound.wind,
        volume: i / 100,
        dynamic: true,
      );
      expect(track.dynamicBounds.$1, inInclusiveRange(0, track.volume));
      expect(track.dynamicBounds.$2, inInclusiveRange(track.volume, 1));
    }
    expect(
      SoundscapeTrack(sound: FocusSound.pink, dynamic: true).dynamic,
      false,
    );
  });

  test('playback, live changes, navigation-independent state, serialization and recovery', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = DriftFocusRepository(db);
    final engine = FakeFocusAudio();
    final player = FocusPlayer(repository, engine, FocusPreferences());
    expect(engine.calls, isEmpty);
    await player.select(focusPresets[1]);
    expect(
      engine.playing,
      false,
      reason: 'Selection and startup never autoplay',
    );
    await player.togglePlayback();
    expect(engine.playing, true);
    player.setMaster(.65);
    player.toggleMute();
    expect(engine.master, 0);
    player.toggleMute();
    expect(engine.master, .65);
    final originalVolume = focusPresets[1].tracks.first.volume;
    player.update(player.mix!.tracks.first.copyWith(volume: .2, dynamic: true));
    expect(engine.tracks.first.volume, .2);
    expect(focusPresets[1].tracks.first.volume, originalVolume);
    await player.togglePlayback();
    expect(engine.playing, false);
    await player.togglePlayback();
    expect(engine.calls.last, 'resume');
    await player.add(FocusSound.brown);
    expect(engine.tracks.any((t) => t.sound == FocusSound.brown), true);
    await player.remove(FocusSound.vinyl);
    expect(engine.tracks.any((t) => t.sound == FocusSound.vinyl), false);
    await player.enable(FocusSound.brown, false);
    expect(player.mix!.tracks.last.enabled, false);
    await Future.wait([
      player.select(focusPresets[3]),
      player.select(focusPresets[4]),
    ]);
    expect(engine.tracks.first.sound, FocusSound.heavyRain);
    engine.failNext = true;
    await player.select(focusPresets[0]);
    expect(player.failure, FocusFailure.audio);
    expect(
      player.mix!.id,
      focusPresets[4].id,
      reason: 'Failed loading preserves previous selection',
    );
    await player.select(focusPresets[0]);
    expect(player.failure, isNull);
    await player.stop();
    expect(engine.playing, false);
    await player.shutdown();
    expect(engine.calls.last, 'dispose');
    await db.close();
  });

  test('custom CRUD, copies, preferences and restart never autoplay', () async {
    final directory = await Directory.systemTemp.createTemp(
      'focus-persistence-',
    );
    final file = File('${directory.path}/test.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var repository = DriftFocusRepository(db);
    var player = FocusPlayer(repository, FakeFocusAudio(), FocusPreferences());
    await player.select(focusPresets.first);
    await player.save('Original');
    final originalId = player.mix!.id;
    await player.save('Duplicate', duplicate: true);
    expect(player.mix!.id, isNot(originalId));
    await player.save('Renamed');
    player.update(player.mix!.tracks.first.copyWith(volume: .123));
    await player.save('Renamed');
    player.setMaster(.37);
    player.toggleMute();
    await player.shutdown();
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    repository = DriftFocusRepository(db);
    final prefs = await repository.loadPreferences();
    final audio = FakeFocusAudio();
    player = FocusPlayer(repository, audio, prefs);
    expect(prefs.mix!.name, 'Renamed');
    expect(prefs.masterVolume, .37);
    expect(prefs.muted, true);
    expect(prefs.mix!.tracks.first.volume, .123);
    expect(audio.calls, isEmpty);
    expect(await repository.watchSoundscapes().first, hasLength(2));
    await player.deleteCurrent();
    expect(player.mix, isNull);
    expect(await repository.watchSoundscapes().first, hasLength(1));
    expect((await repository.loadPreferences()).mix, isNull);
    await player.create('Empty');
    expect(player.mix!.tracks, isEmpty);
    await expectLater(repository.save(focusPresets.first), throwsArgumentError);
    await player.shutdown();
    await db.close();
    await directory.delete(recursive: true);
  });

  test(
    'noise is reproducible PCM with bounded gain, no DC, and different spectra',
    () {
      final differences = <FocusSound, double>{};
      for (final sound in FocusSound.values.where((s) => s.isNoise)) {
        final bytes = generateNoise(sound, seconds: 2);
        expect(bytes, generateNoise(sound, seconds: 2));
        final data = ByteData.sublistView(bytes);
        expect(data.getUint32(24, Endian.little), 44100);
        var sum = 0.0, power = 0.0, difference = 0.0, previous = 0.0;
        final count = (bytes.length - 44) ~/ 2;
        for (var i = 0; i < count; i++) {
          final sample = data.getInt16(44 + i * 2, Endian.little) / 32767;
          expect(sample.abs(), lessThanOrEqualTo(.6501));
          sum += sample;
          power += sample * sample;
          if (i > 0) difference += (sample - previous) * (sample - previous);
          previous = sample;
        }
        expect((sum / count).abs(), lessThan(.0001));
        expect(power / count, greaterThan(.001));
        differences[sound] = difference / power;
      }
      expect(
        differences[FocusSound.white]!,
        greaterThan(differences[FocusSound.pink]!),
      );
      expect(
        differences[FocusSound.pink]!,
        greaterThan(differences[FocusSound.brown]!),
      );
      expect(
        differences[FocusSound.grey]!,
        isNot(differences[FocusSound.white]),
      );
    },
  );
}

class _FailingRepository implements FocusRepository {
  bool failLoad = true, failSave = false, failPreferences = false;
  int writes = 0;
  Soundscape? saved;
  FocusPreferences preferences = FocusPreferences();
  @override
  Stream<List<Soundscape>> watchSoundscapes() =>
      Stream.value(saved == null ? [] : [saved!]);
  @override
  Future<FocusPreferences> loadPreferences() async {
    if (failLoad) throw const FormatException('Unreadable data');
    return preferences;
  }

  @override
  Future<void> savePreferences(FocusPreferences value) async {
    writes++;
    if (failPreferences) throw const FileSystemException('Disk unavailable');
    preferences = value;
  }

  @override
  Future<void> save(Soundscape value) async {
    if (failSave) throw const FileSystemException('Disk unavailable');
    saved = value;
  }

  @override
  Future<void> delete(String id) async {
    saved = null;
  }
}
