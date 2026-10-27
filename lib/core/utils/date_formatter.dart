import 'package:intl/intl.dart';

/// Utility methods for human-friendly date and time formatting and comparisons.
abstract class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, y • hh:mm a');
  static final DateFormat _dateFormat = DateFormat('EEE, MMM d, y');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Parse an ISO-8601 string safely into a local [DateTime].
  static DateTime? parse(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return null;
    try {
      final parsed = DateTime.parse(isoString);
      return parsed.isUtc ? parsed.toLocal() : parsed;
    } catch (_) {
      return null;
    }
  }

  /// Format an ISO-8601 string or DateTime into "MMM d, y • hh:mm a" (e.g. "Oct 27, 2026 • 09:30 AM").
  static String formatDateTime(dynamic date) {
    final dt = date is DateTime ? date : parse(date?.toString());
    if (dt == null) return '—';
    return _dateTimeFormat.format(dt);
  }

  /// Format as date only "EEE, MMM d, y" (e.g., "Tue, Oct 27, 2026").
  static String formatDate(dynamic date) {
    final dt = date is DateTime ? date : parse(date?.toString());
    if (dt == null) return '—';
    return _dateFormat.format(dt);
  }

  /// Format as time only "hh:mm a" (e.g., "11:45 AM").
  static String formatTime(dynamic date) {
    final dt = date is DateTime ? date : parse(date?.toString());
    if (dt == null) return '—';
    return _timeFormat.format(dt);
  }

  /// Check whether a date is "today" in the device's local timezone.
  static bool isToday(dynamic date) {
    final dt = date is DateTime ? date : parse(date?.toString());
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// Generate current timestamp in ISO-8601 format (UTC) for persistence.
  static String nowIso() => DateTime.now().toUtc().toIso8601String();
}
