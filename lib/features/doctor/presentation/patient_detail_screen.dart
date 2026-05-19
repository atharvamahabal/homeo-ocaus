import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/patient_profile.dart';
import '../../patient/domain/health_record.dart';
import '../../patient/data/patient_repository.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends ConsumerWidget {
  final PatientProfile patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfo(context),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consultation History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show dialog to add SOAP note / prescription
                    _showAddConsultationDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Consultation'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<HealthRecord>>(
              future: ref.read(patientRepositoryProvider).getHealthRecords(patient.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final records = snapshot.data ?? [];
                if (records.isEmpty) {
                  return const Text('No history available');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(DateFormat('MMM d, y').format(record.date)),
                        subtitle: Text(record.diagnosis),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(record.symptoms.join(', ')),
                                const SizedBox(height: 8),
                                const Text('Prescription:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...record.remedies.map((r) => Text('• ${r.name} ${r.potency} - ${r.dosage} (${r.frequency})')),
                                if (record.notes != null) ...[
                                  const SizedBox(height: 8),
                                  const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(record.notes!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: Theme.of(context).textTheme.titleLarge),
                    Text('${patient.gender}, ${patient.age} years old'),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            _infoRow('Weight', '${patient.weight} kg'),
            _infoRow('Blood Group', patient.bloodGroup),
            _infoRow('Allergies', patient.knownAllergies.isEmpty ? 'None' : patient.knownAllergies.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showAddConsultationDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ConsultationForm(
          patient: patient,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class ConsultationForm extends StatefulWidget {
  final PatientProfile patient;
  final ScrollController scrollController;

  const ConsultationForm({
    super.key,
    required this.patient,
    required this.scrollController,
  });

  @override
  State<ConsultationForm> createState() => _ConsultationFormState();
}

class _ConsultationFormState extends State<ConsultationForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _planController = TextEditingController();

  final List<Map<String, String>> _remedies = [];
  final _remedyNameController = TextEditingController();
  final _potencyController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  void _addRemedy() {
    if (_remedyNameController.text.isNotEmpty) {
      setState(() {
        _remedies.add({
          'name': _remedyNameController.text,
          'potency': _potencyController.text,
          'dosage': _dosageController.text,
          'instructions': _instructionsController.text,
        });
        _remedyNameController.clear();
        _potencyController.clear();
        _dosageController.clear();
        _instructionsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Text(
              'SOAP Consultation Note',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSOAPField('Subjective', 'Symptoms and patient history...', _subjectiveController),
            _buildSOAPField('Objective', 'Vital signs and observations...', _objectiveController),
            _buildSOAPField('Assessment', 'Diagnosis and analysis...', _assessmentController),
            _buildSOAPField('Plan', 'Next steps and follow-up...', _planController),
            const Divider(height: 48),
            Text(
              'Digital Prescription',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._remedies.map((r) => Card(
                  child: ListTile(
                    title: Text('${r['name']} ${r['potency']}'),
                    subtitle: Text('${r['dosage']} - ${r['instructions']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _remedies.remove(r)),
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildInlineField('Remedy', _remedyNameController)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInlineField('Potency', _potencyController)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildInlineField('Dosage', _dosageController)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInlineField('Instructions', _instructionsController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addRemedy,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Remedy'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Save consultation logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Consultation saved successfully')),
                );
              },
              child: const Text('Save & Issue Prescription', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSOAPField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildInlineField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
