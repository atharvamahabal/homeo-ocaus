import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../patient/domain/appointment.dart';
import '../../patient/domain/health_record.dart';
import '../../auth/domain/patient_profile.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(FirebaseFirestore.instance);
});

class DoctorRepository {
  final FirebaseFirestore _firestore;
  DoctorRepository(this._firestore);

  Future<List<PatientProfile>> getAllPatients(String doctorId) async {
    final snapshot = await _firestore.collection('patients').get();
    final List<PatientProfile> patients = [];
    for (var doc in snapshot.docs) {
      try {
        patients.add(PatientProfile.fromJson(doc.data()));
      } catch (e) {
        print('Error parsing patient ${doc.id}: $e');
        // Continue to next patient if one fails
      }
    }
    return patients;
  }

  Future<List<Appointment>> getTodaysAppointments(String doctorId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day).add(const Duration(days: 1)).toIso8601String();

    return _getAppointmentsInRange(doctorId, startOfDay, endOfDay);
  }

  Future<List<Appointment>> getWeeklyAppointments(String doctorId) async {
    final now = DateTime.now();
    final startOfRange = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfRange = DateTime(now.year, now.month, now.day).add(const Duration(days: 7)).toIso8601String();

    return _getAppointmentsInRange(doctorId, startOfRange, endOfRange);
  }

  Future<List<Appointment>> getMonthlyAppointments(String doctorId) async {
    final now = DateTime.now();
    final startOfRange = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfRange = DateTime(now.year, now.month, now.day).add(const Duration(days: 30)).toIso8601String();

    return _getAppointmentsInRange(doctorId, startOfRange, endOfRange);
  }

  Future<List<Appointment>> _getAppointmentsInRange(String doctorId, String start, String end) async {
    // Fetch all appointments for the doctor to avoid index requirements
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    final allAppointments = snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
    
    // Filter by date range in memory
    final filtered = allAppointments.where((appt) {
      final apptDate = appt.dateTime.toIso8601String();
      return apptDate.compareTo(start) >= 0 && apptDate.compareTo(end) < 0;
    }).toList();

    // Sort by date time ascending
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  Future<int> getTotalPatients(String doctorId) async {
    final snapshot = await _firestore.collection('patients').get();
    return snapshot.docs.length;
  }

  Future<double> getMonthlyEarnings(String doctorId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    
    // Fetch all for doctor to avoid index
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = data['dateTime'] as String;
      final status = data['status'] as String;
      
      if (status == 'completed' && date.compareTo(startOfMonth) >= 0) {
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return total;
  }
  
  Future<String> getPendingConsultations(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.length.toString();
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});
  }

  Future<PatientProfile?> getPatientProfile(String patientId) async {
    final doc = await _firestore.collection('patients').doc(patientId).get();
    if (doc.exists) {
      return PatientProfile.fromJson(doc.data()!);
    }
    return null;
  }
}