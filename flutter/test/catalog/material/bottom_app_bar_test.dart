import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/bottom_app_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら BottomAppBar の既定値で組み立てる', () {
    final built = bottomAppBarEntry.build(
      DemoArgs(bottomAppBarEntry, allOff(bottomAppBarEntry)),
    );
    final bar = built as BottomAppBar;

    expect(bar.child, isNull);
    expect(bar.color, isNull);
    expect(bar.height, isNull);
    expect(bar.elevation, isNull);
    expect(bar.padding, isNull);
    expect(bar.shape, isNull);
    expect(bar.clipBehavior, Clip.none);
    expect(bar.surfaceTintColor, isNull);
    expect(bar.shadowColor, isNull);
  });
}
