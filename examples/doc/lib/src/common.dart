import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'common.freezed.dart';
part 'common.g.dart';

// simulates an action such as loading external data or saving to external storage
Future<String> simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}

// ******************************************************
// Segment

@freezed
class SegmentGrp with _$SegmentGrp, TypedSegment {
  SegmentGrp._();
  factory SegmentGrp.home() = HomeSegment;
  factory SegmentGrp.page({required String title}) = PageSegment;

  factory SegmentGrp.fromJson(Map<String, dynamic> json) => _$SegmentGrpFromJson(json);
}

// ******************************************************

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

@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.hourglass_full, size: 150, color: Colors.deepPurple))));
