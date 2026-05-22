import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/doctor_repository.dart';
import '../../auth/domain/patient_profile.dart';
import '../../patient/domain/health_record.dart';
import '../../patient/data/patient_repository.dart';

class PatientManagementScreen extends ConsumerWidget {
  const PatientManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorRepo = ref.watch(doctorRepositoryProvider);
    final doctorId = 'dr_tanaya'; // Match dashboard hardcoding

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Management'),
      ),
      body: FutureBuilder<List<PatientProfile>>(
        future: doctorRepo.getAllPatients(doctorId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading patients:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }
          final patients = snapshot.data ?? [];
          if (patients.isEmpty) {
            return const Center(child: Text('No patients found'));
          }
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    patient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: ${patient.age} | Gender: ${patient.gender}'),
                      const SizedBox(height: 4),
                      FutureBuilder<List<HealthRecord>>(
                        future: ref.read(patientRepositoryProvider).getHealthRecords(patient.id),
                        builder: (context, recordSnapshot) {
                          if (recordSnapshot.hasData && recordSnapshot.data!.isNotEmpty) {
                            final latest = recordSnapshot.data!.first;
                            return Text(
                              'Latest: ${latest.diagnosis}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return const Text('No history yet', style: TextStyle(fontSize: 12));
                        },
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/doctor/patient-details', extra: patient);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
