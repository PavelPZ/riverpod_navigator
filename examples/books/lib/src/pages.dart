import 'package:books_dart/books_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'provider.dart';

// flutter pub run build_runner watch
part 'pages.g.dart';

@hcwidget
Widget homePage(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      children: (_) => [
        linkHelper(title: 'Books Page', onPressed: ref.read(appNavigatorProvider).toBooks),
      ],
    );

@hcwidget
Widget booksPage(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      children: (_) =>
          [for (var id = 0; id < booksLen; id++) linkHelper(title: 'Book, id=$id', onPressed: () => ref.read(appNavigatorProvider).toBook(id: id))],
    );

@hcwidget
Widget bookPage(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=${segment.id}',
      children: (_) => [
        linkHelper(title: 'Next >>', onPressed: ref.read(appNavigatorProvider).bookNextPrevButton),
        linkHelper(title: '<< Prev', onPressed: () => ref.read(appNavigatorProvider).bookNextPrevButton(isPrev: true)),
      ],
    );

@hcwidget
Widget loginPage(WidgetRef ref, LoginHomeSegment segment) => PageHelper(
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
