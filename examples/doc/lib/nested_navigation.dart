import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
//import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
//import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'nested_navigation.freezed.dart';
part 'nested_navigation.g.dart';

void main() => runApp(
      ProviderScope(
        overrides:
            RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: App(),
      ),
    );

@cwidget
Widget app(WidgetRef ref) => MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: ref.navigator.routerDelegate,
      routeInformationParser: ref.navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.home() = HomeSegment;
  factory Segments.book({required int id}) = BookSegment;
  factory Segments.author({required int id}) = AuthorSegment;
  factory Segments.booksAuthors() = BooksAuthorsSegment;

  factory Segments.fromJson(Map<String, dynamic> json) =>
      _$SegmentsFromJson(json);
}

/// helper extension for screens
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

/// helper extension for test
extension RefApp on Ref {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  /// Constructor for book nested navigator.
  AppNavigator.forBook(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<BookSegment>(BookScreen.new),
            ])
          ],
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<AuthorSegment>(AuthorScreen.new),
            ])
          ],
        );
  // ignore: sort_unnamed_constructors_first
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new),
              RRoute<BookSegment>(BookScreen.new),
              RRoute<AuthorSegment>(AuthorScreen.new),
              RRoute<BooksAuthorsSegment>(BooksAuthorsScreen.new),
            ])
          ],
        );

  // ******* actions used on the screens

  Future gotoNextBook() => replaceLast<BookSegment>((actualBook) =>
      BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));

  Future gotoNextAuthor() => replaceLast<AuthorSegment>((actualAuthor) =>
      AuthorSegment(id: actualAuthor.id == 5 ? 1 : actualAuthor.id + 1));
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) =>
    PageHelper<AppNavigator>(
      title: 'Home',
      segment: segment,
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () =>
              navigator.navigate([HomeSegment(), BooksAuthorsSegment()]),
          child: Text('Books & Authors'),
        ),
        Text('Books', style: TextStyle(fontSize: 32)),
        for (var i = 1; i <= count; i++)
          ElevatedButton(
            onPressed: () =>
                navigator.navigate([HomeSegment(), BookSegment(id: i)]),
            child: Text('Book $i'),
          ), // normal page
        Text('Authors', style: TextStyle(fontSize: 32)),
        for (var i = 1; i <= count; i++)
          ElevatedButton(
            onPressed: () =>
                navigator.navigate([HomeSegment(), AuthorSegment(id: i)]),
            child: Text('Author $i'),
          ) // normal page
      ],
    );

const count = 3;

@cwidget
Widget bookScreen(WidgetRef ref, BookSegment book) => PageHelper<AppNavigator>(
      segment: book,
      title: 'Book ${book.id}',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: navigator.gotoNextBook,
          child: const Text('Go to next book'),
        ),
      ],
    );

@cwidget
Widget authorScreen(WidgetRef ref, AuthorSegment book) =>
    PageHelper<AppNavigator>(
      segment: book,
      title: 'Author ${book.id}',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: navigator.gotoNextAuthor,
          child: const Text('Go to next author'),
        ),
      ],
    );

/// TabBarView screen
@hcwidget
Widget booksAuthorsScreen(
    WidgetRef ref, BooksAuthorsSegment booksAuthorsSegment) {
  /// Remembering RestorePath throughout the widget's lifecycle
  /// Note: *We use **flutter_hooks package** to keep RestorePath instance.
  /// The use of flutter_hooks is not mandatory, it can be implemented using the StatefulWidget*.
  final restoreBook = useMemoized(() => RestorePath());
  final restoreAuthor = useMemoized(() => RestorePath());
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Books'),
            Tab(text: 'Authors'),
          ],
        ),
        title: const Text('Books & Authors'),
      ),
      body: TabBarView(
        children: [
          ProviderScope(
            // The RestorePath class preserves the last state of the navigator.
            // Used during the next navigator initialization.
            overrides: RNavigatorCore.providerOverrides(
                [BookSegment(id: 2)], AppNavigator.forBook,
                restorePath: restoreBook),
            child: BooksTab(),
          ),
          ProviderScope(
            overrides: RNavigatorCore.providerOverrides(
                [AuthorSegment(id: 2)], AppNavigator.forAuthor,
                restorePath: restoreAuthor),
            child: AuthorTab(),
          ),
        ],
      ),
    ),
  );
}
// https://gist.github.com/johnpryan/bbca91e23bbb4d39247fa922533be7c9

@cwidget
Widget booksTab(WidgetRef ref) =>
    Router(routerDelegate: ref.navigator.routerDelegate);

@cwidget
Widget authorTab(WidgetRef ref) =>
    Router(routerDelegate: ref.navigator.routerDelegate);

@cwidget
Widget pageHelper<N extends RNavigator>(
  WidgetRef ref, {
  required TypedSegment segment,
  required String title,
  required List<Widget> buildChildren(N navigator),
}) {
  final navigator = ref.navigator as N;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator))
            res.addAll([w, SizedBox(height: 20)]);
          res.addAll([
            SizedBox(height: 20),
            Text(
                'Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')
          ]);
          if (segment.asyncActionResult != null)
            res.addAll([
              SizedBox(height: 20),
              Text('Async result: "${segment.asyncActionResult}"')
            ]);
          return res;
        })(),
      ),
    ),
  );
}
