import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/relative_positioned_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets(
    'TC-18: 全部 OFF なら RelativePositionedTransition の既定値（size と子は必須）で組み立てる',
    (tester) async {
      await pumpAllOff(tester, relativePositionedTransitionEntry);
      final w = tester.widget<RelativePositionedTransition>(
        demoFinder(RelativePositionedTransition),
      );

      expect(w.size, const Size(240, 160));
      expect(w.child, isA<FlutterLogo>());
    },
  );
}
