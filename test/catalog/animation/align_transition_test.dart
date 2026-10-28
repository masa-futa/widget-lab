import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/align_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets(
    'TC-18: 全部 OFF なら AlignTransition の既定値（widthFactor・heightFactor なし）で組み立てる',
    (tester) async {
      await pumpAllOff(tester, alignTransitionEntry);
      final w = tester.widget<AlignTransition>(demoFinder(AlignTransition));

      expect(w.widthFactor, isNull);
      expect(w.heightFactor, isNull);
      expect(w.child, isA<FlutterLogo>());
    },
  );
}
