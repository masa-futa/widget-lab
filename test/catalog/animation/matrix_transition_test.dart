import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/matrix_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら MatrixTransition の既定値（中心で変形・子なし）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, matrixTransitionEntry);
    final w = tester.widget<MatrixTransition>(demoFinder(MatrixTransition));

    expect(w.alignment, Alignment.center);
    expect(w.child, isNull);
  });
}
