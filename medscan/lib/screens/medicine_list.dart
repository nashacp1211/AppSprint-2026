import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'medicine_details.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() =>
      _MedicineListPageState();
}

class _MedicineListPageState
    extends State<MedicineListPage> {
  final DatabaseService databaseService =
      DatabaseService();

  List<MedicineWithId> medicines = [];

  bool isLoading = true;

  // Selected family member
  String selectedMember = 'All';

  // Family members
  final List<String> familyMembers = [
    'All',
    'Me',
    'Mother',
    'Father',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  // =========================================================
  // LOAD MEDICINES
  // =========================================================

  Future<void> loadMedicines() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await databaseService.getMedicines();

      if (!mounted) return;

      setState(() {
        medicines = result;
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
            'Error loading medicines: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // FILTER MEDICINES
  // =========================================================

  List<MedicineWithId> get filteredMedicines {
    if (selectedMember == 'All') {
      return medicines;
    }

    return medicines.where((item) {
      return item.medicine.familyMember ==
          selectedMember;
    }).toList();
  }

  // =========================================================
  // DELETE MEDICINE
  // =========================================================

  Future<void> confirmDelete(
    MedicineWithId item,
  ) async {
    final medicine = item.medicine;

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

    if (shouldDelete != true) {
      return;
    }

    try {
      await databaseService.deleteMedicine(
        item.id,
      );

      if (!mounted) return;

      await loadMedicines();

      if (!mounted) return;

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
  // FAMILY ICON
  // =========================================================

  IconData getFamilyIcon(
    String member,
  ) {
    switch (member) {
      case 'Mother':
        return Icons.woman;

      case 'Father':
        return Icons.man;

      case 'Brother':
        return Icons.boy;

      case 'Sister':
        return Icons.girl;

      case 'Other':
        return Icons.people;

      default:
        return Icons.person;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final displayedMedicines =
        filteredMedicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Medicines',
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [

                // =================================================
                // FAMILY FILTER
                // =================================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    15,
                    15,
                    15,
                    5,
                  ),

                  child: DropdownButtonFormField<String>(
                    initialValue:
                        selectedMember,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Filter by Family Member',

                      prefixIcon:
                          Icon(
                        Icons.people,
                      ),

                      border:
                          OutlineInputBorder(),
                    ),

                    items:
                        familyMembers.map(
                      (member) {
                        return DropdownMenuItem<
                            String>(
                          value: member,

                          child: Row(
                            children: [
                              Icon(
                                getFamilyIcon(
                                  member,
                                ),
                                size: 20,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Text(
                                member,
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedMember =
                            value;
                      });
                    },
                  ),
                ),

                // =================================================
                // RESULT COUNT
                // =================================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),

                  child: Align(
                    alignment:
                        Alignment.centerLeft,

                    child: Text(
                      selectedMember == 'All'
                          ? 'All medicines: '
                              '${displayedMedicines.length}'
                          : '$selectedMember\'s medicines: '
                              '${displayedMedicines.length}',

                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // =================================================
                // MEDICINE LIST
                // =================================================

                Expanded(
                  child:
                      displayedMedicines.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [
                                  const Icon(
                                    Icons
                                        .medication_outlined,
                                    size: 80,
                                  ),

                                  const SizedBox(
                                    height: 15,
                                  ),

                                  Text(
                                    selectedMember ==
                                            'All'
                                        ? 'No medicines saved'
                                        : 'No medicines for '
                                            '$selectedMember',

                                    style:
                                        const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  const Text(
                                    'Add a medicine to see it here.',
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh:
                                  loadMedicines,

                              child:
                                  ListView.builder(
                                padding:
                                    const EdgeInsets
                                        .all(15),

                                itemCount:
                                    displayedMedicines
                                        .length,

                                itemBuilder:
                                    (context, index) {
                                  final item =
                                      displayedMedicines[
                                          index];

                                  final medicine =
                                      item.medicine;

                                  return Card(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      bottom: 12,
                                    ),

                                    child:
                                        ListTile(
                                      leading:
                                          CircleAvatar(
                                        child:
                                            const Icon(
                                          Icons
                                              .medication,
                                        ),
                                      ),

                                      title:
                                          Text(
                                        medicine.name,

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      subtitle:
                                          Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          top: 5,
                                        ),

                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [
                                            Text(
                                              medicine
                                                  .strength,
                                            ),

                                            const SizedBox(
                                              height: 5,
                                            ),

                                            Row(
                                              children: [
                                                Icon(
                                                  getFamilyIcon(
                                                    medicine
                                                        .familyMember,
                                                  ),
                                                  size:
                                                      16,
                                                ),

                                                const SizedBox(
                                                  width:
                                                      5,
                                                ),

                                                Text(
                                                  'For: '
                                                  '${medicine.familyMember}',
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight
                                                            .w500,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(
                                              height: 5,
                                            ),

                                            Text(
                                              'Quantity: '
                                              '${medicine.quantity}',
                                            ),
                                          ],
                                        ),
                                      ),

                                      isThreeLine:
                                          true,

                                      trailing:
                                          IconButton(
                                        icon:
                                            const Icon(
                                          Icons
                                              .delete_outline,
                                        ),

                                        tooltip:
                                            'Delete medicine',

                                        onPressed: () {
                                          confirmDelete(
                                            item,
                                          );
                                        },
                                      ),

                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    MedicineDetailsPage(
                                              medicine:
                                                  medicine,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}
