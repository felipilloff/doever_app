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
