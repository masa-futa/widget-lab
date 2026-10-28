import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/scale_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら ScaleTransition の既定値（中心で拡大・子なし）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, scaleTransitionEntry);
    final w = tester.widget<ScaleTransition>(demoFinder(ScaleTransition));

    expect(w.alignment, Alignment.center);
    expect(w.child, isNull);
  });
}
