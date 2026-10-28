import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_scale.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedScale の既定値（中心は center・子なし）で組み立てる', () {
    final scale = animatedScaleEntry.build(
      DemoArgs(animatedScaleEntry, allOff(animatedScaleEntry)),
    ) as AnimatedScale;

    expect(scale.scale, 1.5);
    expect(scale.alignment, Alignment.center);
    expect(scale.curve, Curves.linear);
    expect(scale.child, isNull);
  });
}
