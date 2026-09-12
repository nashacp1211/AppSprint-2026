import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../models/medicine.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final OCRService _ocrService = OCRService();
  final DatabaseService _dbService = DatabaseService();
  final TTSService _ttsService = TTSService();

  String _scannedText = "";
  bool _isLoading = false;

  Future<void> _scanLabel() async {
    setState(() => _isLoading = true);
    final text = await _ocrService.scanMedicineLabel();
    setState(() {
      _scannedText = text ?? "No text detected";
      _isLoading = false;
    });
  }

  Future<void> _saveMedicine() async {
    if (_scannedText.isEmpty || _scannedText == "No text detected") return;

    final firstLine = _scannedText.split('\n').first.trim();
    final med = Medicine(
      name: firstLine.isNotEmpty ? firstLine : "Scanned Medicine",
      dosage: "1 tablet",
      time: "Morning",
    );

    await _dbService.insertMedicine(med);
    await _ttsService.speak("Saved ${med.name} to database");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Label')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _scanLabel,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo / Select Image'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _scannedText.isEmpty ? "Tap button to scan..." : _scannedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scannedText.isNotEmpty && !_isLoading ? _saveMedicine : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Save to Database', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}