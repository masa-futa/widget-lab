import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/floating_action_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら FloatingActionButton の既定値（押せない・56×56）で組み立てる', () {
    final fab = floatingActionButtonEntry.build(
      DemoArgs(floatingActionButtonEntry, allOff(floatingActionButtonEntry)),
    ) as FloatingActionButton;

    expect(fab.onPressed, isNull);
    expect(fab.mini, isFalse);
    expect(fab.backgroundColor, isNull);
    expect(fab.elevation, isNull);
    expect(fab.shape, isNull);
    expect(fab.child, isNull);
    // 見本と詳細の両方に出るので Hero を付けない
    expect(fab.heroTag, isNull);
  });
}
