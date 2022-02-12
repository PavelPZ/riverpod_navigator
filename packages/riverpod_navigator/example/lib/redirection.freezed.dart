// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'redirection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Segments _$SegmentsFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'login':
      return LoginSegment.fromJson(json);
    case 'home':
      return HomeSegment.fromJson(json);
    case 'family':
      return FamilySegment.fromJson(json);
    case 'person':
      return PersonSegment.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Segments',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
class _$SegmentsTearOff {
  const _$SegmentsTearOff();

  LoginSegment login() {
    return LoginSegment();
  }

  HomeSegment home() {
    return HomeSegment();
  }

  FamilySegment family({required String fid}) {
    return FamilySegment(
      fid: fid,
    );
  }

  PersonSegment person({required String fid, required String pid}) {
    return PersonSegment(
      fid: fid,
      pid: pid,
    );
  }

  Segments fromJson(Map<String, Object?> json) {
    return Segments.fromJson(json);
  }
}

/// @nodoc
const $Segments = _$SegmentsTearOff();

/// @nodoc
mixin _$Segments {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() login,
    required TResult Function() home,
    required TResult Function(String fid) family,
    required TResult Function(String fid, String pid) person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginSegment value) login,
    required TResult Function(HomeSegment value) home,
    required TResult Function(FamilySegment value) family,
    required TResult Function(PersonSegment value) person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SegmentsCopyWith<$Res> {
  factory $SegmentsCopyWith(Segments value, $Res Function(Segments) then) =
      _$SegmentsCopyWithImpl<$Res>;
}

/// @nodoc
class _$SegmentsCopyWithImpl<$Res> implements $SegmentsCopyWith<$Res> {
  _$SegmentsCopyWithImpl(this._value, this._then);

  final Segments _value;
  // ignore: unused_field
  final $Res Function(Segments) _then;
}

/// @nodoc
abstract class $LoginSegmentCopyWith<$Res> {
  factory $LoginSegmentCopyWith(
          LoginSegment value, $Res Function(LoginSegment) then) =
      _$LoginSegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$LoginSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $LoginSegmentCopyWith<$Res> {
  _$LoginSegmentCopyWithImpl(
      LoginSegment _value, $Res Function(LoginSegment) _then)
      : super(_value, (v) => _then(v as LoginSegment));

  @override
  LoginSegment get _value => super._value as LoginSegment;
}

/// @nodoc
@JsonSerializable()
class _$LoginSegment extends LoginSegment {
  _$LoginSegment({String? $type})
      : $type = $type ?? 'login',
        super._();

