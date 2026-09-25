import 'package:intl/intl.dart';

class DateFormatter {
  static String formatReleaseYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr);
      return dateTime.year.toString();
    } catch (_) {
      return dateStr.length >= 4 ? dateStr.substring(0, 4) : dateStr;
    }
  }

  static String formatFullDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String formatWatchedTimelineHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (checkDate == today) {
      return 'TODAY';
    } else if (checkDate == yesterday) {
      return 'YESTERDAY';
    } else {
      return DateFormat('EEEE, MMM d').format(dateTime).toUpperCase();
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}
