import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_size.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedSize の既定値（子なし・center・linear）で組み立てる', () {
    final size = animatedSizeEntry.build(
      DemoArgs(animatedSizeEntry, allOff(animatedSizeEntry)),
    ) as AnimatedSize;

    expect(size.child, isNull);
    expect(size.alignment, Alignment.center);
    expect(size.curve, Curves.linear);
  });
}
