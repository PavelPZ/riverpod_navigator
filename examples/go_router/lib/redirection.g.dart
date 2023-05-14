// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redirection.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext _context,
    WidgetRef _ref,
  ) =>
      app(_ref);
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen(
    this.segment, {
    Key? key,
  }) : super(key: key);

  final LoginSegment segment;

  @override
  Widget build(
    BuildContext _context,
    WidgetRef _ref,
  ) =>
      loginScreen(
        _ref,
        segment,
      );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(
    this.segment, {
    Key? key,
  }) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(
    BuildContext _context,
    WidgetRef _ref,
  ) =>
      homeScreen(
        _ref,
        segment,
      );
}

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen(
    this.segment, {
    Key? key,
  }) : super(key: key);

  final FamilySegment segment;

  @override
  Widget build(
    BuildContext _context,
    WidgetRef _ref,
  ) =>
      familyScreen(
        _ref,
        segment,
      );
}

class PersonScreen extends ConsumerWidget {
  const PersonScreen(
    this.segment, {
    Key? key,
  }) : super(key: key);

  final PersonSegment segment;

  @override
  Widget build(
    BuildContext _context,
    WidgetRef _ref,
  ) =>
      personScreen(
        _ref,
        segment,
      );
}
