import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/errors.dart';
import '../../../core/logging.dart';
import '../../../core/local_image.dart';

bool get supportsDesktopBackground =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

final backgroundDirectoryProvider = Provider<Future<Directory> Function()>(
  (ref) => () async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}/backgrounds');
  },
);

final backgroundProvider =
    AsyncNotifierProvider<BackgroundPreference, Uint8List?>(
      BackgroundPreference.new,
    );

class BackgroundPreference extends AsyncNotifier<Uint8List?> {
  static const preferenceKey = 'backgroundImage';
  static const maxFileBytes = 20 * 1024 * 1024;

  @override
  Future<Uint8List?> build() async {
    if (!supportsDesktopBackground) return null;
    final name = ref.read(preferencesProvider).getString(preferenceKey);
    if (name == null) return null;
    final file = await _file(name);
    // An optimized 2560px PNG can exceed the input file size limit.
    if (await file.length() > 32 * 1024 * 1024) {
      throw const AppFailure(FailureKind.backgroundImage);
    }
    return prepareLocalImage(await file.readAsBytes());
  }

  Future<File> _file(String name) async {
    if (!RegExp(r'^[a-f0-9-]{36}\.png$').hasMatch(name)) {
      throw const AppFailure(FailureKind.backgroundImage);
    }
    final directory = await ref.read(backgroundDirectoryProvider)();
    return File('${directory.path}/$name');
  }

  Future<void> importImage(XFile selected) async {
    if (!supportsDesktopBackground) return;
    if (await selected.length() > maxFileBytes) {
      throw const AppFailure(FailureKind.backgroundImage);
    }
    final input = await selected.readAsBytes();
    if (input.length > maxFileBytes) {
      throw const AppFailure(FailureKind.backgroundImage);
    }
    final bytes = await prepareLocalImage(input);
    final preferences = ref.read(preferencesProvider);
    final previous = preferences.getString(preferenceKey);
    final name = '${const Uuid().v4()}.png';
    final file = await _file(name);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      if (!await preferences.setString(preferenceKey, name)) {
        throw const AppFailure(FailureKind.persistence);
      }
    } catch (error, stack) {
      await _delete(name);
      logFailure('background.save', error, stack);
      throw const AppFailure(FailureKind.persistence);
    }
    await _delete(previous);
    state = AsyncData(bytes);
  }

  Future<void> remove() async {
    final preferences = ref.read(preferencesProvider);
    final previous = preferences.getString(preferenceKey);
    if (!await preferences.remove(preferenceKey)) {
      throw const AppFailure(FailureKind.persistence);
    }
    await _delete(previous);
    state = const AsyncData(null);
  }

  Future<void> _delete(String? name) async {
    if (name == null) return;
    try {
      final file = await _file(name);
      if (await file.exists()) await file.delete();
    } catch (error, stack) {
      // Cleanup failure must not undo a successfully saved preference.
      logFailure('background.cleanup', error, stack);
    }
  }
}
