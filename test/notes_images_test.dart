import 'dart:io';

import 'package:doever/features/notes/data/note_images.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'background_test.dart' show landscape;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('managed note image survives source removal and rejects invalid paths/input', () async {
    final dir = await Directory.systemTemp.createTemp('note-images-');
    final source = File('${dir.path}/source.png');
    await source.writeAsBytes(await landscape());
    final images = NoteImages(() async => Directory('${dir.path}/managed'));
    final name = await images.import(XFile(source.path));
    await source.delete();
    final reopened = NoteImages(() async => Directory('${dir.path}/managed'));
    expect(await (await reopened.file(name)).length(), greaterThan(0));
    await expectLater(images.file('../source.png'), throwsException);
    final invalid = File('${dir.path}/invalid.png');
    await invalid.writeAsString('not an image');
    await expectLater(images.import(XFile(invalid.path)), throwsException);
    expect(await Directory('${dir.path}/managed').list().length, 1);
    await dir.delete(recursive: true);
  });
}
