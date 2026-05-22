// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthRecord _$HealthRecordFromJson(Map<String, dynamic> json) {
  return _HealthRecord.fromJson(json);
}

/// @nodoc
mixin _$HealthRecord {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;
  String get doctorName => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get diagnosis => throw _privateConstructorUsedError;
  List<String> get symptoms => throw _privateConstructorUsedError;
  List<PrescribedRemedy> get remedies => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get followUpDate => throw _privateConstructorUsedError;
  String? get prescriptionPdfUrl => throw _privateConstructorUsedError;
  String? get labReportUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthRecordCopyWith<HealthRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthRecordCopyWith<$Res> {
  factory $HealthRecordCopyWith(
          HealthRecord value, $Res Function(HealthRecord) then) =
      _$HealthRecordCopyWithImpl<$Res, HealthRecord>;
  @useResult
  $Res call(
      {String id,
      String patientId,
      String patientName,
      String doctorName,
      DateTime date,
      String diagnosis,
      List<String> symptoms,
      List<PrescribedRemedy> remedies,
      String? notes,
      DateTime? followUpDate,
      String? prescriptionPdfUrl,
      String? labReportUrl});
}

/// @nodoc
class _$HealthRecordCopyWithImpl<$Res, $Val extends HealthRecord>
    implements $HealthRecordCopyWith<$Res> {
  _$HealthRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? doctorName = null,
    Object? date = null,
    Object? diagnosis = null,
    Object? symptoms = null,
    Object? remedies = null,
    Object? notes = freezed,
    Object? followUpDate = freezed,
    Object? prescriptionPdfUrl = freezed,
    Object? labReportUrl = freezed,
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
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      diagnosis: null == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      symptoms: null == symptoms
          ? _value.symptoms
          : symptoms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      remedies: null == remedies
          ? _value.remedies
          : remedies // ignore: cast_nullable_to_non_nullable
              as List<PrescribedRemedy>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      followUpDate: freezed == followUpDate
          ? _value.followUpDate
          : followUpDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prescriptionPdfUrl: freezed == prescriptionPdfUrl
          ? _value.prescriptionPdfUrl
          : prescriptionPdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      labReportUrl: freezed == labReportUrl
          ? _value.labReportUrl
          : labReportUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthRecordImplCopyWith<$Res>
    implements $HealthRecordCopyWith<$Res> {
  factory _$$HealthRecordImplCopyWith(
          _$HealthRecordImpl value, $Res Function(_$HealthRecordImpl) then) =
      __$$HealthRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String patientId,
      String patientName,
      String doctorName,
      DateTime date,
      String diagnosis,
      List<String> symptoms,
      List<PrescribedRemedy> remedies,
      String? notes,
      DateTime? followUpDate,
      String? prescriptionPdfUrl,
      String? labReportUrl});
}

