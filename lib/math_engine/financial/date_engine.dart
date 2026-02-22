/// Date calculations (actual and 30/360 day-count conventions).
class DateEngine {
  /// Day-count method for date calculations.
  static const actual = DayCountMethod.actual;
  static const days360 = DayCountMethod.days360;

  /// Returns the number of days between [d1] and [d2].
  ///
  /// For [DayCountMethod.actual], uses calendar days.
  /// For [DayCountMethod.days360], uses the 30/360 convention where each
  /// month is treated as 30 days and the year as 360 days.
  static int daysBetween(DateTime d1, DateTime d2, DayCountMethod method) {
    switch (method) {
      case DayCountMethod.actual:
        // Normalize to date-only (strip time) to avoid DST issues.
        final date1 = DateTime(d1.year, d1.month, d1.day);
        final date2 = DateTime(d2.year, d2.month, d2.day);
        return date2.difference(date1).inDays;

      case DayCountMethod.days360:
        var dd1 = d1.day;
        var dd2 = d2.day;

        // 30/360 convention: cap day values at 30.
        if (dd1 == 31) dd1 = 30;
        if (dd2 == 31 && dd1 >= 30) dd2 = 30;

        return (d2.year - d1.year) * 360 +
            (d2.month - d1.month) * 30 +
            (dd2 - dd1);
    }
  }

  /// Returns a new [DateTime] that is [days] calendar days after [date].
  /// Use a negative value to subtract days.
  static DateTime addDays(DateTime date, int days) {
    return DateTime(date.year, date.month, date.day + days);
  }
}

/// Day-count convention used for date calculations.
enum DayCountMethod {
  /// Actual calendar days.
  actual,

  /// 30/360 convention (each month = 30 days, year = 360 days).
  days360,
}
