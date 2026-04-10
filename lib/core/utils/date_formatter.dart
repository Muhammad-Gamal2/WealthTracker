import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('MMM dd, yyyy');
  static final _shortFormat = DateFormat('MMM dd');
  static final _timeFormat = DateFormat('hh:mm a');

  static String toKey(DateTime date) => _dateFormat.format(date);

  static String toDisplay(DateTime date) => _displayFormat.format(date);

  static String toShort(DateTime date) => _shortFormat.format(date);

  static String toTime(DateTime date) => _timeFormat.format(date);

  static String toDisplayWithTime(DateTime date) =>
      '${_displayFormat.format(date)} ${_timeFormat.format(date)}';

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
