import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/positioned_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら PositionedTransition の既定値（子は必須）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, positionedTransitionEntry);
    final w = tester.widget<PositionedTransition>(
      demoFinder(PositionedTransition),
    );

    expect(w.child, isA<FlutterLogo>());
    expect(w.rect.value, const RelativeRect.fromLTRB(0, 0, 160, 80));
  });
}
