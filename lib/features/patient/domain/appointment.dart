import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required DateTime dateTime,
    required String status, // 'pending', 'confirmed', 'cancelled', 'completed'
    required String type, // 'video', 'clinic'
    String? reason,
    String? healthConcern,
    String? notes,
    @Default(false) bool isPaid,
    double? amount,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
}
