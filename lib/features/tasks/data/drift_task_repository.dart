import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../core/logging.dart';
import '../../../database/app_database.dart' as db;
import '../../lists/domain/task_list.dart';
import '../domain/calendar_date.dart';
import '../domain/recurrence.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';

final class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this.database, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final db.AppDatabase database;
  final DateTime Function() clock;
  static const _uuid = Uuid();
  DateTime get _now => clock().toUtc();
  String _title(String text, [int max = 500]) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > max) {
      throw const AppFailure(FailureKind.validation);
    }
    return trimmed;
  }

  Future<T> _write<T>(Future<T> Function() action) async {
    try {
      return await database.transaction(action);
    } on AppFailure {
      rethrow;
    } catch (error, stack) {
      logFailure('persistence.write', error, stack);
      throw const AppFailure(FailureKind.persistence);
    }
  }

  Task _task(db.Task row) => Task(
    id: row.id,
    listId: row.listId,
    title: row.title,
    notes: row.notes,
    isCompleted: row.isCompleted,
    isImportant: row.isImportant,
    myDayDate: row.myDayDate == null
        ? null
        : CalendarDate.parse(row.myDayDate!),
    dueDate: row.dueDate == null ? null : CalendarDate.parse(row.dueDate!),
    reminderAt: row.reminderAt?.toUtc(),
    recurrenceRule: row.recurrenceRule,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    completedAt: row.completedAt?.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
  );
  @override
  Future<void> initialize() => _write(() async {
    await database
        .into(database.lists)
        .insert(
          db.ListsCompanion.insert(
            id: inboxId,
            name: 'Tasks',
            sortOrder: 0,
            createdAt: _now,
            updatedAt: _now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  });
  @override
  Stream<List<Task>> watchTasks(TaskQuery query) {
    final select = database.select(database.tasks)
      ..where((t) => t.deletedAt.isNull());
    switch (query.view) {
      case TaskView.myDay:
        select.where(
          (t) =>
              t.myDayDate.equals(query.today.toString()) &
              t.isCompleted.equals(false),
        );
      case TaskView.important:
        select.where(
          (t) => t.isImportant.equals(true) & t.isCompleted.equals(false),
        );
      case TaskView.planned:
        select.where(
          (t) => t.dueDate.isNotNull() & t.isCompleted.equals(false),
        );
      case TaskView.list:
        select.where((t) => t.listId.equals(query.listId));
      case TaskView.search:
        // Escape SQL wildcards so user input is a literal substring.
        final pattern =
            "%${query.search.toLowerCase().replaceAll("!", "!!").replaceAll("%", "!%").replaceAll("_", "!_")}%";
        select.where(
          (t) =>
              t.title.lower().like(pattern, escapeChar: '!') |
              t.notes.lower().like(pattern, escapeChar: '!'),
        );
    }
    if (!query.showCompleted) select.where((t) => t.isCompleted.equals(false));
    select.orderBy([
      (t) => OrderingTerm.asc(t.isCompleted),
      if (query.view == TaskView.planned) (t) => OrderingTerm.asc(t.dueDate),
      (t) => OrderingTerm.asc(t.sortOrder),
      (t) => OrderingTerm.asc(t.id),
    ]);
    return select.watch().map((rows) => rows.map(_task).toList());
  }

  @override
  Stream<Task?> watchTask(String id) =>
      (database.select(database.tasks)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _task(r));
  @override
  Future<Task?> getTask(String id) async {
    final row = await (database.select(
      database.tasks,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _task(row);
  }

  Future<db.Task> _active(String id) async {
    final task = await (database.select(
      database.tasks,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (task == null) throw const AppFailure(FailureKind.validation);
    return task;
  }

  Future<void> _validList(String id) async {
    if (await (database.select(database.lists)
              ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
            .getSingleOrNull() ==
        null) {
      throw const AppFailure(FailureKind.validation);
    }
  }

  Future<void> _queue(String id) async {
    await database.customStatement(
      'INSERT INTO reminder_jobs (task_id, revision, pending) VALUES (?, 1, 1) '
      'ON CONFLICT(task_id) DO UPDATE SET revision = revision + 1, pending = 1',
      [id],
    );
    database.notifyUpdates({TableUpdate.onTable(database.reminderJobs)});
  }

  @override
  Future<String> createTask(
    String title, {
    String listId = inboxId,
    TaskPatch? patch,
  }) => _write(() async {
    await _validList(listId);
    final id = _uuid.v4();
    final max = database.tasks.sortOrder.max();
    final row = await (database.selectOnly(
      database.tasks,
    )..addColumns([max])).getSingle();
    await database
        .into(database.tasks)
        .insert(
          db.TasksCompanion.insert(
            id: id,
            listId: listId,
            title: _title(title),
            sortOrder: (row.read(max) ?? 0) + 1024,
            createdAt: _now,
            updatedAt: _now,
          ),
        );
    if (patch != null) await updateTask(id, patch);
    return id;
  });
  @override
  Future<void> updateTask(String id, TaskPatch patch) => _write(() async {
    await _active(id);
    if (patch.listId != null) await _validList(patch.listId!);
    if (patch.notes != null && patch.notes!.length > 100000) {
      throw const AppFailure(FailureKind.validation);
    }
    if (patch.recurrenceRule?.value != null) {
      try {
        Recurrence.parse(patch.recurrenceRule!.value!);
      } on FormatException {
        throw const AppFailure(FailureKind.validation);
      }
    }
    await (database.update(
      database.tasks,
    )..where((t) => t.id.equals(id))).write(
      db.TasksCompanion(
        title: patch.title == null
            ? const Value.absent()
            : Value(_title(patch.title!)),
        notes: patch.notes == null ? const Value.absent() : Value(patch.notes!),
        listId: patch.listId == null
            ? const Value.absent()
            : Value(patch.listId!),
        isImportant: patch.isImportant == null
            ? const Value.absent()
            : Value(patch.isImportant!),
        myDayDate: patch.myDayDate == null
            ? const Value.absent()
            : Value(patch.myDayDate!.value?.toString()),
        dueDate: patch.dueDate == null
            ? const Value.absent()
            : Value(patch.dueDate!.value?.toString()),
        reminderAt: patch.reminderAt == null
            ? const Value.absent()
            : Value(patch.reminderAt!.value?.toUtc()),
        recurrenceRule: patch.recurrenceRule == null
            ? const Value.absent()
            : Value(patch.recurrenceRule!.value),
        updatedAt: Value(_now),
      ),
    );
    if (patch.reminderAt != null || patch.title != null) await _queue(id);
  });
  @override
  Future<void> completeTask(String id, bool completed) => _write(() async {
    final task = await _active(id);
    if (task.isCompleted == completed) return;
    if (completed &&
        task.recurrenceRule != null &&
        task.nextOccurrenceId == null) {
      final base = task.dueDate == null
          ? CalendarDate.fromLocal(clock())
          : CalendarDate.parse(task.dueDate!);
      final next = Recurrence.parse(task.recurrenceRule!).next(base);
      final nextId = _uuid.v4();
      await database
          .into(database.tasks)
          .insert(
            db.TasksCompanion.insert(
              id: nextId,
              listId: task.listId,
              title: task.title,
              notes: Value(task.notes),
              isImportant: Value(task.isImportant),
              dueDate: Value(next.toString()),
              recurrenceRule: Value(task.recurrenceRule),
              sortOrder: task.sortOrder + 0.5,
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      final steps = await (database.select(
        database.steps,
      )..where((s) => s.taskId.equals(id) & s.deletedAt.isNull())).get();
      for (final step in steps) {
        await database
            .into(database.steps)
            .insert(
              db.StepsCompanion.insert(
                id: _uuid.v4(),
                taskId: nextId,
                title: step.title,
                sortOrder: step.sortOrder,
                createdAt: _now,
                updatedAt: _now,
              ),
            );
      }
      await (database.update(database.tasks)..where((t) => t.id.equals(id)))
          .write(db.TasksCompanion(nextOccurrenceId: Value(nextId)));
    }
    await (database.update(
      database.tasks,
    )..where((t) => t.id.equals(id))).write(
      db.TasksCompanion(
        isCompleted: Value(completed),
        completedAt: Value(completed ? _now : null),
        updatedAt: Value(_now),
      ),
    );
    await _queue(id);
  });
  @override
  Future<void> deleteTask(String id) => _write(() async {
    await _active(id);
    await (database.update(
      database.tasks,
    )..where((t) => t.id.equals(id))).write(
      db.TasksCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
    // Steps remain attached and hidden by the parent, so undo restores them.
    await _queue(id);
  });
  @override
  Future<void> restoreTask(String id) => _write(() async {
    final task = await (database.select(
      database.tasks,
    )..where((t) => t.id.equals(id))).getSingle();
    final list = await (database.select(
      database.lists,
    )..where((t) => t.id.equals(task.listId))).getSingle();
    await (database.update(
      database.tasks,
    )..where((t) => t.id.equals(id))).write(
      db.TasksCompanion(
        deletedAt: const Value(null),
        listId: Value(list.deletedAt == null ? task.listId : inboxId),
        updatedAt: Value(_now),
      ),
    );
    await _queue(id);
  });
  @override
  Stream<List<TaskList>> watchLists() {
    final count = database.tasks.id.count();
    final query =
        database.select(database.lists).join([
            leftOuterJoin(
              database.tasks,
              database.tasks.listId.equalsExp(database.lists.id) &
                  database.tasks.deletedAt.isNull() &
                  database.tasks.isCompleted.equals(false),
            ),
          ])
          ..addColumns([count])
          ..where(database.lists.deletedAt.isNull())
          ..groupBy([database.lists.id])
          ..orderBy([
            OrderingTerm.asc(database.lists.sortOrder),
            OrderingTerm.asc(database.lists.id),
          ]);
    return query.watch().map(
      (rows) => rows.map((row) {
        final list = row.readTable(database.lists);
        return TaskList(
          id: list.id,
          name: list.name,
          color: list.color,
          icon: list.icon,
          sortOrder: list.sortOrder,
          createdAt: list.createdAt,
          updatedAt: list.updatedAt,
          taskCount: row.read(count) ?? 0,
        );
      }).toList(),
    );
  }

  @override
  Future<String> createList(String name) => _write(() async {
    final id = _uuid.v4();
    final max = database.lists.sortOrder.max();
    final row = await (database.selectOnly(
      database.lists,
    )..addColumns([max])).getSingle();
    await database
        .into(database.lists)
        .insert(
          db.ListsCompanion.insert(
            id: id,
            name: _title(name, 200),
            sortOrder: (row.read(max) ?? 0) + 1024,
            createdAt: _now,
            updatedAt: _now,
          ),
        );
    return id;
  });
  @override
  Future<void> renameList(String id, String name) => _write(() async {
    if (id == inboxId) throw const AppFailure(FailureKind.validation);
    await _validList(id);
    await (database.update(
      database.lists,
    )..where((t) => t.id.equals(id))).write(
      db.ListsCompanion(name: Value(_title(name, 200)), updatedAt: Value(_now)),
    );
  });
  @override
  Future<void> deleteList(String id) => _write(() async {
    if (id == inboxId) throw const AppFailure(FailureKind.validation);
    await _validList(id);
    await (database.update(
      database.tasks,
    )..where((t) => t.listId.equals(id) & t.deletedAt.isNull())).write(
      db.TasksCompanion(listId: const Value(inboxId), updatedAt: Value(_now)),
    );
    await (database.update(
      database.lists,
    )..where((t) => t.id.equals(id))).write(
      db.ListsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  });
  @override
  Stream<List<TaskStep>> watchSteps(String taskId) =>
      (database.select(database.steps).join([
              innerJoin(
                database.tasks,
                database.tasks.id.equalsExp(database.steps.taskId),
              ),
            ])
            ..where(
              database.steps.taskId.equals(taskId) &
                  database.steps.deletedAt.isNull() &
                  database.tasks.deletedAt.isNull(),
            )
            ..orderBy([
              OrderingTerm.asc(database.steps.sortOrder),
              OrderingTerm.asc(database.steps.id),
            ]))
          .watch()
          .map(
            (rows) => rows.map((joined) {
              final s = joined.readTable(database.steps);
              return TaskStep(
                id: s.id,
                taskId: s.taskId,
                title: s.title,
                isCompleted: s.isCompleted,
                sortOrder: s.sortOrder,
                createdAt: s.createdAt,
                updatedAt: s.updatedAt,
              );
            }).toList(),
          );
  @override
  Future<void> addStep(String taskId, String title) => _write(() async {
    await _active(taskId);
    final max = database.steps.sortOrder.max();
    final row =
        await (database.selectOnly(database.steps)
              ..addColumns([max])
              ..where(database.steps.taskId.equals(taskId)))
            .getSingle();
    await database
        .into(database.steps)
        .insert(
          db.StepsCompanion.insert(
            id: _uuid.v4(),
            taskId: taskId,
            title: _title(title),
            sortOrder: (row.read(max) ?? 0) + 1024,
            createdAt: _now,
            updatedAt: _now,
          ),
        );
  });
  @override
  Future<void> updateStep(String id, {String? title, bool? completed}) =>
      _write(() async {
        final step = await (database.select(
          database.steps,
        )..where((s) => s.id.equals(id) & s.deletedAt.isNull())).getSingle();
        await _active(step.taskId);
        await (database.update(
          database.steps,
        )..where((s) => s.id.equals(id))).write(
          db.StepsCompanion(
            title: title == null ? const Value.absent() : Value(_title(title)),
            isCompleted: completed == null
                ? const Value.absent()
                : Value(completed),
            updatedAt: Value(_now),
          ),
        );
      });
  @override
  Future<void> deleteStep(String id) => _write(() async {
    await (database.update(
      database.steps,
    )..where((s) => s.id.equals(id))).write(
      db.StepsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  });
  @override
  Future<void> reorderList(
    String id, {
    String? beforeId,
    String? afterId,
  }) => _write(() async {
    if (id == inboxId) throw const AppFailure(FailureKind.validation);
    final rows =
        await (database.select(database.lists)
              ..where((s) => s.deletedAt.isNull() & s.id.equals(inboxId).not())
              ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
            .get();
    await _reorder(
      id,
      beforeId,
      afterId,
      rows.map((r) => (r.id, r.sortOrder)).toList(),
      (key, position) async {
        await (database.update(
          database.lists,
        )..where((s) => s.id.equals(key))).write(
          db.ListsCompanion(sortOrder: Value(position), updatedAt: Value(_now)),
        );
      },
    );
  });
  @override
  Future<void> reorderStep(String id, {String? beforeId, String? afterId}) =>
      _write(() async {
        final step = await (database.select(
          database.steps,
        )..where((s) => s.id.equals(id))).getSingle();
        await _active(step.taskId);
        final rows =
            await (database.select(database.steps)
                  ..where(
                    (s) => s.taskId.equals(step.taskId) & s.deletedAt.isNull(),
                  )
                  ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
                .get();
        await _reorder(
          id,
          beforeId,
          afterId,
          rows.map((r) => (r.id, r.sortOrder)).toList(),
          (key, position) async {
            await (database.update(
              database.steps,
            )..where((s) => s.id.equals(key))).write(
              db.StepsCompanion(
                sortOrder: Value(position),
                updatedAt: Value(_now),
              ),
            );
          },
        );
      });
  Future<void> _reorder(
    String id,
    String? before,
    String? after,
    List<(String, double)> rows,
    Future<void> Function(String, double) write,
  ) async {
    if (!rows.any((r) => r.$1 == id)) {
      throw const AppFailure(FailureKind.validation);
    }
    final remaining = rows.where((r) => r.$1 != id).toList();
    final index = before == null
        ? remaining.length
        : remaining.indexWhere((r) => r.$1 == before);
    if (index < 0 ||
        (after != null && (index == 0 || remaining[index - 1].$1 != after))) {
      throw const AppFailure(FailureKind.validation);
    }
    final low = index == 0
        ? (remaining.isEmpty ? 0.0 : remaining.first.$2 - 2048)
        : remaining[index - 1].$2;
    final high = index == remaining.length ? low + 2048 : remaining[index].$2;
    if (high - low > 0.000001) {
      await write(id, (low + high) / 2);
      return;
    }
    // Rare precision exhaustion: normalize only this collection, transactionally.
    remaining.insert(index, (id, 0));
    for (var i = 0; i < remaining.length; i++) {
      await write(remaining[i].$1, (i + 1) * 1024.0);
    }
  }
}
