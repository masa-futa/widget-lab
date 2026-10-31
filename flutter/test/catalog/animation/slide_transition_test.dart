import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/slide_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SlideTransition の既定値（押せる範囲もずらす・子なし）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, slideTransitionEntry);
    final w = tester.widget<SlideTransition>(demoFinder(SlideTransition));

    expect(w.transformHitTests, isTrue);
    expect(w.child, isNull);
  });
}
