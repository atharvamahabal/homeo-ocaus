// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthRecordImpl _$$HealthRecordImplFromJson(Map<String, dynamic> json) =>
    _$HealthRecordImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String? ?? 'Patient',
      doctorName: json['doctorName'] as String? ?? 'Doctor',
      date: DateTime.parse(json['date'] as String),
      diagnosis: json['diagnosis'] as String? ?? 'Consultation',
      healthConcern: json['healthConcern'] as String?,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      remedies: (json['remedies'] as List<dynamic>?)
              ?.map((e) => PrescribedRemedy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
      prescriptionPdfUrl: json['prescriptionPdfUrl'] as String?,
      labReportUrl: json['labReportUrl'] as String?,
    );

Map<String, dynamic> _$$HealthRecordImplToJson(_$HealthRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
      'date': instance.date.toIso8601String(),
      'diagnosis': instance.diagnosis,
      'healthConcern': instance.healthConcern,
      'symptoms': instance.symptoms,
      'remedies': instance.remedies.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'followUpDate': instance.followUpDate?.toIso8601String(),
      'prescriptionPdfUrl': instance.prescriptionPdfUrl,
      'labReportUrl': instance.labReportUrl,
    };

_$PrescribedRemedyImpl _$$PrescribedRemedyImplFromJson(
        Map<String, dynamic> json) =>
    _$PrescribedRemedyImpl(
      name: json['name'] as String,
      potency: json['potency'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'As directed',
      duration: json['duration'] as String? ?? 'Until finished',
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
