// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_init.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => app(_ref);
}

class HomeScreen extends HookConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      homeScreen(_ref, segment);
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => profileTab(_ref);
}

class MoreTab extends ConsumerWidget {
  const MoreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => moreTab(_ref);
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen(this.segment, {Key? key}) : super(key: key);

  final ProfileSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      profileScreen(_ref, segment);
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen(this.segment, {Key? key}) : super(key: key);

  final MoreSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      moreScreen(_ref, segment);
}
