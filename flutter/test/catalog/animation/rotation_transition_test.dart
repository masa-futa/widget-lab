import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/rotation_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら RotationTransition の既定値（中心で回す・子なし）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, rotationTransitionEntry);
    final w = tester.widget<RotationTransition>(demoFinder(RotationTransition));

    expect(w.alignment, Alignment.center);
    expect(w.child, isNull);
  });
}
