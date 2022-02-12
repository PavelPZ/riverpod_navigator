// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'main.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Segments _$SegmentsFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'page1':
      return Page1Segment.fromJson(json);
    case 'page2':
      return Page2Segment.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Segments',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
class _$SegmentsTearOff {
  const _$SegmentsTearOff();

  Page1Segment page1() {
    return Page1Segment();
  }

  Page2Segment page2() {
    return Page2Segment();
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
    required TResult Function() page1,
    required TResult Function() page2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? page1,
    TResult Function()? page2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? page1,
    TResult Function()? page2,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Page1Segment value) page1,
    required TResult Function(Page2Segment value) page2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Page1Segment value)? page1,
    TResult Function(Page2Segment value)? page2,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Page1Segment value)? page1,
    TResult Function(Page2Segment value)? page2,
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
abstract class $Page1SegmentCopyWith<$Res> {
  factory $Page1SegmentCopyWith(
          Page1Segment value, $Res Function(Page1Segment) then) =
      _$Page1SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$Page1SegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $Page1SegmentCopyWith<$Res> {
  _$Page1SegmentCopyWithImpl(
      Page1Segment _value, $Res Function(Page1Segment) _then)
      : super(_value, (v) => _then(v as Page1Segment));

  @override
  Page1Segment get _value => super._value as Page1Segment;
}

/// @nodoc
@JsonSerializable()
class _$Page1Segment extends Page1Segment {
  _$Page1Segment({String? $type})
      : $type = $type ?? 'page1',
        super._();

  factory _$Page1Segment.fromJson(Map<String, dynamic> json) =>
      _$$Page1SegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Page1Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() page1,
    required TResult Function() page2,
  }) {
    return page1();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? page1,
    TResult Function()? page2,
  }) {
    return page1?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? page1,
    TResult Function()? page2,
    required TResult orElse(),
  }) {
    if (page1 != null) {
      return page1();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Page1Segment value) page1,
    required TResult Function(Page2Segment value) page2,
  }) {
    return page1(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Page1Segment value)? page1,
    TResult Function(Page2Segment value)? page2,
  }) {
    return page1?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Page1Segment value)? page1,
    TResult Function(Page2Segment value)? page2,
    required TResult orElse(),
  }) {
    if (page1 != null) {
      return page1(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$Page1SegmentToJson(this);
  }
}

abstract class Page1Segment extends Segments {
  factory Page1Segment() = _$Page1Segment;
  Page1Segment._() : super._();

  factory Page1Segment.fromJson(Map<String, dynamic> json) =
      _$Page1Segment.fromJson;
}

/// @nodoc
abstract class $Page2SegmentCopyWith<$Res> {
  factory $Page2SegmentCopyWith(
          Page2Segment value, $Res Function(Page2Segment) then) =
      _$Page2SegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$Page2SegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $Page2SegmentCopyWith<$Res> {
  _$Page2SegmentCopyWithImpl(
      Page2Segment _value, $Res Function(Page2Segment) _then)
      : super(_value, (v) => _then(v as Page2Segment));

  @override
  Page2Segment get _value => super._value as Page2Segment;
}

/// @nodoc
@JsonSerializable()
class _$Page2Segment extends Page2Segment {
  _$Page2Segment({String? $type})
      : $type = $type ?? 'page2',
        super._();

  factory _$Page2Segment.fromJson(Map<String, dynamic> json) =>
      _$$Page2SegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Page2Segment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() page1,
    required TResult Function() page2,
  }) {
    return page2();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? page1,
    TResult Function()? page2,
  }) {
    return page2?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? page1,
    TResult Function()? page2,
    required TResult orElse(),
  }) {
    if (page2 != null) {
      return page2();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Page1Segment value) page1,
    required TResult Function(Page2Segment value) page2,
  }) {
    return page2(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Page1Segment value)? page1,
    TResult Function(Page2Segment value)? page2,
  }) {
    return page2?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Page1Segment value)? page1,
    TResult Function(Page2Segment value)? page2,
    required TResult orElse(),
  }) {
    if (page2 != null) {
      return page2(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$Page2SegmentToJson(this);
  }
}

abstract class Page2Segment extends Segments {
  factory Page2Segment() = _$Page2Segment;
  Page2Segment._() : super._();

  factory Page2Segment.fromJson(Map<String, dynamic> json) =
      _$Page2Segment.fromJson;
}
