// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'more_groups.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

FirstGrp _$FirstGrpFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'first1':
      return First1Segment.fromJson(json);
    case 'first2':
      return First2Segment.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'FirstGrp',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
class _$FirstGrpTearOff {
  const _$FirstGrpTearOff();

  First1Segment first1() {
    return First1Segment();
  }

  First2Segment first2() {
    return First2Segment();
  }

  FirstGrp fromJson(Map<String, Object?> json) {
    return FirstGrp.fromJson(json);
  }
}

/// @nodoc
const $FirstGrp = _$FirstGrpTearOff();

/// @nodoc
mixin _$FirstGrp {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() first1,
    required TResult Function() first2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? first1,
    TResult Function()? first2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? first1,
    TResult Function()? first2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(First1Segment value) first1,
    required TResult Function(First2Segment value) first2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(First1Segment value)? first1,
    TResult Function(First2Segment value)? first2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(First1Segment value)? first1,
    TResult Function(First2Segment value)? first2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirstGrpCopyWith<$Res> {
  factory $FirstGrpCopyWith(FirstGrp value, $Res Function(FirstGrp) then) =
      _$FirstGrpCopyWithImpl<$Res>;
}

/// @nodoc
class _$FirstGrpCopyWithImpl<$Res> implements $FirstGrpCopyWith<$Res> {
  _$FirstGrpCopyWithImpl(this._value, this._then);

  final FirstGrp _value;
  // ignore: unused_field
  final $Res Function(FirstGrp) _then;
}

/// @nodoc
abstract class $First1SegmentCopyWith<$Res> {
  factory $First1SegmentCopyWith(
          First1Segment value, $Res Function(First1Segment) then) =
      _$First1SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$First1SegmentCopyWithImpl<$Res> extends _$FirstGrpCopyWithImpl<$Res>
    implements $First1SegmentCopyWith<$Res> {
  _$First1SegmentCopyWithImpl(
      First1Segment _value, $Res Function(First1Segment) _then)
      : super(_value, (v) => _then(v as First1Segment));

  @override
  First1Segment get _value => super._value as First1Segment;
}

/// @nodoc
@JsonSerializable()
class _$First1Segment extends First1Segment {
  _$First1Segment({String? $type})
      : $type = $type ?? 'first1',
        super._();

  factory _$First1Segment.fromJson(Map<String, dynamic> json) =>
      _$$First1SegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is First1Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() first1,
    required TResult Function() first2,
  }) {
    return first1();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? first1,
    TResult Function()? first2,
  }) {
    return first1?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? first1,
    TResult Function()? first2,
    required TResult orElse(),
  }) {
    if (first1 != null) {
      return first1();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(First1Segment value) first1,
    required TResult Function(First2Segment value) first2,
  }) {
    return first1(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(First1Segment value)? first1,
    TResult Function(First2Segment value)? first2,
  }) {
    return first1?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(First1Segment value)? first1,
    TResult Function(First2Segment value)? first2,
    required TResult orElse(),
  }) {
    if (first1 != null) {
      return first1(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$First1SegmentToJson(this);
  }
}

abstract class First1Segment extends FirstGrp {
  factory First1Segment() = _$First1Segment;
  First1Segment._() : super._();

  factory First1Segment.fromJson(Map<String, dynamic> json) =
      _$First1Segment.fromJson;
}

/// @nodoc
abstract class $First2SegmentCopyWith<$Res> {
  factory $First2SegmentCopyWith(
          First2Segment value, $Res Function(First2Segment) then) =
      _$First2SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$First2SegmentCopyWithImpl<$Res> extends _$FirstGrpCopyWithImpl<$Res>
    implements $First2SegmentCopyWith<$Res> {
  _$First2SegmentCopyWithImpl(
      First2Segment _value, $Res Function(First2Segment) _then)
      : super(_value, (v) => _then(v as First2Segment));

  @override
  First2Segment get _value => super._value as First2Segment;
}

/// @nodoc
@JsonSerializable()
class _$First2Segment extends First2Segment {
  _$First2Segment({String? $type})
      : $type = $type ?? 'first2',
        super._();

  factory _$First2Segment.fromJson(Map<String, dynamic> json) =>
      _$$First2SegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is First2Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() first1,
    required TResult Function() first2,
  }) {
    return first2();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? first1,
    TResult Function()? first2,
  }) {
    return first2?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? first1,
    TResult Function()? first2,
    required TResult orElse(),
  }) {
    if (first2 != null) {
      return first2();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(First1Segment value) first1,
    required TResult Function(First2Segment value) first2,
  }) {
    return first2(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(First1Segment value)? first1,
    TResult Function(First2Segment value)? first2,
  }) {
    return first2?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(First1Segment value)? first1,
    TResult Function(First2Segment value)? first2,
    required TResult orElse(),
  }) {
    if (first2 != null) {
      return first2(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$First2SegmentToJson(this);
  }
}

abstract class First2Segment extends FirstGrp {
  factory First2Segment() = _$First2Segment;
  First2Segment._() : super._();

  factory First2Segment.fromJson(Map<String, dynamic> json) =
      _$First2Segment.fromJson;
}

SecondGrp _$SecondGrpFromJson(Map<String, dynamic> json) {
  switch (json['_second']) {
    case 'second1':
      return Second1Segment.fromJson(json);
    case 'second2':
      return Second2Segment.fromJson(json);

    default:
      throw CheckedFromJsonException(json, '_second', 'SecondGrp',
          'Invalid union type "${json['_second']}"!');
  }
}

/// @nodoc
class _$SecondGrpTearOff {
  const _$SecondGrpTearOff();

  Second1Segment second1() {
    return Second1Segment();
  }

  Second2Segment second2() {
    return Second2Segment();
  }

  SecondGrp fromJson(Map<String, Object?> json) {
    return SecondGrp.fromJson(json);
  }
}

/// @nodoc
const $SecondGrp = _$SecondGrpTearOff();

/// @nodoc
mixin _$SecondGrp {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() second1,
    required TResult Function() second2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? second1,
    TResult Function()? second2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? second1,
    TResult Function()? second2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Second1Segment value) second1,
    required TResult Function(Second2Segment value) second2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Second1Segment value)? second1,
    TResult Function(Second2Segment value)? second2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Second1Segment value)? second1,
    TResult Function(Second2Segment value)? second2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecondGrpCopyWith<$Res> {
  factory $SecondGrpCopyWith(SecondGrp value, $Res Function(SecondGrp) then) =
      _$SecondGrpCopyWithImpl<$Res>;
}

