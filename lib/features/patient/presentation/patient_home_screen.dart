import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/data/auth_repository.dart';
import '../data/patient_repository.dart';
import '../domain/health_record.dart';
import '../domain/appointment.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homeo ओकस'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(patientRepositoryProvider).getProfile(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final profile = snapshot.data;
          final isProfileIncomplete = profile == null;

          return SingleChildScrollView(
            child: Column(
              children: [
                if (isProfileIncomplete)
                  Container(
                    width: double.infinity,
                    color: Colors.orange[100],
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Your profile is incomplete. Some features may not work.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('Complete Now'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.home_work_rounded,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome, ${profile?.name ?? user?.displayName ?? user?.email ?? "Patient"}!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Homeopathic Care is our priority.',
                  style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FeatureCard(
                        title: 'Book Appointment',
                        subtitle: 'Consult with Dr Tanaya and others',
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        onTap: () {
                          if (isProfileIncomplete) {
                            _showIncompleteProfileDialog(context);
                          } else {
                            context.push('/doctors');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _FeatureCard(
                        title: 'Personal Details',
                        subtitle: 'Manage your profile & health info',
                        icon: Icons.person_outline,
                        color: Colors.teal,
                        onTap: () => context.push('/onboarding'),
                      ),
                      const SizedBox(height: 16),
                      _FeatureCard(
                        title: 'Health Records',
                        subtitle: 'View prescriptions & reports',
                        icon: Icons.history,
                        color: Colors.green,
                        onTap: () => context.push('/records'),
                      ),
                      FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          ref.read(patientRepositoryProvider).getHealthRecords(user?.uid ?? ''),
                          ref.read(patientRepositoryProvider).getPatientAppointments(user?.uid ?? ''),
                        ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          
                          final now = DateTime.now();
                          final records = snapshot.data![0] as List<HealthRecord>;
                          final appointments = snapshot.data![1] as List<Appointment>;
                          
                          final dates = [
                            ...records.where((r) => r.followUpDate != null).map((r) => r.followUpDate!),
                            ...appointments.where((a) => a.status != 'cancelled').map((a) => a.dateTime),
                          ];
                          
                          // Filter: Future only, and (This Month OR Weekly)
                          final filteredDates = dates.where((d) {
                            final isFuture = d.isAfter(now);
                            final isThisMonth = d.month == now.month && d.year == now.year;
                            final isWeekly = d.isBefore(now.add(const Duration(days: 7)));
                            return isFuture && (isThisMonth || isWeekly);
                          }).toList();
                          
                          if (filteredDates.isEmpty) return const SizedBox.shrink();
                          
                          filteredDates.sort();
                          final nextDate = filteredDates.first;

                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              _FeatureCard(
                                title: 'Next Appointment',
                                subtitle: 'View your upcoming visit',
                                trailingWidget: Text(
                                  'On ${DateFormat('EEE, MMM d').format(nextDate)}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                icon: Icons.event,
                                color: Colors.orange,
                                onTap: () => context.push('/records'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showIncompleteProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Incomplete'),
        content: const Text('You need to complete your profile before you can book an appointment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/onboarding');
            },
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: trailingWidget!,
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
