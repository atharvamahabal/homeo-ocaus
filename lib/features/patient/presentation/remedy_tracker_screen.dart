import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/patient_repository.dart';
import '../domain/health_record.dart';
import '../../auth/data/auth_repository.dart';

class RemedyTrackerScreen extends ConsumerWidget {
  const RemedyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remedy Tracker'),
      ),
      body: FutureBuilder<List<HealthRecord>>(
        future: ref.read(patientRepositoryProvider).getHealthRecords(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final records = snapshot.data ?? [];
          final activeRemedies = records.expand((r) => r.remedies).toList();

          if (activeRemedies.isEmpty) {
            return const Center(child: Text('No active remedies tracked.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeRemedies.length,
            itemBuilder: (context, index) {
              final remedy = activeRemedies[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.orange),
                  title: Text('${remedy.name} ${remedy.potency}'),
                  subtitle: Text('${remedy.dosage} - ${remedy.frequency}\nDuration: ${remedy.duration}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.notifications_active, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminders set for this remedy!')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
