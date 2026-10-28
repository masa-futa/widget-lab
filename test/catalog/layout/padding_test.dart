import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Padding の既定値（余白 0・子なし）で組み立てる', () {
    final padding = paddingEntry.build(
      DemoArgs(paddingEntry, allOff(paddingEntry)),
    ) as Padding;

    expect(padding.padding, EdgeInsets.zero);
    expect(padding.child, isNull);
  });
}
