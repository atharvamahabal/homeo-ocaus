// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentImpl _$$AppointmentImplFromJson(Map<String, dynamic> json) =>
    _$AppointmentImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: json['status'] as String,
      type: json['type'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$AppointmentImplToJson(_$AppointmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'dateTime': instance.dateTime.toIso8601String(),
      'status': instance.status,
      'type': instance.type,
      'reason': instance.reason,
      'notes': instance.notes,
      'isPaid': instance.isPaid,
      'amount': instance.amount,
    };
