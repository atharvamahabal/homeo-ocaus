import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/patient_repository.dart';
import '../domain/doctor.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Doctor'),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: ref.read(patientRepositoryProvider).getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) {
            return const Center(child: Text('No doctors available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              final user = ref.watch(authRepositoryProvider).currentUser;
              final isDoctor = user?.email == 'atharva.smahabal@gmail.com';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      doctor.name[0],
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    doctor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('${doctor.rating}'),
                            ],
                          ),
                          Text(
                            '${doctor.experienceYears} years exp',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      if (isDoctor) {
                        context.push('/doctor-appointments', extra: doctor);
                      } else {
                        context.push('/booking', extra: doctor);
                      }
                    },
                    child: Text(isDoctor ? 'View Bookings' : 'Book Now'),
                  ),
                  onTap: () {
                    if (isDoctor) {
                      context.push('/doctor-appointments', extra: doctor);
                    } else {
                      context.push('/booking', extra: doctor);
                    }
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
