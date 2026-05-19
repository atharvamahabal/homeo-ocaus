import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/patient_repository.dart';

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
                const Text('Your Homeopathic Care is our priority.'),
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
                      const SizedBox(height: 16),
                      _FeatureCard(
                        title: 'Remedy Tracker',
                        subtitle: 'Manage your dosages',
                        icon: Icons.medication,
                        color: Colors.orange,
                        onTap: () => context.push('/remedies'),
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

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