/// @nodoc
class _$SecondGrpCopyWithImpl<$Res> implements $SecondGrpCopyWith<$Res> {
  _$SecondGrpCopyWithImpl(this._value, this._then);

  final SecondGrp _value;
  // ignore: unused_field
  final $Res Function(SecondGrp) _then;
}

/// @nodoc
abstract class $Second1SegmentCopyWith<$Res> {
  factory $Second1SegmentCopyWith(
          Second1Segment value, $Res Function(Second1Segment) then) =
      _$Second1SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$Second1SegmentCopyWithImpl<$Res> extends _$SecondGrpCopyWithImpl<$Res>
    implements $Second1SegmentCopyWith<$Res> {
  _$Second1SegmentCopyWithImpl(
      Second1Segment _value, $Res Function(Second1Segment) _then)
      : super(_value, (v) => _then(v as Second1Segment));

  @override
  Second1Segment get _value => super._value as Second1Segment;
}

/// @nodoc
@JsonSerializable()
class _$Second1Segment extends Second1Segment {
  _$Second1Segment({String? $type})
      : $type = $type ?? 'second1',
        super._();

  factory _$Second1Segment.fromJson(Map<String, dynamic> json) =>
      _$$Second1SegmentFromJson(json);

  @JsonKey(name: '_second')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Second1Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() second1,
    required TResult Function() second2,
  }) {
    return second1();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? second1,
    TResult Function()? second2,
  }) {
    return second1?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? second1,
    TResult Function()? second2,
    required TResult orElse(),
  }) {
    if (second1 != null) {
      return second1();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Second1Segment value) second1,
    required TResult Function(Second2Segment value) second2,
  }) {
    return second1(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Second1Segment value)? second1,
    TResult Function(Second2Segment value)? second2,
  }) {
    return second1?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Second1Segment value)? second1,
    TResult Function(Second2Segment value)? second2,
    required TResult orElse(),
  }) {
    if (second1 != null) {
      return second1(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$Second1SegmentToJson(this);
  }
}

abstract class Second1Segment extends SecondGrp {
  factory Second1Segment() = _$Second1Segment;
  Second1Segment._() : super._();

  factory Second1Segment.fromJson(Map<String, dynamic> json) =
      _$Second1Segment.fromJson;
}

/// @nodoc
abstract class $Second2SegmentCopyWith<$Res> {
  factory $Second2SegmentCopyWith(
          Second2Segment value, $Res Function(Second2Segment) then) =
      _$Second2SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$Second2SegmentCopyWithImpl<$Res> extends _$SecondGrpCopyWithImpl<$Res>
    implements $Second2SegmentCopyWith<$Res> {
  _$Second2SegmentCopyWithImpl(
      Second2Segment _value, $Res Function(Second2Segment) _then)
      : super(_value, (v) => _then(v as Second2Segment));

  @override
  Second2Segment get _value => super._value as Second2Segment;
}

/// @nodoc
@JsonSerializable()
class _$Second2Segment extends Second2Segment {
  _$Second2Segment({String? $type})
      : $type = $type ?? 'second2',
        super._();

  factory _$Second2Segment.fromJson(Map<String, dynamic> json) =>
      _$$Second2SegmentFromJson(json);

  @JsonKey(name: '_second')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Second2Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() second1,
    required TResult Function() second2,
  }) {
    return second2();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? second1,
    TResult Function()? second2,
  }) {
    return second2?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? second1,
    TResult Function()? second2,
    required TResult orElse(),
  }) {
    if (second2 != null) {
      return second2();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Second1Segment value) second1,
    required TResult Function(Second2Segment value) second2,
  }) {
    return second2(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Second1Segment value)? second1,
    TResult Function(Second2Segment value)? second2,
  }) {
    return second2?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Second1Segment value)? second1,
    TResult Function(Second2Segment value)? second2,
    required TResult orElse(),
  }) {
    if (second2 != null) {
      return second2(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$Second2SegmentToJson(this);
  }
}

abstract class Second2Segment extends SecondGrp {
  factory Second2Segment() = _$Second2Segment;
  Second2Segment._() : super._();

  factory Second2Segment.fromJson(Map<String, dynamic> json) =
      _$Second2Segment.fromJson;
}

ThirdGrp _$ThirdGrpFromJson(Map<String, dynamic> json) {
  switch (json['_third']) {
    case 'third1':
      return Third1Segment.fromJson(json);
    case 'third2':
      return Third2Segment.fromJson(json);

    default:
      throw CheckedFromJsonException(json, '_third', 'ThirdGrp',
          'Invalid union type "${json['_third']}"!');
  }
}

/// @nodoc
class _$ThirdGrpTearOff {
  const _$ThirdGrpTearOff();

  Third1Segment third1() {
    return Third1Segment();
  }

  Third2Segment third2() {
    return Third2Segment();
  }

  ThirdGrp fromJson(Map<String, Object?> json) {
    return ThirdGrp.fromJson(json);
  }
}

/// @nodoc
const $ThirdGrp = _$ThirdGrpTearOff();

/// @nodoc
mixin _$ThirdGrp {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() third1,
    required TResult Function() third2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? third1,
    TResult Function()? third2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? third1,
    TResult Function()? third2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Third1Segment value) third1,
    required TResult Function(Third2Segment value) third2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Third1Segment value)? third1,
    TResult Function(Third2Segment value)? third2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Third1Segment value)? third1,
    TResult Function(Third2Segment value)? third2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThirdGrpCopyWith<$Res> {
  factory $ThirdGrpCopyWith(ThirdGrp value, $Res Function(ThirdGrp) then) =
      _$ThirdGrpCopyWithImpl<$Res>;
}

