import 'package:intl/intl.dart';

/// Date formatting and comparison utilities.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortFormat = DateFormat('MMM d');

  /// Returns date string in yyyy-MM-dd for Firestore/API.
  static String toStorageDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Parses storage date string to DateTime (date only, no time).
  static DateTime fromStorageDate(String dateStr) {
    return _dateFormat.parse(dateStr);
  }

  /// User-friendly display format.
  static String toDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }

  static String toShortDisplayDate(DateTime date) {
    return _shortFormat.format(date);
  }

  /// Whether [date] is today (by date only).
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Start of day for a given date.
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
