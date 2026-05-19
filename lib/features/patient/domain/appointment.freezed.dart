// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Appointment _$AppointmentFromJson(Map<String, dynamic> json) {
  return _Appointment.fromJson(json);
}

/// @nodoc
mixin _$Appointment {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String get doctorName => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'pending', 'confirmed', 'cancelled', 'completed'
  String get type => throw _privateConstructorUsedError; // 'video', 'clinic'
  String? get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppointmentCopyWith<Appointment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentCopyWith<$Res> {
  factory $AppointmentCopyWith(
          Appointment value, $Res Function(Appointment) then) =
      _$AppointmentCopyWithImpl<$Res, Appointment>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String doctorId,
      String doctorName,
      DateTime dateTime,
      String status,
      String type,
      String? reason,
      String? notes,
      bool isPaid,
      double? amount});
}

/// @nodoc
class _$AppointmentCopyWithImpl<$Res, $Val extends Appointment>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? dateTime = null,
    Object? status = null,
    Object? type = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? isPaid = null,
    Object? amount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppointmentImplCopyWith<$Res>
    implements $AppointmentCopyWith<$Res> {
  factory _$$AppointmentImplCopyWith(
          _$AppointmentImpl value, $Res Function(_$AppointmentImpl) then) =
      __$$AppointmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String doctorId,
      String doctorName,
      DateTime dateTime,
      String status,
      String type,
      String? reason,
      String? notes,
      bool isPaid,
      double? amount});
}

/// @nodoc
class __$$AppointmentImplCopyWithImpl<$Res>
    extends _$AppointmentCopyWithImpl<$Res, _$AppointmentImpl>
    implements _$$AppointmentImplCopyWith<$Res> {
  __$$AppointmentImplCopyWithImpl(
      _$AppointmentImpl _value, $Res Function(_$AppointmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? dateTime = null,
    Object? status = null,
    Object? type = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? isPaid = null,
    Object? amount = freezed,
  }) {
    return _then(_$AppointmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentImpl implements _Appointment {
  const _$AppointmentImpl(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.doctorName,
      required this.dateTime,
      required this.status,
      required this.type,
      this.reason,
      this.notes,
      this.isPaid = false,
      this.amount});

  factory _$AppointmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String doctorId;
  @override
  final String doctorName;
  @override
  final DateTime dateTime;
  @override
  final String status;
// 'pending', 'confirmed', 'cancelled', 'completed'
  @override
  final String type;
// 'video', 'clinic'
  @override
  final String? reason;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isPaid;
  @override
  final double? amount;

  @override
  String toString() {
    return 'Appointment(id: $id, patientId: $patientId, doctorId: $doctorId, doctorName: $doctorName, dateTime: $dateTime, status: $status, type: $type, reason: $reason, notes: $notes, isPaid: $isPaid, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, patientId, doctorId,
      doctorName, dateTime, status, type, reason, notes, isPaid, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      __$$AppointmentImplCopyWithImpl<_$AppointmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentImplToJson(
      this,
    );
  }
}

abstract class _Appointment implements Appointment {
  const factory _Appointment(
      {required final String id,
      required final String patientId,
      required final String doctorId,
      required final String doctorName,
      required final DateTime dateTime,
      required final String status,
      required final String type,
      final String? reason,
      final String? notes,
      final bool isPaid,
      final double? amount}) = _$AppointmentImpl;

  factory _Appointment.fromJson(Map<String, dynamic> json) =
      _$AppointmentImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get doctorId;
  @override
  String get doctorName;
  @override
  DateTime get dateTime;
  @override
  String get status;
  @override // 'pending', 'confirmed', 'cancelled', 'completed'
  String get type;
  @override // 'video', 'clinic'
  String? get reason;
  @override
  String? get notes;
  @override
  bool get isPaid;
  @override
  double? get amount;
  @override
  @JsonKey(ignore: true)
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
