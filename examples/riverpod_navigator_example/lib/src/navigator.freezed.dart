// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'navigator.dart';

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
    case 'books':
      return BooksSegment.fromJson(json);
    case 'book':
      return BookSegment.fromJson(json);

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

  BooksSegment books() {
    return BooksSegment();
  }

  BookSegment book({required int id}) {
    return BookSegment(
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
    required TResult Function() books,
    required TResult Function(int id) book,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BooksSegment value) books,
    required TResult Function(BookSegment value) book,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
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
    required TResult Function() books,
    required TResult Function(int id) book,
  }) {
    return home();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
  }) {
    return home?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
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
    required TResult Function(HomeSegment value) home,
    required TResult Function(BooksSegment value) books,
    required TResult Function(BookSegment value) book,
  }) {
    return home(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
  }) {
    return home?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
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
abstract class $BooksSegmentCopyWith<$Res> {
  factory $BooksSegmentCopyWith(
          BooksSegment value, $Res Function(BooksSegment) then) =
      _$BooksSegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$BooksSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $BooksSegmentCopyWith<$Res> {
  _$BooksSegmentCopyWithImpl(
      BooksSegment _value, $Res Function(BooksSegment) _then)
      : super(_value, (v) => _then(v as BooksSegment));

  @override
  BooksSegment get _value => super._value as BooksSegment;
}

/// @nodoc
@JsonSerializable()
class _$BooksSegment extends BooksSegment {
  _$BooksSegment({String? $type})
      : $type = $type ?? 'books',
        super._();

  factory _$BooksSegment.fromJson(Map<String, dynamic> json) =>
      _$$BooksSegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is BooksSegment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() home,
    required TResult Function() books,
    required TResult Function(int id) book,
  }) {
    return books();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
  }) {
    return books?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
    required TResult orElse(),
  }) {
    if (books != null) {
      return books();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BooksSegment value) books,
    required TResult Function(BookSegment value) book,
  }) {
    return books(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
  }) {
    return books?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
    required TResult orElse(),
  }) {
    if (books != null) {
      return books(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BooksSegmentToJson(this);
  }
}

abstract class BooksSegment extends Segments {
  factory BooksSegment() = _$BooksSegment;
  BooksSegment._() : super._();

  factory BooksSegment.fromJson(Map<String, dynamic> json) =
      _$BooksSegment.fromJson;
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
    required TResult Function() books,
    required TResult Function(int id) book,
  }) {
    return book(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
  }) {
    return book?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function()? books,
    TResult Function(int id)? book,
    required TResult orElse(),
  }) {
    if (book != null) {
      return book(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BooksSegment value) books,
    required TResult Function(BookSegment value) book,
  }) {
    return book(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
  }) {
    return book?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BooksSegment value)? books,
    TResult Function(BookSegment value)? book,
    required TResult orElse(),
  }) {
    if (book != null) {
      return book(this);
    }
    return orElse();
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
