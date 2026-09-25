# Architecture decisions

## Boundaries and source of truth

The domain contains only Dart values and a repository interface. Repository methods
are the write boundary; Drift streams are the read boundary. Application services
coordinate notification permission with persistence. Riverpod provides dependencies
and focused reactive queries, without a second in-memory task store. The router
owns mobile details and settings; wide windows embed details beside the list.

No network client, sync placeholders, accounts, or remote service credentials exist.
UUID identifiers, UTC audit timestamps, and tombstones are retained for future sync.
The reminder outbox uses local integer IDs solely because OS notification APIs
require them; these IDs are not task identity or sync keys.

## Dates and recurrence

`CalendarDate` stores an ISO `YYYY-MM-DD` string. Its UTC DateTime is only a calendar
arithmetic implementation detail; due dates and My Day never undergo timezone
conversion. Reminder instants and audit fields use UTC. UI converts reminder input
from the device's local timezone once, then schedules the absolute instant via
`TZDateTime` in UTC. Reminders do not drift when the device changes timezone.

My Day refreshes every 15 seconds and on application resume, handling midnight and
clock/timezone changes without bulk updates. Recurrence is the explicit RFC 5545
subset offered by the UI. Unsupported rules are rejected, never guessed. Monthly
and yearly invalid dates are skipped, not clamped. The next date is based on the
previous due date, or the local completion date if none exists. Overdue recurrence
advances one occurrence per completion, preserving missed occurrences.

A completion transaction writes the completed task, creates the next UUID task,
copies/reset steps, and records the next-occurrence link. Repeating completion is
idempotent, including after reopening the original. A generated next occurrence
survives reopening or deletion of the original. Reminders are per occurrence and
are not implicitly copied; the UI explains this behavior.

## Persistence and migrations

Drift Flutter opens SQLite in a background isolate on native platforms and chooses
an appropriate persistent browser backend on web. Foreign keys are enabled.
Schema v1 is exported under `drift_schemas/app/` and verified against both fresh and
pre-existing databases. There is no historical version to migrate from in v0.1.
Unimplemented upgrade paths fail safely rather than destroying data.

For every future schema change:

1. Increment `schemaVersion`.
2. Run `dart run drift_dev make-migrations` and generate schema test helpers.
3. Implement every required forward migration; do not recreate user tables destructively.
4. Test schema equivalence and representative preserved rows from each supported prior version.
5. Commit schema JSON, generated helpers/code, migrations, and tests together.

Indexes cover list/date/step access. Important and literal title/notes search use
SQLite scans on the database isolate; measure before adding an importance index or
FTS. Search contracts do not expose SQL, so FTS can replace the implementation.
SQLite's default case folding covers the English alphabet; full Unicode case
folding belongs with the future multilingual search work.

## Ordering and deletion

Real-valued sortable positions leave gaps of 1024. Moving an item normally updates
one row with the midpoint between its neighbors. If floating-point spacing falls
below a small threshold, that one collection is normalized in a transaction.
No distributed ordering scheme is introduced before sync requires it.

Deleting a list moves nondeleted tasks to the Inbox and tombstones the list in one
transaction. Deleting a task leaves steps attached but hides them through a join
against the parent's tombstone. Undo restores the task and its steps. If its list
was deleted meanwhile, undo restores into the Inbox. Separately deleted steps
retain their own tombstones and remain hidden. No automatic tombstone purge exists.

## Notifications and failures

Permission is requested in direct response to setting a reminder. Initialization
never prompts. The database transaction records each reminder change in a durable
outbox, keyed to a collision-free local notification ID. The serial worker cancels
the old schedule before applying the current task state and acknowledges only the
revision it read. Newer edits cannot be acknowledged accidentally. Failed jobs stay
pending for a one-minute retry and restart recovery; the UI surfaces a failure.

Completion/deletion cancels the pending reminder; reopening/undo reschedules a
future reminder. Past reminder timestamps remain visible but do not fire late on
restart. Windows repeating notifications are unnecessary: recurrence is task logic.
Linux and web explicitly disable assignment because the plugin cannot reliably
schedule OS notifications while the app is closed.

Repository failures are translated into typed validation/persistence failures.
UI displays localized actionable messages. Debug logs omit raw exception strings,
SQL values, titles, and notes. Unexpected Flutter/platform failures are logged
locally. No external error reporting is installed.

## Presentation and accessibility

Breakpoints, spacing, shape, colors, and motion tokens are centralized. Material
ThemeData expresses semantic colors and states. Lato is bundled for offline use.
English ARB strings establish Flutter's localization architecture.

Task and list collections are lazy. Task details progressively reveal properties.
Inline edits begin local writes immediately, serialize them, and expose retry on
failure. Ctrl/Cmd+N focuses quick add; Ctrl/Cmd+F opens search; Escape closes search
or the wide detail panel. Native Tab traversal works through task controls. No
Delete/Backspace shortcut intercepts text editing. Reorder menus are accessible
alternatives to list drag handles. Material's built-in motion behavior is used;
there are no decorative or looping animations.
