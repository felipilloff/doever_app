import 'soundscape.dart';

/// Runtime audio only. Native sources and handles never leave the adapter.
abstract interface class AudioEngine {
  Future<void> play(List<SoundscapeTrack> tracks);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  void updateTrack(SoundscapeTrack track);
  void setMasterVolume(double volume);
  Future<void> dispose();
}

abstract interface class FocusRepository {
  Stream<List<Soundscape>> watchSoundscapes();
  Future<FocusPreferences> loadPreferences();
  Future<void> savePreferences(FocusPreferences preferences);
  Future<void> save(Soundscape soundscape);
  Future<void> delete(String id);
}
