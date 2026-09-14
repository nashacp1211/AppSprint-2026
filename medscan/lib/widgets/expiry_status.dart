```dart
import 'package:flutter/material.dart';

class ExpiryStatus extends StatelessWidget {
  final DateTime? expiryDate;
  final String? expiryMonthYear;
  final bool expiryVerified;

  const ExpiryStatus({
    super.key,
    this.expiryDate,
    this.expiryMonthYear,
    this.expiryVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    // Unknown expiry
    if (expiryDate == null &&
        (expiryMonthYear == null ||
            expiryMonthYear!.isEmpty)) {
      return _statusBox(
        icon: Icons.warning_amber_rounded,
        text: 'Expiry Unknown',
        color: Colors.orange,
      );
    }

    // Expiry date is not verified
    if (!expiryVerified) {
      return _statusBox(
        icon: Icons.help_outline,
        text: 'Expiry Not Verified',
        color: Colors.orange,
      );
    }

    final DateTime date = expiryDate!;

    final DateTime today = DateTime.now();

    final DateTime todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final DateTime expiryOnly = DateTime(
      date.year,
      date.month,
      date.day,
    );

    // Already expired
    if (expiryOnly.isBefore(todayOnly)) {
      return _statusBox(
        icon: Icons.cancel,
        text: 'Expired',
        color: Colors.red,
      );
    }

    // Days remaining
    final int daysLeft =
        expiryOnly.difference(todayOnly).inDays;

    // Expiring within 30 days
    if (daysLeft <= 30) {
      return _statusBox(
        icon: Icons.warning_amber_rounded,
        text: 'Expires in $daysLeft days',
        color: Colors.orange,
      );
    }

    // Safe
    return _statusBox(
      icon: Icons.check_circle,
      text: 'Safe • Expires ${_formatDate(date)}',
      color: Colors.green,
    );
  }

  Widget _statusBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

