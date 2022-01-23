import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'dataLayer.dart';
import 'model.dart';
import 'provider.dart';
import 'route.dart';

class AppNavigator extends SimpleNavigator {
  AppNavigator(Ref ref, GetRoute4Segment getRouteForSegment, PathParser pathParser) : super(ref, getRouteForSegment, pathParser);

  @override
  TypedPath appNavigationLogic(TypedPath oldPath, TypedPath newPath) {
    if (!ref.read(userIsLoggedProvider)) {
      // user not logged => check in navigation stack is ppage which needs login
      final routeWithSegments = newPath.map((s) => getRouteWithSegment(s)).toList();
      // check if there is any route which needs login
      final pathNeedsLogin = routeWithSegments.any((rs) {
        if (rs.route is RouteNeedsLogin)
          return (rs.route as RouteNeedsLogin).needsLogin(rs.segment);
        else
          return false;
      });
      // login needed => redirect to login page
      if (pathNeedsLogin) {
        final loggedUrl = pathParser.typedPath2Path(newPath);
        var canceledUrl = oldPath.last is LoginHomeSegment ? '' : pathParser.typedPath2Path(oldPath);
        // logout on page which needs login - called refresh() {navigate([...actualTypedPath]);}
        if (loggedUrl == canceledUrl) canceledUrl = '';
        return [LoginHomeSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
      }
    } else {
      // user logged => redirect from login page to home
      if (newPath.last is LoginHomeSegment) return [HomeSegment()];
    }
    // login OK => return newSegment
    return newPath;
  }

  /* ******************************************** */
  /*     navigation agnostic app actions          */
  /* ******************************************** */

  Future<void> toHome() => navigate([HomeSegment()]);
  Future<void> toBooks() => navigate([HomeSegment(), BooksSegment()]);
  Future<void> toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);

  Future<void> bookNextPrevButton({bool? isPrev}) {
    assert(actualTypedPath.last is BookSegment);
    var id = (actualTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }

  Future<void> globalLogoutButton() {
    // checking
    final isLogged = ref.read(userIsLoggedProvider.notifier);
    assert(isLogged.state); // is logged?
    // change login state
    isLogged.state = false;
    // e.g. logout needs refresh (when some of the pages in navigation stack could need login)
    return refresh();
  }

  Future<void> globalLoginButton() {
    // checking
    final isLogged = ref.read(userIsLoggedProvider.notifier);
    assert(!isLogged.state); // is logoff?
    // navigate to login page
    final segment = pathParser.typedPath2Path(actualTypedPath);
    return navigate([LoginHomeSegment(loggedUrl: segment, canceledUrl: segment)]);
  }

  Future<void> loginPageCancel() => _loginPageButtons(true);
  Future<void> loginPageOK() => _loginPageButtons(false);

  Future<void> _loginPageButtons(bool cancel) async {
    assert(actualTypedPath.last is LoginHomeSegment);
    final loginHomeSegment = actualTypedPath.last as LoginHomeSegment;

    if (cancel) {
      assert(!ref.read(userIsLoggedProvider)); // not loged
    } else
      ref.read(userIsLoggedProvider.notifier).state = true; // lofin successfull => set to provider

    final newSegment = cancel ? pathParser.path2TypedPath(loginHomeSegment.canceledUrl) : pathParser.path2TypedPath(loginHomeSegment.loggedUrl);
    await navigate(newSegment.isEmpty ? [HomeSegment()] : newSegment);
  }
}
