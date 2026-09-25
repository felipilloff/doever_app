// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Doever';

  @override
  String get tagline => 'Do what matters.';

  @override
  String get myDay => 'My Day';

  @override
  String get important => 'Important';

  @override
  String get planned => 'Planned';

  @override
  String get tasks => 'Tasks';

  @override
  String get lists => 'Your lists';

  @override
  String get newList => 'New list';

  @override
  String get renameList => 'Rename list';

  @override
  String get deleteList => 'Delete list';

  @override
  String get deleteListMessage => 'Tasks in this list will move to Tasks.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search tasks';

  @override
  String get searchHint => 'Search titles and notes';

  @override
  String get addTask => 'Add task';

  @override
  String get taskTitle => 'Task title';

  @override
  String get addStep => 'Add step';

  @override
  String get renameStep => 'Rename step';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Add a note…';

  @override
  String get dueDate => 'Due date';

  @override
  String get reminder => 'Reminder';

  @override
  String get repeat => 'Repeat';

  @override
  String get never => 'Never';

  @override
  String get daily => 'Daily';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get moveTo => 'Move to list';

  @override
  String get removeDate => 'Remove due date';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get addToMyDay => 'Add to My Day';

  @override
  String get removeFromMyDay => 'Remove from My Day';

  @override
  String get markImportant => 'Mark important';

  @override
  String get unmarkImportant => 'Remove importance';

  @override
  String get completeTask => 'Complete task';

  @override
  String get uncompleteTask => 'Reopen task';

  @override
  String get completeStep => 'Complete step';

  @override
  String get uncompleteStep => 'Reopen step';

  @override
  String get deleteStep => 'Delete step';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get undo => 'Undo';

  @override
  String get closeDetails => 'Close details';

  @override
  String get taskDetails => 'Task details';

  @override
  String get emptyDay => 'Nothing planned for today.';

  @override
  String get emptyDayHint =>
      'Add a task below, or bring one here from another list.';

  @override
  String get emptyImportant => 'No important tasks.';

  @override
  String get emptyImportantHint => 'Mark a task with a star to keep it close.';

  @override
  String get emptyPlanned => 'No planned tasks.';

  @override
  String get emptyPlannedHint => 'Tasks with due dates will appear here.';

  @override
  String get emptyTasks => 'A little space to get started.';

  @override
  String get emptyTasksHint => 'Add your first task below.';

  @override
  String get emptySearch => 'No tasks found.';

  @override
  String get emptySearchHint =>
      'Try a different title or a word from your notes.';

  @override
  String get theme => 'Appearance';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get showCompleted => 'Show completed tasks';

  @override
  String get preferences => 'Preferences';

  @override
  String get privacyTitle => 'Local by design';

  @override
  String get privacyBody =>
      'Your tasks stay on this device. No account, analytics, advertising, or tracking.';

  @override
  String get validationError =>
      'Check your input and try again. Titles cannot be empty and reminders must be in the future.';

  @override
  String get persistenceError =>
      'Could not save your changes. Check available storage and try again.';

  @override
  String get notificationError =>
      'Reminders are unavailable or notification permission was denied. Check system notification settings.';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get loadError => 'Could not load your tasks. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get reminderPending =>
      'A reminder change could not be applied. Doever will retry automatically.';

  @override
  String get remindersUnsupported =>
      'Scheduled reminders are not supported on this platform.';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get reorder => 'Reorder';

  @override
  String get openNavigation => 'Open navigation';

  @override
  String get quickAddHint => 'New task: Ctrl/Cmd+N';

  @override
  String get searchShortcutHint => 'Search: Ctrl/Cmd+F';

  @override
  String get completed => 'Completed';

  @override
  String get taskUnavailable => 'This task is no longer available.';

  @override
  String get startupError =>
      'Doever could not open local storage. Check available storage, then retry.';

  @override
  String get saving => 'Saving…';

  @override
  String get saved => 'Saved locally';

  @override
  String get reminderTiming =>
      'Android may delay reminders to conserve battery.';

  @override
  String get recurrenceHint =>
      'The next occurrence is created on completion. Reminders are set separately for each occurrence.';

  @override
  String get steps => 'Steps';

  @override
  String get back => 'Back';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get today => 'Today';

  @override
  String get allLocal => 'Stored on this device';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String remindOn(String date) {
    return 'Remind me $date';
  }

  @override
  String get titleRequired => 'Enter a task title.';

  @override
  String get language => 'Language';
}
