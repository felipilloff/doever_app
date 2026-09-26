import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'errors.dart';
import 'logging.dart';

Future<Uint8List> prepareLocalImage(Uint8List bytes) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? image;
  try {
    final png =
        bytes.length >= 8 &&
        listEquals(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    final webp =
        bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
    if (!png && !jpeg && !webp) {
      throw const FormatException('Unsupported background format');
    }
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    if (descriptor.width * descriptor.height > 40000000) {
      throw const FormatException('Background dimensions too large');
    }
    final scale = math.min(
      1.0,
      2560 / math.max(descriptor.width, descriptor.height),
    );
    codec = await descriptor.instantiateCodec(
      targetWidth: math.max(1, (descriptor.width * scale).round()),
      targetHeight: math.max(1, (descriptor.height * scale).round()),
    );
    if (codec.frameCount != 1) {
      throw const FormatException('Animated backgrounds are not supported');
    }
    image = (await codec.getNextFrame()).image;
    final encoded = await image.toByteData(format: ui.ImageByteFormat.png);
    if (encoded == null) throw const FormatException('Cannot encode image');
    return encoded.buffer.asUint8List(
      encoded.offsetInBytes,
      encoded.lengthInBytes,
    );
  } catch (error, stack) {
    logFailure('background.decode', error, stack);
    throw const AppFailure(FailureKind.backgroundImage);
  } finally {
    image?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}
