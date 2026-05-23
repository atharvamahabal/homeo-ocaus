import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_record.freezed.dart';
part 'health_record.g.dart';

@freezed
class HealthRecord with _$HealthRecord {
  @JsonSerializable(explicitToJson: true)
  const factory HealthRecord({
    required String id,
    required String patientId,
    @Default('Patient') String patientName,
    @Default('Doctor') String doctorName,
    required DateTime date,
    @Default('Consultation') String diagnosis,
    String? healthConcern,
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
    @Default('') String potency,
    @Default('') String dosage, // e.g., "4 pills"
    @Default('As directed') String frequency, // e.g., "3 times a day"
    @Default('Until finished') String duration, // e.g., "7 days"
    String? instructions,
  }) = _PrescribedRemedy;

  factory PrescribedRemedy.fromJson(Map<String, dynamic> json) => _$PrescribedRemedyFromJson(json);
}
