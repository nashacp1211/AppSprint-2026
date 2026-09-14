```dart
class ExpiryService {
  static String getStatus(
    DateTime? expiryDate,
    bool expiryUnknown, {
    String? expiryMonthYear,
  }) {
    // =========================================================
    // UNKNOWN EXPIRY
    // =========================================================

    if (expiryUnknown ||
        (expiryDate == null &&
            (expiryMonthYear == null ||
                expiryMonthYear.isEmpty))) {
      return 'EXPIRY UNKNOWN';
    }

    // =========================================================
    // GET EFFECTIVE EXPIRY DATE
    // =========================================================

    DateTime? effectiveExpiryDate = expiryDate;

    // If only month and year are available,
    // use the last day of that month.
    if (effectiveExpiryDate == null &&
        expiryMonthYear != null &&
        expiryMonthYear.isNotEmpty) {
      effectiveExpiryDate =
          _getLastDayOfMonth(expiryMonthYear);
    }

    if (effectiveExpiryDate == null) {
      return 'EXPIRY UNKNOWN';
    }

    // =========================================================
    // CALCULATE DAYS LEFT
    // =========================================================

    final today = DateTime.now();

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final expiryOnly = DateTime(
      effectiveExpiryDate.year,
      effectiveExpiryDate.month,
      effectiveExpiryDate.day,
    );

    final days = expiryOnly
        .difference(todayOnly)
        .inDays;

    // =========================================================
    // EXPIRED
    // =========================================================

    if (days < 0) {
      return 'EXPIRED';
    }

    // =========================================================
    // EXPIRING SOON
    // =========================================================

    if (days <= 7) {
      return 'EXPIRING SOON';
    }

    // =========================================================
    // EXPIRING THIS MONTH
    // =========================================================

    if (days <= 30) {
      return 'EXPIRING THIS MONTH';
    }

    // =========================================================
    // SAFE
    // =========================================================

    return 'SAFE';
  }

  // =========================================================
  // GET LAST DAY OF MONTH
  // =========================================================

  static DateTime? _getLastDayOfMonth(
    String monthYear,
  ) {
    try {
      final parts = monthYear.trim().split(
        RegExp(r'\s+'),
      );

      if (parts.length != 2) {
        return null;
      }

      final monthName = parts[0];
      final year = int.tryParse(parts[1]);

      if (year == null) {
        return null;
      }

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final monthIndex = months.indexWhere(
        (month) =>
            month.toLowerCase() ==
            monthName.toLowerCase(),
      );

      if (monthIndex == -1) {
        return null;
      }

      // Day 0 of the next month =
      // last day of the current month.
      return DateTime(
        year,
        monthIndex + 2,
        0,
      );
    } catch (e) {
      return null;
    }
  }
}
```
