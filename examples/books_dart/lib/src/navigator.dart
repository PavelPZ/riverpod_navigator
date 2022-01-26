import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'extensions.dart';
import 'model/model.dart';
import 'provider.dart';

class AppNavigator extends AsyncRiverpodNavigator {
  AppNavigator(Ref ref, Config4Dart config) : super(ref, config);

  @override
  TypedPath appNavigationLogic(TypedPath oldPath, TypedPath newPath) {
    if (!ref.read(userIsLoggedProvider)) {
      // user not logged => check in navigation stack is ppage which needs login
      // if there is any route which needs login
      final needsLogin4Dart = ref.read(appConfig4DartProvider).needsLogin4Dart;
      if (newPath.any((segment) => needsLogin4Dart(segment))) {
        // navigate to login page
        final loggedUrl = config.pathParser.typedPath2Path(newPath);
        var canceledUrl = oldPath.isEmpty || oldPath.last is LoginHomeSegment ? '' : config.pathParser.typedPath2Path(oldPath);
        if (loggedUrl == canceledUrl) canceledUrl = ''; // logout on page which needs login - called refresh() {navigate([...actualTypedPath]);}
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
    final actPath = getActualTypedPath();
    assert(actPath.last is BookSegment);
    var id = (actPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }

  Future<void> globalLogoutButton() {
    final isLogged = ref.read(userIsLoggedProvider.notifier);
    assert(isLogged.state); // is logged?
    // change login state
    isLogged.state = false;
    // logout needs refresh (when some of the pages in navigation stack could need login)
    return refresh();
  }

  Future<void> globalLoginButton() {
    final actPath = getActualTypedPath();
    final isLogged = ref.read(userIsLoggedProvider.notifier);
    assert(!isLogged.state); // is logoff?
    // navigate to login page
    final path2String = config.pathParser.typedPath2Path(actPath);
    return navigate([LoginHomeSegment(loggedUrl: path2String, canceledUrl: path2String)]);
  }

  Future<void> loginPageCancel() => _loginPageButtons(true);
  Future<void> loginPageOK() => _loginPageButtons(false);

  Future<void> _loginPageButtons(bool cancel) async {
    final actPath = getActualTypedPath();
    assert(actPath.last is LoginHomeSegment);
    final loginHomeSegment = actPath.last as LoginHomeSegment;

    if (cancel) {
      assert(!ref.read(userIsLoggedProvider)); // not loged
    } else
      ref.read(userIsLoggedProvider.notifier).state = true; // login successfull => change userIsLogged state

    final newSegment = config.pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);

    await navigate(newSegment.isEmpty ? [HomeSegment()] : newSegment);
  }
}
