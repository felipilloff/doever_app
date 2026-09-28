import 'dart:math';
import 'dart:typed_data';

import '../domain/soundscape.dart';

/// Runs once per loaded noise in a worker isolate, never on the audio/UI clock.
/// Pink: original implementation of octave-summed Voss–McCartney noise,
/// with an extra white component filling the high-frequency response.
/// Algorithm discussion: https://www.firstpr.com.au/dsp/pink-noise/
/// Brown: leaky integration (DC bounded). Grey: deliberately approximate
/// equal-loudness compensation, boosting bass and treble around a quiet midband;
/// it is not an ISO loudness calibration or a canonical grey spectrum.
Uint8List generateNoise(FocusSound sound, {int seconds = 16}) {
  if (!sound.isNoise) throw ArgumentError('Expected a noise source');
  const rate = 44100;
  const overlap = 2205;
  final count = seconds * rate;
  final samples = Float64List(count + overlap);
  final random = Random(417 + sound.index);
  double white() => random.nextDouble() * 2 - 1;
  final rows = List.generate(16, (_) => white());
  var sum = rows.reduce((a, b) => a + b);
  var brown = 0.0;
  var bass = 0.0;
  var lowMid = 0.0;
  for (var i = 0; i < samples.length; i++) {
    final w = white();
    switch (sound) {
      case FocusSound.white:
        samples[i] = w;
      case FocusSound.pink:
        var key = (i + 1) & 65535;
        var row = 0;
        if (key != 0) {
          while ((key & 1) == 0) {
            row++;
            key >>= 1;
          }
          sum -= rows[row];
          rows[row] = white();
          sum += rows[row];
        }
        samples[i] = (sum + w) / 17;
      case FocusSound.brown:
        brown = .998 * brown + .04 * w;
        samples[i] = brown;
      case FocusSound.grey:
        bass += .012 * (w - bass);
        lowMid += .45 * (w - lowMid);
        samples[i] = 5 * bass + .55 * (w - lowMid);
      default:
        throw ArgumentError('Not noise');
    }
  }
  // Overlap the tail into the start. At the loop boundary both sides belong to
  // the same contiguous noise sequence; equal-power blending avoids a dip.
  for (var i = 0; i < overlap; i++) {
    final theta = i / overlap * pi / 2;
    samples[i] = samples[count + i] * cos(theta) + samples[i] * sin(theta);
  }
  var mean = 0.0;
  for (var i = 0; i < count; i++) {
    mean += samples[i];
  }
  mean /= count;
  var peak = .0001;
  for (var i = 0; i < count; i++) {
    peak = max(peak, (samples[i] - mean).abs());
  }
  final bytes = ByteData(44 + count * 2);
  void tag(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  bytes.setUint32(4, 36 + count * 2, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, rate, Endian.little);
  bytes.setUint32(28, rate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  bytes.setUint32(40, count * 2, Endian.little);
  for (var i = 0; i < count; i++) {
    bytes.setInt16(
      44 + 2 * i,
      ((samples[i] - mean) / peak * .65 * 32767).round(),
      Endian.little,
    );
  }
  return bytes.buffer.asUint8List();
}
