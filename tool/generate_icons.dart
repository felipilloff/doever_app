// Run with: flutter test tool/generate_icons.dart
// Draws the original neutral Doever mark from vector primitives, no image package.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> mark(int size) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..scale(size / 100);
  canvas.drawColor(const Color(0xff426b59), BlendMode.src);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(23, 23, 54, 54),
      const Radius.circular(17),
    ),
    Paint()
      ..color = const Color(0xffedf5ec)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5,
  );
  canvas.drawPath(
    Path()
      ..moveTo(36, 51)
      ..lineTo(46, 61)
      ..lineTo(65, 40),
    Paint()
      ..color = const Color(0xffedf5ec)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final data = await image.toByteData(format: ImageByteFormat.png);
  final result = data!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return result;
}

void main() {
  test('generate platform application marks', () async {
    final targets = <String, int>{
      'web/favicon.png': 32,
      for (final size in [192, 512]) 'web/icons/Icon-$size.png': size,
      for (final size in [192, 512]) 'web/icons/Icon-maskable-$size.png': size,
      for (final entry in {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      }.entries)
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png':
            entry.value,
    };
    for (final platform in ['ios', 'macos']) {
      final dir = '$platform/Runner/Assets.xcassets/AppIcon.appiconset';
      final json = jsonDecode(
        await File('$dir/Contents.json').readAsString(),
      ) as Map<String, Object?>;
      for (final image
          in (json['images']! as List<Object?>).cast<Map<String, Object?>>()) {
        final size = double.parse((image['size']! as String).split('x').first);
        final scale = double.parse(
          (image['scale']! as String).replaceAll('x', ''),
        );
        targets['$dir/${image['filename']}'] = (size * scale).round();
      }
    }
    for (final entry in targets.entries) {
      await File(entry.key).writeAsBytes(await mark(entry.value));
    }
    final png = await mark(256);
    final header = ByteData(22)
      ..setUint16(2, 1, Endian.little)
      ..setUint16(4, 1, Endian.little)
      ..setUint16(10, 1, Endian.little)
      ..setUint16(12, 32, Endian.little)
      ..setUint32(14, png.length, Endian.little)
      ..setUint32(18, 22, Endian.little);
    await File('windows/runner/resources/app_icon.ico')
        .writeAsBytes([...header.buffer.asUint8List(), ...png]);
  });
}
