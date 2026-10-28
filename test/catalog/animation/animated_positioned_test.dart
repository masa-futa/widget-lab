import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_positioned.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedPositioned の既定値（位置の指定なし）で組み立てる', () {
    final box = animatedPositionedEntry.build(
      DemoArgs(animatedPositionedEntry, allOff(animatedPositionedEntry)),
    ) as SizedBox;
    final positioned =
        (box.child! as Stack).children.single as AnimatedPositioned;

    expect(positioned.left, isNull);
    expect(positioned.top, isNull);
    expect(positioned.curve, Curves.linear);
    expect(positioned.child, isA<FlutterLogo>());
  });
}
