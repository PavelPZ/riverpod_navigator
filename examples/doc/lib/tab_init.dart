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
  void setProfilePath(Uri value) => sharedPreferences.setString('profilePath', value.toString());
  void setMorePath(Uri value) => sharedPreferences.setString('morePath', value.toString());
  void setTabId(int value) => sharedPreferences.setInt('tabId', value);
}

final nestedUrlsProvider = Provider<NestedUrls>((_) => throw UnimplementedError());

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final pPath = sharedPreferences.getString('profilePath');
  final mPath = sharedPreferences.getString('morePath');
  final homeSegment = HomeSegment(
    tabId: sharedPreferences.getInt('tabId'),
    profilePath: pPath != null ? Uri.tryParse(pPath) : null,
    morePath: mPath != null ? Uri.tryParse(mPath) : null,
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
        profilePath: pars.getUriNull('profilePath'),
        morePath: pars.getUriNull('morePath'),
      );

  final int? tabId;
  final Uri? profilePath;
  final Uri? morePath;

  @override
  void encode(UrlPars pars) => pars.setInt('tabId', tabId).setUri('profilePath', profilePath).setUri('morePath', morePath);
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
            homeSegment.profilePath == null ? [ProfileSegment()] : uri2Path(homeSegment.profilePath!),
            NestedNavigator.forProfile,
          ),
          child: ProfileTab(),
        ),
        ProviderScope(
          overrides: riverpodNavigatorOverrides(
            homeSegment.morePath == null ? [MoreSegment()] : uri2Path(homeSegment.morePath!),
            NestedNavigator.forMore,
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
  NestedNavigator.forProfile(Ref ref)
      : super.nested(
          ref,
          onPathChanged: (path) => ref.read(nestedUrlsProvider).setProfilePath(path2Uri(path)),
        );

  NestedNavigator.forMore(Ref ref)
      : super.nested(
          ref,
          onPathChanged: (path) => ref.read(nestedUrlsProvider).setMorePath(path2Uri(path)),
        );
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
        Text(getDeepUrl(ref, tabId: 0).toString()),
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
        ElevatedButton(onPressed: () => navig.navigate([MoreSegment(counter: segment.counter + 1)]), child: Text('Counter: ${segment.counter}')),
        SizedBox(height: 20),
        Text(getDeepUrl(ref, tabId: 1).toString()),
      ],
    ),
  );
}

Uri getDeepUrl(WidgetRef ref, {required int tabId}) => path2Uri([
      HomeSegment(
        tabId: tabId,
        profilePath: tabId == 0 ? path2Uri(ref.read(navigationStackProvider)) : null,
        morePath: tabId == 1 ? path2Uri(ref.read(navigationStackProvider)) : null,
      )
    ]);
