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

  @override
  String get backgroundTitle => 'Workspace background';

  @override
  String get backgroundDescription =>
      'Make this space yours. Choose a photo that helps you focus.';

  @override
  String get backgroundPreview => 'Preview of your workspace';

  @override
  String get backgroundApplying => 'Preparing your background…';

  @override
  String get backgroundChoose => 'Choose image';

  @override
  String get backgroundChange => 'Change image';

  @override
  String get backgroundRemove => 'Remove background';

  @override
  String get backgroundLoadError =>
      'Your saved image could not be opened. Choose another image or remove the background.';

  @override
  String get backgroundFormats =>
      'PNG, JPEG or WebP · Up to 20 MB. Landscape images work best.';

  @override
  String get backgroundLocal =>
      'Saved on this device. Your original image stays unchanged.';

  @override
  String get backgroundInvalid =>
      'Choose a valid, still PNG, JPEG or WebP image (up to 20 MB and 40 megapixels).';

  @override
  String get notesLabel => 'Notes';

  @override
  String get newPage => 'New page';

  @override
  String get untitledPage => 'Untitled';

  @override
  String get noNotes => 'No notes yet. Create a page to start writing.';

  @override
  String get searchPages => 'Search pages';

  @override
  String get searchPage => 'Find in page';

  @override
  String get noteSaved => 'Saved locally';

  @override
  String get noteSaving => 'Saving…';

  @override
  String get noteSaveFailed => 'Changes not saved. Retry before leaving.';

  @override
  String get noteHint => 'Write something, or type / for blocks';

  @override
  String get blockActions => 'Block actions';

  @override
  String get addBlock => 'Add block';

  @override
  String get duplicateBlock => 'Duplicate';

  @override
  String get changeBlock => 'Change block type';

  @override
  String get blockDeleted => 'Block deleted';

  @override
  String get pageDeleted => 'Page deleted';

  @override
  String get createNoteTask => 'Create Doever Task';

  @override
  String get noteTaskCreated => 'Task created in Tasks';

  @override
  String get noteRedo => 'Redo';

  @override
  String get previousMatch => 'Previous match';

  @override
  String get nextMatch => 'Next match';

  @override
  String get noteUrl => 'Web address (http or https)';

  @override
  String get noteInvalidUrl => 'Enter a valid http or https address.';

  @override
  String get noteOpenLink => 'Open link';

  @override
  String get noteImage => 'Choose image';

  @override
  String get noteImageError => 'Image unavailable';

  @override
  String get noteToggleBody => 'Collapsible content';

  @override
  String get noteIcon => 'Callout icon (optional)';

  @override
  String get noteText => 'Text';

  @override
  String get noteH1 => 'Heading 1';

  @override
  String get noteH2 => 'Heading 2';

  @override
  String get noteH3 => 'Heading 3';

  @override
  String get noteBullet => 'Bulleted list';

  @override
  String get noteNumbered => 'Numbered list';

  @override
  String get noteTodo => 'Todo';

  @override
  String get noteQuote => 'Quote';

  @override
  String get noteDivider => 'Divider';

  @override
  String get noteCode => 'Code';

  @override
  String get noteCallout => 'Callout';

  @override
  String get noteLink => 'Link';

  @override
  String get noteToggle => 'Toggle';

  @override
  String get noteChoosePage => 'Select a page, or create a new one.';
}
