import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medicine.dart';

class MedicineWithId {
  final String id;
  final Medicine medicine;

  MedicineWithId({
    required this.id,
    required this.medicine,
  });
}

class DatabaseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================================================
  // ADD MEDICINE
  // =========================================================

  Future<void> addMedicine(
    Medicine medicine,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('medicines')
        .add({
      'userId': user.uid,

      'name': medicine.name,
      'strength': medicine.strength,
      'quantity': medicine.quantity,
      'batchNumber': medicine.batchNumber,

      'expiryDate': medicine.expiryDate,
      'expiryMonthYear': medicine.expiryMonthYear,
      'expiryUnknown': medicine.expiryUnknown,

      'instructions': medicine.instructions,

      'reminderEnabled':
          medicine.reminderEnabled,
      'reminderTime':
          medicine.reminderTime,

      // FAMILY MEMBER
      'familyMember':
          medicine.familyMember,
    });
  }

  // =========================================================
  // GET MEDICINES
  // =========================================================

  Future<List<MedicineWithId>> getMedicines() async {
    final user = _auth.currentUser;

    if (user == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('medicines')
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      DateTime? expiryDate;

      if (data['expiryDate'] != null) {
        expiryDate =
            (data['expiryDate'] as Timestamp)
                .toDate();
      }

      String? expiryMonthYear;

      if (data['expiryMonthYear'] != null) {
        expiryMonthYear =
            data['expiryMonthYear'].toString();
      }

      final medicine = Medicine(
        name: data['name'] ?? '',
        strength: data['strength'] ?? '',
        quantity: data['quantity'] ?? 0,
        batchNumber:
            data['batchNumber'] ?? '',

        expiryDate: expiryDate,

        expiryMonthYear:
            expiryMonthYear,

        expiryUnknown:
            data['expiryUnknown'] ?? false,

        instructions:
            data['instructions'] ?? '',

        reminderEnabled:
            data['reminderEnabled'] ?? false,

        reminderTime:
            data['reminderTime'],

        familyMember:
            data['familyMember'] ?? 'Me',
      );

      return MedicineWithId(
        id: doc.id,
        medicine: medicine,
      );
    }).toList();
  }

  // =========================================================
  // UPDATE QUANTITY
  // =========================================================

  Future<void> updateQuantity(
    String medicineId,
    int newQuantity,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in',
      );
    }

    // Quantity cannot be negative
    if (newQuantity < 0) {
      newQuantity = 0;
    }

    final medicineRef =
        _firestore
            .collection('medicines')
            .doc(medicineId);

    final medicine =
        await medicineRef.get();

    if (!medicine.exists) {
      throw Exception(
        'Medicine not found',
      );
    }

    final data = medicine.data();

    // Make sure this medicine belongs
    // to the logged-in user
    if (data?['userId'] != user.uid) {
      throw Exception(
        'You cannot update this medicine',
      );
    }

    await medicineRef.update({
      'quantity': newQuantity,
    });
  }

  // =========================================================
  // DELETE MEDICINE
  // =========================================================

  Future<void> deleteMedicine(
    String medicineId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in',
      );
    }

    final medicineRef =
        _firestore
            .collection('medicines')
            .doc(medicineId);

    final medicine =
        await medicineRef.get();

    if (!medicine.exists) {
      return;
    }

    final data = medicine.data();

    if (data?['userId'] != user.uid) {
      throw Exception(
        'You cannot delete this medicine',
      );
    }

    await medicineRef.delete();
  }
}
