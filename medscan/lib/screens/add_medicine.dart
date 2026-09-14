import 'package:flutter/material.dart';
import '../models/medicine.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final strengthController = TextEditingController();
  final batchController = TextEditingController();
  final instructionsController = TextEditingController();
  final usesController = TextEditingController();
  final sideEffectsController = TextEditingController();
  final warningsController = TextEditingController();

  DateTime? expiryDate;

  String familyMember = 'Me';

  bool expiryVerified = false;

  @override
  void dispose() {
    nameController.dispose();
    strengthController.dispose();
    batchController.dispose();
    instructionsController.dispose();
    usesController.dispose();
    sideEffectsController.dispose();
    warningsController.dispose();

    super.dispose();
  }

  // Select expiry date
  Future<void> selectExpiryDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'Select expiry date',
    );

    if (selectedDate != null) {
      setState(() {
        expiryDate = selectedDate;
        expiryVerified = true;
      });
    }
  }

  // Save medicine
  void saveMedicine() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final medicine = Medicine(
      name: nameController.text.trim(),
      strength: strengthController.text.trim(),
      expiryDate: expiryDate,
      expiryVerified: expiryVerified,
      batchNumber: batchController.text.trim(),
      instructions: instructionsController.text.trim(),
      familyMember: familyMember,
      commonUses: usesController.text.trim(),
      sideEffects: sideEffectsController.text.trim(),
      warnings: warningsController.text.trim(),
    );

    Navigator.pop(context, medicine);
  }

  // Common text field
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Medicine Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Medicine name
              buildTextField(
                controller: nameController,
                label: 'Medicine Name',
                hint: 'Example: Paracetamol',
                required: true,
              ),

              // Strength
              buildTextField(
                controller: strengthController,
                label: 'Strength',
                hint: 'Example: 500 mg',
              ),

              // Batch number
              buildTextField(
                controller: batchController,
                label: 'Batch Number',
                hint: 'Enter batch number',
              ),

              // Family member
              DropdownButtonFormField<String>(
                initialValue: familyMember,
                decoration: const InputDecoration(
                  labelText: 'For Family Member',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Me',
                    child: Text('Me'),
                  ),
                  DropdownMenuItem(
                    value: 'Father',
                    child: Text('Father'),
                  ),
                  DropdownMenuItem(
                    value: 'Mother',
                    child: Text('Mother'),
                  ),
                  DropdownMenuItem(
                    value: 'Child',
                    child: Text('Child'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      familyMember = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Expiry date
              InkWell(
                onTap: selectExpiryDate,

                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),

                  child: Text(
                    expiryDate == null
                        ? 'Select expiry date'
                        : '${expiryDate!.day}/'
                            '${expiryDate!.month}/'
                            '${expiryDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Expiry verification status
              Row(
                children: [
                  Icon(
                    expiryVerified
                        ? Icons.verified
                        : Icons.warning_amber,
                    color: expiryVerified
                        ? Colors.green
                        : Colors.orange,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      expiryVerified
                          ? 'Expiry date verified'
                          : 'Expiry date not verified',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Medicine Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Instructions
              buildTextField(
                controller: instructionsController,
                label: 'Instructions',
                hint: 'Example: Take after food',
                maxLines: 3,
              ),

              // Common uses
              buildTextField(
                controller: usesController,
                label: 'Common Uses',
                hint: 'Example: Used for fever and pain',
                maxLines: 3,
              ),

              // Side effects
              buildTextField(
                controller: sideEffectsController,
                label: 'Side Effects',
                hint: 'Enter known side effects',
                maxLines: 3,
              ),

              // Warnings
              buildTextField(
                controller: warningsController,
                label: 'Warnings',
                hint: 'Enter important warnings',
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              // Safety warning
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Always verify medicine information '
                        'from the original packaging or a pharmacist. '
                        'Do not use a medicine when its expiry cannot '
                        'be safely verified.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: saveMedicine,

                  icon: const Icon(Icons.save),

                  label: const Text(
                    'Save Medicine',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
