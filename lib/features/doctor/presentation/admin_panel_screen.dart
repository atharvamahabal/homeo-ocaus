import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/doctor_repository.dart';
import '../../patient/domain/appointment.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Appointment>> _appointmentsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    // Normalize day to midnight for comparison
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _appointmentsByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final doctorRepo = ref.watch(doctorRepositoryProvider);
    final doctorId = 'dr_tanaya';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: doctorRepo.getMonthlyAppointments(doctorId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Group appointments by day
            _appointmentsByDay = {};
            for (var appt in snapshot.data!) {
              final day = DateTime(appt.dateTime.year, appt.dateTime.month, appt.dateTime.day);
              if (_appointmentsByDay[day] == null) {
                _appointmentsByDay[day] = [];
              }
              _appointmentsByDay[day]!.add(appt);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, 'Analytics'),
                const SizedBox(height: 16),
                _buildAnalyticsSummary(snapshot.data ?? []),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Appointment Calendar'),
                const SizedBox(height: 16),
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2026, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: Colors.green.withOpacity(0.3), shape: BoxShape.circle),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return const SizedBox.shrink();
                        
                        final count = events.length;
                        
                        return Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedDay != null) ...[
                  Text(
                    'Appointments for ${DateFormat('MMM d, y').format(_selectedDay!)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ..._getEventsForDay(_selectedDay!).map((appt) => _buildAppointmentDetailCard(context, appt, doctorRepo)),
                  if (_getEventsForDay(_selectedDay!).isEmpty)
                    const Text('No appointments for this day', style: TextStyle(color: Colors.white70)),
                ],
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Clinic Management'),
                const SizedBox(height: 16),
                _AdminActionTile(
                  title: 'Working Hours',
                  subtitle: 'Set clinic timings and availability',
                  icon: Icons.access_time,
                  onTap: () {},
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Revenue Report'),
                const SizedBox(height: 16),
                _buildRevenueChart(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsSummary(List<Appointment> appointments) {
    final double totalRevenue = appointments
        .where((a) => a.status == 'completed')
        .fold(0, (sum, item) => sum + (item.amount ?? 0));
    
    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            title: 'Revenue',
            value: '₹${totalRevenue.toStringAsFixed(0)}',
            icon: Icons.payments,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AnalyticsCard(
            title: 'Bookings',
            value: appointments.length.toString(),
            icon: Icons.event,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailCard(BuildContext context, Appointment appt, DoctorRepository repo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: FutureBuilder(
          future: repo.getPatientProfile(appt.patientId),
          builder: (context, snapshot) {
            return Text(
              snapshot.data?.name ?? 'Patient: ${appt.patientId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('hh:mm a').format(appt.dateTime)} • ${appt.status.toUpperCase()}',
              style: TextStyle(
                color: appt.status == 'confirmed' ? Colors.green[700] : Colors.orange[700],
                fontSize: 12,
              ),
            ),
            if (appt.healthConcern != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Concern: ${appt.healthConcern}',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        children: [
          FutureBuilder(
            future: repo.getPatientProfile(appt.patientId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final patient = snapshot.data!;
              
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildReminderButton(
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: Colors.green,
                          onTap: () => _sendWhatsAppReminder(patient, appt),
                        ),
                        _buildReminderButton(
                          icon: Icons.email,
                          label: 'Email',
                          color: Colors.blue,
                          onTap: () => _sendEmailReminder(patient, appt),
                        ),
                      ],
                    ),
                    if (patient.phoneNumber == null && patient.email == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'No contact info available for this patient',
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _sendWhatsAppReminder(dynamic patient, Appointment appt) async {
    final phone = patient.phoneNumber;
    if (phone == null || phone.isEmpty) return;

    final dateStr = DateFormat('EEE, MMM d').format(appt.dateTime);
    final timeStr = DateFormat('hh:mm a').format(appt.dateTime);
    final message = Uri.encodeComponent(
      'Reminder: You have an appointment with Homeo ओकस on $dateStr at $timeStr. Please be on time.'
    );
    
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmailReminder(dynamic patient, Appointment appt) async {
    final email = patient.email;
    if (email == null || email.isEmpty) return;

    final dateStr = DateFormat('EEE, MMM d').format(appt.dateTime);
    final timeStr = DateFormat('hh:mm a').format(appt.dateTime);
    
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters({
        'subject': 'Appointment Reminder - Homeo ओकस',
        'body': 'Dear ${patient.name},\n\nThis is a reminder for your appointment on $dateStr at $timeStr.\n\nRegards,\nHomeo ओकस Clinic'
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.green,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.day, this.revenue);
  final String day;
  final double revenue;
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminActionTile({
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
        onTap: onTap,
      ),
    );
  }
}
