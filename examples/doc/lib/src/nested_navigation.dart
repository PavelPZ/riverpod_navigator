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
        overrides: [
          riverpodNavigatorProvider.overrideWithProvider(Provider(AppNavigator.new)),
        ],
        child: App(),
      ),
    );

@cwidget
Widget app(WidgetRef ref) {
  final navigator = ref.read(riverpodNavigatorProvider);
  return MaterialApp.router(
    title: 'Riverpod Navigator Example',
    routerDelegate: navigator.routerDelegate,
    routeInformationParser: navigator.routeInformationParser,
    debugShowCheckedModeBanner: false,
  );
}

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.home() = HomeSegment;
  factory Segments.book({required int id}) = BookSegment;
  factory Segments.author({required int id}) = AuthorSegment;
  factory Segments.booksAuthors() = BooksAuthorsSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}

class AppNavigator extends RiverpodNavigator {
  /// Constructor for book nested navigator.
  AppNavigator.forBook(Ref ref, RestorePath restorePath)
      : super(
          ref,
          [BookSegment(id: 2)],
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<BookSegment>(BookScreen.new),
            ])
          ],

          /// required nested flag
          isNested: true,

          /// The RestorePath class preserves the last state of the navigator.
          /// Used during the next navigator initialization.
          restorePath: restorePath,
        );

  // ignore: sort_unnamed_constructors_first
  AppNavigator(Ref ref)
      : super(
          ref,
          [HomeSegment()],
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new),
              RRoute<BookSegment>(BookScreen.new),
              RRoute<AuthorSegment>(AuthorScreen.new),
              RRoute<BooksAuthorsSegment>(BooksAuthorsScreen.new),
            ])
          ],
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref, RestorePath restorePath)
      : super(
          ref,
          [AuthorSegment(id: 2)],
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<AuthorSegment>(AuthorScreen.new),
            ])
          ],
          isNested: true,
          restorePath: restorePath,
        ) {
    return;
  }

  // ******* actions used on the screens

  Future gotoNextBook() {
    final actualBook = currentPath.last as BookSegment;
    return replaceLast(BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));
  }

  Future gotoNextAuthor() {
    final actualBook = currentPath.last as AuthorSegment;
    return replaceLast(AuthorSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));
  }
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper<AppNavigator>(
      title: 'Home',
      segment: segment,
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () => navigator.navigate([HomeSegment(), BooksAuthorsSegment()]),
          child: Text('Books & Authors'),
        ),
        Text('Books', style: TextStyle(fontSize: 32)),
        for (var i = 1; i <= count; i++)
          ElevatedButton(
            onPressed: () => navigator.navigate([HomeSegment(), BookSegment(id: i)]),
            child: Text('Book $i'),
          ), // normal page
        Text('Authors', style: TextStyle(fontSize: 32)),
        for (var i = 1; i <= count; i++)
          ElevatedButton(
            onPressed: () => navigator.navigate([HomeSegment(), AuthorSegment(id: i)]),
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
          //const Text('Go to next book'),
        ),
      ],
    );

@cwidget
Widget authorScreen(WidgetRef ref, AuthorSegment book) => PageHelper<AppNavigator>(
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
Widget booksAuthorsScreen(WidgetRef ref, BooksAuthorsSegment booksAuthorsSegment) {
  /// Remembering RestorePath throughout the widget's lifecycle
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
            overrides: [
              /// initialize the navigator using restoreBook
              riverpodNavigatorProvider.overrideWithProvider(Provider((ref) => AppNavigator.forBook(ref, restoreBook))),

              /// pass all navigator dependsOn to the nested ProviderScope
              ...ref.read(riverpodNavigatorProvider).dependsOn.map((e) => e as Override).toList(),
            ],
            child: BooksTab(),
          ),
          ProviderScope(
            overrides: [
              riverpodNavigatorProvider.overrideWithProvider(Provider((ref) => AppNavigator.forAuthor(ref, restoreAuthor))),
              ...ref.read(riverpodNavigatorProvider).dependsOn.map((e) => e as Override).toList(),
            ],
            child: AuthorTab(),
          ),
        ],
      ),
    ),
  );
}
// https://gist.github.com/johnpryan/bbca91e23bbb4d39247fa922533be7c9

@cwidget
Widget booksTab(WidgetRef ref) => Router(routerDelegate: ref.read(riverpodNavigatorProvider).routerDelegate);

@cwidget
Widget authorTab(WidgetRef ref) => Router(routerDelegate: ref.read(riverpodNavigatorProvider).routerDelegate);

@cwidget
Widget pageHelper<N extends RiverpodNavigator>(
  WidgetRef ref, {
  required TypedSegment segment,
  required String title,
  required List<Widget> buildChildren(N navigator),
}) {
  final navigator = ref.read(riverpodNavigatorProvider) as N;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          res.addAll([SizedBox(height: 20), Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')]);
          if (segment.asyncActionResult != null) res.addAll([SizedBox(height: 20), Text('Async result: "${segment.asyncActionResult}"')]);
          return res;
        })(),
      ),
    ),
  );
}
