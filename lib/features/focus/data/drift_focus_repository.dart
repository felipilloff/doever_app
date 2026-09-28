import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../../core/logging.dart';
import '../domain/audio_engine.dart';
import '../domain/soundscape.dart';
import 'soundscape_codec.dart';

class DriftFocusRepository implements FocusRepository {
  DriftFocusRepository(this.db);
  final AppDatabase db;

  @override
  Stream<List<Soundscape>> watchSoundscapes() => db
      .select(db.focusSoundscapes)
      .watch()
      .map(
        (rows) =>
            rows.map((r) => SoundscapeCodec.decode(r.document)).toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      )
      .handleError((Object error, StackTrace stack) {
        logFailure('focus.library', error, stack);
        throw error;
      });

  @override
  Future<void> save(Soundscape soundscape) async {
    if (soundscape.isBuiltIn || soundscape.id.startsWith('preset:')) {
      throw ArgumentError('Presets are immutable');
    }
    await db
        .into(db.focusSoundscapes)
        .insertOnConflictUpdate(
          FocusSoundscapesCompanion.insert(
            id: soundscape.id,
            document: SoundscapeCodec.encode(soundscape),
          ),
        );
  }

  @override
  Future<void> delete(String id) => db.transaction(() async {
    await (db.delete(db.focusSoundscapes)..where((t) => t.id.equals(id))).go();
    final prefs = await loadPreferences();
    if (prefs.mix?.id == id) {
      await savePreferences(
        FocusPreferences(masterVolume: prefs.masterVolume, muted: prefs.muted),
      );
    }
  });

  @override
  Future<FocusPreferences> loadPreferences() async {
    final row = await db.select(db.focusSettings).getSingleOrNull();
    return row == null
        ? FocusPreferences()
        : FocusPreferences(
            mix: row.mix == null ? null : SoundscapeCodec.decode(row.mix!),
            masterVolume: row.masterVolume,
            muted: row.muted,
          );
  }

  @override
  Future<void> savePreferences(FocusPreferences p) async {
    await db
        .into(db.focusSettings)
        .insertOnConflictUpdate(
          FocusSettingsCompanion.insert(
            id: const Value(1),
            mix: Value(p.mix == null ? null : SoundscapeCodec.encode(p.mix!)),
            masterVolume: Value(p.masterVolume),
            muted: Value(p.muted),
          ),
        );
  }
}
