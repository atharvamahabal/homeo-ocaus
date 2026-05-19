// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DoctorImpl _$$DoctorImplFromJson(Map<String, dynamic> json) => _$DoctorImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      rating: (json['rating'] as num).toDouble(),
      experienceYears: (json['experienceYears'] as num).toInt(),
      phoneNumber: json['phoneNumber'] as String,
      imageUrl: json['imageUrl'] as String,
      availableDays: (json['availableDays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timeSlots:
          (json['timeSlots'] as List<dynamic>).map((e) => e as String).toList(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$DoctorImplToJson(_$DoctorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialization': instance.specialization,
      'rating': instance.rating,
      'experienceYears': instance.experienceYears,
      'phoneNumber': instance.phoneNumber,
      'imageUrl': instance.imageUrl,
      'availableDays': instance.availableDays,
      'timeSlots': instance.timeSlots,
      'isActive': instance.isActive,
    };
