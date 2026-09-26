import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../core/local_image.dart';

final noteImagesProvider = Provider(
  (ref) => NoteImages(
    () async => Directory(
      '${(await getApplicationSupportDirectory()).path}/note_images',
    ),
  ),
);

class NoteImages {
  NoteImages(this.directory);
  final Future<Directory> Function() directory;
  Future<String> import(XFile selected) async {
    if (await selected.length() > 20 * 1024 * 1024) {
      throw const AppFailure(FailureKind.backgroundImage);
    }
    final input = await selected.readAsBytes();
    if (input.length > 20 * 1024 * 1024) {
      throw const AppFailure(FailureKind.backgroundImage);
    }
    final bytes = await prepareLocalImage(input);
    final name = '${const Uuid().v4()}.png';
    final target = await file(name);
    await target.parent.create(recursive: true);
    await target.writeAsBytes(bytes, flush: true);
    return name;
  }

  Future<File> file(String name) async {
    if (!RegExp(r'^[a-f0-9-]{36}\.png$').hasMatch(name)) {
      throw const AppFailure(FailureKind.validation);
    }
    return File('${(await directory()).path}/$name');
  }
}
