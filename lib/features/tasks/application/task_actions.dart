import '../../../core/errors.dart';
import '../../../core/notifications/reminder_service.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';

final class TaskActions {
  TaskActions(this.repository, this.reminders);
  final TaskRepository repository;
  final ReminderService reminders;
  Future<void> setReminder(String id, DateTime? at) async {
    if (at != null) {
      if (!at.isAfter(DateTime.now())) {
        throw const AppFailure(FailureKind.validation);
      }
      if (!await reminders.requestPermission()) {
        throw const AppFailure(FailureKind.notification);
      }
    }
    await repository.updateTask(id, TaskPatch(reminderAt: Change(at)));
  }
}
