import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson04.dart';

part 'screens.g.dart';

// *** 5. Map TypedSegment's to Screens

final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
  // See Constructor tear-offs in Dart ^2.15, "HomeScreen.new" is equivalent to "(segment) => HomeScreen(segment)"
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));

@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.circle_outlined, size: 150, color: Colors.deepPurple))));

@hwidget
Widget countBuilds() {
  final count = useState(0);
  count.value++;
  return Text('Builded ${count.value} times.');
}

@swidget
Widget homeScreen(HomeSegment segment) => PageHelper(
      title: 'Home Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

@cwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        for (var id = 0; id < booksLen; id++)
          LinkHelper(
              title: 'Book Screen, id=4${!ref.watch(userIsLoggedProvider) && id.isOdd ? ' (log in first)' : ''}',
              onPressed: () => navigator.toBook(id: id))
      ],
    );

@swidget
Widget bookScreen(BookSegment segment) => PageHelper(
      title: 'Book Screen, id=${segment.id}',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        LinkHelper(title: 'Next >>', onPressed: navigator.bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.bookNextPrevButton(isPrev: true)),
      ],
    );

final ScreenBuilder loginSegmentsScreenBuilder = (segment) => (segment as LoginHomeSegment).map(
      (value) => throw UnimplementedError(),
      home: LoginHomeScreen.new,
    );

@swidget
Widget loginHomeScreen(LoginHomeSegment segment) => PageHelper(
      title: 'Login Page',
      isLoginPage: true,
      buildChildren: (navigator) => [
        ElevatedButton(onPressed: navigator.loginPageOK, child: Text('Login')),
      ],
    );

@cwidget
Widget pageHelper(
  WidgetRef ref, {
  required String title,
  required List<Widget> buildChildren(AppNavigator navigator),
  bool? isLoginPage,
  dynamic asyncActionResult,
}) {
  final navigator = ref.read(riverpodNavigatorProvider) as AppNavigator;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: isLoginPage == true
          ? IconButton(
              onPressed: navigator.loginPageCancel,
              icon: Icon(Icons.cancel),
            )
          : null,
      actions: [
        if (isLoginPage != true)
          Consumer(builder: (_, ref, __) {
            final isLogged = ref.watch(userIsLoggedProvider);
            return ElevatedButton(
              onPressed: () => isLogged ? navigator.globalLogoutButton() : navigator.globalLoginButton(),
              child: Text(isLogged ? 'Logout' : 'Login'),
            );
          }),
      ],
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          res.add(CountBuilds());
          if (asyncActionResult!=null) res.addAll([Text(asyncActionResult.toString()), SizedBox(height: 20)]);
          SizedBox(height: 40);
          return res;
        })(),
      ),
    ),
  );
}

