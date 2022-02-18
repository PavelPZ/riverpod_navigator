import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'more_groups.g.dart';
part 'more_groups.freezed.dart';

// ******************************************************
// more segment groups

/// The first segment group does not need "unionKey".
@Freezed(maybeWhen: false, maybeMap: false)
class FirstGrp with _$FirstGrp, TypedSegment {
  FirstGrp._();
  factory FirstGrp.first1() = First1Segment;
  factory FirstGrp.first2() = First2Segment;

  factory FirstGrp.fromJson(Map<String, dynamic> json) => _$FirstGrpFromJson(json);
}

@Freezed(unionKey: SecondGrp.jsonNameSpace, maybeWhen: false, maybeMap: false)
class SecondGrp with _$SecondGrp, TypedSegment {
  SecondGrp._();
  factory SecondGrp.second1() = Second1Segment;
  factory SecondGrp.second2() = Second2Segment;

  factory SecondGrp.fromJson(Map<String, dynamic> json) => _$SecondGrpFromJson(json);
  static const String jsonNameSpace = '_second';
}

@Freezed(unionKey: ThirdGrp.jsonNameSpace, maybeWhen: false, maybeMap: false)
class ThirdGrp with _$ThirdGrp, TypedSegment {
  ThirdGrp._();
  factory ThirdGrp.third1() = Third1Segment;
  factory ThirdGrp.third2() = Third2Segment;

  factory ThirdGrp.fromJson(Map<String, dynamic> json) => _$ThirdGrpFromJson(json);
  static const String jsonNameSpace = '_third';
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(ref, [
          RRoutes<FirstGrp>(FirstGrp.fromJson, [
            RRoute<First1Segment>(First1Screen.new),
            RRoute<First2Segment>(First2Screen.new),
          ]),
          RRoutes<SecondGrp>(SecondGrp.fromJson, [
            RRoute<Second1Segment>(Second1Screen.new),
            RRoute<Second2Segment>(Second2Screen.new),
          ]),
          RRoutes<ThirdGrp>(ThirdGrp.fromJson, [
            RRoute<Third1Segment>(Third1Screen.new),
            RRoute<Third2Segment>(Third2Screen.new),
          ]),
        ]);
}

@cwidget
Widget first1Screen(WidgetRef ref, First1Segment segment) => SizedBox();

@cwidget
Widget first2Screen(WidgetRef ref, First2Segment segment) => SizedBox();

@cwidget
Widget second1Screen(WidgetRef ref, Second1Segment segment) => SizedBox();

@cwidget
Widget second2Screen(WidgetRef ref, Second2Segment segment) => SizedBox();

@cwidget
Widget third1Screen(WidgetRef ref, Third1Segment segment) => SizedBox();

@cwidget
Widget third2Screen(WidgetRef ref, Third2Segment segment) => SizedBox();
