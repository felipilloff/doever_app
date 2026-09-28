import 'package:doever/features/focus/data/soloud_audio_engine.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Requires an available native audio device. Muted throughout, verifying engine
/// commands and loop survival rather than claiming physical speaker validation.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final noDevice =
      const bool.fromEnvironment('allowNoAudioDevice') &&
      SoLoud.instance.listPlaybackDevices().isEmpty;
  testWidgets(
    'native mixer initializes, loops, crossfades, pauses and releases voices',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Focus audio verification')),
        ),
      );
      final engine = SoloudAudioEngine();
      engine.setMasterVolume(0);
      try {
        await engine.play([
          SoundscapeTrack(sound: FocusSound.pink),
          SoundscapeTrack(sound: FocusSound.lightRain, dynamic: true),
        ]);
        expect(SoLoud.instance.isInitialized, true);
        expect(SoLoud.instance.getVoiceCount(), 2);
        await Future<void>.delayed(const Duration(seconds: 25));
        expect(
          SoLoud.instance.getVoiceCount(),
          2,
          reason: 'Both sources outlive a complete loop',
        );
        await engine.pause();
        await engine.resume();
        await engine.play([
          SoundscapeTrack(sound: FocusSound.brown),
          SoundscapeTrack(sound: FocusSound.wind),
        ]);
        expect(
          SoLoud.instance.getVoiceCount(),
          2,
          reason: 'Previous crossfade bank was released',
        );
        await engine.stop();
        expect(SoLoud.instance.getVoiceCount(), 0);
      } finally {
        await engine.dispose();
      }
      expect(SoLoud.instance.isInitialized, false);
    },
    skip: noDevice,
  );
}
