import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_opacity.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedOpacity の既定値（curve は linear・子なし）で組み立てる', () {
    final opacity = animatedOpacityEntry.build(
      DemoArgs(animatedOpacityEntry, allOff(animatedOpacityEntry)),
    ) as AnimatedOpacity;

    expect(opacity.opacity, 0.3);
    expect(opacity.curve, Curves.linear);
    expect(opacity.child, isNull);
  });
}
