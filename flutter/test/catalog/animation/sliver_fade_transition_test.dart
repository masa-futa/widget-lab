import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/sliver_fade_transition.dart';

import 'pump_all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverFadeTransition の既定値（Sliver は必須）で組み立てる', (
    tester,
  ) async {
    await pumpAllOff(tester, sliverFadeTransitionEntry);
    final w = tester.widget<SliverFadeTransition>(
      demoFinder(SliverFadeTransition),
    );

    expect(w.alwaysIncludeSemantics, isFalse);
    expect(w.child, isA<SliverToBoxAdapter>());
  });
}
