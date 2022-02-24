// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_flow.dart';

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

class LoginScreen extends StatelessWidget {
  const LoginScreen(this.segment, {Key? key}) : super(key: key);

  final LoginSegment segment;

  @override
  Widget build(BuildContext _context) => loginScreen(segment);
}

class PageHelper extends ConsumerWidget {
  const PageHelper(
      {Key? key,
      required this.title,
      required this.segment,
      required this.buildChildren,
      this.isLoginPage})
      : super(key: key);

  final String title;

  final TypedSegment segment;

  final List<Widget> Function(AppNavigator) buildChildren;

  final bool? isLoginPage;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => pageHelper(_ref,
      title: title,
      segment: segment,
      buildChildren: buildChildren,
      isLoginPage: isLoginPage);
}
