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

  Future<List<PatientProfile>> getAllPatients() async {
    final snapshot = await _firestore.collection('patients').get();
    return snapshot.docs.map((doc) => PatientProfile.fromJson(doc.data())).toList();
  }

  Future<List<Appointment>> getTodaysAppointments(String doctorId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThan: endOfDay)
        .where('status', isEqualTo: 'confirmed')
        .get();

    return snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
  }

  Future<int> getTotalPatients(String doctorId) async {
    // This is a simplified version, ideally you'd have a mapping or unique patient IDs in appointments
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();
    
    final patientIds = snapshot.docs.map((doc) => doc.data()['patientId'] as String).toSet();
    return patientIds.length;
  }

  Future<double> getMonthlyEarnings(String doctorId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isGreaterThanOrEqualTo: startOfMonth)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }
  
  Future<int> getPendingConsultations(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'confirmed')
        .get();
    return snapshot.docs.length;
  }
}
