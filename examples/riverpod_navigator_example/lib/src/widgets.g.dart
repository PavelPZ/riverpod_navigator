// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widgets.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

/// Note: *To make it less verbose, we use the functional_widget package to generate widgets.
/// See generated "widgets.g.dart"" file for details.*
/// Flutter app root
class AppRoot extends HookConsumerWidget {
  /// Note: *To make it less verbose, we use the functional_widget package to generate widgets.
  /// See generated "widgets.g.dart"" file for details.*
  /// Flutter app root
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => appRoot(_ref);
}

class HomeScreen extends HookConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      homeScreen(_ref, segment);
}

class BooksScreen extends HookConsumerWidget {
  const BooksScreen(this.segment, {Key? key}) : super(key: key);

  final BooksSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      booksScreen(_ref, segment);
}

class BookScreen extends HookConsumerWidget {
  const BookScreen(this.segment, {Key? key}) : super(key: key);

  final BookSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      bookScreen(_ref, segment);
}

class LinkHelper extends StatelessWidget {
  const LinkHelper({Key? key, required this.title, this.onPressed})
      : super(key: key);

  final String title;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext _context) =>
      linkHelper(title: title, onPressed: onPressed);
}

class PageHelper extends ConsumerWidget {
  const PageHelper({Key? key, required this.title, required this.buildChildren})
      : super(key: key);

  final String title;

  final List<Widget> Function(AppNavigator) buildChildren;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      pageHelper(_ref, title: title, buildChildren: buildChildren);
}
