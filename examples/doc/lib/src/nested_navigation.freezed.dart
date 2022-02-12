// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'nested_navigation.dart';

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
    case 'author':
      return AuthorSegment.fromJson(json);
    case 'booksAuthors':
      return BooksAuthorsSegment.fromJson(json);

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

  AuthorSegment author({required int id}) {
    return AuthorSegment(
      id: id,
    );
  }

  BooksAuthorsSegment booksAuthors() {
    return BooksAuthorsSegment();
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
    required TResult Function(int id) author,
    required TResult Function() booksAuthors,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(AuthorSegment value) author,
    required TResult Function(BooksAuthorsSegment value) booksAuthors,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
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
    required TResult Function(int id) book,
    required TResult Function(int id) author,
    required TResult Function() booksAuthors,
  }) {
    return home();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
  }) {
    return home?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
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
    required TResult Function(BookSegment value) book,
    required TResult Function(AuthorSegment value) author,
    required TResult Function(BooksAuthorsSegment value) booksAuthors,
  }) {
    return home(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
  }) {
    return home?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
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
    required TResult Function(int id) author,
    required TResult Function() booksAuthors,
  }) {
    return book(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
  }) {
    return book?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
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
    required TResult Function(BookSegment value) book,
    required TResult Function(AuthorSegment value) author,
    required TResult Function(BooksAuthorsSegment value) booksAuthors,
  }) {
    return book(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
  }) {
    return book?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
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

/// @nodoc
abstract class $AuthorSegmentCopyWith<$Res> {
  factory $AuthorSegmentCopyWith(
          AuthorSegment value, $Res Function(AuthorSegment) then) =
      _$AuthorSegmentCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class _$AuthorSegmentCopyWithImpl<$Res> extends _$SegmentsCopyWithImpl<$Res>
    implements $AuthorSegmentCopyWith<$Res> {
  _$AuthorSegmentCopyWithImpl(
      AuthorSegment _value, $Res Function(AuthorSegment) _then)
      : super(_value, (v) => _then(v as AuthorSegment));

  @override
  AuthorSegment get _value => super._value as AuthorSegment;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(AuthorSegment(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorSegment extends AuthorSegment {
  _$AuthorSegment({required this.id, String? $type})
      : $type = $type ?? 'author',
        super._();

  factory _$AuthorSegment.fromJson(Map<String, dynamic> json) =>
      _$$AuthorSegmentFromJson(json);

  @override
  final int id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthorSegment &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  $AuthorSegmentCopyWith<AuthorSegment> get copyWith =>
      _$AuthorSegmentCopyWithImpl<AuthorSegment>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() home,
    required TResult Function(int id) book,
    required TResult Function(int id) author,
    required TResult Function() booksAuthors,
  }) {
    return author(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
  }) {
    return author?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
    required TResult orElse(),
  }) {
    if (author != null) {
      return author(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(AuthorSegment value) author,
    required TResult Function(BooksAuthorsSegment value) booksAuthors,
  }) {
    return author(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
  }) {
    return author?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
    required TResult orElse(),
  }) {
    if (author != null) {
      return author(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorSegmentToJson(this);
  }
}

abstract class AuthorSegment extends Segments {
  factory AuthorSegment({required int id}) = _$AuthorSegment;
  AuthorSegment._() : super._();

  factory AuthorSegment.fromJson(Map<String, dynamic> json) =
      _$AuthorSegment.fromJson;

  int get id;
  @JsonKey(ignore: true)
  $AuthorSegmentCopyWith<AuthorSegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BooksAuthorsSegmentCopyWith<$Res> {
  factory $BooksAuthorsSegmentCopyWith(
          BooksAuthorsSegment value, $Res Function(BooksAuthorsSegment) then) =
      _$BooksAuthorsSegmentCopyWithImpl<$Res>;
}

/// @nodoc
class _$BooksAuthorsSegmentCopyWithImpl<$Res>
    extends _$SegmentsCopyWithImpl<$Res>
    implements $BooksAuthorsSegmentCopyWith<$Res> {
  _$BooksAuthorsSegmentCopyWithImpl(
      BooksAuthorsSegment _value, $Res Function(BooksAuthorsSegment) _then)
      : super(_value, (v) => _then(v as BooksAuthorsSegment));

  @override
  BooksAuthorsSegment get _value => super._value as BooksAuthorsSegment;
}

/// @nodoc
@JsonSerializable()
class _$BooksAuthorsSegment extends BooksAuthorsSegment {
  _$BooksAuthorsSegment({String? $type})
      : $type = $type ?? 'booksAuthors',
        super._();

  factory _$BooksAuthorsSegment.fromJson(Map<String, dynamic> json) =>
      _$$BooksAuthorsSegmentFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is BooksAuthorsSegment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() home,
    required TResult Function(int id) book,
    required TResult Function(int id) author,
    required TResult Function() booksAuthors,
  }) {
    return booksAuthors();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
  }) {
    return booksAuthors?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? home,
    TResult Function(int id)? book,
    TResult Function(int id)? author,
    TResult Function()? booksAuthors,
    required TResult orElse(),
  }) {
    if (booksAuthors != null) {
      return booksAuthors();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeSegment value) home,
    required TResult Function(BookSegment value) book,
    required TResult Function(AuthorSegment value) author,
    required TResult Function(BooksAuthorsSegment value) booksAuthors,
  }) {
    return booksAuthors(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
  }) {
    return booksAuthors?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeSegment value)? home,
    TResult Function(BookSegment value)? book,
    TResult Function(AuthorSegment value)? author,
    TResult Function(BooksAuthorsSegment value)? booksAuthors,
    required TResult orElse(),
  }) {
    if (booksAuthors != null) {
      return booksAuthors(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BooksAuthorsSegmentToJson(this);
  }
}

abstract class BooksAuthorsSegment extends Segments {
  factory BooksAuthorsSegment() = _$BooksAuthorsSegment;
  BooksAuthorsSegment._() : super._();

  factory BooksAuthorsSegment.fromJson(Map<String, dynamic> json) =
      _$BooksAuthorsSegment.fromJson;
}
