import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../domain/focus_session.dart';

class FocusSessionRepository {
  FocusSessionRepository(this.db);
  final AppDatabase db;
  Future<void> save(FocusSession session) async => db
      .into(db.focusSessions)
      .insertOnConflictUpdate(
        FocusSessionsCompanion.insert(
          id: session.id,
          linkedTaskId: Value(session.linkedTaskId),
          startedAt: session.startedAt,
          finished: session.terminal,
          document: session.encode(),
        ),
      );
  Stream<List<FocusSession>> watchHistory() =>
      (db.select(db.focusSessions)
            ..where((t) => t.finished.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(100))
          .watch()
          .map(
            (rows) => rows.map((r) => FocusSession.decode(r.document)).toList(),
          );
  Future<FocusSession?> recover() async {
    final rows =
        await (db.select(db.focusSessions)
              ..where((t) => t.finished.equals(false))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
            .get();
    return rows.isEmpty ? null : FocusSession.decode(rows.first.document);
  }
}
