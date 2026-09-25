import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doever/database/app_database.dart';
import 'package:doever/features/tasks/data/drift_task_repository.dart';
import 'package:doever/features/tasks/application/task_actions.dart';
import 'package:doever/core/notifications/reminder_worker.dart';
import 'package:doever/core/errors.dart';

import 'support/fake_reminders.dart';

void main() {
  test(
    'permission only on assignment; durable retries, updates and cancellations',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftTaskRepository(db);
      await repo.initialize();
      final fake = FakeReminders();
      final actions = TaskActions(repo, fake);
      var failures = 0;
      final worker = ReminderWorker(db, fake, onFailure: () => failures++);
      try {
        final id = await repo.createTask('A');
        await worker.flush();
        expect(fake.permissionRequests, 0);
        fake.allow = false;
        await expectLater(
          actions.setReminder(id, DateTime.utc(2099)),
          throwsA(isA<AppFailure>()),
        );
        expect((await repo.getTask(id))!.reminderAt, isNull);
        fake.allow = true;
        fake.fail = true;
        await actions.setReminder(id, DateTime.utc(2099));
        await worker.flush();
        expect(failures, 1);
        expect((await db.select(db.reminderJobs).get()).single.pending, true);
        fake.fail = false;
        await worker.flush();
        expect(fake.scheduled.values.single, DateTime.utc(2099));
        expect((await db.select(db.reminderJobs).get()).single.pending, false);
        await actions.setReminder(id, DateTime.utc(2099, 2));
        await worker.flush();
        expect(fake.scheduled.values.single, DateTime.utc(2099, 2));
        await repo.completeTask(id, true);
        await worker.flush();
        expect(fake.scheduled, isEmpty);
        await repo.completeTask(id, false);
        await worker.flush();
        expect(fake.scheduled, hasLength(1));
        await repo.deleteTask(id);
        await worker.flush();
        expect(fake.scheduled, isEmpty);
        await repo.restoreTask(id);
        await worker.flush();
        expect(fake.scheduled, hasLength(1));
        final requests = fake.permissionRequests;
        await actions.setReminder(id, null);
        await worker.flush();
        expect(fake.scheduled, isEmpty);
        expect(fake.permissionRequests, requests);
      } finally {
        await worker.dispose();
        await db.close();
      }
    },
  );
}
