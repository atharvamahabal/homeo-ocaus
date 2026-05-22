import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/patient_profile.dart';
import '../../patient/domain/health_record.dart';
import '../../patient/domain/appointment.dart';
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
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
                if (snapshot.hasError) {
                  return Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Error loading history:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text(snapshot.error.toString(), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
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
                        title: Text(DateFormat('MMM d, y • HH:mm:ss').format(record.date)),
                        subtitle: Text(record.diagnosis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddConsultationDialog(context, ref, recordToEdit: record),
                              tooltip: 'Edit Consultation',
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => context.push('/consultation-detail', extra: record),
                            ),
                          ],
                        ),
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
            _infoRow('Email', patient.email ?? 'N/A'),
            _infoRow('Mobile', patient.phoneNumber ?? 'N/A'),
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

  void _showAddConsultationDialog(BuildContext context, WidgetRef ref, {HealthRecord? recordToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ConsultationForm(patient: patient, recordToEdit: recordToEdit),
      ),
    ).then((_) {
      // Refresh the screen after the dialog is closed to show the new consultation
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    });
  }
}

class ConsultationForm extends ConsumerStatefulWidget {
  final PatientProfile patient;
  final HealthRecord? recordToEdit;

  const ConsultationForm({
    super.key,
    required this.patient,
    this.recordToEdit,
  });

  @override
  ConsumerState<ConsultationForm> createState() => _ConsultationFormState();
}