/// @nodoc
class _$ThirdGrpCopyWithImpl<$Res> implements $ThirdGrpCopyWith<$Res> {
  _$ThirdGrpCopyWithImpl(this._value, this._then);

  final ThirdGrp _value;
  // ignore: unused_field
  final $Res Function(ThirdGrp) _then;
}

/// @nodoc
abstract class $Third1SegmentCopyWith<$Res> {
  factory $Third1SegmentCopyWith(
          Third1Segment value, $Res Function(Third1Segment) then) =
      _$Third1SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$Third1SegmentCopyWithImpl<$Res> extends _$ThirdGrpCopyWithImpl<$Res>
    implements $Third1SegmentCopyWith<$Res> {
  _$Third1SegmentCopyWithImpl(
      Third1Segment _value, $Res Function(Third1Segment) _then)
      : super(_value, (v) => _then(v as Third1Segment));

  @override
  Third1Segment get _value => super._value as Third1Segment;
}

/// @nodoc
@JsonSerializable()
class _$Third1Segment extends Third1Segment {
  _$Third1Segment({String? $type})
      : $type = $type ?? 'third1',
        super._();

  factory _$Third1Segment.fromJson(Map<String, dynamic> json) =>
      _$$Third1SegmentFromJson(json);

  @JsonKey(name: '_third')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Third1Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() third1,
    required TResult Function() third2,
  }) {
    return third1();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? third1,
    TResult Function()? third2,
  }) {
    return third1?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? third1,
    TResult Function()? third2,
    required TResult orElse(),
  }) {
    if (third1 != null) {
      return third1();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Third1Segment value) third1,
    required TResult Function(Third2Segment value) third2,
  }) {
    return third1(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Third1Segment value)? third1,
    TResult Function(Third2Segment value)? third2,
  }) {
    return third1?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Third1Segment value)? third1,
    TResult Function(Third2Segment value)? third2,
    required TResult orElse(),
  }) {
    if (third1 != null) {
      return third1(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$Third1SegmentToJson(this);
  }
}

abstract class Third1Segment extends ThirdGrp {
  factory Third1Segment() = _$Third1Segment;
  Third1Segment._() : super._();

  factory Third1Segment.fromJson(Map<String, dynamic> json) =
      _$Third1Segment.fromJson;
}

/// @nodoc
abstract class $Third2SegmentCopyWith<$Res> {
  factory $Third2SegmentCopyWith(
          Third2Segment value, $Res Function(Third2Segment) then) =
      _$Third2SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$Third2SegmentCopyWithImpl<$Res> extends _$ThirdGrpCopyWithImpl<$Res>
    implements $Third2SegmentCopyWith<$Res> {
  _$Third2SegmentCopyWithImpl(
      Third2Segment _value, $Res Function(Third2Segment) _then)
      : super(_value, (v) => _then(v as Third2Segment));

  @override
  Third2Segment get _value => super._value as Third2Segment;
}

/// @nodoc
@JsonSerializable()
class _$Third2Segment extends Third2Segment {
  _$Third2Segment({String? $type})
      : $type = $type ?? 'third2',
        super._();

  factory _$Third2Segment.fromJson(Map<String, dynamic> json) =>
      _$$Third2SegmentFromJson(json);

  @JsonKey(name: '_third')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Third2Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() third1,
    required TResult Function() third2,
  }) {
    return third2();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? third1,
    TResult Function()? third2,
  }) {
    return third2?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? third1,
    TResult Function()? third2,
    required TResult orElse(),
  }) {
    if (third2 != null) {
      return third2();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Third1Segment value) third1,
    required TResult Function(Third2Segment value) third2,
  }) {
    return third2(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Third1Segment value)? third1,
    TResult Function(Third2Segment value)? third2,
  }) {
    return third2?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Third1Segment value)? third1,
    TResult Function(Third2Segment value)? third2,
    required TResult orElse(),
  }) {
    if (third2 != null) {
      return third2(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$Third2SegmentToJson(this);
  }
}

abstract class Third2Segment extends ThirdGrp {
  factory Third2Segment() = _$Third2Segment;
  Third2Segment._() : super._();

  factory Third2Segment.fromJson(Map<String, dynamic> json) =
      _$Third2Segment.fromJson;
}
