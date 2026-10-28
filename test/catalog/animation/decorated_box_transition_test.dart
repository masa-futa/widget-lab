import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/decorated_box_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら DecoratedBoxTransition の既定値（後ろに飾る）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, decoratedBoxTransitionEntry);
    final w = tester.widget<DecoratedBoxTransition>(
      demoFinder(DecoratedBoxTransition),
    );

    expect(w.position, DecorationPosition.background);
    expect(w.child, isA<FlutterLogo>());
  });
}
