//************************************************ */
// EXAMPLE for https://github.com/PavelPZ/riverpod_navigator/issues/20
//************************************************ */
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs
part 'tab_init2.g.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final initPathStr = sharedPreferences.getString('homeSegment');
  runApp(
    ProviderScope(
      // home path and navigator constructor are required
      overrides: [
        ...riverpodNavigatorOverrides([HomeSegment()], AppNavigator.new, initPathStr: initPathStr),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}

class HomeSegment extends TypedSegment {
  const HomeSegment({this.tabId, this.profilePath, this.morePath});
  factory HomeSegment.decode(UrlPars pars) => HomeSegment(
        tabId: pars.getIntNull('tabId'),
        profilePath: pars.getStringNull('profilePath'),
        morePath: pars.getStringNull('morePath'),
      );

  final int? tabId;
  final String? profilePath;
  final String? morePath;

  @override
  void encode(UrlPars pars) => pars.setInt('tabId', tabId).setString('profilePath', profilePath).setString('morePath', morePath);
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          routes: [
            RRoute<HomeSegment>(
              'home',
              HomeSegment.decode,
              HomeScreen.new,
            ),
            RRoute<ProfileSegment>(
              'profile',
              ProfileSegment.decode,
              ProfileScreen.new,
            ),
            RRoute<MoreSegment>(
              'more',
              MoreSegment.decode,
              MoreScreen.new,
            ),
          ],
          progressIndicatorBuilder: () => const SpinKitCircle(color: Colors.blue, size: 45),
          onPathChanged: (path) => ref.read(sharedPreferencesProvider).setString('homeSegment', path2String(path)),
        );

  void changeTab(int tabId) {
    final homeSegment = getNavigationStack().last as HomeSegment;
    navigate([HomeSegment(tabId: tabId, profilePath: homeSegment.profilePath, morePath: homeSegment.morePath)]);
  }

  void changeProfilePath(TypedPath profilePath) {
    final homeSegment = getNavigationStack().last as HomeSegment;
    navigate([HomeSegment(tabId: homeSegment.tabId, profilePath: path2String(profilePath), morePath: homeSegment.morePath)]);
  }

  void changeMorePath(TypedPath morePath) {
    final homeSegment = getNavigationStack().last as HomeSegment;
    navigate([HomeSegment(tabId: homeSegment.tabId, profilePath: homeSegment.profilePath, morePath: path2String(morePath))]);
  }
}

@cwidget
Widget app(WidgetRef ref) {
  final navigator = ref.read(navigatorProvider) as AppNavigator;
  return MaterialApp.router(
    title: 'Riverpod Navigator Example',
    routerDelegate: navigator.routerDelegate,
    routeInformationParser: navigator.routeInformationParser,
    debugShowCheckedModeBanner: false,
  );
}

@hcwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) {
  final navigator = ref.read(navigatorProvider) as AppNavigator;

  final tinkerMixin = useSingleTickerProvider();
  final tabController = useMemoized(() => TabController(vsync: tinkerMixin, length: 2, initialIndex: segment.tabId ?? 0), []);
  tabController.addListener(() => navigator.changeTab(tabController.index));

  // read HomeSegment:
  final homeSegment = ref.read(navigationStackProvider).last as HomeSegment;

  return Scaffold(
    appBar: AppBar(
      title: Text('Home'),
      // https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples
      // https://codewithandrea.com/articles/flutter-tab-bar-navigation/
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'Profile'),
          Tab(text: 'More'),
        ],
        onTap: (_) {},
      ),
    ),
    body: TabBarView(
      controller: tabController,
      children: [
        ProviderScope(
          overrides: riverpodNavigatorOverrides(
            homeSegment.profilePath == null ? [ProfileSegment()] : string2Path(homeSegment.profilePath)!,
            (ref) => NestedNavigator.forProfile(ref, navigator),
          ),
          child: ProfileTab(),
        ),
        ProviderScope(
          overrides: riverpodNavigatorOverrides(
            homeSegment.morePath == null ? [MoreSegment()] : string2Path(homeSegment.morePath)!,
            (ref) => NestedNavigator.forMore(ref, navigator),
          ),
          child: MoreTab(),
        ),
      ],
    ),
  );
}
// ============== NESTED navigators

class ProfileSegment extends TypedSegment {
  const ProfileSegment({this.counter = 0});
  factory ProfileSegment.decode(UrlPars pars) => ProfileSegment(counter: pars.getIntNull('counter') ?? 0);
  final int counter;
  @override
  void encode(UrlPars pars) => pars.setInt('counter', counter);
}

class MoreSegment extends TypedSegment {
  const MoreSegment({this.counter = 0});
  factory MoreSegment.decode(UrlPars pars) => MoreSegment(counter: pars.getIntNull('counter') ?? 0);
  final int counter;
  @override
  void encode(UrlPars pars) => pars.setInt('counter', counter);
}

class NestedNavigator extends RNavigator {
  NestedNavigator.forProfile(Ref ref, this.rootNavigator) : super.nested(ref);
  NestedNavigator.forMore(Ref ref, this.rootNavigator) : super.nested(ref);
  final AppNavigator rootNavigator;
}

@cwidget
Widget profileTab(WidgetRef ref) => Router(routerDelegate: (ref.read(navigatorProvider) as NestedNavigator).routerDelegate);

@cwidget
Widget moreTab(WidgetRef ref) => Router(routerDelegate: (ref.read(navigatorProvider) as NestedNavigator).routerDelegate);

@cwidget
Widget profileScreen(WidgetRef ref, ProfileSegment segment) {
  final navig = ref.read(navigatorProvider) as NestedNavigator;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('PROFILE SCREEN'),
        SizedBox(height: 20),
        ElevatedButton(
            onPressed: () => navig.rootNavigator.changeProfilePath([ProfileSegment(counter: segment.counter + 1)]),
            child: Text('Counter: ${segment.counter}')),
        SizedBox(height: 20),
        Text(getDeepUrl(ref, tabId: 0)),
      ],
    ),
  );
}

@cwidget
Widget moreScreen(WidgetRef ref, MoreSegment segment) {
  final navig = ref.read(navigatorProvider) as NestedNavigator;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('MORE SCREEN'),
        SizedBox(height: 20),
        ElevatedButton(
            onPressed: () => navig.rootNavigator.changeMorePath([MoreSegment(counter: segment.counter + 1)]),
            child: Text('Counter: ${segment.counter}')),
        SizedBox(height: 20),
        Text(getDeepUrl(ref, tabId: 1)),
      ],
    ),
  );
}

String getDeepUrl(WidgetRef ref, {required int tabId}) => path2String([
      HomeSegment(
        tabId: tabId,
        profilePath: tabId == 0 ? path2String(ref.read(navigationStackProvider)) : null,
        morePath: tabId == 1 ? path2String(ref.read(navigationStackProvider)) : null,
      )
    ]);
