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

  @override
  String get themeStudio => 'Theme Studio';

  @override
  String get themeStudioSubtitle => 'Make Doever feel like yours';

  @override
  String get themeLayers => 'Foundation, Surface & Accent';

  @override
  String get themeFoundation => 'Foundation';

  @override
  String get themeSurface => 'Surface';

  @override
  String get themeAccent => 'Accent';

  @override
  String get themeFoundationDescription =>
      'The workspace background and overall atmosphere.';

  @override
  String get themeSurfaceDescription =>
      'Cards, panels, inputs, and elevated content.';

  @override
  String get themeAccentDescription =>
      'Actions, focus, selection, and personality.';

  @override
  String get themeApply => 'Apply';

  @override
  String get themeUnsaved => 'Unsaved theme changes';

  @override
  String get themeLeavePrompt =>
      'Apply your changes before leaving Theme Studio?';

  @override
  String get themeContinueEditing => 'Continue editing';

  @override
  String get themeDiscard => 'Discard';

  @override
  String get themeNameInvalid => 'Give this theme a name of 1–200 characters.';

  @override
  String get themeApplied => 'Theme applied';

  @override
  String get themeApplyFailed =>
      'Couldn’t apply this theme. Your changes are still here.';

  @override
  String get themeUntitled => 'Untitled theme';

  @override
  String get themeRename => 'Rename theme';

  @override
  String themeDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get themeDeleteMessage =>
      'This saved theme will be permanently removed.';

  @override
  String get themeFile => 'Doever theme';

  @override
  String get themeFileTooLarge =>
      'That theme file is too large. Choose a file under 64 KB.';

  @override
  String get themeFileInvalid => 'That file isn’t a valid Doever theme.';

  @override
  String get themeExportFailed => 'Couldn’t export this theme.';

  @override
  String get themeSaveFailed => 'Couldn’t save that change. Please try again.';

  @override
  String get themeBack => 'Back to settings';

  @override
  String get themeRedo => 'Redo';

  @override
  String get themeThemes => 'Themes';

  @override
  String get themeLivePreview => 'Live preview';

  @override
  String get themePreviewHint =>
      'Preview changes throughout Doever before applying';

  @override
  String get themePreviewInApp => 'Preview in app';

  @override
  String get themeContrastGood => 'Contrast · Good';

  @override
  String get themeContrastProtected => 'Contrast · Readability protected';

  @override
  String get themeName => 'Theme name';

  @override
  String get themeReset => 'Reset theme';

  @override
  String get themeMode => 'Mode';

  @override
  String get themeAutoBalance => 'Auto Balance';

  @override
  String get themeAutoBalanceDescription =>
      'Keep layers distinct and comfortably readable.';

  @override
  String get themeLowContrast => 'Low contrast in selected colors';

  @override
  String get themeBalanceContrast => 'Auto balance contrast';

  @override
  String get themeBalanced => 'Balanced automatically';

  @override
  String get themeFix => 'Fix automatically';

  @override
  String get themeKeep => 'Keep anyway';

  @override
  String get themeGallery => 'Theme gallery';

  @override
  String get themeImport => 'Import theme';

  @override
  String get themeExport => 'Export theme';

  @override
  String get themeGalleryDescription =>
      'Start from a curated look or one you saved.';

  @override
  String get themeBuiltIn => 'Built in';

  @override
  String get themeSaved => 'Saved';

  @override
  String get themeNew => 'New theme';

  @override
  String get themeEmpty => 'Your saved themes will appear here.';

  @override
  String get themeActive => 'Applied';

  @override
  String themeActions(String name) {
    return '$name actions';
  }

  @override
  String get themeResetLayer => 'Reset layer';

  @override
  String get themeSolid => 'Solid';

  @override
  String get themeGradient => 'Gradient';

  @override
  String get themeColors => 'Colors';

  @override
  String get themeAddStop => 'Add stop';

  @override
  String get themeRemoveStop => 'Remove stop';

  @override
  String themeColorStop(int number) {
    return 'Color stop $number';
  }

  @override
  String get themeDirection => 'Direction';

  @override
  String get themeTopBottom => 'Top to bottom';

  @override
  String get themeBottomTop => 'Bottom to top';

  @override
  String get themeLeftRight => 'Left to right';

  @override
  String get themeRightLeft => 'Right to left';

  @override
  String get themeTopLeftBottomRight => 'Top left to bottom right';

  @override
  String get themeTopRightBottomLeft => 'Top right to bottom left';

  @override
  String get themeBottomLeftTopRight => 'Bottom left to top right';

  @override
  String get themeBottomRightTopLeft => 'Bottom right to top left';

  @override
  String get themeAdvanced => 'Advanced';

  @override
  String get themeAdvancedDescription =>
      'Tone, intensity, and gradient strength';

  @override
  String get themeTone => 'Tone';

  @override
  String get themeIntensity => 'Intensity';

  @override
  String get themeGradientStrength => 'Gradient strength';

  @override
  String themePercent(String label, int value) {
    return '$label $value percent';
  }

  @override
  String get themeHexInvalid => 'Use #RRGGBB';

  @override
  String get themeSaturationBrightness => 'Saturation and brightness';

  @override
  String get themeHue => 'Hue';

  @override
  String themeHueDegrees(int value) {
    return 'Hue $value degrees';
  }

  @override
  String get themeRecentColors => 'Recent colors';

  @override
  String get themePreviewSemantics =>
      'Theme preview: navigation, tasks, text, input and action';

  @override
  String get themePersonalSpace => 'Your personal space';

  @override
  String get themeRoom => 'Room for what matters.';

  @override
  String get themeSampleDone => 'Shape the day';

  @override
  String get themeSampleTask => 'Review project notes';

  @override
  String get themeLocal => 'All changes stay local';

  @override
  String get themeCreate => 'Create';

  @override
  String get themeHierarchyBalanced =>
      'Foundation and Surface were balanced for clearer hierarchy.';

  @override
  String get themeHierarchyLow =>
      'Foundation and Surface have low visual hierarchy.';

  @override
  String get themeAccentAdjusted =>
      'Accent tones were adjusted to keep foreground text readable.';

  @override
  String get themeGradientMissing => 'A gradient needs at least two colors.';

  @override
  String get themeLightAdjusted =>
      'Layer tones were adjusted for readable light mode.';

  @override
  String get themeDarkAdjusted =>
      'Layer tones were adjusted for readable dark mode.';

  @override
  String themeCopyName(String name) {
    return '$name Copy';
  }

  @override
  String get themePresetMidnight => 'Midnight';

  @override
  String get themePresetGraphite => 'Graphite';

  @override
  String get themePresetOcean => 'Ocean';

  @override
  String get themePresetAurora => 'Aurora';

  @override
  String get themePresetEmber => 'Ember';

  @override
  String get themePresetForest => 'Forest';

  @override
  String get themePresetSand => 'Sand';

  @override
  String get focusLabel => 'Focus';

  @override
  String get focusTagline => 'Make room for a quieter mind.';

  @override
  String get focusLocal => 'Original synthetic ambience. Entirely offline.';

  @override
  String get focusMixer => 'Your mix';

  @override
  String get focusLibrary => 'Sound library';

  @override
  String get focusPresets => 'Made for the moment';

  @override
  String get focusCustom => 'Your soundscapes';

  @override
  String get focusNew => 'New soundscape';

  @override
  String get focusSave => 'Save soundscape';

  @override
  String get focusCopy => 'Save a copy';

  @override
  String get focusDelete => 'Delete this soundscape?';

  @override
  String get focusPlay => 'Play';

  @override
  String get focusPause => 'Pause';

  @override
  String get focusStop => 'Stop';

  @override
  String get focusMute => 'Mute';

  @override
  String get focusUnmute => 'Unmute';

  @override
  String get focusMaster => 'Master volume';

  @override
  String get focusDynamic => 'Dynamic ambience';

  @override
  String get focusDynamicHint => 'Slow, subtle variation in volume.';

  @override
  String get focusAdd => 'Add sound';

  @override
  String get focusRemove => 'Remove sound';

  @override
  String get focusLimit => 'Up to eight sounds per mix.';

  @override
  String get focusEmpty => 'Choose a soundscape, or create your own.';

  @override
  String get focusAddHint => 'Add a sound from the library to begin.';

  @override
  String get focusUnsaved => 'Edited mix · save to your library';

  @override
  String get focusAudioError =>
      'Audio could not start or update. Try playing again.';

  @override
  String get focusStorageError =>
      'Changes could not be saved. Retry before closing.';

  @override
  String get focusNoise => 'Noise';

  @override
  String get focusWeather => 'Weather';

  @override
  String get focusNature => 'Nature';

  @override
  String get focusCozy => 'Cozy';

  @override
  String get focusUrban => 'Urban';

  @override
  String get focusWorkspace => 'Workspace';

  @override
  String get focusWhite => 'White noise';

  @override
  String get focusPink => 'Pink noise';

  @override
  String get focusBrown => 'Brown noise';

  @override
  String get focusGrey => 'Grey noise';

  @override
  String get focusLightRain => 'Light rain';

  @override
  String get focusHeavyRain => 'Heavy rain';

  @override
  String get focusThunder => 'Rolling thunder';

  @override
  String get focusWind => 'Wind';

  @override
  String get focusOcean => 'Ocean waves';

  @override
  String get focusStream => 'Stream';

  @override
  String get focusBirds => 'Birdsong';

  @override
  String get focusCrickets => 'Night crickets';

  @override
  String get focusFireplace => 'Fireplace';

  @override
  String get focusVinyl => 'Vinyl crackle';

  @override
  String get focusCafe => 'Café ambience';

  @override
  String get focusTrain => 'Train journey';

  @override
  String get focusKeyboard => 'Soft keyboard';

  @override
  String get focusOffice => 'Quiet office';

  @override
  String get focusDeepPreset => 'Deep focus';

  @override
  String get focusCafePreset => 'Rainy café';

  @override
  String get focusNightPreset => 'Night coding';

  @override
  String get focusForestPreset => 'Forest study';

  @override
  String get focusStormPreset => 'Stormy evening';

  @override
  String get focusJourneyPreset => 'Quiet journey';

  @override
  String get focusLoadError => 'Could not load Focus. Please try again.';
}
