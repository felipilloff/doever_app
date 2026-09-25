import 'dart:async';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../logging.dart';
import 'reminder_service.dart';

/// Serializes OS writes. Revision checks prevent acknowledging newer edits.
final class ReminderWorker {
  ReminderWorker(this.database, this.service, {required this.onFailure});
  final AppDatabase database;
  final ReminderService service;
  final void Function() onFailure;
  StreamSubscription<List<ReminderJob>>? _subscription;
  Timer? _retry;
  Completer<void>? _idle;
  bool _running = false, _again = false, _closed = false;
  void start() {
    _subscription =
        (database.select(
          database.reminderJobs,
        )..where((j) => j.pending.equals(true))).watch().listen(
          (_) => unawaited(flush()),
          onError: (Object e, StackTrace s) {
            logFailure('reminders.watch', e, s);
            onFailure();
          },
        );
    _retry = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(flush()),
    );
  }

  Future<void> flush() async {
    if (_closed) return;
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    _idle = Completer<void>();
    try {
      do {
        _again = false;
        final jobs = await (database.select(
          database.reminderJobs,
        )..where((j) => j.pending.equals(true))).get();
        for (final job in jobs) {
          if (_closed) return;
          try {
            final task = await (database.select(
              database.tasks,
            )..where((t) => t.id.equals(job.taskId))).getSingle();
            await service.cancel(job.notificationId);
            if (task.deletedAt == null &&
                !task.isCompleted &&
                task.reminderAt != null &&
                task.reminderAt!.isAfter(DateTime.now())) {
              await service.schedule(
                id: job.notificationId,
                taskId: task.id,
                title: task.title,
                at: task.reminderAt!.toUtc(),
              );
            }
            await (database.update(database.reminderJobs)..where(
                  (j) =>
                      j.notificationId.equals(job.notificationId) &
                      j.revision.equals(job.revision),
                ))
                .write(const ReminderJobsCompanion(pending: Value(false)));
          } catch (error, stack) {
            logFailure('reminders.apply', error, stack);
            onFailure();
          }
        }
      } while (_again && !_closed);
    } catch (error, stack) {
      logFailure('reminders.flush', error, stack);
      onFailure();
    } finally {
      _running = false;
      _idle?.complete();
    }
  }

  Future<void> dispose() async {
    _closed = true;
    _retry?.cancel();
    await _subscription?.cancel();
    await _idle?.future;
  }
}
