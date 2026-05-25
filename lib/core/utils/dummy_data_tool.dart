import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A utility class to insert dummy data for testing purposes.
/// You can call [DummyDataTool.insertTestData()] from a button or during app init.
class DummyDataTool {
  static Future<void> insertTestData() async {
    final firestore = FirebaseFirestore.instance;

    // 1. Create a Dummy Patient
    // Replace 'dummy_patient_uid' with a real UID if you want to link it to an auth account
    const patientId = 'test_patient_123';
    final patientData = {
      'id': patientId,
      'name': 'John Doe (Test)',
      'age': 35,
      'gender': 'Male',
      'weight': 75.5,
      'bloodGroup': 'O+',
      'knownAllergies': ['Dust', 'Pollen'],
      'chronicConditions': ['Slight Hypertension'],
      'phoneNumber': '+91 9876543210',
      'email': 'john.doe.test@example.com',
    };

    // 2. Create a Dummy Doctor (matching the hardcoded ID used in the app)
    const doctorId = 'dr_tanaya';
    final doctorData = {
      'id': doctorId,
      'name': 'Dr Tanaya',
      'specialization': 'Homeopathy Specialist',
      'rating': 4.9,
      'experienceYears': 10,
      'phoneNumber': '+91 8329213590',
      'imageUrl': 'https://placeholder.com/dr_tanaya.png',
      'availableDays': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      'timeSlots': [
        '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
        '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
        '07:00 PM', '07:30 PM'
      ],
      'isActive': true,
    };

    // 3. Create a Pending Appointment
    final appointmentId = 'test_appt_${DateTime.now().millisecondsSinceEpoch}';
    final appointmentData = {
      'id': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': 'Dr Tanaya',
      'dateTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'status': 'pending',
      'type': 'clinic',
      'reason': 'Routine Checkup',
      'healthConcern': 'Persistent headache and fatigue',
      'notes': 'Dummy record for notification testing',
      'isPaid': false,
      'amount': 500.0,
    };

    try {
      print('Starting dummy data insertion...');

      // Insert Patient
      await firestore.collection('patients').doc(patientId).set(patientData);
      print('Dummy patient inserted.');

      // Insert Doctor
      await firestore.collection('doctors').doc(doctorId).set(doctorData);
      print('Dummy doctor inserted.');

      // Insert Appointment
      await firestore.collection('appointments').doc(appointmentId).set(appointmentData);
      print('Dummy appointment inserted.');

      // 4. Trigger a notification record (matching our new NotificationService logic)
      await firestore.collection('notifications').add({
        'recipientId': doctorId,
        'title': 'New Appointment Booking',
        'body': 'John Doe (Test) has booked an appointment regarding: Persistent headache and fatigue',
        'data': {
          'type': 'new_appointment',
          'appointmentId': appointmentId,
          'patientId': patientId,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Dummy notification triggered.');

      print('All dummy data inserted successfully!');
    } catch (e) {
      print('Error inserting dummy data: $e');
    }
  }
}
