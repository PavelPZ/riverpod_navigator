// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'login_flow.dart';

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
    case 'book':
      return BookSegment.fromJson(json);
    case 'login':
      return LoginSegment.fromJson(json);

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

  BookSegment book({required int id}) {
    return BookSegment(
      id: id,
    );
  }

  LoginSegment login({String? loggedUrl, String? canceledUrl}) {
    return LoginSegment(
      loggedUrl: loggedUrl,
      canceledUrl: canceledUrl,
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
    required TResult Function(int id) book,
    required TResult Function(String? loggedUrl, String? canceledUrl) login,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(String? loggedUrl, String? canceledUrl)? login,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(LoginSegment value) login,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(LoginSegment value)? login,
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
    required TResult Function(int id) book,
    required TResult Function(String? loggedUrl, String? canceledUrl) login,
  }) {
    return home();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(String? loggedUrl, String? canceledUrl)? login,
  }) {
    return home?.call();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(LoginSegment value) login,
  }) {
    return home(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(LoginSegment value)? login,
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
abstract class $BookSegmentCopyWith<$Res> {
  factory $BookSegmentCopyWith(
          BookSegment value, $Res Function(BookSegment) then) =
      _$BookSegmentCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class _$BookSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $BookSegmentCopyWith<$Res> {
  _$BookSegmentCopyWithImpl(
      BookSegment _value, $Res Function(BookSegment) _then)
      : super(_value, (v) => _then(v as BookSegment));

  @override
  BookSegment get _value => super._value as BookSegment;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(BookSegment(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookSegment extends BookSegment {
  _$BookSegment({required this.id, String? $type})
      : $type = $type ?? 'book',
        super._();

  factory _$BookSegment.fromJson(Map<String, dynamic> json) =>
      _$$BookSegmentFromJson(json);

  @override
  final int id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BookSegment &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  $BookSegmentCopyWith<BookSegment> get copyWith =>
      _$BookSegmentCopyWithImpl<BookSegment>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() home,
    required TResult Function(int id) book,
    required TResult Function(String? loggedUrl, String? canceledUrl) login,
  }) {
    return book(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(String? loggedUrl, String? canceledUrl)? login,
  }) {
    return book?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(LoginSegment value) login,
  }) {
    return book(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(LoginSegment value)? login,
  }) {
    return book?.call(this);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookSegmentToJson(this);
  }
}

abstract class BookSegment extends Segments {
  factory BookSegment({required int id}) = _$BookSegment;
  BookSegment._() : super._();

  factory BookSegment.fromJson(Map<String, dynamic> json) =
      _$BookSegment.fromJson;

  int get id;
  @JsonKey(ignore: true)
  $BookSegmentCopyWith<BookSegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginSegmentCopyWith<$Res> {
  factory $LoginSegmentCopyWith(
          LoginSegment value, $Res Function(LoginSegment) then) =
      _$LoginSegmentCopyWithImpl<$Res>;
  $Res call({String? loggedUrl, String? canceledUrl});
}

/// @nodoc
class _$LoginSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $LoginSegmentCopyWith<$Res> {
  _$LoginSegmentCopyWithImpl(
      LoginSegment _value, $Res Function(LoginSegment) _then)
      : super(_value, (v) => _then(v as LoginSegment));

  @override
  LoginSegment get _value => super._value as LoginSegment;

  @override
  $Res call({
    Object? loggedUrl = freezed,
    Object? canceledUrl = freezed,
  }) {
    return _then(LoginSegment(
      loggedUrl: loggedUrl == freezed
          ? _value.loggedUrl
          : loggedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      canceledUrl: canceledUrl == freezed
          ? _value.canceledUrl
          : canceledUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginSegment extends LoginSegment {
  _$LoginSegment({this.loggedUrl, this.canceledUrl, String? $type})
      : $type = $type ?? 'login',
        super._();

  factory _$LoginSegment.fromJson(Map<String, dynamic> json) =>
      _$$LoginSegmentFromJson(json);

  @override
  final String? loggedUrl;
  @override
  final String? canceledUrl;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LoginSegment &&
            const DeepCollectionEquality().equals(other.loggedUrl, loggedUrl) &&
            const DeepCollectionEquality()
                .equals(other.canceledUrl, canceledUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(loggedUrl),
      const DeepCollectionEquality().hash(canceledUrl));

  @JsonKey(ignore: true)
  @override
  $LoginSegmentCopyWith<LoginSegment> get copyWith =>
      _$LoginSegmentCopyWithImpl<LoginSegment>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() home,
    required TResult Function(int id) book,
    required TResult Function(String? loggedUrl, String? canceledUrl) login,
  }) {
    return login(loggedUrl, canceledUrl);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(String? loggedUrl, String? canceledUrl)? login,
  }) {
    return login?.call(loggedUrl, canceledUrl);
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(LoginSegment value) login,
  }) {
    return login(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(LoginSegment value)? login,
  }) {
    return login?.call(this);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginSegmentToJson(this);
  }
}

abstract class LoginSegment extends Segments {
  factory LoginSegment({String? loggedUrl, String? canceledUrl}) =
      _$LoginSegment;
  LoginSegment._() : super._();

  factory LoginSegment.fromJson(Map<String, dynamic> json) =
      _$LoginSegment.fromJson;

  String? get loggedUrl;
  String? get canceledUrl;
  @JsonKey(ignore: true)
  $LoginSegmentCopyWith<LoginSegment> get copyWith =>
      throw _privateConstructorUsedError;
}
