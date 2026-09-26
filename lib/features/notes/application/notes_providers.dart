import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/note_repository.dart';

bool get supportsNotes =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => throw StateError('Notes not bootstrapped'),
);
final notePagesProvider = StreamProvider.autoDispose.family(
  (ref, String search) =>
      ref.watch(noteRepositoryProvider).watchPages(search: search),
);
final noteBlocksProvider = StreamProvider.autoDispose.family(
  (ref, String pageId) => ref.watch(noteRepositoryProvider).watchBlocks(pageId),
);

/// Router exits share the editor's flush operation, including reminder deep links.
final noteLeaveGuardProvider = Provider((ref) => NoteLeaveGuard());

class NoteLeaveGuard {
  Future<bool> Function()? save;
  Future<bool> flush() async => await save?.call() ?? true;
}
