import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/doctor_repository.dart';
import '../../patient/domain/appointment.dart';
import 'package:intl/intl.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final doctorRepo = ref.watch(doctorRepositoryProvider);
    final doctorId = 'dr_tanaya'; // Hardcoded for now as per requirements

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Dr Tanaya',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'atharva.smahabal@gmail.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Today\'s Appts',
                  future: doctorRepo.getTodaysAppointments(doctorId).then((value) => value.length.toString()),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Total Patients',
                  future: doctorRepo.getTotalPatients(doctorId).then((value) => value.toString()),
                  icon: Icons.people,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Pending',
                  future: doctorRepo.getPendingConsultations(doctorId).then((value) => value.toString()),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Monthly Earnings',
                  future: doctorRepo.getMonthlyEarnings(doctorId).then((value) => '₹${value.toStringAsFixed(0)}'),
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _QuickActionTile(
              title: 'Patient Management',
              subtitle: 'History, SOAP notes & Prescriptions',
              icon: Icons.assignment,
              onTap: () => context.push('/doctor/patients'),
            ),
            _QuickActionTile(
              title: 'Remedy Database',
              subtitle: 'Search & manage remedies',
              icon: Icons.medication,
              onTap: () => context.push('/doctor/remedies'),
            ),
            _QuickActionTile(
              title: 'Admin Panel',
              subtitle: 'Profile, hours & analytics',
              icon: Icons.admin_panel_settings,
              onTap: () => context.push('/doctor/admin'),
            ),
            
            const SizedBox(height: 32),
            Text(
              'Today\'s Appointments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Appointment>>(
              future: doctorRepo.getTodaysAppointments(doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final appointments = snapshot.data ?? [];
                if (appointments.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No appointments for today'),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(appt.patientId.substring(0, 1).toUpperCase()),
                        ),
                        title: Text('Patient ID: ${appt.patientId}'),
                        subtitle: Text(DateFormat('hh:mm a').format(appt.dateTime)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to patient detail/consultation
                        },
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final Future<String> future;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.future,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            FutureBuilder<String>(
              future: future,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? '...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