class _ConsultationFormState extends ConsumerState<ConsultationForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _planController = TextEditingController();

  DateTime? _followUpDate;
  TimeOfDay? _followUpTime;

  final List<PrescribedRemedy> _remedies = [];
  final _remedyNameController = TextEditingController();
  final _potencyController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _subjectiveController.text = widget.recordToEdit!.symptoms.join(', ');
      _assessmentController.text = widget.recordToEdit!.diagnosis;
      
      // Extract Objective and Plan from notes
      final notes = widget.recordToEdit!.notes ?? '';
      final objectiveMatch = RegExp(r'Objective: (.*?)\nPlan:', dotAll: true).firstMatch(notes);
      final planMatch = RegExp(r'Plan: (.*)', dotAll: true).firstMatch(notes);
      
      if (objectiveMatch != null) {
        _objectiveController.text = objectiveMatch.group(1)?.trim() ?? '';
      }
      if (planMatch != null) {
        _planController.text = planMatch.group(1)?.trim() ?? '';
      }
      
      _remedies.addAll(widget.recordToEdit!.remedies);
      
      if (widget.recordToEdit!.followUpDate != null) {
        _followUpDate = widget.recordToEdit!.followUpDate;
        _followUpTime = TimeOfDay.fromDateTime(widget.recordToEdit!.followUpDate!);
      }
    }
  }

  void _addRemedy() {
    if (_remedyNameController.text.isNotEmpty) {
      setState(() {
        _remedies.add(PrescribedRemedy(
          name: _remedyNameController.text,
          potency: _potencyController.text,
          dosage: _dosageController.text,
          frequency: _frequencyController.text.isEmpty ? 'As directed' : _frequencyController.text,
          duration: _durationController.text.isEmpty ? 'Until finished' : _durationController.text,
          instructions: _instructionsController.text,
        ));
        _remedyNameController.clear();
        _potencyController.clear();
        _dosageController.clear();
        _frequencyController.clear();
        _durationController.clear();
        _instructionsController.clear();
      });
    }
  }

  Future<void> _saveConsultation() async {
    // Check if any field has been filled (Subjective, Objective, Assessment, Plan, or Remedies)
    final bool hasData = _subjectiveController.text.isNotEmpty ||
        _objectiveController.text.isNotEmpty ||
        _assessmentController.text.isNotEmpty ||
        _planController.text.isNotEmpty ||
        _remedies.isNotEmpty;

    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one field before saving')),
      );
      return;
    }

    try {
      DateTime? followUpDateTime;
      if (_followUpDate != null && _followUpTime != null) {
        followUpDateTime = DateTime(
          _followUpDate!.year,
          _followUpDate!.month,
          _followUpDate!.day,
          _followUpTime!.hour,
          _followUpTime!.minute,
        );
      }

      final record = HealthRecord(
        id: widget.recordToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        doctorName: widget.recordToEdit?.doctorName ?? 'Dr Tanaya',
        date: widget.recordToEdit?.date ?? DateTime.now(),
        diagnosis: _assessmentController.text.isEmpty ? 'Consultation' : _assessmentController.text,
        symptoms: _subjectiveController.text.isEmpty 
            ? [] 
            : _subjectiveController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        remedies: _remedies,
        notes: 'Objective: ${_objectiveController.text}\nPlan: ${_planController.text}',
        followUpDate: followUpDateTime,
      );

      await ref.read(patientRepositoryProvider).addHealthRecord(record);

      // If follow-up is set and changed, create a linked confirmed appointment (auto-approved for doctors)
      if (followUpDateTime != null && followUpDateTime != widget.recordToEdit?.followUpDate) {
        final appointment = Appointment(
          id: 'followup_${DateTime.now().millisecondsSinceEpoch}',
          patientId: widget.patient.id,
          doctorId: 'dr_tanaya', // Match doctorName
          doctorName: 'Dr Tanaya',
          dateTime: followUpDateTime,
          status: 'confirmed', // Doctors create confirmed appointments directly
          type: 'clinic',
          reason: 'Follow-up for ${record.diagnosis}',
        );
        await ref.read(patientRepositoryProvider).bookAppointment(appointment);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recordToEdit != null ? 'Consultation updated' : 'Consultation saved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Permission Denied') || errorMessage.contains('permission-denied')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Firestore Error', style: TextStyle(color: Colors.green)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('The operation was denied by Firestore.', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  const Text('Potential Reasons:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const Text('• Your Firestore Security Rules are blocking the write.', style: TextStyle(color: Colors.white)),
                  const Text('• The collection "health_records" does not exist or is misconfigured.', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  const Text('Raw Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  Text(errorMessage, style: const TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving consultation: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.recordToEdit != null ? 'Edit Consultation' : 'SOAP Consultation Note',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSOAPField('Subjective', 'Symptoms (comma separated)...', _subjectiveController),
              _buildSOAPField('Objective', 'Vital signs and observations...', _objectiveController),
              _buildSOAPField('Assessment', 'Diagnosis and analysis...', _assessmentController),
              _buildSOAPField('Plan', 'Next steps and follow-up...', _planController),
              const SizedBox(height: 16),
              // Follow-up Selection
            _buildSectionTitleInForm(context, 'Next Follow-up', Icons.event_repeat),
            Card(
              color: Colors.grey[900],
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey[700]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.green),
                title: Text(
                  _followUpDate == null 
                    ? 'Set Follow-up Date & Time' 
                    : '${DateFormat('EEE, MMM d, y').format(_followUpDate!)} at ${_followUpTime?.format(context) ?? ""}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: _followUpDate != null 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20, color: Colors.white),
                      onPressed: () => setState(() {
                        _followUpDate = null;
                        _followUpTime = null;
                      }),
                    )
                  : const Icon(Icons.add, size: 20, color: Colors.white),
                onTap: () async {
                  // Get already booked slots for the chosen date to show warning
                  final bookedSlots = await ref.read(patientRepositoryProvider).getBookedSlots('dr_tanaya', _followUpDate ?? DateTime.now());
                  
                  if (!mounted) return;

                  final date = await showDatePicker(
                    context: context,
                    initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            surface: Colors.black,
                            onSurface: Colors.white,
                          ),
                          dialogBackgroundColor: Colors.grey[900],
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _followUpTime ?? const TimeOfDay(hour: 10, minute: 0),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              surface: Colors.black,
                              onSurface: Colors.white,
                            ),
                            dialogBackgroundColor: Colors.grey[900],
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      final timeStr = DateFormat('hh:mm a').format(DateTime(2000, 1, 1, time.hour, time.minute));
                      if (bookedSlots.contains(timeStr)) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Warning: $timeStr is already booked by another patient!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      setState(() {
                        _followUpDate = date;
                        _followUpTime = time;
                      });
                    }
                  }
                },
              ),
            ),

            const Divider(height: 48, color: Colors.grey),
              const Text(
                'Digital Prescription',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ..._remedies.map((r) => Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text('${r.name} ${r.potency}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${r.dosage} | ${r.frequency} | ${r.duration}\n${r.instructions ?? ''}', style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _remedies.remove(r)),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[900],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                          Expanded(child: _buildInlineField('Frequency', _frequencyController)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildInlineField('Duration', _durationController)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInlineField('Instructions', _instructionsController)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _addRemedy,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Remedy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          foregroundColor: Colors.green,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveConsultation,
                child: Text(widget.recordToEdit != null ? 'Save Changes' : 'Save & Issue Prescription', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleInForm(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
