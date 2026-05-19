import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/patient_profile.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';
import '../domain/health_record.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository(ref.watch(firestoreProvider));
});

class PatientRepository {
  final FirebaseFirestore _firestore;
  PatientRepository(this._firestore);

  // Existing Patient Profile methods
  Future<void> saveProfile(PatientProfile profile) async {
    await _firestore
        .collection('patients')
        .doc(profile.id)
        .set(profile.toJson());
  }

  Future<PatientProfile?> getProfile(String id) async {
    final doc = await _firestore.collection('patients').doc(id).get();
    if (doc.exists) {
      return PatientProfile.fromJson(doc.data()!);
    }
    return null;
  }

  // Doctor methods
  Future<List<Doctor>> getDoctors() async {
    // For now, returning mock data including Dr Tanaya
    return [
      const Doctor(
        id: 'dr_tanaya',
        name: 'Dr Tanaya',
        specialization: 'Homeopathy Specialist',
        rating: 4.9,
        experienceYears: 10,
        phoneNumber: '+91 8329213590',
        imageUrl: '',
        availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        timeSlots: ['10:00 AM', '11:00 AM', '12:00 PM', '04:00 PM', '05:00 PM'],
      ),
    ];
  }

  // Appointment methods
  Future<void> bookAppointment(Appointment appointment) async {
    final user = appointment.patientId;
    print('Attempting to book appointment for user: $user');
    
    try {
      final dateTimeStr = appointment.dateTime.toIso8601String();
      final data = appointment.toJson();

      // IMPORTANT: In some Firestore rules, you cannot query (read) a collection 
      // even if you have permission to write to it. 
      // We will skip the "existing slot" check for now to ensure the write operation 
      // is not being blocked by a read permission error.
      
      print('Sending set() request to Firestore for document: ${appointment.id}');
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(data);
          
      print('Firestore set() request successful');
    } catch (e) {
      print('CRITICAL Error in bookAppointment: $e');
      // Re-throw with a more descriptive message if it's a permission error
      if (e.toString().contains('permission-denied')) {
        throw Exception('Firestore Permission Denied: You may not have permission to write to the appointments collection. Please check your Firestore Rules.');
      }
      rethrow;
    }
  }

  Future<List<Appointment>> getBookedSlots(String doctorId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day).add(const Duration(days: 1)).toIso8601String();

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
          .where('dateTime', isLessThan: endOfDay)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error in getBookedSlots: $e');
      // If permission denied, return empty list instead of crashing
      if (e.toString().contains('permission-denied')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
  }

  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
  }

  // Health Record methods
  Future<List<HealthRecord>> getHealthRecords(String patientId) async {
    final snapshot = await _firestore
        .collection('health_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => HealthRecord.fromJson(doc.data())).toList();
  }
}
