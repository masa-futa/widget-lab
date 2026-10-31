import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_container.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedContainer の既定値で組み立てる', () {
    final container = animatedContainerEntry.build(
      DemoArgs(animatedContainerEntry, allOff(animatedContainerEntry)),
    ) as AnimatedContainer;
    final defaults = AnimatedContainer(duration: Duration.zero);

    expect(container.duration, const Duration(milliseconds: 600));
    expect(container.curve, Curves.linear);
    expect(container.decoration, defaults.decoration);
    expect(container.constraints, defaults.constraints);
    expect(container.child, isNull);
  });
}
