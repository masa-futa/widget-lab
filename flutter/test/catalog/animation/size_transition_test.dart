import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/size_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SizeTransition の既定値（縦に縮める・子なし）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, sizeTransitionEntry);
    final w = tester.widget<SizeTransition>(demoFinder(SizeTransition));

    expect(w.axis, Axis.vertical);
    expect(w.alignment, isNull);
    expect(w.child, isNull);
  });
}
