import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../core/logging.dart';
import '../../../database/app_database.dart' as db;
import '../domain/note.dart';
import '../domain/note_repository.dart';

final class DriftNoteRepository implements NoteRepository {
  DriftNoteRepository(this.database);
  final db.AppDatabase database;
  DateTime get now => DateTime.now().toUtc();

  Future<T> _write<T>(Future<T> Function() action) async {
    try {
      return await database.transaction(action);
    } on AppFailure {
      rethrow;
    } catch (error, stack) {
      logFailure('notes.persistence', error, stack);
      throw const AppFailure(FailureKind.persistence);
    }
  }

  NotePage _page(db.NotePageRow row) => NotePage(
    id: row.id,
    title: row.title,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
  );
  NoteBlock _block(db.NoteBlockRow row) => NoteBlock(
    id: row.id,
    pageId: row.pageId,
    type: NoteBlockType.values.byName(row.type),
    content: row.content,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
    checked: row.checked,
    url: row.url,
    imageName: row.imageName,
    detail: row.detail,
    icon: row.icon,
    expanded: row.expanded,
  );

  @override
  Stream<List<NotePage>> watchPages({String search = ''}) {
    final pattern =
        '%${search.toLowerCase().replaceAll('!', '!!').replaceAll('%', '!%').replaceAll('_', '!_')}%';
    return (database.select(database.notePages)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.title.lower().like(pattern, escapeChar: '!'),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch()
        .map((rows) => rows.map(_page).toList());
  }

  @override
  Stream<List<NoteBlock>> watchBlocks(String pageId) {
    final query =
        database.select(database.noteBlocks).join([
            innerJoin(
              database.notePages,
              database.notePages.id.equalsExp(database.noteBlocks.pageId),
            ),
          ])
          ..where(
            database.noteBlocks.pageId.equals(pageId) &
                database.noteBlocks.deletedAt.isNull() &
                database.notePages.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(database.noteBlocks.sortOrder),
            OrderingTerm.asc(database.noteBlocks.id),
          ]);
    return query.watch().map(
      (rows) =>
          rows.map((r) => _block(r.readTable(database.noteBlocks))).toList(),
    );
  }

  @override
  Future<NoteDocument> load(String pageId) async {
    final page = await (database.select(
      database.notePages,
    )..where((t) => t.id.equals(pageId) & t.deletedAt.isNull())).getSingle();
    final blocks =
        await (database.select(database.noteBlocks)
              ..where((t) => t.pageId.equals(pageId) & t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return NoteDocument(_page(page), blocks.map(_block));
  }

  @override
  Future<NotePage> createPage() => _write(() async {
    final last =
        await (database.select(database.notePages)
              ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
    final id = const Uuid().v4();
    final time = now;
    final order = (last?.sortOrder ?? 0) + 1024;
    await database
        .into(database.notePages)
        .insert(
          db.NotePagesCompanion.insert(
            id: id,
            sortOrder: order,
            createdAt: time,
            updatedAt: time,
          ),
        );
    await database
        .into(database.noteBlocks)
        .insert(
          db.NoteBlocksCompanion.insert(
            id: const Uuid().v4(),
            pageId: id,
            type: NoteBlockType.text.name,
            sortOrder: 1024,
            createdAt: time,
            updatedAt: time,
          ),
        );
    return NotePage(
      id: id,
      title: '',
      sortOrder: order,
      createdAt: time,
      updatedAt: time,
    );
  });

  @override
  Future<void> deletePage(String id) => _write(() async {
    await (database.update(
      database.notePages,
    )..where((t) => t.id.equals(id))).write(
      db.NotePagesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  });
  @override
  Future<void> restorePage(String id) => _write(() async {
    await (database.update(
      database.notePages,
    )..where((t) => t.id.equals(id))).write(
      db.NotePagesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  });
  @override
  Future<void> movePage(String id, int target) => _write(() async {
    final rows =
        await (database.select(database.notePages)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    final old = rows.indexWhere((r) => r.id == id);
    if (old < 0 || target < 0 || target >= rows.length) {
      throw const AppFailure(FailureKind.validation);
    }
    rows.insert(target, rows.removeAt(old));
    final before = target == 0
        ? rows[target + (rows.length > 1 ? 1 : 0)].sortOrder - 2048
        : rows[target - 1].sortOrder;
    final after = target == rows.length - 1
        ? before + 2048
        : rows[target + 1].sortOrder;
    if (after - before > .000001) {
      await (database.update(
        database.notePages,
      )..where((t) => t.id.equals(id))).write(
        db.NotePagesCompanion(
          sortOrder: Value((before + after) / 2),
          updatedAt: Value(now),
        ),
      );
    } else {
      for (var i = 0; i < rows.length; i++) {
        await (database.update(
          database.notePages,
        )..where((t) => t.id.equals(rows[i].id))).write(
          db.NotePagesCompanion(
            sortOrder: Value((i + 1) * 1024.0),
            updatedAt: Value(now),
          ),
        );
      }
    }
  });

  @override
  Future<void> save(String pageId, String title, List<NoteBlock> blocks) =>
      _write(() async {
        if (title.length > 500 ||
            blocks.map((b) => b.id).toSet().length != blocks.length) {
          throw const AppFailure(FailureKind.validation);
        }
        final page =
            await (database.select(database.notePages)
                  ..where((t) => t.id.equals(pageId) & t.deletedAt.isNull()))
                .getSingleOrNull();
        if (page == null) throw const AppFailure(FailureKind.validation);
        final existing = {
          for (final r in await (database.select(
            database.noteBlocks,
          )..where((t) => t.pageId.equals(pageId))).get())
            r.id: r,
        };
        final liveIds = blocks.map((b) => b.id).toSet();
        for (final row in existing.values.where(
          (r) => r.deletedAt == null && !liveIds.contains(r.id),
        )) {
          await (database.update(
            database.noteBlocks,
          )..where((t) => t.id.equals(row.id))).write(
            db.NoteBlocksCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
        for (final block in blocks) {
          if (block.pageId != pageId ||
              !block.sortOrder.isFinite ||
              block.content.length > 1000000 ||
              block.detail.length > 1000000 ||
              block.icon.length > 32 ||
              (block.url.isNotEmpty && !validNoteUrl(block.url)) ||
              (block.imageName.isNotEmpty &&
                  !RegExp(r'^[a-f0-9-]{36}\.png$').hasMatch(block.imageName))) {
            throw const AppFailure(FailureKind.validation);
          }
          final old = existing[block.id];
          if (old != null &&
              old.deletedAt == null &&
              block.sameContent(_block(old))) {
            continue;
          }
          final value = db.NoteBlocksCompanion.insert(
            id: block.id,
            pageId: pageId,
            type: block.type.name,
            content: Value(block.content),
            checked: Value(block.checked),
            url: Value(block.url),
            imageName: Value(block.imageName),
            detail: Value(block.detail),
            icon: Value(block.icon),
            expanded: Value(block.expanded),
            sortOrder: block.sortOrder,
            createdAt: old?.createdAt ?? now,
            updatedAt: now,
            deletedAt: const Value(null),
          );
          // Never upsert an ID owned by another page.
          if (old == null) {
            await database.into(database.noteBlocks).insert(value);
          } else {
            await (database.update(
              database.noteBlocks,
            )..where((t) => t.id.equals(block.id))).write(value);
          }
        }
        await (database.update(
          database.notePages,
        )..where((t) => t.id.equals(pageId))).write(
          db.NotePagesCompanion(title: Value(title), updatedAt: Value(now)),
        );
      });
}
