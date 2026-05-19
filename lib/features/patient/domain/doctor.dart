import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
class Doctor with _$Doctor {
  const factory Doctor({
    required String id,
    required String name,
    required String specialization,
    required double rating,
    required int experienceYears,
    required String phoneNumber,
    required String imageUrl,
    required List<String> availableDays,
    required List<String> timeSlots,
    @Default(true) bool isActive,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
}
