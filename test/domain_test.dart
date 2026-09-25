import 'package:flutter_test/flutter_test.dart';
import 'package:doever/features/tasks/domain/calendar_date.dart';
import 'package:doever/features/tasks/domain/recurrence.dart';
import 'package:doever/features/tasks/domain/task.dart';

void main() {
  test('calendar date round trips without a timezone shift', () {
    final date = CalendarDate(2026, 9, 6);
    expect(CalendarDate.parse('$date'), date);
    expect(date.addDays(1), CalendarDate(2026, 9, 7));
    expect(CalendarDate(2026, 12, 31).addDays(1), CalendarDate(2027, 1, 1));
    expect(() => CalendarDate(2025, 2, 29), throwsArgumentError);
  });
  test('My Day changes with the local calendar, never a stored boolean', () {
    final task = Task(
      id: 'a',
      listId: inboxId,
      title: 'Task',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      myDayDate: CalendarDate(2026, 9, 25),
    );
    expect(task.isInMyDay(CalendarDate(2026, 9, 25)), true);
    expect(task.isInMyDay(CalendarDate(2026, 9, 26)), false);
  });
  test(
    'daily and weekly cross DST calendar boundaries without duration drift',
    () {
      expect(
        Recurrence.daily.next(CalendarDate(2026, 9, 5)),
        CalendarDate(2026, 9, 6),
      );
      expect(
        Recurrence.weekly.next(CalendarDate(2026, 9, 5)),
        CalendarDate(2026, 9, 12),
      );
      expect(
        Recurrence.weekdays.next(CalendarDate(2026, 9, 25)),
        CalendarDate(2026, 9, 28),
      );
      expect(
        Recurrence.weekdays.next(CalendarDate(2026, 9, 26)),
        CalendarDate(2026, 9, 28),
      );
    },
  );
  test('RFC invalid month days and leap days are skipped, never clamped', () {
    expect(
      Recurrence.monthly.next(CalendarDate(2026, 1, 31)),
      CalendarDate(2026, 3, 31),
    );
    expect(
      Recurrence.monthly.next(CalendarDate(2026, 12, 31)),
      CalendarDate(2027, 1, 31),
    );
    expect(
      Recurrence.yearly.next(CalendarDate(2024, 2, 29)),
      CalendarDate(2028, 2, 29),
    );
    expect(
      Recurrence.yearly.next(CalendarDate(2096, 2, 29)),
      CalendarDate(2104, 2, 29),
    );
    expect(() => Recurrence.parse('FREQ=HOURLY'), throwsFormatException);
    for (final value in Recurrence.values) {
      expect(Recurrence.parse(value.rule), value);
    }
  });
}
