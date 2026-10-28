import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/navigation_rail.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら NavigationRail の既定値（未選択・名前なし・広げない）で組み立てる', () {
    final built = navigationRailEntry.build(
      DemoArgs(navigationRailEntry, allOff(navigationRailEntry)),
    );
    final align = (built as DemoStage).child as Align;
    final rail = align.child! as NavigationRail;

    expect(rail.destinations, hasLength(3));
    expect(rail.selectedIndex, isNull);
    expect(rail.labelType, isNull);
    expect(rail.extended, isFalse);
    expect(rail.backgroundColor, isNull);
  });
}
