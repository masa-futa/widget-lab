import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_cross_fade.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AnimatedCrossFade の既定値（sizeCurve は linear）で組み立てる', () {
    final fade = animatedCrossFadeEntry.build(
      DemoArgs(animatedCrossFadeEntry, allOff(animatedCrossFadeEntry)),
    ) as AnimatedCrossFade;

    // 必須の crossFadeState・duration・2 つの子は OFF にしても渡る
    expect(fade.crossFadeState, CrossFadeState.showFirst);
    expect(fade.duration, const Duration(milliseconds: 600));
    expect(fade.sizeCurve, Curves.linear);
    expect(fade.firstChild, isA<FlutterLogo>());
    expect(fade.secondChild, isA<SizedBox>());
  });
}
