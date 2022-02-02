// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson05.freezed.dart';
part 'lesson05.g.dart';

// *** 1. classes for typed path segments (TypedSegment)

/// The Freezed package generates three immutable classes used for writing typed navigation path,
/// e.g TypedPath path = [HomeSegment (), BooksSegment () and BookSegment (id: 3)]
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

final Json2Segment json2AppSegments = (json, _) => AppSegments.fromJson(json);

@Freezed(unionKey: LoginSegments.jsonNameSpace)
class LoginSegments with _$LoginSegments, TypedSegment {
  /// json serialization hack: must be at least two constructors
  factory LoginSegments() = _LoginSegments;
  LoginSegments._();
  factory LoginSegments.home({String? loggedUrl, String? canceledUrl}) = LoginHomeSegment;

  factory LoginSegments.fromJson(Map<String, dynamic> json) => _$LoginSegmentsFromJson(json);
  static const String jsonNameSpace = '_login';
}

final Json2Segment json2LoginSegments = (json, _) => LoginSegments.fromJson(json);

/// mark screens which needs login
bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;

// *** 2. App-specific navigator with navigation aware actions (used in screens)

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref) : super(ref);

  @override
  FutureOr<TypedPath?> appNavigationLogic(Ref ref, TypedPath oldPath, TypedPath newPath) {
    // !!!! actual navigation stack depends not only on TypedPath but also on login state
    final isLogged = ref.watch(userIsLoggedProvider);

    if (!isLogged) {
      final pathNeedsLogin = newPath.any((segment) => needsLogin(segment));

      // login needed => redirect to login page
      if (pathNeedsLogin) {
        final pathParser = ref.read(config4DartProvider).pathParser;
        // parametters for login screen
        final loggedUrl = pathParser.typedPath2Path(newPath);
        var canceledUrl = oldPath.isEmpty || oldPath.last is LoginHomeSegment ? '' : pathParser.typedPath2Path(oldPath);
        // chance to exit login loop
        if (loggedUrl == canceledUrl) canceledUrl = '';
        // redirect to login screen
        return [LoginHomeSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
      }
    } else {
      // user logged and navigation to Login page => redirect to home
      if (newPath.isEmpty || newPath.last is LoginHomeSegment) return [HomeSegment()];
    }
    // login OK => no redirect
    return null;
  }

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(actualTypedPath.last is BookSegment);
    var id = (actualTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }

  Future<void> globalLogoutButton() {
    // checking
    final isLogged = ref.read(userIsLoggedProvider.notifier);
    assert(isLogged.state); // is logged?
    // change login state
    isLogged.state = false;
    return Future.value();
  }

  Future<void> globalLoginButton() {
    // checking
    final isLogged = ref.read(userIsLoggedProvider.notifier);
    assert(!isLogged.state); // is logoff?
    // navigate to login page
    final segment = ref.read(config4DartProvider).pathParser.typedPath2Path(actualTypedPath);
    return navigate([LoginHomeSegment(loggedUrl: segment, canceledUrl: segment)]);
  }

  Future<void> loginPageCancel() => _loginPageButtons(true);
  Future<void> loginPageOK() => _loginPageButtons(false);

  Future<void> _loginPageButtons(bool cancel) async {
    final path = actualTypedPath;
    final pathParser = ref.read(config4DartProvider).pathParser;
    assert(path.last is LoginHomeSegment);
    final loginHomeSegment = path.last as LoginHomeSegment;

    var newSegment = cancel ? pathParser.path2TypedPath(loginHomeSegment.canceledUrl) : pathParser.path2TypedPath(loginHomeSegment.loggedUrl);
    if (newSegment.isEmpty) newSegment = [HomeSegment()];
    final notifier = ref.read(actualTypedPathProvider.notifier); // !!!
    notifier.state = [...newSegment];
    ref.refresh(actualTypedPathProvider);
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true; // login successfull => set to provider
    //   assert(!ref.read(userIsLoggedProvider)); // not logged
    // else
    //   ref.read(userIsLoggedProvider.notifier).state = true; // login successfull => set to provider
    //await navigate(newSegment.isEmpty ? [HomeSegment()] : newSegment);
  }
}

final userIsLoggedProvider = StateProvider<bool>((_) => false);

/// provide a correctly typed navigator for tests
extension ReadNavigator on ProviderContainer {
  AppNavigator readNavigator() => read(riverpodNavigatorProvider) as AppNavigator;
}

// *** 3. Dart-part of app configuration

final config4DartCreator = () => Config4Dart(
      json2Segment: (json, unionKey) => (unionKey == LoginSegments.jsonNameSpace ? json2LoginSegments : json2AppSegments)(json, unionKey),
      initPath: [HomeSegment()],
      riverpodNavigatorCreator: (ref) => AppNavigator(ref),
    );

// *** 4. Flutter-part of app configuration

final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => segment is LoginSegments ? screenBuilderLoginSegments(segment) : screenBuilderAppSegments(segment),
      config4Dart: config4Dart,
    );

// *** 5. root widget for app

/// Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart
@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.read(riverpodNavigatorProvider).routerDelegate as RiverpodRouterDelegate,
      routeInformationParser: RouteInformationParserImpl(ref),
    );

// *** 6. app entry point with ProviderScope

void runMain() {
  final config = configCreator(config4DartCreator());
  runApp(ProviderScope(
    // initialize configs providers
    overrides: [
      config4DartProvider.overrideWithValue(config.config4Dart),
      configProvider.overrideWithValue(config),
    ],
    child: const BooksExampleApp(),
  ));
}
