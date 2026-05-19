// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthRecordImpl _$$HealthRecordImplFromJson(Map<String, dynamic> json) =>
    _$HealthRecordImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorName: json['doctorName'] as String,
      date: DateTime.parse(json['date'] as String),
      diagnosis: json['diagnosis'] as String,
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      remedies: (json['remedies'] as List<dynamic>)
          .map((e) => PrescribedRemedy.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      prescriptionPdfUrl: json['prescriptionPdfUrl'] as String?,
      labReportUrl: json['labReportUrl'] as String?,
    );

Map<String, dynamic> _$$HealthRecordImplToJson(_$HealthRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorName': instance.doctorName,
      'date': instance.date.toIso8601String(),
      'diagnosis': instance.diagnosis,
      'symptoms': instance.symptoms,
      'remedies': instance.remedies,
      'notes': instance.notes,
      'prescriptionPdfUrl': instance.prescriptionPdfUrl,
      'labReportUrl': instance.labReportUrl,
    };

_$PrescribedRemedyImpl _$$PrescribedRemedyImplFromJson(
        Map<String, dynamic> json) =>
    _$PrescribedRemedyImpl(
      name: json['name'] as String,
      potency: json['potency'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$$PrescribedRemedyImplToJson(
        _$PrescribedRemedyImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'potency': instance.potency,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'instructions': instance.instructions,
    };
