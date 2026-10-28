import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/navigation_drawer.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら NavigationDrawer の既定値で組み立てる（中身は必須）', () {
    final built = navigationDrawerEntry.build(
      DemoArgs(navigationDrawerEntry, allOff(navigationDrawerEntry)),
    );
    final drawer = (built as DemoStage).child as NavigationDrawer;

    expect(drawer.children, hasLength(4));
    expect(drawer.selectedIndex, 0);
    expect(drawer.indicatorColor, isNull);
    expect(drawer.backgroundColor, isNull);
  });
}
