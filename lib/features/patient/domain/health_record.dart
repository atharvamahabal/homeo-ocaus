import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_record.freezed.dart';
part 'health_record.g.dart';

@freezed
class HealthRecord with _$HealthRecord {
  const factory HealthRecord({
    required String id,
    required String patientId,
    @Default('Patient') String patientName,
    @Default('Doctor') String doctorName,
    required DateTime date,
    @Default('Consultation') String diagnosis,
    @Default([]) List<String> symptoms,
    @Default([]) List<PrescribedRemedy> remedies,
    String? notes,
    DateTime? followUpDate,
    String? prescriptionPdfUrl,
    String? labReportUrl,
  }) = _HealthRecord;

  factory HealthRecord.fromJson(Map<String, dynamic> json) => _$HealthRecordFromJson(json);
}

@freezed
class PrescribedRemedy with _$PrescribedRemedy {
  const factory PrescribedRemedy({
    required String name,
    required String potency,
    required String dosage, // e.g., "4 pills"
    required String frequency, // e.g., "3 times a day"
    required String duration, // e.g., "7 days"
    String? instructions,
  }) = _PrescribedRemedy;

  factory PrescribedRemedy.fromJson(Map<String, dynamic> json) => _$PrescribedRemedyFromJson(json);
}
