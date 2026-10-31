import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_physical_model.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedPhysicalModel の既定値（浮き上がり 0・角丸なし）で組み立てる', () {
    final model = animatedPhysicalModelEntry.build(
      DemoArgs(animatedPhysicalModelEntry, allOff(animatedPhysicalModelEntry)),
    ) as AnimatedPhysicalModel;

    expect(model.elevation, 0);
    expect(model.borderRadius, isNull);
    expect(model.curve, Curves.linear);
    expect(model.color, const Color(0xFFFFFFFF));
  });
}
