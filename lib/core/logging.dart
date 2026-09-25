import 'dart:developer' as developer;

// Exception messages from SQLite can contain bound user data. Log type and
// stack only; never task titles, notes, SQL arguments or notification payloads.
void logFailure(String operation, Object error, StackTrace stack) {
  developer.log(
    operation,
    name: 'doever',
    error: error.runtimeType.toString(),
    stackTrace: stack,
    level: 1000,
  );
}
