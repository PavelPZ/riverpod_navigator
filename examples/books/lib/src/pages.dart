import 'package:books_dart/books_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'provider.dart';
import 'route.dart';

// flutter pub run build_runner watch
part 'pages.g.dart';

Widget screenBuilder(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.map<Widget>(
      home: (segment) => HomeScreen(segment),
      books: (segment) => BooksScreen(segment),
      book: (segment) => BookScreen(segment),
    );
  else if (segment is LoginSegments)
    return segment.map<Widget>(
      (segment) => throw UnimplementedError(),
      home: (segment) => LoginScreen(segment),
    );
  else
    throw UnimplementedError();
}

/// used when routes are used
Widget screenBuilder$Routes(TypedSegment segment) => segment2Route(segment).buildPage(segment);

@hcwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      children: (_) => [
        linkHelper(title: 'Books Page', onPressed: ref.read(appNavigatorProvider).toBooks),
      ],
    );

@hcwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      children: (_) =>
          [for (var id = 0; id < booksLen; id++) linkHelper(title: 'Book, id=$id', onPressed: () => ref.read(appNavigatorProvider).toBook(id: id))],
    );

@hcwidget
Widget bookScreen(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=${segment.id}',
      children: (_) => [
        linkHelper(title: 'Next >>', onPressed: ref.read(appNavigatorProvider).bookNextPrevButton),
        linkHelper(title: '<< Prev', onPressed: () => ref.read(appNavigatorProvider).bookNextPrevButton(isPrev: true)),
      ],
    );

@hcwidget
Widget loginScreen(WidgetRef ref, LoginHomeSegment segment) => PageHelper(
      title: 'Login Page',
      isLoginPage: true,
      children: (_) => [
        ElevatedButton(onPressed: ref.read(appNavigatorProvider).loginPageOK, child: Text('Login')),
      ],
    );

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );

@hcwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> children(AppNavigator navigator), bool? isLoginPage}) {
  final navigator = ref.read(appNavigatorProvider);
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
          for (final w in children(navigator)) res.addAll([w, SizedBox(height: 20)]);
          res.add(CountBuilds());
          return res;
        })(),
        //children(navigator).map((e) => [e, SizedBox(height: 20)]).expand((e) => e).toList(),
      ),
    ),
  );
}

@hcwidget
Widget countBuilds() {
  final count = useState(0);
  count.value++;
  return Text('Builded ${count.value} times.');
}
