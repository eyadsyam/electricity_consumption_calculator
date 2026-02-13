import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for date formatting
class DateFormatter {
  DateFormatter._(); // Private constructor

  /// Format date to standard format (yyyy-MM-dd)
  static String formatToStandard(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format date to display format (MMM dd, yyyy)
  static String formatToDisplay(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  /// Format date to month-year format (MMMM yyyy)
  static String formatToMonthYear(DateTime date) {
    return DateFormat(AppConstants.monthYearFormat).format(date);
  }

  /// Parse standard date string to DateTime
  static DateTime? parseStandardDate(String dateString) {
    try {
      return DateFormat(AppConstants.dateFormat).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get current date as standard string
  static String getCurrentDateString() {
    return formatToStandard(DateTime.now());
  }

  /// Get month name from month number (1-12)
  static String getMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return AppConstants.monthKeys[month - 1];
  }

  /// Get current month key
  static String getCurrentMonthKey() {
    return getMonthName(DateTime.now().month);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is in current month
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get days difference from now
  static int getDaysFromNow(DateTime date) {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }
}
