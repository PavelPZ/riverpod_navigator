// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'async.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Segments _$SegmentsFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'home':
      return HomeSegment.fromJson(json);
    case 'page':
      return PageSegment.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Segments',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
class _$SegmentsTearOff {
  const _$SegmentsTearOff();

  HomeSegment home() {
    return HomeSegment();
  }

  PageSegment page({required int id}) {
    return PageSegment(
      id: id,
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
    required TResult Function() home,
    required TResult Function(int id) page,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? page,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(PageSegment value) page,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(PageSegment value)? page,
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
    required TResult Function() home,
    required TResult Function(int id) page,
  }) {
    return home();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? page,
  }) {
    return home?.call();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(PageSegment value) page,
  }) {
    return home(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(PageSegment value)? page,
  }) {
    return home?.call(this);
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
abstract class $PageSegmentCopyWith<$Res> {
  factory $PageSegmentCopyWith(
          PageSegment value, $Res Function(PageSegment) then) =
      _$PageSegmentCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class _$PageSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $PageSegmentCopyWith<$Res> {
  _$PageSegmentCopyWithImpl(
      PageSegment _value, $Res Function(PageSegment) _then)
      : super(_value, (v) => _then(v as PageSegment));

  @override
  PageSegment get _value => super._value as PageSegment;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(PageSegment(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PageSegment extends PageSegment {
  _$PageSegment({required this.id, String? $type})
      : $type = $type ?? 'page',
        super._();

  factory _$PageSegment.fromJson(Map<String, dynamic> json) =>
      _$$PageSegmentFromJson(json);

  @override
  final int id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PageSegment &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  $PageSegmentCopyWith<PageSegment> get copyWith =>
      _$PageSegmentCopyWithImpl<PageSegment>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() home,
    required TResult Function(int id) page,
  }) {
    return page(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? page,
  }) {
    return page?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(PageSegment value) page,
  }) {
    return page(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(PageSegment value)? page,
  }) {
    return page?.call(this);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PageSegmentToJson(this);
  }
}

abstract class PageSegment extends Segments {
  factory PageSegment({required int id}) = _$PageSegment;
  PageSegment._() : super._();

  factory PageSegment.fromJson(Map<String, dynamic> json) =
      _$PageSegment.fromJson;

  int get id;
  @JsonKey(ignore: true)
  $PageSegmentCopyWith<PageSegment> get copyWith =>
      throw _privateConstructorUsedError;
}