/// @nodoc
class __$$HealthRecordImplCopyWithImpl<$Res>
    extends _$HealthRecordCopyWithImpl<$Res, _$HealthRecordImpl>
    implements _$$HealthRecordImplCopyWith<$Res> {
  __$$HealthRecordImplCopyWithImpl(
      _$HealthRecordImpl _value, $Res Function(_$HealthRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? doctorName = null,
    Object? date = null,
    Object? diagnosis = null,
    Object? symptoms = null,
    Object? remedies = null,
    Object? notes = freezed,
    Object? followUpDate = freezed,
    Object? prescriptionPdfUrl = freezed,
    Object? labReportUrl = freezed,
  }) {
    return _then(_$HealthRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      doctorName: null == doctorName
          ? _value.doctorName
          : doctorName // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      diagnosis: null == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      symptoms: null == symptoms
          ? _value._symptoms
          : symptoms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      remedies: null == remedies
          ? _value._remedies
          : remedies // ignore: cast_nullable_to_non_nullable
              as List<PrescribedRemedy>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      followUpDate: freezed == followUpDate
          ? _value.followUpDate
          : followUpDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prescriptionPdfUrl: freezed == prescriptionPdfUrl
          ? _value.prescriptionPdfUrl
          : prescriptionPdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      labReportUrl: freezed == labReportUrl
          ? _value.labReportUrl
          : labReportUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthRecordImpl implements _HealthRecord {
  const _$HealthRecordImpl(
      {required this.id,
      required this.patientId,
      this.patientName = 'Patient',
      this.doctorName = 'Doctor',
      required this.date,
      this.diagnosis = 'Consultation',
      final List<String> symptoms = const [],
      final List<PrescribedRemedy> remedies = const [],
      this.notes,
      this.followUpDate,
      this.prescriptionPdfUrl,
      this.labReportUrl})
      : _symptoms = symptoms,
        _remedies = remedies;

  factory _$HealthRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  @JsonKey()
  final String patientName;
  @override
  @JsonKey()
  final String doctorName;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final String diagnosis;
  final List<String> _symptoms;
  @override
  @JsonKey()
  List<String> get symptoms {
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symptoms);
  }

  final List<PrescribedRemedy> _remedies;
  @override
  @JsonKey()
  List<PrescribedRemedy> get remedies {
    if (_remedies is EqualUnmodifiableListView) return _remedies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_remedies);
  }

  @override
  final String? notes;
  @override
  final DateTime? followUpDate;
  @override
  final String? prescriptionPdfUrl;
  @override
  final String? labReportUrl;

  @override
  String toString() {
    return 'HealthRecord(id: $id, patientId: $patientId, patientName: $patientName, doctorName: $doctorName, date: $date, diagnosis: $diagnosis, symptoms: $symptoms, remedies: $remedies, notes: $notes, followUpDate: $followUpDate, prescriptionPdfUrl: $prescriptionPdfUrl, labReportUrl: $labReportUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            const DeepCollectionEquality().equals(other._remedies, _remedies) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.followUpDate, followUpDate) ||
                other.followUpDate == followUpDate) &&
            (identical(other.prescriptionPdfUrl, prescriptionPdfUrl) ||
                other.prescriptionPdfUrl == prescriptionPdfUrl) &&
            (identical(other.labReportUrl, labReportUrl) ||
                other.labReportUrl == labReportUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientId,
      patientName,
      doctorName,
      date,
      diagnosis,
      const DeepCollectionEquality().hash(_symptoms),
      const DeepCollectionEquality().hash(_remedies),
      notes,
      followUpDate,
      prescriptionPdfUrl,
      labReportUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthRecordImplCopyWith<_$HealthRecordImpl> get copyWith =>
      __$$HealthRecordImplCopyWithImpl<_$HealthRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthRecordImplToJson(
      this,
    );
  }
}

abstract class _HealthRecord implements HealthRecord {
  const factory _HealthRecord(
      {required final String id,
      required final String patientId,
      final String patientName,
      final String doctorName,
      required final DateTime date,
      final String diagnosis,
      final List<String> symptoms,
      final List<PrescribedRemedy> remedies,
      final String? notes,
      final DateTime? followUpDate,
      final String? prescriptionPdfUrl,
      final String? labReportUrl}) = _$HealthRecordImpl;

  factory _HealthRecord.fromJson(Map<String, dynamic> json) =
      _$HealthRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get patientName;
  @override
  String get doctorName;
  @override
  DateTime get date;
  @override
  String get diagnosis;
  @override
  List<String> get symptoms;
  @override
  List<PrescribedRemedy> get remedies;
  @override
  String? get notes;
  @override
  DateTime? get followUpDate;
  @override
  String? get prescriptionPdfUrl;
  @override
  String? get labReportUrl;
  @override
  @JsonKey(ignore: true)
  _$$HealthRecordImplCopyWith<_$HealthRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrescribedRemedy _$PrescribedRemedyFromJson(Map<String, dynamic> json) {
  return _PrescribedRemedy.fromJson(json);
}

/// @nodoc
mixin _$PrescribedRemedy {
  String get name => throw _privateConstructorUsedError;
  String get potency => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError; // e.g., "4 pills"
  String get frequency =>
      throw _privateConstructorUsedError; // e.g., "3 times a day"
  String get duration => throw _privateConstructorUsedError; // e.g., "7 days"
  String? get instructions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrescribedRemedyCopyWith<PrescribedRemedy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrescribedRemedyCopyWith<$Res> {
  factory $PrescribedRemedyCopyWith(
          PrescribedRemedy value, $Res Function(PrescribedRemedy) then) =
      _$PrescribedRemedyCopyWithImpl<$Res, PrescribedRemedy>;
  @useResult
  $Res call(
      {String name,
      String potency,
      String dosage,
      String frequency,
      String duration,
      String? instructions});
}

/// @nodoc
class _$PrescribedRemedyCopyWithImpl<$Res, $Val extends PrescribedRemedy>
    implements $PrescribedRemedyCopyWith<$Res> {
  _$PrescribedRemedyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? potency = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? duration = null,
    Object? instructions = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      potency: null == potency
          ? _value.potency
          : potency // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrescribedRemedyImplCopyWith<$Res>
    implements $PrescribedRemedyCopyWith<$Res> {
  factory _$$PrescribedRemedyImplCopyWith(_$PrescribedRemedyImpl value,
          $Res Function(_$PrescribedRemedyImpl) then) =
      __$$PrescribedRemedyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String potency,
      String dosage,
      String frequency,
      String duration,
      String? instructions});
}

/// @nodoc
class __$$PrescribedRemedyImplCopyWithImpl<$Res>
    extends _$PrescribedRemedyCopyWithImpl<$Res, _$PrescribedRemedyImpl>
    implements _$$PrescribedRemedyImplCopyWith<$Res> {
  __$$PrescribedRemedyImplCopyWithImpl(_$PrescribedRemedyImpl _value,
      $Res Function(_$PrescribedRemedyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? potency = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? duration = null,
    Object? instructions = freezed,
  }) {
    return _then(_$PrescribedRemedyImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      potency: null == potency
          ? _value.potency
          : potency // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrescribedRemedyImpl implements _PrescribedRemedy {
  const _$PrescribedRemedyImpl(
      {required this.name,
      required this.potency,
      required this.dosage,
      required this.frequency,
      required this.duration,
      this.instructions});

  factory _$PrescribedRemedyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrescribedRemedyImplFromJson(json);

  @override
  final String name;
  @override
  final String potency;
  @override
  final String dosage;
// e.g., "4 pills"
  @override
  final String frequency;
// e.g., "3 times a day"
  @override
  final String duration;
// e.g., "7 days"
  @override
  final String? instructions;

  @override
  String toString() {
    return 'PrescribedRemedy(name: $name, potency: $potency, dosage: $dosage, frequency: $frequency, duration: $duration, instructions: $instructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrescribedRemedyImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.potency, potency) || other.potency == potency) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, potency, dosage, frequency, duration, instructions);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrescribedRemedyImplCopyWith<_$PrescribedRemedyImpl> get copyWith =>
      __$$PrescribedRemedyImplCopyWithImpl<_$PrescribedRemedyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrescribedRemedyImplToJson(
      this,
    );
  }
}

abstract class _PrescribedRemedy implements PrescribedRemedy {
  const factory _PrescribedRemedy(
      {required final String name,
      required final String potency,
      required final String dosage,
      required final String frequency,
      required final String duration,
      final String? instructions}) = _$PrescribedRemedyImpl;

  factory _PrescribedRemedy.fromJson(Map<String, dynamic> json) =
      _$PrescribedRemedyImpl.fromJson;

  @override
  String get name;
  @override
  String get potency;
  @override
  String get dosage;
  @override // e.g., "4 pills"
  String get frequency;
  @override // e.g., "3 times a day"
  String get duration;
  @override // e.g., "7 days"
  String? get instructions;
  @override
  @JsonKey(ignore: true)
  _$$PrescribedRemedyImplCopyWith<_$PrescribedRemedyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
