import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  /// Format date to display format (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format date to short format (e.g., "15/01/2024")
  static String formatDateShort(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  /// Get date without time
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = dateOnly(from);
    to = dateOnly(to);
    return to.difference(from).inDays;
  }

  /// Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Subtract days from a date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Get the first day of the month
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the last day of the month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return dateOnly(date).isBefore(dateOnly(DateTime.now()));
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return dateOnly(date).isAfter(dateOnly(DateTime.now()));
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
