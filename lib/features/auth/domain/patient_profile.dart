import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_profile.freezed.dart';
part 'patient_profile.g.dart';

@freezed
class PatientProfile with _$PatientProfile {
  const factory PatientProfile({
    required String id,
    required String name,
    required int age,
    required String gender,
    required double weight,
    required String bloodGroup,
    @Default([]) List<String> knownAllergies,
    @Default([]) List<String> chronicConditions,
    String? phoneNumber,
    String? email,
  }) = _PatientProfile;

  factory PatientProfile.fromJson(Map<String, dynamic> json) =>
      _$PatientProfileFromJson(json);
}
