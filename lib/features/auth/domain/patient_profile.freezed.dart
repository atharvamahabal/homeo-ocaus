// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PatientProfile _$PatientProfileFromJson(Map<String, dynamic> json) {
  return _PatientProfile.fromJson(json);
}

/// @nodoc
mixin _$PatientProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  String get bloodGroup => throw _privateConstructorUsedError;
  List<String> get knownAllergies => throw _privateConstructorUsedError;
  List<String> get chronicConditions => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PatientProfileCopyWith<PatientProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientProfileCopyWith<$Res> {
  factory $PatientProfileCopyWith(
          PatientProfile value, $Res Function(PatientProfile) then) =
      _$PatientProfileCopyWithImpl<$Res, PatientProfile>;
  @useResult
  $Res call(
      {String id,
      String name,
      int age,
      String gender,
      double weight,
      String bloodGroup,
      List<String> knownAllergies,
      List<String> chronicConditions,
      String? phoneNumber,
      String? email});
}

/// @nodoc
class _$PatientProfileCopyWithImpl<$Res, $Val extends PatientProfile>
    implements $PatientProfileCopyWith<$Res> {
  _$PatientProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? weight = null,
    Object? bloodGroup = null,
    Object? knownAllergies = null,
    Object? chronicConditions = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      bloodGroup: null == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String,
      knownAllergies: null == knownAllergies
          ? _value.knownAllergies
          : knownAllergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chronicConditions: null == chronicConditions
          ? _value.chronicConditions
          : chronicConditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientProfileImplCopyWith<$Res>
    implements $PatientProfileCopyWith<$Res> {
  factory _$$PatientProfileImplCopyWith(_$PatientProfileImpl value,
          $Res Function(_$PatientProfileImpl) then) =
      __$$PatientProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int age,
      String gender,
      double weight,
      String bloodGroup,
      List<String> knownAllergies,
      List<String> chronicConditions,
      String? phoneNumber,
      String? email});
}

/// @nodoc
class __$$PatientProfileImplCopyWithImpl<$Res>
    extends _$PatientProfileCopyWithImpl<$Res, _$PatientProfileImpl>
    implements _$$PatientProfileImplCopyWith<$Res> {
  __$$PatientProfileImplCopyWithImpl(
      _$PatientProfileImpl _value, $Res Function(_$PatientProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? weight = null,
    Object? bloodGroup = null,
    Object? knownAllergies = null,
    Object? chronicConditions = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
  }) {
    return _then(_$PatientProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      bloodGroup: null == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String,
      knownAllergies: null == knownAllergies
          ? _value._knownAllergies
          : knownAllergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chronicConditions: null == chronicConditions
          ? _value._chronicConditions
          : chronicConditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientProfileImpl implements _PatientProfile {
  const _$PatientProfileImpl(
      {required this.id,
      required this.name,
      required this.age,
      required this.gender,
      required this.weight,
      required this.bloodGroup,
      final List<String> knownAllergies = const [],
      final List<String> chronicConditions = const [],
      this.phoneNumber,
      this.email})
      : _knownAllergies = knownAllergies,
        _chronicConditions = chronicConditions;

  factory _$PatientProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int age;
  @override
  final String gender;
  @override
  final double weight;
  @override
  final String bloodGroup;
  final List<String> _knownAllergies;
  @override
  @JsonKey()
  List<String> get knownAllergies {
    if (_knownAllergies is EqualUnmodifiableListView) return _knownAllergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_knownAllergies);
  }

  final List<String> _chronicConditions;
  @override
  @JsonKey()
  List<String> get chronicConditions {
    if (_chronicConditions is EqualUnmodifiableListView)
      return _chronicConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chronicConditions);
  }

  @override
  final String? phoneNumber;
  @override
  final String? email;

  @override
  String toString() {
    return 'PatientProfile(id: $id, name: $name, age: $age, gender: $gender, weight: $weight, bloodGroup: $bloodGroup, knownAllergies: $knownAllergies, chronicConditions: $chronicConditions, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            const DeepCollectionEquality()
                .equals(other._knownAllergies, _knownAllergies) &&
            const DeepCollectionEquality()
                .equals(other._chronicConditions, _chronicConditions) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      age,
      gender,
      weight,
      bloodGroup,
      const DeepCollectionEquality().hash(_knownAllergies),
      const DeepCollectionEquality().hash(_chronicConditions),
      phoneNumber,
      email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientProfileImplCopyWith<_$PatientProfileImpl> get copyWith =>
      __$$PatientProfileImplCopyWithImpl<_$PatientProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientProfileImplToJson(
      this,
    );
  }
}

abstract class _PatientProfile implements PatientProfile {
  const factory _PatientProfile(
      {required final String id,
      required final String name,
      required final int age,
      required final String gender,
      required final double weight,
      required final String bloodGroup,
      final List<String> knownAllergies,
      final List<String> chronicConditions,
      final String? phoneNumber,
      final String? email}) = _$PatientProfileImpl;

  factory _PatientProfile.fromJson(Map<String, dynamic> json) =
      _$PatientProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get age;
  @override
  String get gender;
  @override
  double get weight;
  @override
  String get bloodGroup;
  @override
  List<String> get knownAllergies;
  @override
  List<String> get chronicConditions;
  @override
  String? get phoneNumber;
  @override
  String? get email;
  @override
  @JsonKey(ignore: true)
  _$$PatientProfileImplCopyWith<_$PatientProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
