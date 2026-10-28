import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/repeating_animation_builder.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  final entry = repeatingAnimationBuilderEntry;

  test(
    'TC-18: 全部 OFF なら既定値（restart・止めない）で組み立てる（animatable と duration は必須）',
    () {
      final builder = entry.build(
        DemoArgs(entry, allOff(entry)),
      ) as RepeatingAnimationBuilder<double>;

      expect(builder.animatable, isA<Tween<double>>());
      expect(builder.duration, const Duration(milliseconds: 2000));
      expect(builder.repeatMode, RepeatMode.restart);
      expect(builder.paused, isFalse);
    },
  );
}
