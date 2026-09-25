import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:doever/features/tasks/domain/calendar_date.dart';
import 'package:doever/features/tasks/domain/recurrence.dart';
import 'package:doever/features/tasks/domain/task.dart' as domain;
import 'package:doever/core/errors.dart';

void main() {
  // Tests intentionally open distinct in-memory and file executors.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late DriftTaskRepository repo;
  final today = CalendarDate(2026, 9, 25);
  domain.TaskQuery query(
    domain.TaskView view, {
    String listId = domain.inboxId,
    String search = '',
  }) => domain.TaskQuery(
    view: view,
    listId: listId,
    search: search,
    today: today,
  );
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTaskRepository(db, clock: () => DateTime(2026, 9, 25, 12));
    await repo.initialize();
  });
  tearDown(() => db.close());
  test('first run is idempotent and creates exactly one inbox', () async {
    await repo.initialize();
    expect(await repo.watchLists().first, hasLength(1));
    expect((await repo.watchLists().first).single.id, domain.inboxId);
    expect(
      (await db.customSelect('PRAGMA foreign_keys').getSingle())
          .data
          .values
          .single,
      1,
    );
  });
  test('CRUD, smart views and completion refer to one task', () async {
    final id = await repo.createTask(
      '  Plan trip  ',
      patch: domain.TaskPatch(
        myDayDate: domain.Change(today),
        dueDate: domain.Change(today.addDays(2)),
        isImportant: true,
      ),
    );
    for (final view in [
      domain.TaskView.myDay,
      domain.TaskView.important,
      domain.TaskView.planned,
      domain.TaskView.list,
    ]) {
      expect((await repo.watchTasks(query(view)).first).single.id, id);
    }
    expect(await db.select(db.tasks).get(), hasLength(1));
    await repo.updateTask(
      id,
      const domain.TaskPatch(title: 'Plan holiday', notes: 'Packing checklist'),
    );
    expect((await repo.getTask(id))!.title, 'Plan holiday');
    await repo.completeTask(id, true);
    expect((await repo.getTask(id))!.completedAt, isNotNull);
    expect(await repo.watchTasks(query(domain.TaskView.myDay)).first, isEmpty);
    expect(
      await repo.watchTasks(query(domain.TaskView.important)).first,
      isEmpty,
    );
    expect(
      await repo.watchTasks(query(domain.TaskView.planned)).first,
      isEmpty,
    );
    await repo.completeTask(id, false);
    expect((await repo.getTask(id))!.completedAt, isNull);
    expect(
      await repo.watchTasks(query(domain.TaskView.myDay)).first,
      hasLength(1),
    );
    expect(
      await repo.watchTasks(domain.TaskQuery(today: today.addDays(1))).first,
      isEmpty,
    );
    await repo.updateTask(
      id,
      const domain.TaskPatch(
        dueDate: domain.Change(null),
        myDayDate: domain.Change(null),
        isImportant: false,
      ),
    );
    expect(
      await repo.watchTasks(query(domain.TaskView.planned)).first,
      isEmpty,
    );
  });
  test(
    'search matches title and notes, is case insensitive and escapes wildcards',
    () async {
      await repo.createTask(
        '100% ready',
        patch: const domain.TaskPatch(notes: 'Project_ALPHA'),
      );
      await repo.createTask('1000 ready');
      expect(
        await repo
            .watchTasks(query(domain.TaskView.search, search: 'READY'))
            .first,
        hasLength(2),
      );
      expect(
        await repo.watchTasks(query(domain.TaskView.search, search: '%')).first,
        hasLength(1),
      );
      expect(
        await repo
            .watchTasks(query(domain.TaskView.search, search: '_alpha'))
            .first,
        hasLength(1),
      );
      expect(
        await repo
            .watchTasks(query(domain.TaskView.search, search: "' OR 1=1 --"))
            .first,
        isEmpty,
      );
    },
  );
  test(
    'move, list deletion and restore preserve tasks without resurrecting lists',
    () async {
      final list = await repo.createList('Work');
      await repo.renameList(list, 'Projects');
      final id = await repo.createTask('A');
      await repo.updateTask(id, domain.TaskPatch(listId: list));
      expect(
        await repo.watchTasks(query(domain.TaskView.list, listId: list)).first,
        hasLength(1),
      );
      await repo.addStep(id, 'Step');
      await repo.deleteTask(id);
      expect(await repo.watchSteps(id).first, isEmpty);
      expect(await repo.getTask(id), isNull);
      await repo.deleteList(list);
      await repo.restoreTask(id);
      expect((await repo.getTask(id))!.listId, domain.inboxId);
      expect(await repo.watchSteps(id).first, hasLength(1));
      final second = await repo.createList('Second');
      await repo.updateTask(id, domain.TaskPatch(listId: second));
      await repo.deleteList(second);
      expect((await repo.getTask(id))!.listId, domain.inboxId);
      expect(() => repo.deleteList(domain.inboxId), throwsA(isA<AppFailure>()));
      expect(
        () => repo.updateTask(id, domain.TaskPatch(listId: second)),
        throwsA(isA<AppFailure>()),
      );
    },
  );
  test('steps can be edited, completed, reordered and soft deleted', () async {
    final id = await repo.createTask('Task');
    await repo.addStep(id, 'First');
    await repo.addStep(id, 'Second');
    final steps = await repo.watchSteps(id).first;
    await repo.updateStep(steps.first.id, title: 'Edited', completed: true);
    await repo.reorderStep(steps.last.id, beforeId: steps.first.id);
    expect((await repo.watchSteps(id).first).first.title, 'Second');
    expect((await repo.watchSteps(id).first).last.isCompleted, true);
    await repo.deleteStep(steps.first.id);
    expect(await repo.watchSteps(id).first, hasLength(1));
    expect(await db.select(db.steps).get(), hasLength(2));
  });
  test(
    'list reordering modifies one position and remains deterministic',
    () async {
      final a = await repo.createList('A'),
          b = await repo.createList('B'),
          c = await repo.createList('C');
      await repo.reorderList(c, beforeId: a);
      expect((await repo.watchLists().first).map((l) => l.id), [
        domain.inboxId,
        c,
        a,
        b,
      ]);
      await repo.reorderList(c, afterId: b);
      expect((await repo.watchLists().first).map((l) => l.id), [
        domain.inboxId,
        a,
        b,
        c,
      ]);
    },
  );
  test(
    'recurrence completion is atomic and idempotent, cloning reset steps',
    () async {
      final id = await repo.createTask(
        'Monthly',
        patch: domain.TaskPatch(
          dueDate: domain.Change(CalendarDate(2026, 1, 31)),
          recurrenceRule: domain.Change(Recurrence.monthly.rule),
          myDayDate: domain.Change(today),
        ),
      );
      await repo.addStep(id, 'Review');
      final step = (await repo.watchSteps(id).first).single;
      await repo.updateStep(step.id, completed: true);
      await Future.wait([
        repo.completeTask(id, true),
        repo.completeTask(id, true),
      ]);
      await repo.completeTask(id, false);
      await repo.completeTask(id, true);
      final all = await repo.watchTasks(query(domain.TaskView.list)).first;
      expect(all, hasLength(2));
      final next = all.singleWhere((t) => t.id != id);
      expect(next.dueDate, CalendarDate(2026, 3, 31));
      expect(next.myDayDate, isNull);
      expect(next.reminderAt, isNull);
      expect((await repo.watchSteps(next.id).first).single.isCompleted, false);
    },
  );
  test('recurrence without due date starts from completion calendar', () async {
    final id = await repo.createTask(
      'Daily',
      patch: domain.TaskPatch(
        recurrenceRule: domain.Change(Recurrence.daily.rule),
      ),
    );
    await repo.completeTask(id, true);
    expect(
      (await repo.watchTasks(query(domain.TaskView.planned)).first)
          .single
          .dueDate,
      today.addDays(1),
    );
  });
  test(
    'planned sorting is chronological and completed preference filters',
    () async {
      final later = await repo.createTask(
        'Later',
        patch: domain.TaskPatch(dueDate: domain.Change(today.addDays(10))),
      );
      await repo.createTask(
        'Earlier',
        patch: domain.TaskPatch(dueDate: domain.Change(today)),
      );
      expect(
        (await repo.watchTasks(query(domain.TaskView.planned)).first).map(
          (t) => t.title,
        ),
        ['Earlier', 'Later'],
      );
      await repo.completeTask(later, true);
      expect(
        await repo
            .watchTasks(
              domain.TaskQuery(
                view: domain.TaskView.list,
                today: today,
                showCompleted: false,
              ),
            )
            .first,
        hasLength(1),
      );
      expect((await repo.watchLists().first).single.taskCount, 1);
    },
  );
  test('invalid input rolls back creation and does not corrupt data', () async {
    expect(() => repo.createTask('   '), throwsA(isA<AppFailure>()));
    expect(
      () => repo.createTask(
        'Task',
        patch: const domain.TaskPatch(recurrenceRule: domain.Change('invalid')),
      ),
      throwsA(isA<AppFailure>()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(await db.select(db.tasks).get(), isEmpty);
  });
  test('soft deletion retains tombstones and queues cancellation', () async {
    final id = await repo.createTask('Private');
    await repo.deleteTask(id);
    expect(await repo.watchTasks(query(domain.TaskView.search)).first, isEmpty);
    expect((await db.select(db.tasks).get()).single.deletedAt, isNotNull);
    expect((await db.select(db.reminderJobs).get()).single.pending, true);
  });
  test(
    'file database survives close/reopen with schema version and all fields',
    () async {
      final dir = await Directory.systemTemp.createTemp('doever-test-');
      final file = File('${dir.path}/tasks.sqlite');
      var disk = AppDatabase(NativeDatabase(file));
      var saved = DriftTaskRepository(disk);
      try {
        await saved.initialize();
        final list = await saved.createList('Persisted');
        final id = await saved.createTask(
          'Durable',
          listId: list,
          patch: domain.TaskPatch(
            notes: 'Notes',
            dueDate: domain.Change(today),
            reminderAt: domain.Change(DateTime.utc(2030, 4, 2, 5)),
          ),
        );
        await saved.addStep(id, 'Persisted step');
        await disk.close();
        disk = AppDatabase(NativeDatabase(file));
        saved = DriftTaskRepository(disk);
        await saved.initialize();
        expect((await saved.getTask(id))!.notes, 'Notes');
        expect((await saved.getTask(id))!.dueDate, today);
        expect(
          (await saved.getTask(id))!.reminderAt,
          DateTime.utc(2030, 4, 2, 5),
        );
        expect(await saved.watchSteps(id).first, hasLength(1));
        expect(await saved.watchLists().first, hasLength(2));
        expect(
          (await disk.customSelect('PRAGMA user_version').getSingle())
              .data
              .values
              .single,
          1,
        );
      } finally {
        await disk.close();
        await dir.delete(recursive: true);
      }
    },
  );
}
