```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_language.dart';
import '../models/medicine.dart';
import '../services/database_service.dart';
import '../services/expiry_service.dart';

import 'add_medicine.dart';
import 'login.dart';
import 'medicine_details.dart';
import 'medicine_list.dart';
import 'scan_medicine.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService databaseService =
      DatabaseService();

  List<Medicine> medicines = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  // =========================================================
  // LOAD MEDICINES
  // =========================================================

  Future<void> loadMedicines() async {
    try {
      final result =
          await databaseService.getMedicines();

      if (!mounted) return;

      setState(() {
        medicines =
            result.map((item) => item.medicine).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load medicines: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // SAVE MEDICINE
  // =========================================================

  Future<void> saveMedicine(
    Medicine medicine,
  ) async {
    await databaseService.addMedicine(
      medicine,
    );
  }

  // =========================================================
  // DELETE MEDICINE
  // =========================================================

  Future<void> deleteMedicine(
    Medicine medicine,
  ) async {
    try {
      final savedMedicines =
          await databaseService.getMedicines();

      MedicineWithId? medicineToDelete;

      for (final item in savedMedicines) {
        final saved = item.medicine;

        if (saved.name == medicine.name &&
            saved.strength == medicine.strength &&
            saved.quantity == medicine.quantity &&
            saved.batchNumber ==
                medicine.batchNumber) {
          medicineToDelete = item;
          break;
        }
      }

      if (medicineToDelete == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Medicine not found',
            ),
          ),
        );

        return;
      }

      await databaseService.deleteMedicine(
        medicineToDelete.id,
      );

      if (!mounted) return;

      setState(() {
        medicines.remove(medicine);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${medicine.name} deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // CONFIRM DELETE
  // =========================================================

  Future<void> confirmDelete(
    Medicine medicine,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Medicine?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '${medicine.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'DELETE',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteMedicine(medicine);
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  // =========================================================
  // EXPIRING SOON COUNT
  // =========================================================

  int get expiringSoonCount {
    return medicines.where((medicine) {
      return ExpiryService.getStatus(
            medicine.expiryDate,
            medicine.expiryUnknown,
            expiryMonthYear:
                medicine.expiryMonthYear,
          ) ==
          'EXPIRING SOON';
    }).length;
  }

  // =========================================================
  // SAFE COUNT
  // =========================================================

  int get safeCount {
    return medicines.where((medicine) {
      return ExpiryService.getStatus(
            medicine.expiryDate,
            medicine.expiryUnknown,
            expiryMonthYear:
                medicine.expiryMonthYear,
          ) ==
          'SAFE';
    }).length;
  }

  // =========================================================
  // UNKNOWN EXPIRY COUNT
  // =========================================================

  int get unknownCount {
    return medicines.where((medicine) {
      return medicine.expiryUnknown ||
          (medicine.expiryDate == null &&
              (medicine.expiryMonthYear == null ||
                  medicine.expiryMonthYear!.isEmpty));
    }).length;
  }

  // =========================================================
  // THIS MONTH COUNT
  // =========================================================

  int get thisMonthCount {
    final now = DateTime.now();

    return medicines.where((medicine) {
      if (medicine.expiryUnknown) {
        return false;
      }

      if (medicine.expiryDate != null) {
        return medicine.expiryDate!.year ==
                now.year &&
            medicine.expiryDate!.month ==
                now.month;
      }

      if (medicine.expiryMonthYear != null &&
          medicine.expiryMonthYear!.isNotEmpty) {
        final parts =
            medicine.expiryMonthYear!.split(' ');

        if (parts.length == 2) {
          final year =
              int.tryParse(parts[1]);

          final month =
              getMonthNumber(parts[0]);

          return year == now.year &&
              month == now.month;
        }
      }

      return false;
    }).length;
  }

  // =========================================================
  // MONTH NUMBER
  // =========================================================

  int? getMonthNumber(String month) {
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

    for (int i = 0; i < months.length; i++) {
      if (months[i].toLowerCase() ==
          month.toLowerCase()) {
        return i + 1;
      }
    }

    return null;
  }

  // =========================================================
  // STATUS ICON
  // =========================================================

  IconData getStatusIcon(
    String status,
  ) {
    switch (status) {
      case 'SAFE':
        return Icons.check_circle;

      case 'EXPIRING SOON':
        return Icons.warning;

      case 'EXPIRING THIS MONTH':
        return Icons.calendar_month;

      case 'EXPIRED':
        return Icons.cancel;

      default:
        return Icons.help;
    }
  }

  // =========================================================
  // STATUS COLOR
  // =========================================================

  Color getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'SAFE':
        return Colors.green;

      case 'EXPIRING SOON':
        return Colors.orange;

      case 'EXPIRING THIS MONTH':
        return Colors.amber.shade700;

      case 'EXPIRED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MedScan',
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // GREETING
                  // =================================================

                  Text(
                    AppLanguage.text(
                      'Hello! 👋',
                    ),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    AppLanguage.text(
                      'Manage your medicines safely',
                    ),
                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =================================================
                  // DASHBOARD
                  // =================================================

                  Row(
                    children: [
                      Expanded(
                        child: statusCard(
                          'Expiring Soon',
                          '$expiringSoonCount',
                          Icons.warning,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: statusCard(
                          'Safe',
                          '$safeCount',
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: statusCard(
                          'This Month',
                          '$thisMonthCount',
                          Icons.calendar_month,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: statusCard(
                          'Unknown',
                          '$unknownCount',
                          Icons.help,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =================================================
                  // SCAN MEDICINE
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child:
                        ElevatedButton.icon(
                      onPressed: () async {
                        final Medicine? medicine =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ScanMedicinePage(),
                          ),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (medicine != null) {
                          try {
                            await saveMedicine(
                              medicine,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            setState(() {
                              medicines.add(
                                medicine,
                              );
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Medicine saved successfully!',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not save medicine: $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                      ),
                      label: Text(
                        AppLanguage.text(
                          'SCAN MEDICINE',
                        ),
                        style:
                            const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =================================================
                  // ADD MEDICINE
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child:
                        OutlinedButton.icon(
                      onPressed: () async {
                        final Medicine? medicine =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AddMedicinePage(),
                          ),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (medicine != null) {
                          try {
                            await saveMedicine(
                              medicine,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            setState(() {
                              medicines.add(
                                medicine,
                              );
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Medicine saved successfully!',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not save medicine: $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: Text(
                        AppLanguage.text(
                          'ADD MEDICINE',
                        ),
                        style:
                            const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // =================================================
                  // MY MEDICINES
                  // =================================================

                  Text(
                    AppLanguage.text(
                      'My Medicines',
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  if (medicines.isEmpty)
                    Text(
                      AppLanguage.text(
                        'No medicines added yet.',
                      ),
                      style:
                          const TextStyle(
                        fontSize: 16,
                      ),
                    )
                  else
                    ...medicines.map(
                      (medicine) =>
                          medicineCard(
                        medicine,
                      ),
                    ),
                ],
              ),
            ),

      // =========================================================
      // BOTTOM NAVIGATION
      // =========================================================

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 0,

        onTap: (index) {
          // MEDICINES
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MedicineListPage(),
              ),
            );
          }

          // FAMILY
          if (index == 2) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Family section coming soon',
                ),
              ),
            );
          }

          // SETTINGS
          if (index == 3) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Settings coming soon',
                ),
              ),
            );
          }
        },

        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.home,
            ),
            label:
                AppLanguage.text(
              'Home',
            ),
          ),

          BottomNavigationBarItem(
            icon: const Icon(
              Icons.medication,
            ),
            label:
                AppLanguage.text(
              'Medicines',
            ),
          ),

          BottomNavigationBarItem(
            icon: const Icon(
              Icons.people,
            ),
            label:
                AppLanguage.text(
              'Family',
            ),
          ),

          BottomNavigationBarItem(
            icon: const Icon(
              Icons.settings,
            ),
            label:
                AppLanguage.text(
              'Settings',
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS CARD
  // =========================================================

  Widget statusCard(
    String title,
    String number,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              number,
              style: const TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              AppLanguage.text(title),
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MEDICINE CARD
  // =========================================================

  Widget medicineCard(
    Medicine medicine,
  ) {
    final status =
        ExpiryService.getStatus(
      medicine.expiryDate,
      medicine.expiryUnknown,
      expiryMonthYear:
          medicine.expiryMonthYear,
    );

    final statusColor =
        getStatusColor(status);

    final statusIcon =
        getStatusIcon(status);

    String expiryText;

    if (medicine.expiryUnknown) {
      expiryText =
          'Expiry: Unknown';
    } else if (medicine.expiryDate != null) {
      expiryText =
          'Expiry: '
          '${medicine.expiryDate!.day}/'
          '${medicine.expiryDate!.month}/'
          '${medicine.expiryDate!.year}';
    } else if (medicine.expiryMonthYear !=
            null &&
        medicine.expiryMonthYear!.isNotEmpty) {
      expiryText =
          'Expiry: '
          '${medicine.expiryMonthYear}';
    } else {
      expiryText =
          'Expiry: Unknown';
    }

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          child: Icon(
            Icons.medication,
            color: statusColor,
          ),
        ),

        title: Text(
          medicine.name,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 17,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 6,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                medicine.strength,
              ),

              const SizedBox(
                height: 6,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    'For: '
                    '${medicine.familyMember}',
                  ),
                ],
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                expiryText,
              ),

              const SizedBox(
                height: 6,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      statusColor.withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color:
                          statusColor,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      status,
                      style: TextStyle(
                        color:
                            statusColor,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
          ),
          onPressed: () {
            confirmDelete(
              medicine,
            );
          },
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MedicineDetailsPage(
                medicine: medicine,
              ),
            ),
          );
        },
      ),
    );
  }
}
```
