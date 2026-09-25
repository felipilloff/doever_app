import 'calendar_date.dart';

/// Bounded RFC 5545 subset. Invalid instances are skipped, as RRULE requires.
enum Recurrence {
  daily('FREQ=DAILY'),
  weekdays('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'),
  weekly('FREQ=WEEKLY'),
  monthly('FREQ=MONTHLY'),
  yearly('FREQ=YEARLY');

  const Recurrence(this.rule);
  final String rule;
  static Recurrence parse(String rule) => values.firstWhere(
    (item) => item.rule == rule,
    orElse: () => throw const FormatException('Unsupported recurrence rule'),
  );
  CalendarDate next(CalendarDate date) {
    switch (this) {
      case daily:
        return date.addDays(1);
      case weekdays:
        var next = date.addDays(1);
        while (next.weekday > DateTime.friday) {
          next = next.addDays(1);
        }
        return next;
      case weekly:
        return date.addDays(7);
      case monthly:
        var month = date.month + 1;
        while (true) {
          final candidate = DateTime.utc(date.year, month, date.day);
          if (candidate.day == date.day) {
            return CalendarDate.fromLocal(candidate);
          }
          month++;
        }
      case yearly:
        var year = date.year + 1;
        while (DateTime.utc(year, date.month, date.day).month != date.month) {
          year++;
        }
        return CalendarDate(year, date.month, date.day);
    }
  }
}
