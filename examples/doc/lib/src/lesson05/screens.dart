import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson05.dart';

part 'screens.g.dart';

final ScreenBuilder screenBuilderAppSegments = (segment) => (segment as AppSegments).map(
      home: (home) => HomeScreen(home),
      books: (books) => BooksScreen(books),
      book: (book) => BookScreen(book),
    );

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));

@swidget
Widget homeScreen(HomeSegment segment) => PageHelper(
      title: 'Home Screen',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

@swidget
Widget booksScreen(BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      buildChildren: (navigator) =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book Screen, id=$id', onPressed: () => navigator.toBook(id: id))],
    );

@swidget
Widget bookScreen(BookSegment segment) => PageHelper(
      title: 'Book Screen, id=${segment.id}',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Next >>', onPressed: navigator.bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.bookNextPrevButton(isPrev: true)),
      ],
    );

final ScreenBuilder screenBuilderLoginSegments = (segment) => (segment as LoginHomeSegment).map(
      (value) => throw UnimplementedError(),
      home: (loginHome) => LoginScreen(loginHome),
    );

@swidget
Widget loginScreen(LoginHomeSegment segment) => PageHelper(
      title: 'Login Page',
      isLoginPage: true,
      buildChildren: (navigator) => [
        ElevatedButton(onPressed: navigator.loginPageOK, child: Text('Login')),
      ],
    );

@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(AppNavigator navigator), bool? isLoginPage}) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          return res;
        })(),
      ),
    ),
  );
}
