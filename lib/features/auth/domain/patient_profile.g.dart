// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientProfileImpl _$$PatientProfileImplFromJson(Map<String, dynamic> json) =>
    _$PatientProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      weight: (json['weight'] as num).toDouble(),
      bloodGroup: json['bloodGroup'] as String,
      knownAllergies: (json['knownAllergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$PatientProfileImplToJson(
        _$PatientProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'weight': instance.weight,
      'bloodGroup': instance.bloodGroup,
      'knownAllergies': instance.knownAllergies,
      'chronicConditions': instance.chronicConditions,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
    };
