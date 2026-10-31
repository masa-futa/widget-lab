import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/badge.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Badge の既定値（文字なしの点・右上）で組み立てる', () {
    final badge =
        badgeEntry.build(DemoArgs(badgeEntry, allOff(badgeEntry))) as Badge;

    expect(badge.label, isNull);
    expect(badge.isLabelVisible, isTrue);
    expect(badge.backgroundColor, isNull);
    expect(badge.alignment, isNull);
    expect(badge.textColor, isNull);
    expect(badge.smallSize, isNull);
    expect(badge.largeSize, isNull);
    expect(badge.textStyle, isNull);
    expect(badge.padding, isNull);
    expect(badge.offset, isNull);
    expect(badge.child, isNull);
  });
}
