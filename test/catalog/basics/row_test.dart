import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Row() の既定値で組み立てる', () {
    final built = rowEntry.build(DemoArgs(rowEntry, allOff(rowEntry))) as Row;
    const defaults = Row();

    expect(built.mainAxisAlignment, defaults.mainAxisAlignment);
    expect(built.mainAxisSize, defaults.mainAxisSize);
    expect(built.crossAxisAlignment, defaults.crossAxisAlignment);
    expect(built.spacing, defaults.spacing);
    expect(built.children, defaults.children);
  });
}
