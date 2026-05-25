import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/doctor_repository.dart';
import '../../patient/domain/appointment.dart';
import 'package:intl/intl.dart';
import 'package:homeo_ocaus/core/services/notification_service.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  String _timeRange = 'Today'; // 'Today', 'Weekly', 'Monthly'
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Save FCM token for doctor notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveDoctorToken();
    });
  }

  Future<void> _showPendingAppointments(BuildContext context, String doctorId) async {
    final doctorRepo = ref.read(doctorRepositoryProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Appointments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Appointment>>(
                  future: doctorRepo.getPendingAppointmentsList(doctorId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final appointments = snapshot.data ?? [];
                    if (appointments.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                            SizedBox(height: 16),
                            Text('No pending appointments!'),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appt = appointments[index];
                        return FutureBuilder<PatientProfile?>(
                          future: doctorRepo.getPatientProfile(appt.patientId),
                          builder: (context, patientSnapshot) {
                            final patient = patientSnapshot.data;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            patient?.name ?? 'Loading...',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'PENDING',
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('EEE, MMM d, yyyy').format(appt.dateTime),
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('hh:mm a').format(appt.dateTime),
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Concern: ${appt.healthConcern ?? "Not specified"}',
                                      style: const TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              await doctorRepo.updateAppointmentStatus(appt.id, 'rejected');
                                              setModalState(() {}); // Refresh modal content
                                              setState(() {}); // Refresh dashboard
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(color: Colors.red),
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await doctorRepo.updateAppointmentStatus(appt.id, 'confirmed');
                                              setModalState(() {}); // Refresh modal content
                                              setState(() {}); // Refresh dashboard
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Approve'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDoctorToken() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      debugPrint('Initializing notifications for doctor: ${user.email}');
      // Use the hardcoded doctor ID or the user's UID
      // For consistency with PatientRepository.getDoctors, we use 'dr_tanaya'
      // but also the user's UID to be more specific.
      await NotificationService().saveTokenToFirestore('dr_tanaya');
      await NotificationService().saveTokenToFirestore(user.uid);

      // Start listening for new appointment notifications while in foreground
      NotificationService().startForegroundNotificationListener('dr_tanaya');
      NotificationService().startForegroundNotificationListener(user.uid);
    } else {
      debugPrint('No user logged in, skipping notification initialization');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final doctorRepo = ref.watch(doctorRepositoryProvider);
    final doctorId = 'dr_tanaya'; // Hardcoded ID for now

    Future<List<Appointment>> getAppointments() {
      switch (_timeRange) {
        case 'Weekly':
          return doctorRepo.getWeeklyAppointments(doctorId);
        case 'Monthly':
          return doctorRepo.getMonthlyAppointments(doctorId);
        default:
          return doctorRepo.getTodaysAppointments(doctorId);
      }
    }

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
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome ${user?.displayName ?? 'Dr Tanaya'}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'homeo.ocus@gmail.com',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _timeRange,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _timeRange = newValue;
                      });
                    }
                  },
                  items: <String>['Today', 'Weekly', 'Monthly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
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
                  title: '$_timeRange Appts',
                  future: getAppointments().then((value) => value.length.toString()),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                _StatCard(
                  title: 'Total Patients',
                  future: doctorRepo.getTotalPatients(doctorId).then((value) => value.toString()),
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () => context.push('/doctor/patients'),
                ),
                _StatCard(
                  title: 'Pending',
                  future: doctorRepo.getPendingConsultations(doctorId),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  onTap: () => _showPendingAppointments(context, doctorId),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _QuickActionTile(
              title: 'Patient Management',
              subtitle: 'History, SOAP notes & Prescriptions',
              icon: Icons.assignment,
              onTap: () => context.push('/doctor/patients'),
            ),
            _QuickActionTile(
              title: 'Remedy AI Chatbot',
              subtitle: 'Search symptoms using AI Materia Medica',
              icon: Icons.chat_bubble_outline,
              onTap: () => context.push('/ai-chat'),
            ),
            _QuickActionTile(
              title: 'Admin Panel',
              subtitle: 'Profile, hours & analytics',
              icon: Icons.admin_panel_settings,
              onTap: () => context.push('/doctor/admin'),
            ),
            
            const SizedBox(height: 32),
            Text(
              '$_timeRange\'s Appointments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Appointment>>(
              future: getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading appointments: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                final appointments = snapshot.data ?? [];
                if (appointments.isEmpty) {
                  return InkWell(
                    onTap: () {
                      // Refresh or provide feedback
                      setState(() {});
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('No appointments for $_timeRange. Click to refresh.'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    final isPending = appt.status.toLowerCase() == 'pending';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(appt.patientId.substring(0, 1).toUpperCase()),
                              ),
                              title: FutureBuilder(
                                future: doctorRepo.getPatientProfile(appt.patientId),
                                builder: (context, profileSnapshot) {
                                  if (profileSnapshot.hasData) {
                                    return Text(profileSnapshot.data!.name, style: const TextStyle(fontWeight: FontWeight.bold));
                                  }
                                  return Text('Patient ID: ${appt.patientId}');
                                },
                              ),
                              subtitle: Text(
                                '${DateFormat('MMM d').format(appt.dateTime)} at ${DateFormat('hh:mm a').format(appt.dateTime)}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(appt.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  appt.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(appt.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (appt.reason != null || appt.healthConcern != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (appt.healthConcern != null)
                                        Text('Health Concern: ${appt.healthConcern}', 
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                                      if (appt.reason != null)
                                        Text('Reason: ${appt.reason}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),
                            if (isPending)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        await doctorRepo.updateAppointmentStatus(appt.id, 'cancelled');
                                        setState(() {});
                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Reject'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await doctorRepo.updateAppointmentStatus(appt.id, 'confirmed');
                                        setState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                  ],
                                ),
                              )
                            else if (appt.status.toLowerCase() == 'confirmed')
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Get patient profile first
                                      final patient = await doctorRepo.getPatientProfile(appt.patientId);
                                      if (patient != null && context.mounted) {
                                        context.push('/doctor/patient-details', extra: patient);
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Error: Could not load patient profile')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Start Consultation'),
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Future<String> future;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.future,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
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
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
