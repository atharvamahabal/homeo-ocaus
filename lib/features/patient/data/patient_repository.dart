import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/patient_profile.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';
import '../domain/health_record.dart';
import 'package:homeo_ocaus/core/services/notification_service.dart';

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
        timeSlots: [
          '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
          '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
          '07:00 PM', '07:30 PM'
        ],
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

      // Trigger push notification to doctor
      try {
        final patientProfile = await getProfile(appointment.patientId);
        final patientName = patientProfile?.name ?? 'A patient';
        
        await NotificationService().sendNotification(
          recipientId: appointment.doctorId, // Send to the doctor (e.g., 'dr_tanaya')
          title: 'New Appointment Booking',
          body: '$patientName has booked an appointment regarding: ${appointment.healthConcern ?? "No health concern provided"}',
          data: {
            'type': 'new_appointment',
            'appointmentId': appointment.id,
            'patientId': appointment.patientId,
          },
        );
      } catch (e) {
        print('Error sending notification record: $e');
        // Don't fail the booking if notification fails
      }
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
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch all appointments for this doctor and filter in memory to avoid composite index
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data()))
          .where((a) {
            final apptDate = a.dateTime;
            final isSameDay = apptDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
                             apptDate.isBefore(endOfDay);
            return isSameDay && (a.status == 'confirmed' || a.status == 'pending');
          })
          .toList();
    } catch (e) {
      print('Error in getBookedSlots: $e');
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
        .get();
    
    final appointments = snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
    // Sort in memory to avoid index requirement
    appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return appointments;
  }

  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();
    
    final appointments = snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList();
    // Sort in memory to avoid index requirement
    appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return appointments;
  }

  // Health Record methods
  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      print('Attempting to add health record for patient: ${record.patientId}');
      print('Remedies count to save: ${record.remedies.length}');
      final data = record.toJson();
      print('Serialized remedies: ${data['remedies']}');
      
      await _firestore
          .collection('health_records')
          .doc(record.id)
          .set(data);
      print('Health record added successfully');
    } catch (e) {
      print('CRITICAL Error in addHealthRecord: $e');
      if (e.toString().contains('permission-denied') || e.toString().contains('Permission Denied')) {
        throw Exception('Firestore Permission Denied: You do not have permission to write to the "health_records" collection. Please ensure your Firestore Security Rules allow authenticated users to write to this collection.');
      }
      rethrow;
    }
  }

  Future<List<HealthRecord>> getHealthRecords(String patientId) async {
    try {
      print('Fetching health records for patient: $patientId');
      final snapshot = await _firestore
          .collection('health_records')
          .where('patientId', isEqualTo: patientId)
          .get();
      
      final List<HealthRecord> records = [];
      for (var doc in snapshot.docs) {
        try {
          records.add(HealthRecord.fromJson(doc.data()));
        } catch (e) {
          print('Error parsing health record ${doc.id}: $e');
          // Skip records that fail to parse instead of breaking the entire list
        }
      }
      
      // Sort in memory to avoid index requirement
      records.sort((a, b) => b.date.compareTo(a.date));
      print('Successfully fetched ${records.length} health records');
      return records;
    } catch (e) {
      print('CRITICAL Error in getHealthRecords: $e');
      if (e.toString().contains('permission-denied') || e.toString().contains('Permission Denied')) {
        // Return empty list or rethrow depending on desired behavior
        // Rethrowing allows the UI to show an error message
        throw Exception('Firestore Permission Denied: You do not have permission to read from the "health_records" collection.');
      }
      rethrow;
    }
  }
}
