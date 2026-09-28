import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
part 'app_database.g.dart';

@DataClassName('ListRow')
class Lists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get color => integer().withDefault(const Constant(0xff426b59))();
  TextColumn get icon => text().withDefault(const Constant('list'))();
  RealColumn get sortOrder => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'tasks_list', columns: {#listId, #deletedAt, #sortOrder})
@TableIndex(name: 'tasks_day', columns: {#myDayDate, #isCompleted, #deletedAt})
@TableIndex(name: 'tasks_due', columns: {#dueDate, #isCompleted, #deletedAt})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text().references(Lists, #id)();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();
  TextColumn get myDayDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  RealColumn get sortOrder => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  // Prevent duplicate next occurrences on uncomplete/recomplete.
  TextColumn get nextOccurrenceId => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'steps_task', columns: {#taskId, #deletedAt, #sortOrder})
class Steps extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  RealColumn get sortOrder => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Durable outbox: notification changes retry after failures or restart.
class ReminderJobs extends Table {
  IntColumn get notificationId => integer().autoIncrement()();
  TextColumn get taskId => text().unique().references(Tasks, #id)();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get pending => boolean().withDefault(const Constant(true))();
}

@DataClassName('NotePageRow')
@TableIndex(name: 'notes_order', columns: {#deletedAt, #sortOrder})
class NotePages extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  RealColumn get sortOrder => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('NoteBlockRow')
@TableIndex(
  name: 'note_blocks_page',
  columns: {#pageId, #deletedAt, #sortOrder},
)
class NoteBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get pageId => text().references(NotePages, #id)();
  TextColumn get type => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get imageName => text().withDefault(const Constant(''))();
  TextColumn get detail => text().withDefault(const Constant(''))();
  TextColumn get icon => text().withDefault(const Constant(''))();
  BoolColumn get expanded => boolean().withDefault(const Constant(true))();
  RealColumn get sortOrder => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CustomThemeRow')
class CustomThemes extends Table {
  TextColumn get id => text()();
  TextColumn get document => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ThemeSettingsRow')
class ThemeSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get activeCustomThemeId =>
      text().nullable().references(CustomThemes, #id)();
  TextColumn get activePresetId =>
      text().nullable().withDefault(const Constant('preset:default'))();
  TextColumn get recentColors => text().withDefault(const Constant('[]'))();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => const [
    'CHECK (id = 1)',
    'CHECK ((active_custom_theme_id IS NULL) != (active_preset_id IS NULL))',
  ];
}

@DataClassName('FocusSoundscapeRow')
class FocusSoundscapes extends Table {
  TextColumn get id => text()();
  TextColumn get document => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FocusPreferenceRow')
class FocusSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get mix => text().nullable()();
  RealColumn get masterVolume => real().withDefault(const Constant(.5))();
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => const [
    'CHECK (id = 1)',
    'CHECK (master_volume BETWEEN 0 AND 1)',
  ];
}

@DriftDatabase(
  tables: [
    Lists,
    Tasks,
    Steps,
    ReminderJobs,
    NotePages,
    NoteBlocks,
    CustomThemes,
    ThemeSettings,
    FocusSoundscapes,
    FocusSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'doever',
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationSupportDirectory,
              ),
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
              ),
            ),
      );
  @override
  int get schemaVersion => 4;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _insertThemeSettings();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(notePages);
        await m.createTable(noteBlocks);
        await customStatement(
          'CREATE INDEX notes_order ON note_pages (deleted_at, sort_order)',
        );
        await customStatement(
          'CREATE INDEX note_blocks_page ON note_blocks (page_id, deleted_at, sort_order)',
        );
      }
      if (from < 3) {
        await m.createTable(customThemes);
        await m.createTable(themeSettings);
        await _insertThemeSettings();
      }
      if (from < 4) {
        await m.createTable(focusSoundscapes);
        await m.createTable(focusSettings);
      }
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<void> _insertThemeSettings() =>
      customStatement("INSERT OR IGNORE INTO theme_settings (id) VALUES (1)");
}
