import 'calendar_date.dart';

const inboxId = '00000000-0000-4000-8000-000000000001';

final class Task {
  const Task({
    required this.id,
    required this.listId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
    this.isCompleted = false,
    this.isImportant = false,
    this.myDayDate,
    this.dueDate,
    this.reminderAt,
    this.recurrenceRule,
    this.sortOrder = 0,
    this.completedAt,
    this.deletedAt,
  });
  final String id, listId, title, notes;
  final bool isCompleted, isImportant;
  final CalendarDate? myDayDate, dueDate;
  final DateTime createdAt, updatedAt;
  final DateTime? reminderAt, completedAt, deletedAt;
  final String? recurrenceRule;
  final double sortOrder;
  bool isInMyDay(CalendarDate today) =>
      deletedAt == null && !isCompleted && myDayDate == today;
}

enum TaskView { myDay, important, planned, list, search }

final class TaskQuery {
  const TaskQuery({
    this.view = TaskView.myDay,
    this.listId = inboxId,
    this.search = '',
    required this.today,
    this.showCompleted = true,
  });
  final TaskView view;
  final String listId, search;
  final CalendarDate today;
  final bool showCompleted;
  @override
  bool operator ==(Object other) =>
      other is TaskQuery &&
      view == other.view &&
      listId == other.listId &&
      search == other.search &&
      today == other.today &&
      showCompleted == other.showCompleted;
  @override
  int get hashCode => Object.hash(view, listId, search, today, showCompleted);
}

/// Distinguishes clearing a nullable field from leaving it unchanged.
final class Change<T> {
  const Change(this.value);
  final T value;
}

final class TaskPatch {
  const TaskPatch({
    this.title,
    this.notes,
    this.listId,
    this.isImportant,
    this.myDayDate,
    this.dueDate,
    this.reminderAt,
    this.recurrenceRule,
  });
  final String? title, notes, listId;
  final bool? isImportant;
  final Change<CalendarDate?>? myDayDate, dueDate;
  final Change<DateTime?>? reminderAt;
  final Change<String?>? recurrenceRule;
}

final class TaskStep {
  const TaskStep({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final String id, taskId, title;
  final bool isCompleted;
  final double sortOrder;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;
}
