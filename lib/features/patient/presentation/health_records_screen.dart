import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/patient_repository.dart';
import '../domain/health_record.dart';
import '../../auth/data/auth_repository.dart';

class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
      ),
      body: FutureBuilder<List<HealthRecord>>(
        future: ref.read(patientRepositoryProvider).getHealthRecords(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load health records',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => (context as Element).markNeedsBuild(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No health records found yet.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isLast = index == records.length - 1;

              return IntrinsicHeight(
                child: Row(
                  children: [
                    // Timeline Line and Dot
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Record Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('MMM d, y • HH:mm:ss').format(record.date),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.open_in_new, size: 20),
                                      onPressed: () => context.push('/consultation-detail', extra: record),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  record.diagnosis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('By ${record.doctorName}'),
                                const SizedBox(height: 12),
                                const Text(
                                  'Symptoms:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(record.symptoms.join(', ')),
                                const SizedBox(height: 12),
                                const Text(
                                  'Remedies:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (record.remedies.isEmpty)
                                  const Text('No remedies prescribed', style: TextStyle(color: Colors.grey, fontSize: 13))
                                else
                                  ...record.remedies.map((remedy) => Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('• ${remedy.name} ${remedy.potency} (${remedy.dosage})'),
                                  )),
                                if (record.prescriptionPdfUrl != null) ...[
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // TODO: Implement PDF download
                                    },
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download Prescription'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
