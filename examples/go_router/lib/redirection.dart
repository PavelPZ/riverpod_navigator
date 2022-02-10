import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'data.dart' as d;

part 'redirection.freezed.dart';
part 'redirection.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: [
          riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
        ],
        child: const App(),
      ),
    );

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.login() = LoginSegment;
  factory Segments.home() = HomeSegment;
  factory Segments.family({required String fid}) = FamilySegment;
  factory Segments.person({required String fid, required String pid}) = PersonSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          dependsOn: [loginInfoProvider],
          fromJson: Segments.fromJson,
          screenBuilder: (segment) => (segment as Segments).map(
            login: LoginScreen.new,
            home: HomeScreen.new,
            family: FamilyScreen.new,
            person: PersonScreen.new,
          ),
        );

  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath) {
    final loginInfo = ref.read(loginInfoProvider.notifier);

    final loggedIn = loginInfo.state.isNotEmpty;
    final loggingIn = currentTypedPath.any((segment) => segment is LoginSegment);
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
  final navigator = ref.read(riverpodNavigatorProvider);
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
  final navigator = ref.read(riverpodNavigatorProvider);
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
  final navigator = ref.read(riverpodNavigatorProvider);
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
