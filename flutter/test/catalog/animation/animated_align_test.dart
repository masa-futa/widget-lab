import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_align.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedAlign の既定値（curve は linear・子なし）で組み立てる', () {
    final align = animatedAlignEntry.build(
      DemoArgs(animatedAlignEntry, allOff(animatedAlignEntry)),
    ) as AnimatedAlign;

    // alignment と duration は必須なので OFF にしても渡る
    expect(align.alignment, Alignment.center);
    expect(align.duration, const Duration(milliseconds: 600));
    expect(align.curve, Curves.linear);
    expect(align.child, isNull);
  });
}
