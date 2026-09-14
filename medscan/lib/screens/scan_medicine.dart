import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';
import '../services/medicine_info_service.dart';
import '../models/medicine.dart';
import 'add_medicine.dart';

class ScanMedicinePage extends StatefulWidget {
  const ScanMedicinePage({super.key});

  @override
  State<ScanMedicinePage> createState() =>
      _ScanMedicinePageState();
}

class _ScanMedicinePageState
    extends State<ScanMedicinePage> {
  final ImagePicker picker = ImagePicker();
  final OCRService ocrService = OCRService();

  XFile? medicineImage;

  String detectedText = '';
  bool isScanning = false;
  bool isVerifying = false;

  String medicineName = 'Unknown';
  String strength = 'Unknown';
  String expiry = 'Unknown';
  String batchNumber = 'Unknown';

  MedicineInfo? verifiedMedicine;
  bool verificationCompleted = false;

  // =========================================================
  // EXTRACT MEDICINE DETAILS
  // =========================================================

  void extractMedicineDetails(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    medicineName = 'Unknown';
    strength = 'Unknown';
    expiry = 'Unknown';
    batchNumber = 'Unknown';

    // =======================================================
    // MEDICINE NAME
    // =======================================================

    final knownMedicines = [
      'paracetamol',
      'ibuprofen',
      'amoxicillin',
      'azithromycin',
      'cetirizine',
      'omeprazole',
      'metformin',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();

      for (final medicine in knownMedicines) {
        if (lower.contains(medicine)) {
          medicineName =
              medicine[0].toUpperCase() +
              medicine.substring(1);

          break;
        }
      }

      if (medicineName != 'Unknown') {
        break;
      }
    }

    // =======================================================
    // STRENGTH
    // =======================================================

    final strengthPattern = RegExp(
      r'(\d+(?:\.\d+)?)\s*'
      r'(mg|mcg|g|ml|%)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match =
          strengthPattern.firstMatch(line);

      if (match != null) {
        strength =
            '${match.group(1)} ${match.group(2)}';
        break;
      }
    }

    // =======================================================
    // EXPIRY DATE
    // =======================================================

    // IMPORTANT:
    // We search ONLY near EXP / EXPIRY.
    //
    // This prevents:
    //
    // MFG.FEB.2025
    // EXP.FEB.2027
    //
    // from becoming FEB 2025.

    expiry = _extractExpiry(text);

    // =======================================================
    // BATCH NUMBER
    // =======================================================

    final batchPattern = RegExp(
      r'(batch|b\.?\s*no\.?|lot)'
      r'[\s:.-]*'
      r'([A-Z0-9/-]+)',
      caseSensitive: false,
    );

    final batchMatch =
        batchPattern.firstMatch(text);

    if (batchMatch != null) {
      batchNumber =
          batchMatch.group(2)!;
    }
  }

  // =========================================================
  // EXTRACT EXPIRY ONLY
  // =========================================================

  String _extractExpiry(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // -------------------------------------------------------
    // MONTH NAME FORMAT
    // -------------------------------------------------------
    //
    // EXP.FEB.2027
    // EXP FEB 2027
    // EXP: FEB 2027
    // EXP-FEB-2027
    //
    final monthExpiryPattern = RegExp(
      r'\b(?:exp|expiry|expiration|expires?)'
      r'[\s:./-]*'
      r'(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)'
      r'[a-z]*'
      r'[\s:./-]*'
      r'(20\d{2}|\d{2})\b',
      caseSensitive: false,
    );

    // Search the complete text for EXP + month + year.
    final monthMatch =
        monthExpiryPattern.firstMatch(text);

    if (monthMatch != null) {
      final month =
          monthMatch.group(1)!.toUpperCase();

      final year =
          monthMatch.group(2)!;

      final fullYear =
          year.length == 2
              ? '20$year'
              : year;

      return '$month $fullYear';
    }

    // -------------------------------------------------------
    // NUMERIC FORMAT
    // -------------------------------------------------------
    //
    // EXP 05/2027
    // EXP:05/2027
    // EXP-05-2027
    // EXP 05/27
    //

    final numericExpiryPattern = RegExp(
      r'\b(?:exp|expiry|expiration|expires?)'
      r'[\s:./-]*'
      r'(0?[1-9]|1[0-2])'
      r'[\s./-]'
      r'(20\d{2}|\d{2})\b',
      caseSensitive: false,
    );

    final numericMatch =
        numericExpiryPattern.firstMatch(text);

    if (numericMatch != null) {
      final month =
          numericMatch.group(1)!;

      final year =
          numericMatch.group(2)!;

      final fullYear =
          year.length == 2
              ? '20$year'
              : year;

      return '$month/$fullYear';
    }

    // -------------------------------------------------------
    // SECOND METHOD: CHECK EACH LINE
    // -------------------------------------------------------
    //
    // Useful when OCR separates:
    //
    // EXP
    // FEB 2027
    //

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      final isExpiryLabel = RegExp(
        r'\b(exp|expiry|expiration|expires?)\b',
        caseSensitive: false,
      ).hasMatch(line);

      if (!isExpiryLabel) {
        continue;
      }

      // First check the same line.
      final sameLineMonth =
          RegExp(
        r'(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)'
        r'[a-z]*'
        r'[\s:./-]*'
        r'(20\d{2}|\d{2})',
        caseSensitive: false,
      ).firstMatch(line);

      if (sameLineMonth != null) {
        final month =
            sameLineMonth.group(1)!.toUpperCase();

        final year =
            sameLineMonth.group(2)!;

        final fullYear =
            year.length == 2
                ? '20$year'
                : year;

        return '$month $fullYear';
      }

      // Check the next line.
      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1];

        final nextMonth =
            RegExp(
          r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)'
          r'[a-z]*'
          r'[\s:./-]*'
          r'(20\d{2}|\d{2})\b',
          caseSensitive: false,
        ).firstMatch(nextLine);

        if (nextMonth != null) {
          final month =
              nextMonth.group(1)!.toUpperCase();

          final year =
              nextMonth.group(2)!;

          final fullYear =
              year.length == 2
                  ? '20$year'
                  : year;

          return '$month $fullYear';
        }
      }
    }

    // -------------------------------------------------------
    // NOTHING FOUND
    // -------------------------------------------------------

    return 'Unknown';
  }

  // =========================================================
  // VERIFY MEDICINE
  // =========================================================

  Future<void> verifyMedicine() async {
    if (medicineName == 'Unknown' ||
        medicineName.trim().isEmpty) {
      setState(() {
        verificationCompleted = true;
        verifiedMedicine = null;
      });

      return;
    }

    setState(() {
      isVerifying = true;
      verificationCompleted = false;
      verifiedMedicine = null;
    });

    try {
      final result =
          await MedicineInfoService.searchMedicine(
        medicineName,
      );

      if (!mounted) return;

      setState(() {
        verifiedMedicine = result;
        verificationCompleted = true;
        isVerifying = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        verifiedMedicine = null;
        verificationCompleted = true;
        isVerifying = false;
      });
    }
  }

  // =========================================================
  // OPEN CAMERA
  // =========================================================

  Future<void> openCamera() async {
    final XFile? image =
        await picker.pickImage(
      source: ImageSource.camera,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      medicineImage = image;
      isScanning = true;
      detectedText = '';

      medicineName = 'Unknown';
      strength = 'Unknown';
      expiry = 'Unknown';
      batchNumber = 'Unknown';

      verifiedMedicine = null;
      verificationCompleted = false;
    });

    try {
      final text =
          await ocrService.scanMedicine(image);

      extractMedicineDetails(text);

      if (!mounted) return;

      setState(() {
        detectedText = text;
        isScanning = false;
      });

      await verifyMedicine();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isScanning = false;
        detectedText =
            'Could not read the medicine package.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OCR error: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    ocrService.dispose();
    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Medicine',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // =================================================
            // IMAGE
            // =================================================

            if (medicineImage == null)
              const Icon(
                Icons.camera_alt,
                size: 100,
              )
            else
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(15),

                child: Image.file(
                  File(
                    medicineImage!.path,
                  ),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 25),

            const Text(
              'Scan Medicine Package',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Take a clear photo of the medicine '
              'package to detect its information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // CAMERA BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed:
                    isScanning ||
                            isVerifying
                        ? null
                        : openCamera,

                icon: const Icon(
                  Icons.camera_alt,
                ),

                label: const Text(
                  'OPEN CAMERA',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            // =================================================
            // SCANNING
            // =================================================

            if (isScanning) ...[
              const SizedBox(height: 25),

              const CircularProgressIndicator(),

              const SizedBox(height: 10),

              const Text(
                'Reading medicine package...',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],

            // =================================================
            // VERIFYING
            // =================================================

            if (isVerifying) ...[
              const SizedBox(height: 25),

              const CircularProgressIndicator(),

              const SizedBox(height: 10),

              const Text(
                'Checking medicine information...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],

            // =================================================
            // DETECTED INFORMATION
            // =================================================

            if (detectedText.isNotEmpty &&
                !isScanning) ...[
              const SizedBox(height: 25),

              const Align(
                alignment:
                    Alignment.centerLeft,

                child: Text(
                  'Detected Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Medicine Name',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        medicineName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Strength',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        strength,
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Expiry',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        expiry,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              expiry ==
                                      'Unknown'
                                  ? Colors.red
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Batch Number',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        batchNumber,
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // VERIFICATION
              // =================================================

              if (verificationCompleted)
                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(15),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Icon(
                          verifiedMedicine !=
                                  null
                              ? Icons.verified
                              : Icons.help_outline,

                          color:
                              verifiedMedicine !=
                                      null
                                  ? Colors.green
                                  : Colors.orange,

                          size: 30,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                verifiedMedicine !=
                                        null
                                    ? 'Medicine information found'
                                    : 'Medicine name could not be verified',

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,

                                  color:
                                      verifiedMedicine !=
                                              null
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                verifiedMedicine !=
                                        null
                                    ? 'A matching medicine was found. Please compare it with the package before saving.'
                                    : 'The medicine name may not have been read correctly. Please enter the name manually or check the package.',

                                style:
                                    const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              // =================================================
              // SAFETY MESSAGE
              // =================================================

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(15),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 28,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          expiry == 'Unknown'
                              ? 'Expiry date could not be verified. '
                                'Do not use the medicine until the '
                                'expiry date is verified. Check the '
                                'original package or ask a pharmacist.'
                              : 'Please check the detected '
                                'information before saving.',

                          style:
                              const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // EDIT & SAVE
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: () async {
                    final navigator =
                        Navigator.of(context);

                    final Medicine? medicine =
                        await navigator.push<Medicine>(
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMedicinePage(
                          scannedName:
                              medicineName,

                          scannedStrength:
                              strength,

                          scannedExpiry:
                              expiry,
                        ),
                      ),
                    );

                    if (medicine != null &&
                        mounted) {
                      navigator.pop(
                        medicine,
                      );
                    }
                  },

                  icon: const Icon(
                    Icons.edit,
                  ),

                  label: const Text(
                    'EDIT & SAVE',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

