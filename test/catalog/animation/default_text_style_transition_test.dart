import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/default_text_style_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら DefaultTextStyleTransition の既定値で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, defaultTextStyleTransitionEntry);
    final w = tester.widget<DefaultTextStyleTransition>(
      demoFinder(DefaultTextStyleTransition),
    );

    expect(w.textAlign, isNull);
    expect(w.maxLines, isNull);
    expect(w.softWrap, isTrue);
    expect(w.overflow, TextOverflow.clip);
  });
}