  factory _$LoginSegment.fromJson(Map<String, dynamic> json) =>
      _$$LoginSegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LoginSegment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() login,
    required TResult Function() home,
    required TResult Function(String fid) family,
    required TResult Function(String fid, String pid) person,
  }) {
    return login();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
  }) {
    return login?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
    required TResult orElse(),
  }) {
    if (login != null) {
      return login();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginSegment value) login,
    required TResult Function(HomeSegment value) home,
    required TResult Function(FamilySegment value) family,
    required TResult Function(PersonSegment value) person,
  }) {
    return login(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
  }) {
    return login?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
    required TResult orElse(),
  }) {
    if (login != null) {
      return login(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginSegmentToJson(this);
  }
}

abstract class LoginSegment extends Segments {
  factory LoginSegment() = _$LoginSegment;
  LoginSegment._() : super._();

  factory LoginSegment.fromJson(Map<String, dynamic> json) =
      _$LoginSegment.fromJson;
}

/// @nodoc
abstract class $HomeSegmentCopyWith<$Res> {
  factory $HomeSegmentCopyWith(
          HomeSegment value, $Res Function(HomeSegment) then) =
      _$HomeSegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$HomeSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $HomeSegmentCopyWith<$Res> {
  _$HomeSegmentCopyWithImpl(
      HomeSegment _value, $Res Function(HomeSegment) _then)
      : super(_value, (v) => _then(v as HomeSegment));

  @override
  HomeSegment get _value => super._value as HomeSegment;
}

/// @nodoc
@JsonSerializable()
class _$HomeSegment extends HomeSegment {
  _$HomeSegment({String? $type})
      : $type = $type ?? 'home',
        super._();

  factory _$HomeSegment.fromJson(Map<String, dynamic> json) =>
      _$$HomeSegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeSegment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() login,
    required TResult Function() home,
    required TResult Function(String fid) family,
    required TResult Function(String fid, String pid) person,
  }) {
    return home();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
  }) {
    return home?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
    required TResult orElse(),
  }) {
    if (home != null) {
      return home();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginSegment value) login,
    required TResult Function(HomeSegment value) home,
    required TResult Function(FamilySegment value) family,
    required TResult Function(PersonSegment value) person,
  }) {
    return home(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
  }) {
    return home?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
    required TResult orElse(),
  }) {
    if (home != null) {
      return home(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeSegmentToJson(this);
  }
}

abstract class HomeSegment extends Segments {
  factory HomeSegment() = _$HomeSegment;
  HomeSegment._() : super._();

  factory HomeSegment.fromJson(Map<String, dynamic> json) =
      _$HomeSegment.fromJson;
}

/// @nodoc
abstract class $FamilySegmentCopyWith<$Res> {
  factory $FamilySegmentCopyWith(
          FamilySegment value, $Res Function(FamilySegment) then) =
      _$FamilySegmentCopyWithImpl<$Res>;
  $Res call({String fid});
}

/// @nodoc
class _$FamilySegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $FamilySegmentCopyWith<$Res> {
  _$FamilySegmentCopyWithImpl(
      FamilySegment _value, $Res Function(FamilySegment) _then)
      : super(_value, (v) => _then(v as FamilySegment));

  @override
  FamilySegment get _value => super._value as FamilySegment;

  @override
  $Res call({
    Object? fid = freezed,
  }) {
    return _then(FamilySegment(
      fid: fid == freezed
          ? _value.fid
          : fid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilySegment extends FamilySegment {
  _$FamilySegment({required this.fid, String? $type})
      : $type = $type ?? 'family',
        super._();

  factory _$FamilySegment.fromJson(Map<String, dynamic> json) =>
      _$$FamilySegmentFromJson(json);

  @override
  final String fid;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FamilySegment &&
            const DeepCollectionEquality().equals(other.fid, fid));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(fid));

  @JsonKey(ignore: true)
  @override
  $FamilySegmentCopyWith<FamilySegment> get copyWith =>
      _$FamilySegmentCopyWithImpl<FamilySegment>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() login,
    required TResult Function() home,
    required TResult Function(String fid) family,
    required TResult Function(String fid, String pid) person,
  }) {
    return family(fid);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
  }) {
    return family?.call(fid);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
    required TResult orElse(),
  }) {
    if (family != null) {
      return family(fid);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginSegment value) login,
    required TResult Function(HomeSegment value) home,
    required TResult Function(FamilySegment value) family,
    required TResult Function(PersonSegment value) person,
  }) {
    return family(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
  }) {
    return family?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
    required TResult orElse(),
  }) {
    if (family != null) {
      return family(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilySegmentToJson(this);
  }
}

abstract class FamilySegment extends Segments {
  factory FamilySegment({required String fid}) = _$FamilySegment;
  FamilySegment._() : super._();

  factory FamilySegment.fromJson(Map<String, dynamic> json) =
      _$FamilySegment.fromJson;

  String get fid;
  @JsonKey(ignore: true)
  $FamilySegmentCopyWith<FamilySegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonSegmentCopyWith<$Res> {
  factory $PersonSegmentCopyWith(
          PersonSegment value, $Res Function(PersonSegment) then) =
      _$PersonSegmentCopyWithImpl<$Res>;
  $Res call({String fid, String pid});
}

/// @nodoc
class _$PersonSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $PersonSegmentCopyWith<$Res> {
  _$PersonSegmentCopyWithImpl(
      PersonSegment _value, $Res Function(PersonSegment) _then)
      : super(_value, (v) => _then(v as PersonSegment));

  @override
  PersonSegment get _value => super._value as PersonSegment;

  @override
  $Res call({
    Object? fid = freezed,
    Object? pid = freezed,
  }) {
    return _then(PersonSegment(
      fid: fid == freezed
          ? _value.fid
          : fid // ignore: cast_nullable_to_non_nullable
              as String,
      pid: pid == freezed
          ? _value.pid
          : pid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonSegment extends PersonSegment {
  _$PersonSegment({required this.fid, required this.pid, String? $type})
      : $type = $type ?? 'person',
        super._();

  factory _$PersonSegment.fromJson(Map<String, dynamic> json) =>
      _$$PersonSegmentFromJson(json);

  @override
  final String fid;
  @override
  final String pid;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonSegment &&
            const DeepCollectionEquality().equals(other.fid, fid) &&
            const DeepCollectionEquality().equals(other.pid, pid));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(fid),
      const DeepCollectionEquality().hash(pid));

  @JsonKey(ignore: true)
  @override
  $PersonSegmentCopyWith<PersonSegment> get copyWith =>
      _$PersonSegmentCopyWithImpl<PersonSegment>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() login,
    required TResult Function() home,
    required TResult Function(String fid) family,
    required TResult Function(String fid, String pid) person,
  }) {
    return person(fid, pid);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
  }) {
    return person?.call(fid, pid);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? login,
    TResult Function()? home,
    TResult Function(String fid)? family,
    TResult Function(String fid, String pid)? person,
    required TResult orElse(),
  }) {
    if (person != null) {
      return person(fid, pid);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginSegment value) login,
    required TResult Function(HomeSegment value) home,
    required TResult Function(FamilySegment value) family,
    required TResult Function(PersonSegment value) person,
  }) {
    return person(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
  }) {
    return person?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginSegment value)? login,
    TResult Function(HomeSegment value)? home,
    TResult Function(FamilySegment value)? family,
    TResult Function(PersonSegment value)? person,
    required TResult orElse(),
  }) {
    if (person != null) {
      return person(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonSegmentToJson(this);
  }
}

abstract class PersonSegment extends Segments {
  factory PersonSegment({required String fid, required String pid}) =
      _$PersonSegment;
  PersonSegment._() : super._();

  factory PersonSegment.fromJson(Map<String, dynamic> json) =
      _$PersonSegment.fromJson;

  String get fid;
  String get pid;
  @JsonKey(ignore: true)
  $PersonSegmentCopyWith<PersonSegment> get copyWith =>
      throw _privateConstructorUsedError;
}
