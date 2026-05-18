import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/patient_profile.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository(ref.watch(firestoreProvider));
});

class PatientRepository {
  final FirebaseFirestore _firestore;
  PatientRepository(this._firestore);

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
}
