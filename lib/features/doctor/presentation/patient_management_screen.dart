import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/doctor_repository.dart';
import '../../auth/domain/patient_profile.dart';

class PatientManagementScreen extends ConsumerWidget {
  const PatientManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorRepo = ref.watch(doctorRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Management'),
      ),
      body: FutureBuilder<List<PatientProfile>>(
        future: doctorRepo.getAllPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final patients = snapshot.data ?? [];
          if (patients.isEmpty) {
            return const Center(child: Text('No patients found'));
          }
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(patient.name),
                subtitle: Text('Age: ${patient.age} | Gender: ${patient.gender}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/doctor/patient-details', extra: patient);
                },
              );
            },
          );
        },
      ),
    );
  }
}
