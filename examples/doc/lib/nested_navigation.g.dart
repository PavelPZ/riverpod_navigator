// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nested_navigation.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => app(_ref);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      homeScreen(_ref, segment);
}

class BookScreen extends ConsumerWidget {
  const BookScreen(this.book, {Key? key}) : super(key: key);

  final BookSegment book;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => bookScreen(_ref, book);
}

class AuthorScreen extends ConsumerWidget {
  const AuthorScreen(this.book, {Key? key}) : super(key: key);

  final AuthorSegment book;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      authorScreen(_ref, book);
}

/// TabBarView screen
class BooksAuthorsScreen extends HookConsumerWidget {
  /// TabBarView screen
  const BooksAuthorsScreen(this.booksAuthorsSegment, {Key? key})
      : super(key: key);

  /// TabBarView screen
  final BooksAuthorsSegment booksAuthorsSegment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      booksAuthorsScreen(_ref, booksAuthorsSegment);
}

class BooksTab extends ConsumerWidget {
  const BooksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => booksTab(_ref);
}

class AuthorTab extends ConsumerWidget {
  const AuthorTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => authorTab(_ref);
}

class PageHelper<N extends RNavigator> extends ConsumerWidget {
  const PageHelper(
      {Key? key,
      required this.segment,
      required this.title,
      required this.buildChildren})
      : super(key: key);

  final TypedSegment segment;

  final String title;

  final List<Widget> Function(N) buildChildren;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => pageHelper<N>(_ref,
      segment: segment, title: title, buildChildren: buildChildren);
}
