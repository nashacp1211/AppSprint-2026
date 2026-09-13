```dart
class Medicine {
  String id;
  String name;
  String strength;

  // Expiry information
  DateTime? expiryDate;
  String? expiryMonthYear;
  bool expiryVerified;

  // Medicine information
  String batchNumber;
  String instructions;
  String familyMember;

  // Optional information
  String imagePath;
  String commonUses;
  String sideEffects;
  String warnings;

  Medicine({
    this.id = '',
    required this.name,
    this.strength = '',
    this.expiryDate,
    this.expiryMonthYear,
    this.expiryVerified = false,
    this.batchNumber = '',
    this.instructions = '',
    this.familyMember = 'Me',
    this.imagePath = '',
    this.commonUses = '',
    this.sideEffects = '',
    this.warnings = '',
  });

  // Convert Medicine into Firebase/Firestore data
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'strength': strength,
      'expiryDate': expiryDate?.toIso8601String(),
      'expiryMonthYear': expiryMonthYear,
      'expiryVerified': expiryVerified,
      'batchNumber': batchNumber,
      'instructions': instructions,
      'familyMember': familyMember,
      'imagePath': imagePath,
      'commonUses': commonUses,
      'sideEffects': sideEffects,
      'warnings': warnings,
    };
  }

  // Create Medicine from Firebase/Firestore data
  factory Medicine.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? parsedExpiry;

    if (map['expiryDate'] != null &&
        map['expiryDate'].toString().isNotEmpty) {
      parsedExpiry = DateTime.tryParse(
        map['expiryDate'].toString(),
      );
    }

    return Medicine(
      id: id,
      name: map['name'] ?? '',
      strength: map['strength'] ?? '',
      expiryDate: parsedExpiry,
      expiryMonthYear: map['expiryMonthYear'],
      expiryVerified: map['expiryVerified'] ?? false,
      batchNumber: map['batchNumber'] ?? '',
      instructions: map['instructions'] ?? '',
      familyMember: map['familyMember'] ?? 'Me',
      imagePath: map['imagePath'] ?? '',
      commonUses: map['commonUses'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      warnings: map['warnings'] ?? '',
    );
  }

  // Returns a readable expiry value
  String get expiryText {
    if (expiryDate != null) {
      return '${expiryDate!.day}/'
          '${expiryDate!.month}/'
          '${expiryDate!.year}';
    }

    if (expiryMonthYear != null &&
        expiryMonthYear!.isNotEmpty) {
      return expiryMonthYear!;
    }

    return 'Expiry Unknown';
  }
}
```
