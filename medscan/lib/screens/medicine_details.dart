import 'package:flutter/material.dart';

import '../app_language.dart';
import '../models/medicine.dart';
import '../services/expiry_service.dart';
import '../services/medicine_info_service.dart';

class MedicineDetailsPage extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailsPage({
    super.key,
    required this.medicine,
  });

  @override
  State<MedicineDetailsPage> createState() =>
      _MedicineDetailsPageState();
}

class _MedicineDetailsPageState
    extends State<MedicineDetailsPage> {
  MedicineInfo? medicineInfo;

  bool isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    loadMedicineInformation();
  }

  // =========================================================
  // LOAD MEDICINE INFORMATION
  // =========================================================

  Future<void> loadMedicineInformation() async {
    final name =
        widget.medicine.name.trim();

    if (name.isEmpty ||
        name.toLowerCase() == 'unknown') {
      if (mounted) {
        setState(() {
          isLoadingInfo = false;
        });
      }

      return;
    }

    final result =
        await MedicineInfoService.searchMedicine(
      name,
    );

    if (!mounted) return;

    setState(() {
      medicineInfo = result;
      isLoadingInfo = false;
    });
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final medicine =
        widget.medicine;

    final String status =
        ExpiryService.getStatus(
      medicine.expiryDate,
      medicine.expiryUnknown,
      expiryMonthYear:
          medicine.expiryMonthYear,
    );

    final Color statusColor =
        getStatusColor(status);

    final IconData statusIcon =
        getStatusIcon(status);

    // =========================================================
    // EXPIRY TEXT
    // =========================================================

    String expiryText;

    if (medicine.expiryUnknown) {
      expiryText =
          '⚠️ ${AppLanguage.text('Expiry Unknown')}';
    } else if (medicine.expiryDate != null) {
      expiryText =
          '${medicine.expiryDate!.day}/'
          '${medicine.expiryDate!.month}/'
          '${medicine.expiryDate!.year}';
    } else if (medicine.expiryMonthYear != null &&
        medicine.expiryMonthYear!.isNotEmpty) {
      expiryText =
          medicine.expiryMonthYear!;
    } else {
      expiryText =
          '⚠️ ${AppLanguage.text('Expiry Unknown')}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLanguage.text(
            'Medicine Details',
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =================================================
            // MEDICINE ICON
            // =================================================

            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor:
                    statusColor.withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  Icons.medication,
                  size: 52,
                  color: statusColor,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =================================================
            // MEDICINE NAME
            // =================================================

            Center(
              child: Text(
                medicine.name,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // =================================================
            // STRENGTH
            // =================================================

            if (medicine.strength.isNotEmpty)
              Center(
                child: Text(
                  medicine.strength,
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // =================================================
            // EXPIRY STATUS
            // =================================================

            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 22,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // BASIC DETAILS
            // =================================================

            sectionTitle(
              '📋 ${AppLanguage.text('Medicine Details')}',
            ),

            const SizedBox(height: 15),

            detailItem(
              AppLanguage.text(
                'Strength',
              ),
              medicine.strength.isEmpty
                  ? AppLanguage.text(
                      'Not provided',
                    )
                  : medicine.strength,
            ),

            detailItem(
              AppLanguage.text(
                'Quantity',
              ),
              '${medicine.quantity}',
            ),

            detailItem(
              AppLanguage.text(
                'Batch Number',
              ),
              medicine.batchNumber.isEmpty
                  ? AppLanguage.text(
                      'Not provided',
                    )
                  : medicine.batchNumber,
            ),

            detailItem(
              AppLanguage.text(
                'Expiry Status',
              ),
              status,
            ),

            detailItem(
              AppLanguage.text(
                'Expiry Date',
              ),
              expiryText,
            ),

            // =================================================
            // UNKNOWN EXPIRY WARNING
            // =================================================

            if (medicine.expiryUnknown)
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.only(
                  bottom: 22,
                ),
                padding:
                    const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color: Colors.orange,
                    width: 1.5,
                  ),
                  color:
                      Colors.orange.withValues(
                    alpha: 0.08,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.orange,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child: Text(
                            AppLanguage.text(
                              'EXPIRY CANNOT BE VERIFIED',
                            ),
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      AppLanguage.text(
                        'Do not use the medicine until its expiry date has been verified.',
                      ),
                      style:
                          const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      AppLanguage.text(
                        'Please check the original packaging or ask a pharmacist.',
                      ),
                      style:
                          const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            // =================================================
            // PRESCRIPTION INSTRUCTIONS
            // =================================================

            sectionTitle(
              '📝 ${AppLanguage.text('Prescription Instructions')}',
            ),

            const SizedBox(height: 12),

            infoCard(
              icon:
                  Icons.receipt_long,
              title:
                  AppLanguage.text(
                    'Doctor / Prescription Instructions',
                  ),
              text:
                  medicine.instructions.isEmpty
                      ? AppLanguage.text(
                          'Not provided',
                        )
                      : medicine.instructions,
            ),

            const SizedBox(height: 10),

            // =================================================
            // MEDICINE INFORMATION
            // =================================================

            sectionTitle(
              '💊 ${AppLanguage.text('Medicine Information')}',
            ),

            const SizedBox(height: 12),

            Text(
              AppLanguage.text(
                'Information is retrieved from a trusted medicine data source. Always compare it with the medicine package or leaflet.',
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            // =================================================
            // INFORMATION LOADING
            // =================================================

            if (isLoadingInfo)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(25),
                  child:
                      CircularProgressIndicator(),
                ),
              ),

            // =================================================
            // INFORMATION FOUND
            // =================================================

            if (!isLoadingInfo &&
                medicineInfo != null) ...[
              infoCard(
                icon:
                    Icons.medical_information,
                title:
                    AppLanguage.text(
                      'Common Uses',
                    ),
                text:
                    medicineInfo!.uses.isNotEmpty
                        ? medicineInfo!.uses
                        : AppLanguage.text(
                            'Information is not available from the selected source.',
                          ),
              ),

              infoCard(
                icon:
                    Icons.warning_amber,
                title:
                    AppLanguage.text(
                      'Common Side Effects',
                    ),
                text:
                    medicineInfo!
                            .sideEffects
                            .isNotEmpty
                        ? medicineInfo!
                            .sideEffects
                        : AppLanguage.text(
                            'Information is not available from the selected source.',
                          ),
              ),

              infoCard(
                icon:
                    Icons.report_problem,
                title:
                    AppLanguage.text(
                      'Important Warnings',
                    ),
                text:
                    medicineInfo!
                            .warnings
                            .isNotEmpty
                        ? medicineInfo!
                            .warnings
                        : AppLanguage.text(
                            'Information is not available from the selected source.',
                          ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  color:
                      Colors.blue.withValues(
                    alpha: 0.08,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 22,
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Expanded(
                      child: Text(
                        'Medicine identity matched with RxNorm. Information is provided for reference and should not replace professional medical advice.',
                        style:
                            const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // =================================================
            // INFORMATION NOT FOUND
            // =================================================

            if (!isLoadingInfo &&
                medicineInfo == null)
              infoCard(
                icon:
                    Icons.help_outline,
                title:
                    AppLanguage.text(
                      'Information Unavailable',
                    ),
                text:
                    AppLanguage.text(
                  'This medicine could not be reliably matched with the available medicine database. Please check the package, leaflet, pharmacist, or healthcare professional.',
                ),
              ),

            const SizedBox(height: 20),

            // =================================================
            // SAFETY INFORMATION
            // =================================================

            sectionTitle(
              '⚠️ ${AppLanguage.text('Safety Information')}',
            ),

            const SizedBox(height: 12),

            safetyItem(
              'Always follow the instructions given by your doctor or pharmacist.',
            ),

            safetyItem(
              'Do not use a medicine if its expiry date cannot be verified.',
            ),

            safetyItem(
              'Never use a medicine after its expiry date.',
            ),

            safetyItem(
              'The app does not diagnose diseases or prescribe medicines.',
            ),

            safetyItem(
              'Medicine information shown by the app is for reference and should be confirmed with a healthcare professional when needed.',
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DETAIL ITEM
  // =========================================================

  Widget detailItem(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 17,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget sectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight:
            FontWeight.bold,
      ),
    );
  }

  // =========================================================
  // INFORMATION CARD
  // =========================================================

  Widget infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              size: 30,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Text(
                    text,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SAFETY ITEM
  // =========================================================

  Widget safetyItem(
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 21,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              AppLanguage.text(text),
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
