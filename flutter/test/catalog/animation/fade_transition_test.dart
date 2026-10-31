import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/fade_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら FadeTransition の既定値（子なし・透明なら読み上げない）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, fadeTransitionEntry);
    final w = tester.widget<FadeTransition>(demoFinder(FadeTransition));

    expect(w.alwaysIncludeSemantics, isFalse);
    expect(w.child, isNull);
  });
}
