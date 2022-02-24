import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'data.dart' as d;

part 'redirection.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new, dependsOn: [loginInfoProvider]),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment {
  static HomeSegment fromSegmentMap(SegmentMap map) => HomeSegment();
}

class LoginSegment extends TypedSegment {
  static LoginSegment fromSegmentMap(SegmentMap map) => LoginSegment();
}

class FamilySegment extends TypedSegment {
  const FamilySegment({required this.fid});
  final String fid;

  @override
  void toSegmentMap(SegmentMap map) => map.setString('fid', fid);
  static FamilySegment fromSegmentMap(SegmentMap map) => FamilySegment(fid: map.getString('fid'));
}

class PersonSegment extends TypedSegment {
  const PersonSegment({required this.fid, required this.pid});
  final String fid;
  final String pid;

  @override
  void toSegmentMap(SegmentMap map) => map.setString('fid', fid)..setString('pid', pid);
  static PersonSegment fromSegmentMap(SegmentMap map) => PersonSegment(fid: map.getString('fid'), pid: map.getString('pid'));
}

/// helper extension for screens
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

/// helper extension for test
extension RefApp on Ref {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(HomeSegment.fromSegmentMap, HomeScreen.new),
            RRoute<LoginSegment>(LoginSegment.fromSegmentMap, LoginScreen.new),
            RRoute<FamilySegment>(FamilySegment.fromSegmentMap, FamilyScreen.new),
            RRoute<PersonSegment>(PersonSegment.fromSegmentMap, PersonScreen.new),
          ],
        );

  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath) {
    final loginInfo = ref.read(loginInfoProvider.notifier);

    final loggedIn = loginInfo.state.isNotEmpty;
    final loggingIn = ongoingPath.any((segment) => segment is LoginSegment);
    if (!loggedIn && !loggingIn) return [LoginSegment()];
    if (loggedIn && loggingIn) return [HomeSegment()];
    return ongoingPath;
  }

  static const title = 'GoRouter Example: Redirection';
}

final loginInfoProvider = StateProvider<String>((_) => '');
final familiesProvider = Provider<List<d.Family>>((_) => d.Families.data);

@cwidget
Widget app(WidgetRef ref) {
  final navigator = ref.navigator;
  return MaterialApp.router(
    title: AppNavigator.title,
    routerDelegate: navigator.routerDelegate,
    routeInformationParser: RouteInformationParserImpl(navigator.pathParser),
    debugShowCheckedModeBanner: false,
  );
}

@cwidget
Widget loginScreen(WidgetRef ref, LoginSegment segment) {
  final loginInfo = ref.read(loginInfoProvider.notifier);
  return Scaffold(
    appBar: AppBar(title: const Text(AppNavigator.title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => loginInfo.state = 'test-user',
            child: const Text('Login'),
          ),
        ],
      ),
    ),
  );
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) {
  final info = ref.read(loginInfoProvider.notifier);
  final families = ref.read(familiesProvider);
  final navigator = ref.navigator;
  return Scaffold(
    appBar: AppBar(
      title: const Text(AppNavigator.title),
      actions: [
        IconButton(
          onPressed: () => info.state = '',
          tooltip: 'Logout: ${info.state}',
          icon: const Icon(Icons.logout),
        )
      ],
    ),
    body: ListView(
      children: [
        for (final f in families)
          ListTile(
            title: Text(f.name),
            onTap: () => navigator.navigate([HomeSegment(), FamilySegment(fid: f.id)]),
          )
      ],
    ),
  );
}

@cwidget
Widget familyScreen(WidgetRef ref, FamilySegment segment) {
  final family = d.Families.family(segment.fid);
  final navigator = ref.navigator;
  return Scaffold(
    appBar: AppBar(title: Text(family.name)),
    body: ListView(
      children: [
        for (final p in family.people)
          ListTile(
            title: Text(p.name),
            onTap: () => navigator.navigate([HomeSegment(), FamilySegment(fid: segment.fid), PersonSegment(fid: segment.fid, pid: p.id)]),
          ),
      ],
    ),
  );
}

@cwidget
Widget personScreen(WidgetRef ref, PersonSegment segment) {
  final family = d.Families.family(segment.fid);
  final person = family.person(segment.pid);
  return Scaffold(
    appBar: AppBar(title: Text(person.name)),
    body: Text('${person.name} ${family.name} is ${person.age} years old'),
  );
}
