class Medicine {
  String name;
  String strength;
  int quantity;
  String batchNumber;

  DateTime? expiryDate;
  String? expiryMonthYear;
  bool expiryUnknown;

  String instructions;

  bool reminderEnabled;
  String? reminderTime;

  // Family member who owns this medicine
  String familyMember;

  Medicine({
    required this.name,
    required this.strength,
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    this.expiryMonthYear,
    required this.expiryUnknown,
    required this.instructions,
    this.reminderEnabled = false,
    this.reminderTime,

    // Default value
    this.familyMember = 'Me',
  });
}
