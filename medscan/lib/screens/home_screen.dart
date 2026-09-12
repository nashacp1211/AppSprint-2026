import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TTSService _ttsService = TTSService();
  List<Medicine> _medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    final data = await _dbService.getMedicines();
    setState(() {
      _medicines = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartMed Tracker'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
              ? const Center(
                  child: Text(
                    'No medicines saved yet.\nTap + to scan a medicine label!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final med = _medicines[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.medication, color: Colors.blue),
                        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${med.dosage} - ${med.time}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.deepPurple),
                          onPressed: () {
                            _ttsService.speak('${med.name}, take ${med.dosage} in the ${med.time}');
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanScreen()),
          );
          _loadMedicines(); // Refresh list after returning from scan screen
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan New'),
      ),
    );
  }
}