import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/patient_repository.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';

class DoctorAppointmentsScreen extends ConsumerWidget {
  final Doctor doctor;

  const DoctorAppointmentsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings for ${doctor.name}'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: ref.read(patientRepositoryProvider).getDoctorAppointments(doctor.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments booked yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                child: ListTile(
                  title: Text('Patient ID: ${appointment.patientId}'),
                  subtitle: Text(
                    '${DateFormat('EEEE, MMM d').format(appointment.dateTime)} at ${DateFormat('hh:mm a').format(appointment.dateTime)}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
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
