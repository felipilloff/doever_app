/// Calendar dates never undergo timezone conversion.
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(int year, int month, int day)
    : value = DateTime.utc(year, month, day) {
    if (value.year != year || value.month != month || value.day != day) {
      throw ArgumentError('Invalid calendar date');
    }
  }
  factory CalendarDate.fromLocal(DateTime date) =>
      CalendarDate(date.year, date.month, date.day);
  factory CalendarDate.parse(String date) {
    final parts = date.split('-').map(int.parse).toList();
    if (parts.length != 3) throw const FormatException('Invalid date');
    return CalendarDate(parts[0], parts[1], parts[2]);
  }
  final DateTime value;
  int get year => value.year;
  int get month => value.month;
  int get day => value.day;
  int get weekday => value.weekday;
  DateTime get local => DateTime(year, month, day);
  CalendarDate addDays(int days) =>
      CalendarDate.fromLocal(value.add(Duration(days: days)));
  @override
  int compareTo(CalendarDate other) => value.compareTo(other.value);
  @override
  bool operator ==(Object other) =>
      other is CalendarDate && value == other.value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value.toIso8601String().substring(0, 10);
}
