import 'dart:convert';

const all = 0xffffff;
const l1 = 1;
const l2 = 2;
const l3 = 8; // async screen actions
const l4 = 16; // async screen actions with splash screen
const l5 = 32;
const l6 = 64;
const l7 = 128;
const l8 = 256;
const l9 = 512;
const l_async = l3 + l4;

const lessonMasks = <int>[0, l1, l2, l3, l4, l5, l6, l7, l8, l9];

String int2LessonId(int id) => id.toString().padLeft(2, '0');

String fileGen(
  bool isLesson,
  int id,
  // =true => dart only, =false => flutter only, null => single file for flutter and dart
  bool? lessonDartOnly,
  bool forDoc, {
  bool? screenSplitDartFlutterOnly, // =true => for splited example, null => single file for flutter and dart
}) {
  assert(screenSplitDartFlutterOnly != false);

  final lessonMask = lessonMasks[id];
  final lessonId = int2LessonId(id);

  String filter(int maskPlus, int? maskMinus, bool? forDart, String body) {
    final mask = maskPlus & ~(maskMinus ?? 0);
    if ((lessonMask & mask) == 0) return '';

    if (lessonDartOnly != null) {
      if (forDart != lessonDartOnly) return '';
    } else {
      if (forDart != null) return '';
    }
    return body;
  }

  String filterScreen(bool? forSplitDartFlutter, String body) {
    assert(forSplitDartFlutter != false);
    if (screenSplitDartFlutterOnly != null) {
      if (forSplitDartFlutter != screenSplitDartFlutterOnly) return '';
    } else {
      if (forSplitDartFlutter != null) return '';
    }
    return body;
  }

  String filter2(int maskPlus, int? maskMinus, bool filterDartOnly, String title, String subTitle, String body) {
    final mask = maskPlus & ~(maskMinus ?? 0);
    if ((lessonMask & mask) == 0) return '';

    if (lessonDartOnly != null) {
      if (filterDartOnly != lessonDartOnly) return '';
    }
    return title + subTitle + body;
  }

  String comment(String body) => LineSplitter().convert(body).map((l) => '/// $l').join('\n');

  String t(String title) => (title = title.trim()).isEmpty ? '' : '// *** $title\n\n';
  String st(String subTitle) => (subTitle = subTitle.trim()).isEmpty ? '' : '${comment(subTitle)}\n';
  String b(String body) => (body = body.trim()).isEmpty ? '' : '$body\n\n';

  String lessonGen() => filter(all, null, null, b('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson$lessonId.freezed.dart';
part 'lesson$lessonId.g.dart';
''')) + filter(all, null, true, b('''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

part 'dart-lesson$lessonId.freezed.dart';
part 'dart-lesson$lessonId.g.dart';
''')) + filter(all, null, false, b('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart-lesson$lessonId.dart';
import 'screens.dart';

part 'flutter-lesson$lessonId.g.dart';
''')) + filter2(all, null, true, t('''
1. classes for typed path segments (TypedSegment)
'''), st('''
The Freezed package generates three immutable classes used for writing typed navigation path,
e.g TypedPath path = [HomeSegment (), BooksSegment () and BookSegment (id: 3)]
'''), b(''' 
@freezed
class AppSegments with _\$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _\$AppSegmentsFromJson(json);
}
''')) + filter2(l_async, null, true, t('''
1.1. async screen actions  
'''), st('''
'''), b(''' 
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  // simulate helper
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
  }

  return (segment as AppSegments).maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) async => simulateAsyncResult('Book creating async result after 1 sec', 1000),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) async => newSegment.id.isOdd ? simulateAsyncResult('Book merging async result after 500 msec', 500) : null,
      // for every Book screen with even id: creating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
        // Home screen takes some timefor creating
        creating: (_) async => simulateAsyncResult('Home creating async result after 1 sec', 1000)),
    orElse: () => null,
  );
}
''')) + filter2(all, null, true, t('''
2. App-specific navigator with navigation aware actions (used in screens)  
'''), st('''
'''), b('''
const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref) : super(ref);

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(getActualTypedPath().last is BookSegment);
    var id = (getActualTypedPath().last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }
}

/// provide a correctly typed navigator for tests
extension ReadNavigator on ProviderContainer {
  AppNavigator readNavigator() => read(riverpodNavigatorProvider) as AppNavigator;
}
''')) + filter2(all, l4, true, t('''
3. Dart-part of app configuration
'''), st('''
'''), b('''
final config4DartCreator = () => Config4Dart(
      initPath: [HomeSegment()],
      json2Segment: (json, _) => AppSegments.fromJson(json),
      riverpodNavigatorCreator: (ref) => AppNavigator(ref),
    );
''')) + filter2(l4, null, true, t('''
3. Dart-part of app configuration
'''), st('''
'''), b('''
final config4DartCreator = () => Config4Dart(
      json2Segment: (json, _) => AppSegments.fromJson(json),
      initPath: [HomeSegment()],
      segment2AsyncScreenActions: segment2AsyncScreenActions,
      riverpodNavigatorCreator: (ref) => AppNavigator(ref),
    );
''')) + filter2(all, l4, false, t('''
4. Flutter-part of app configuration
'''), st('''
'''), b('''
final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (home) => HomeScreen(home),
        books: (books) => BooksScreen(books),
        book: (book) => BookScreen(book),
      ),
      config4Dart: config4Dart,
    );
''')) + filter2(l4, null, false, t('''
4. Flutter-part of app configuration  
'''), st('''
'''), b('''
final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (home) => HomeScreen(home),
        books: (books) => BooksScreen(books),
        book: (book) => BookScreen(book),
      ),
      splashBuilder: () => SplashScreen(),
      config4Dart: config4Dart,
    );
''')) + filter2(all, null, false, t('''
5. root widget for app  
'''), st('''
Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart
'''), b('''
@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.read(routerDelegateProvider) as RiverpodRouterDelegate,
      routeInformationParser: RouteInformationParserImpl(ref),
    );
''')) + filter2(all, null, false, t('''
6. app entry point with ProviderScope  
'''), st('''
'''), b('''
void main() {
  runApp(ProviderScope(
    // initialize configs providers
    overrides: [
      config4DartProvider.overrideWithValue(config4DartCreator()),
      configProvider.overrideWithValue(configCreator(config4DartCreator())),
    ],
    child: const BooksExampleApp(),
  ));
}
''')) + filter2(all, null, false, t('''
'''), st('''
'''), b('''
'''));

  String screenGen() => filterScreen(null, b('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson$lessonId.dart';

part 'screens.g.dart';

extension ReadNavigator on WidgetRef {
  AppNavigator readNavigator() => read(riverpodNavigatorProvider) as AppNavigator;
}

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************
''')) + filterScreen(true, b('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart-lesson$lessonId.dart';

part 'screens.g.dart';

extension ReadNavigator on WidgetRef {
  AppNavigator readNavigator() => read(riverpodNavigatorProvider) as AppNavigator;
}

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************
''')) + filter(all, 0, null, b('''
@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      buildChildren: () => [
        LinkHelper(title: 'Books Page', onPressed: ref.readNavigator().toBooks),
      ],
    );

@cwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      buildChildren: () =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book, id=\$id', onPressed: () => ref.readNavigator().toBook(id: id))],
    );

@cwidget
Widget bookScreen(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=\${segment.id}',
      buildChildren: () => [
        LinkHelper(title: 'Next >>', onPressed: ref.readNavigator().bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => ref.readNavigator().bookNextPrevButton(isPrev: true)),
      ],
    );
''')) + filter(l4, 0, null, b('''
@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.circle_outlined, size: 150, color: Colors.deepPurple))));
''')) + filter(all, 0, null, b('''
@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));

@swidget
Widget pageHelper({required String title, required List<Widget> buildChildren()}) => Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: (() {
            final res = <Widget>[SizedBox(height: 20)];
            for (final w in buildChildren()) res.addAll([w, SizedBox(height: 20)]);
            return res;
          })(),
        ),
      ),
    );
'''));

  return isLesson ? lessonGen() : screenGen();
}
