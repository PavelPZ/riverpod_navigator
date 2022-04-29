//************************************************ */
// EXAMPLE for https://github.com/PavelPZ/riverpod_navigator/issues/20
//************************************************ */
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs
part 'tab_init.g.dart';

void main() => runApp(
      ProviderScope(
        // home path and navigator constructor are required
        overrides: riverpodNavigatorOverrides(const [HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

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

@hwidget
Widget homeScreen(HomeSegment segment) => Consumer(builder: (_, ref, ___) {
      // read main navigation stack and navigator:
      final homeSegment = ref.read(navigationStackProvider).last as HomeSegment;
      final navigator = ref.read(navigatorProvider);
      // decode profilePath and morePath (from string to typed path):
      final profilePath = navigator.pathParser.fromUrl(homeSegment.profilePath);
      final morePath = navigator.pathParser.fromUrl(homeSegment.morePath);
      return DefaultTabController(
        initialIndex: homeSegment.tabId ?? 0,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Home'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Profile'),
                  Tab(text: 'More'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ProviderScope(
                  overrides: riverpodNavigatorOverrides(
                    profilePath ?? [ProfileSegment()],
                    NestedNavigator.forProfile,
                  ),
                  child: ProfileTab(),
                ),
                ProviderScope(
                  overrides: riverpodNavigatorOverrides(
                    morePath ?? [MoreSegment()],
                    NestedNavigator.forMore,
                  ),
                  child: MoreTab(),
                ),
              ],
            )),
      );
    });

// ============== NESTED navigators

class ProfileSegment extends TypedSegment {
  const ProfileSegment();
  // ignore: avoid_unused_constructor_parameters
  factory ProfileSegment.decode(UrlPars pars) => ProfileSegment();
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
