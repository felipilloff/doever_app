import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('hi'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Doever'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Do what matters.'**
  String get tagline;

  /// No description provided for @myDay.
  ///
  /// In en, this message translates to:
  /// **'My Day'**
  String get myDay;

  /// No description provided for @important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get important;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @lists.
  ///
  /// In en, this message translates to:
  /// **'Your lists'**
  String get lists;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newList;

  /// No description provided for @renameList.
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get renameList;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteList;

  /// No description provided for @deleteListMessage.
  ///
  /// In en, this message translates to:
  /// **'Tasks in this list will move to Tasks.'**
  String get deleteListMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search titles and notes'**
  String get searchHint;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get addStep;

  /// No description provided for @renameStep.
  ///
  /// In en, this message translates to:
  /// **'Rename step'**
  String get renameStep;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get notesHint;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to list'**
  String get moveTo;

  /// No description provided for @removeDate.
  ///
  /// In en, this message translates to:
  /// **'Remove due date'**
  String get removeDate;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// No description provided for @addToMyDay.
  ///
  /// In en, this message translates to:
  /// **'Add to My Day'**
  String get addToMyDay;

  /// No description provided for @removeFromMyDay.
  ///
  /// In en, this message translates to:
  /// **'Remove from My Day'**
  String get removeFromMyDay;

  /// No description provided for @markImportant.
  ///
  /// In en, this message translates to:
  /// **'Mark important'**
  String get markImportant;

  /// No description provided for @unmarkImportant.
  ///
  /// In en, this message translates to:
  /// **'Remove importance'**
  String get unmarkImportant;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get completeTask;

  /// No description provided for @uncompleteTask.
  ///
  /// In en, this message translates to:
  /// **'Reopen task'**
  String get uncompleteTask;

  /// No description provided for @completeStep.
  ///
  /// In en, this message translates to:
  /// **'Complete step'**
  String get completeStep;

  /// No description provided for @uncompleteStep.
  ///
  /// In en, this message translates to:
  /// **'Reopen step'**
  String get uncompleteStep;

  /// No description provided for @deleteStep.
  ///
  /// In en, this message translates to:
  /// **'Delete step'**
  String get deleteStep;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @closeDetails.
  ///
  /// In en, this message translates to:
  /// **'Close details'**
  String get closeDetails;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetails;

  /// No description provided for @emptyDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for today.'**
  String get emptyDay;

  /// No description provided for @emptyDayHint.
  ///
  /// In en, this message translates to:
  /// **'Add a task below, or bring one here from another list.'**
  String get emptyDayHint;

  /// No description provided for @emptyImportant.
  ///
  /// In en, this message translates to:
  /// **'No important tasks.'**
  String get emptyImportant;

  /// No description provided for @emptyImportantHint.
  ///
  /// In en, this message translates to:
  /// **'Mark a task with a star to keep it close.'**
  String get emptyImportantHint;

  /// No description provided for @emptyPlanned.
  ///
  /// In en, this message translates to:
  /// **'No planned tasks.'**
  String get emptyPlanned;

  /// No description provided for @emptyPlannedHint.
  ///
  /// In en, this message translates to:
  /// **'Tasks with due dates will appear here.'**
  String get emptyPlannedHint;

  /// No description provided for @emptyTasks.
  ///
  /// In en, this message translates to:
  /// **'A little space to get started.'**
  String get emptyTasks;

  /// No description provided for @emptyTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first task below.'**
  String get emptyTasksHint;

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'No tasks found.'**
  String get emptySearch;

  /// No description provided for @emptySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different title or a word from your notes.'**
  String get emptySearchHint;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @showCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed tasks'**
  String get showCompleted;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Local by design'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your tasks stay on this device. No account, analytics, advertising, or tracking.'**
  String get privacyBody;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Check your input and try again. Titles cannot be empty and reminders must be in the future.'**
  String get validationError;

  /// No description provided for @persistenceError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your changes. Check available storage and try again.'**
  String get persistenceError;

  /// No description provided for @notificationError.
  ///
  /// In en, this message translates to:
  /// **'Reminders are unavailable or notification permission was denied. Check system notification settings.'**
  String get notificationError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unexpectedError;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your tasks. Please try again.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reminderPending.
  ///
  /// In en, this message translates to:
  /// **'A reminder change could not be applied. Doever will retry automatically.'**
  String get reminderPending;

  /// No description provided for @remindersUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reminders are not supported on this platform.'**
  String get remindersUnsupported;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @openNavigation.
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get openNavigation;

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'New task: Ctrl/Cmd+N'**
  String get quickAddHint;

  /// No description provided for @searchShortcutHint.
  ///
  /// In en, this message translates to:
  /// **'Search: Ctrl/Cmd+F'**
  String get searchShortcutHint;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @taskUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This task is no longer available.'**
  String get taskUnavailable;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Doever could not open local storage. Check available storage, then retry.'**
  String get startupError;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved locally'**
  String get saved;

  /// No description provided for @reminderTiming.
  ///
  /// In en, this message translates to:
  /// **'Android may delay reminders to conserve battery.'**
  String get reminderTiming;

  /// No description provided for @recurrenceHint.
  ///
  /// In en, this message translates to:
  /// **'The next occurrence is created on completion. Reminders are set separately for each occurrence.'**
  String get recurrenceHint;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @allLocal.
  ///
  /// In en, this message translates to:
  /// **'Stored on this device'**
  String get allLocal;

  /// No description provided for @taskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @remindOn.
  ///
  /// In en, this message translates to:
  /// **'Remind me {date}'**
  String remindOn(String date);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a task title.'**
  String get titleRequired;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @backgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace background'**
  String get backgroundTitle;

  /// No description provided for @backgroundDescription.
  ///
  /// In en, this message translates to:
  /// **'Make this space yours. Choose a photo that helps you focus.'**
  String get backgroundDescription;

  /// No description provided for @backgroundPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview of your workspace'**
  String get backgroundPreview;

  /// No description provided for @backgroundApplying.
  ///
  /// In en, this message translates to:
  /// **'Preparing your background…'**
  String get backgroundApplying;

  /// No description provided for @backgroundChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get backgroundChoose;

  /// No description provided for @backgroundChange.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get backgroundChange;

  /// No description provided for @backgroundRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove background'**
  String get backgroundRemove;

  /// No description provided for @backgroundLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your saved image could not be opened. Choose another image or remove the background.'**
  String get backgroundLoadError;

  /// No description provided for @backgroundFormats.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPEG or WebP · Up to 20 MB. Landscape images work best.'**
  String get backgroundFormats;

  /// No description provided for @backgroundLocal.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Your original image stays unchanged.'**
  String get backgroundLocal;

  /// No description provided for @backgroundInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid, still PNG, JPEG or WebP image (up to 20 MB and 40 megapixels).'**
  String get backgroundInvalid;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @newPage.
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get newPage;

  /// No description provided for @untitledPage.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledPage;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Create a page to start writing.'**
  String get noNotes;

  /// No description provided for @searchPages.
  ///
  /// In en, this message translates to:
  /// **'Search pages'**
  String get searchPages;

  /// No description provided for @searchPage.
  ///
  /// In en, this message translates to:
  /// **'Find in page'**
  String get searchPage;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved locally'**
  String get noteSaved;

  /// No description provided for @noteSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get noteSaving;

  /// No description provided for @noteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Changes not saved. Retry before leaving.'**
  String get noteSaveFailed;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Write something, or type / for blocks'**
  String get noteHint;

  /// No description provided for @blockActions.
  ///
  /// In en, this message translates to:
  /// **'Block actions'**
  String get blockActions;

  /// No description provided for @addBlock.
  ///
  /// In en, this message translates to:
  /// **'Add block'**
  String get addBlock;

  /// No description provided for @duplicateBlock.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateBlock;

  /// No description provided for @changeBlock.
  ///
  /// In en, this message translates to:
  /// **'Change block type'**
  String get changeBlock;

  /// No description provided for @blockDeleted.
  ///
  /// In en, this message translates to:
  /// **'Block deleted'**
  String get blockDeleted;

  /// No description provided for @pageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Page deleted'**
  String get pageDeleted;

  /// No description provided for @createNoteTask.
  ///
  /// In en, this message translates to:
  /// **'Create Doever Task'**
  String get createNoteTask;

  /// No description provided for @noteTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task created in Tasks'**
  String get noteTaskCreated;

  /// No description provided for @noteRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get noteRedo;

  /// No description provided for @previousMatch.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get previousMatch;

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nextMatch;

  /// No description provided for @noteUrl.
  ///
  /// In en, this message translates to:
  /// **'Web address (http or https)'**
  String get noteUrl;

  /// No description provided for @noteInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http or https address.'**
  String get noteInvalidUrl;

  /// No description provided for @noteOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get noteOpenLink;

  /// No description provided for @noteImage.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get noteImage;

  /// No description provided for @noteImageError.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get noteImageError;

  /// No description provided for @noteToggleBody.
  ///
  /// In en, this message translates to:
  /// **'Collapsible content'**
  String get noteToggleBody;

  /// No description provided for @noteIcon.
  ///
  /// In en, this message translates to:
  /// **'Callout icon (optional)'**
  String get noteIcon;

  /// No description provided for @noteText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get noteText;

  /// No description provided for @noteH1.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get noteH1;

  /// No description provided for @noteH2.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get noteH2;

  /// No description provided for @noteH3.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get noteH3;

  /// No description provided for @noteBullet.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get noteBullet;

  /// No description provided for @noteNumbered.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get noteNumbered;

  /// No description provided for @noteTodo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get noteTodo;

  /// No description provided for @noteQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get noteQuote;

  /// No description provided for @noteDivider.
  ///
  /// In en, this message translates to:
  /// **'Divider'**
  String get noteDivider;

  /// No description provided for @noteCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get noteCode;

  /// No description provided for @noteCallout.
  ///
  /// In en, this message translates to:
  /// **'Callout'**
  String get noteCallout;

  /// No description provided for @noteLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get noteLink;

  /// No description provided for @noteToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get noteToggle;

  /// No description provided for @noteChoosePage.
  ///
  /// In en, this message translates to:
  /// **'Select a page, or create a new one.'**
  String get noteChoosePage;

  /// No description provided for @themeStudio.
  ///
  /// In en, this message translates to:
  /// **'Theme Studio'**
  String get themeStudio;

  /// No description provided for @themeStudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make Doever feel like yours'**
  String get themeStudioSubtitle;

  /// No description provided for @themeLayers.
  ///
  /// In en, this message translates to:
  /// **'Foundation, Surface & Accent'**
  String get themeLayers;

  /// No description provided for @themeFoundation.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get themeFoundation;

  /// No description provided for @themeSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get themeSurface;

  /// No description provided for @themeAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get themeAccent;

  /// No description provided for @themeFoundationDescription.
  ///
  /// In en, this message translates to:
  /// **'The workspace background and overall atmosphere.'**
  String get themeFoundationDescription;

  /// No description provided for @themeSurfaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Cards, panels, inputs, and elevated content.'**
  String get themeSurfaceDescription;

  /// No description provided for @themeAccentDescription.
  ///
  /// In en, this message translates to:
  /// **'Actions, focus, selection, and personality.'**
  String get themeAccentDescription;

  /// No description provided for @themeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get themeApply;

  /// No description provided for @themeUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved theme changes'**
  String get themeUnsaved;

  /// No description provided for @themeLeavePrompt.
  ///
  /// In en, this message translates to:
  /// **'Apply your changes before leaving Theme Studio?'**
  String get themeLeavePrompt;

  /// No description provided for @themeContinueEditing.
  ///
  /// In en, this message translates to:
  /// **'Continue editing'**
  String get themeContinueEditing;

  /// No description provided for @themeDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get themeDiscard;

  /// No description provided for @themeNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Give this theme a name of 1–200 characters.'**
  String get themeNameInvalid;

  /// No description provided for @themeApplied.
  ///
  /// In en, this message translates to:
  /// **'Theme applied'**
  String get themeApplied;

  /// No description provided for @themeApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t apply this theme. Your changes are still here.'**
  String get themeApplyFailed;

  /// No description provided for @themeUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled theme'**
  String get themeUntitled;

  /// No description provided for @themeRename.
  ///
  /// In en, this message translates to:
  /// **'Rename theme'**
  String get themeRename;

  /// No description provided for @themeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String themeDeleteTitle(String name);

  /// No description provided for @themeDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This saved theme will be permanently removed.'**
  String get themeDeleteMessage;

  /// No description provided for @themeFile.
  ///
  /// In en, this message translates to:
  /// **'Doever theme'**
  String get themeFile;

  /// No description provided for @themeFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That theme file is too large. Choose a file under 64 KB.'**
  String get themeFileTooLarge;

  /// No description provided for @themeFileInvalid.
  ///
  /// In en, this message translates to:
  /// **'That file isn’t a valid Doever theme.'**
  String get themeFileInvalid;

  /// No description provided for @themeExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t export this theme.'**
  String get themeExportFailed;

  /// No description provided for @themeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save that change. Please try again.'**
  String get themeSaveFailed;

  /// No description provided for @themeBack.
  ///
  /// In en, this message translates to:
  /// **'Back to settings'**
  String get themeBack;

  /// No description provided for @themeRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get themeRedo;

  /// No description provided for @themeThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themeThemes;

  /// No description provided for @themeLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get themeLivePreview;

  /// No description provided for @themePreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Preview changes throughout Doever before applying'**
  String get themePreviewHint;

  /// No description provided for @themePreviewInApp.
  ///
  /// In en, this message translates to:
  /// **'Preview in app'**
  String get themePreviewInApp;

  /// No description provided for @themeContrastGood.
  ///
  /// In en, this message translates to:
  /// **'Contrast · Good'**
  String get themeContrastGood;

  /// No description provided for @themeContrastProtected.
  ///
  /// In en, this message translates to:
  /// **'Contrast · Readability protected'**
  String get themeContrastProtected;

  /// No description provided for @themeName.
  ///
  /// In en, this message translates to:
  /// **'Theme name'**
  String get themeName;

  /// No description provided for @themeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset theme'**
  String get themeReset;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get themeMode;

  /// No description provided for @themeAutoBalance.
  ///
  /// In en, this message translates to:
  /// **'Auto Balance'**
  String get themeAutoBalance;

  /// No description provided for @themeAutoBalanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep layers distinct and comfortably readable.'**
  String get themeAutoBalanceDescription;

  /// No description provided for @themeLowContrast.
  ///
  /// In en, this message translates to:
  /// **'Low contrast in selected colors'**
  String get themeLowContrast;

  /// No description provided for @themeBalanceContrast.
  ///
  /// In en, this message translates to:
  /// **'Auto balance contrast'**
  String get themeBalanceContrast;

  /// No description provided for @themeBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced automatically'**
  String get themeBalanced;

  /// No description provided for @themeFix.
  ///
  /// In en, this message translates to:
  /// **'Fix automatically'**
  String get themeFix;

  /// No description provided for @themeKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep anyway'**
  String get themeKeep;

  /// No description provided for @themeGallery.
  ///
  /// In en, this message translates to:
  /// **'Theme gallery'**
  String get themeGallery;

  /// No description provided for @themeImport.
  ///
  /// In en, this message translates to:
  /// **'Import theme'**
  String get themeImport;

  /// No description provided for @themeExport.
  ///
  /// In en, this message translates to:
  /// **'Export theme'**
  String get themeExport;

  /// No description provided for @themeGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Start from a curated look or one you saved.'**
  String get themeGalleryDescription;

  /// No description provided for @themeBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built in'**
  String get themeBuiltIn;

  /// No description provided for @themeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get themeSaved;

  /// No description provided for @themeNew.
  ///
  /// In en, this message translates to:
  /// **'New theme'**
  String get themeNew;

  /// No description provided for @themeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your saved themes will appear here.'**
  String get themeEmpty;

  /// No description provided for @themeActive.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get themeActive;

  /// No description provided for @themeActions.
  ///
  /// In en, this message translates to:
  /// **'{name} actions'**
  String themeActions(String name);

  /// No description provided for @themeResetLayer.
  ///
  /// In en, this message translates to:
  /// **'Reset layer'**
  String get themeResetLayer;

  /// No description provided for @themeSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get themeSolid;

  /// No description provided for @themeGradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get themeGradient;

  /// No description provided for @themeColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get themeColors;

  /// No description provided for @themeAddStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get themeAddStop;

  /// No description provided for @themeRemoveStop.
  ///
  /// In en, this message translates to:
  /// **'Remove stop'**
  String get themeRemoveStop;

  /// No description provided for @themeColorStop.
  ///
  /// In en, this message translates to:
  /// **'Color stop {number}'**
  String themeColorStop(int number);

  /// No description provided for @themeDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get themeDirection;

  /// No description provided for @themeTopBottom.
  ///
  /// In en, this message translates to:
  /// **'Top to bottom'**
  String get themeTopBottom;

  /// No description provided for @themeBottomTop.
  ///
  /// In en, this message translates to:
  /// **'Bottom to top'**
  String get themeBottomTop;

  /// No description provided for @themeLeftRight.
  ///
  /// In en, this message translates to:
  /// **'Left to right'**
  String get themeLeftRight;

  /// No description provided for @themeRightLeft.
  ///
  /// In en, this message translates to:
  /// **'Right to left'**
  String get themeRightLeft;

  /// No description provided for @themeTopLeftBottomRight.
  ///
  /// In en, this message translates to:
  /// **'Top left to bottom right'**
  String get themeTopLeftBottomRight;

  /// No description provided for @themeTopRightBottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Top right to bottom left'**
  String get themeTopRightBottomLeft;

  /// No description provided for @themeBottomLeftTopRight.
  ///
  /// In en, this message translates to:
  /// **'Bottom left to top right'**
  String get themeBottomLeftTopRight;

  /// No description provided for @themeBottomRightTopLeft.
  ///
  /// In en, this message translates to:
  /// **'Bottom right to top left'**
  String get themeBottomRightTopLeft;

  /// No description provided for @themeAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get themeAdvanced;

  /// No description provided for @themeAdvancedDescription.
  ///
  /// In en, this message translates to:
  /// **'Tone, intensity, and gradient strength'**
  String get themeAdvancedDescription;

  /// No description provided for @themeTone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get themeTone;

  /// No description provided for @themeIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get themeIntensity;

  /// No description provided for @themeGradientStrength.
  ///
  /// In en, this message translates to:
  /// **'Gradient strength'**
  String get themeGradientStrength;

  /// No description provided for @themePercent.
  ///
  /// In en, this message translates to:
  /// **'{label} {value} percent'**
  String themePercent(String label, int value);

  /// No description provided for @themeHexInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use #RRGGBB'**
  String get themeHexInvalid;

  /// No description provided for @themeSaturationBrightness.
  ///
  /// In en, this message translates to:
  /// **'Saturation and brightness'**
  String get themeSaturationBrightness;

  /// No description provided for @themeHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get themeHue;

  /// No description provided for @themeHueDegrees.
  ///
  /// In en, this message translates to:
  /// **'Hue {value} degrees'**
  String themeHueDegrees(int value);

  /// No description provided for @themeRecentColors.
  ///
  /// In en, this message translates to:
  /// **'Recent colors'**
  String get themeRecentColors;

  /// No description provided for @themePreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Theme preview: navigation, tasks, text, input and action'**
  String get themePreviewSemantics;

  /// No description provided for @themePersonalSpace.
  ///
  /// In en, this message translates to:
  /// **'Your personal space'**
  String get themePersonalSpace;

  /// No description provided for @themeRoom.
  ///
  /// In en, this message translates to:
  /// **'Room for what matters.'**
  String get themeRoom;

  /// No description provided for @themeSampleDone.
  ///
  /// In en, this message translates to:
  /// **'Shape the day'**
  String get themeSampleDone;

  /// No description provided for @themeSampleTask.
  ///
  /// In en, this message translates to:
  /// **'Review project notes'**
  String get themeSampleTask;

  /// No description provided for @themeLocal.
  ///
  /// In en, this message translates to:
  /// **'All changes stay local'**
  String get themeLocal;

  /// No description provided for @themeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get themeCreate;

  /// No description provided for @themeHierarchyBalanced.
  ///
  /// In en, this message translates to:
  /// **'Foundation and Surface were balanced for clearer hierarchy.'**
  String get themeHierarchyBalanced;

  /// No description provided for @themeHierarchyLow.
  ///
  /// In en, this message translates to:
  /// **'Foundation and Surface have low visual hierarchy.'**
  String get themeHierarchyLow;

  /// No description provided for @themeAccentAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Accent tones were adjusted to keep foreground text readable.'**
  String get themeAccentAdjusted;

  /// No description provided for @themeGradientMissing.
  ///
  /// In en, this message translates to:
  /// **'A gradient needs at least two colors.'**
  String get themeGradientMissing;

  /// No description provided for @themeLightAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Layer tones were adjusted for readable light mode.'**
  String get themeLightAdjusted;

  /// No description provided for @themeDarkAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Layer tones were adjusted for readable dark mode.'**
  String get themeDarkAdjusted;

  /// No description provided for @themeCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} Copy'**
  String themeCopyName(String name);

  /// No description provided for @themePresetMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themePresetMidnight;

  /// No description provided for @themePresetGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get themePresetGraphite;

  /// No description provided for @themePresetOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themePresetOcean;

  /// No description provided for @themePresetAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get themePresetAurora;

  /// No description provided for @themePresetEmber.
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get themePresetEmber;

  /// No description provided for @themePresetForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themePresetForest;

  /// No description provided for @themePresetSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get themePresetSand;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'hi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
