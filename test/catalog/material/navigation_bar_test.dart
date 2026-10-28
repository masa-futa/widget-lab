import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/navigation_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら NavigationBar の既定値で組み立てる（行き先は必須）', () {
    final bar = navigationBarEntry.build(
      DemoArgs(navigationBarEntry, allOff(navigationBarEntry)),
    ) as NavigationBar;

    expect(bar.destinations, hasLength(3));
    expect(bar.selectedIndex, 0);
    expect(bar.labelBehavior, isNull);
    expect(bar.indicatorColor, isNull);
    expect(bar.height, isNull);
  });
}
