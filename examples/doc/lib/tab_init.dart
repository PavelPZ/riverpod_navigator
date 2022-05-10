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
part 'tab_init.g.dart';

class NestedUrls {
  NestedUrls(this.sharedPreferences);
  final SharedPreferences sharedPreferences;
  void setProfilePath(String value) => sharedPreferences.setString('profilePath', value);
  void setMorePath(String value) => sharedPreferences.setString('morePath', value);
  void setTabId(int value) => sharedPreferences.setInt('tabId', value);
}

final nestedUrlsProvider = Provider<NestedUrls>((_) => throw UnimplementedError());

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final homeSegment = HomeSegment(
    tabId: sharedPreferences.getInt('tabId'),
    profilePath: sharedPreferences.getString('profilePath'),
    morePath: sharedPreferences.getString('morePath'),
  );
  runApp(
    ProviderScope(
      // home path and navigator constructor are required
      overrides: [
        ...riverpodNavigatorOverrides([homeSegment], AppNavigator.new),
        nestedUrlsProvider.overrideWithValue(NestedUrls(sharedPreferences)),
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
          [
            RRoute<HomeSegment>(
              'home',
              HomeSegment.decode,
              HomeScreen.new,
            ),
          ],
          progressIndicatorBuilder: () => const SpinKitCircle(color: Colors.blue, size: 45),
        );
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
  final tinkerMixin = useSingleTickerProvider();
  final tabController = useMemoized(() => TabController(vsync: tinkerMixin, length: 2, initialIndex: segment.tabId ?? 0), []);
  tabController.addListener(() => ref.read(nestedUrlsProvider).setTabId(tabController.index));

  // read HomeSegment:
  final homeSegment = ref.read(navigationStackProvider).last as HomeSegment;

  return Scaffold(
    appBar: AppBar(
      title: Text('Home'),
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'Profile'),
          Tab(text: 'More'),
        ],
      ),
    ),
    body: TabBarView(
      controller: tabController,
      children: [
        ProviderScope(
          overrides: riverpodNavigatorOverrides(
            [ProfileSegment()],
            NestedNavigator.forProfile,
            initPathAsString: homeSegment.profilePath,
          ),
          child: ProfileTab(),
        ),
        ProviderScope(
          overrides: riverpodNavigatorOverrides(
            [MoreSegment()],
            NestedNavigator.forMore,
            initPathAsString: homeSegment.morePath,
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
  const MoreSegment();
  // ignore: avoid_unused_constructor_parameters
  factory MoreSegment.decode(UrlPars pars) => MoreSegment();
}

class NestedNavigator extends RNavigator {
  NestedNavigator.forProfile(Ref ref)
      : super(
          ref,
          [
            RRoute<ProfileSegment>(
              'profile',
              ProfileSegment.decode,
              ProfileScreen.new,
            ),
          ],
          onPathChanged: (path) => ref.read(nestedUrlsProvider).setProfilePath(path2String(path)),
        );

  NestedNavigator.forMore(Ref ref)
      : super(
          ref,
          [
            RRoute<MoreSegment>(
              'more',
              MoreSegment.decode,
              MoreScreen.new,
            ),
          ],
          onPathChanged: (path) => ref.read(nestedUrlsProvider).setMorePath(path2String(path)),
        );

  String getDeepUrl({required int tabId}) => path2String([
        HomeSegment(
          tabId: tabId,
          profilePath: tabId == 0 ? path2String(ref.read(navigationStackProvider)) : null,
          morePath: tabId == 1 ? path2String(ref.read(navigationStackProvider)) : null,
        )
      ]);
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
        ElevatedButton(onPressed: () => navig.navigate([ProfileSegment(counter: segment.counter + 1)]), child: Text('Counter: ${segment.counter}')),
        SizedBox(height: 20),
        Text(navig.getDeepUrl(tabId: 0)),
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
        Text(navig.getDeepUrl(tabId: 1)),
      ],
    ),
  );
}
