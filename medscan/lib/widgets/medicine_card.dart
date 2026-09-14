```dart
import 'package:flutter/material.dart';

import '../models/medicine.dart';
import 'expiry_status.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // Medicine icon
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  Icons.medication,
                  size: 30,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(width: 14),

              // Medicine information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (medicine.strength.isNotEmpty)
                      Text(
                        medicine.strength,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          medicine.familyMember,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Expiry status
                    ExpiryStatus(
                      expiryDate: medicine.expiryDate,
                      expiryMonthYear: medicine.expiryMonthYear,
                      expiryVerified: medicine.expiryVerified,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

