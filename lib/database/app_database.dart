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

@DriftDatabase(tables: [Lists, Tasks, Steps, ReminderJobs])
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
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      throw StateError('No migration from $from to $to');
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
