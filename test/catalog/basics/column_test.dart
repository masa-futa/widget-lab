import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/column.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Column の既定値で組み立てる（children は必須ではないので空）', () {
    final built =
        columnEntry.build(DemoArgs(columnEntry, allOff(columnEntry))) as Column;
    const defaults = Column();

    expect(built.mainAxisAlignment, defaults.mainAxisAlignment);
    expect(built.mainAxisSize, defaults.mainAxisSize);
    expect(built.crossAxisAlignment, defaults.crossAxisAlignment);
    expect(built.spacing, defaults.spacing);
    expect(built.children, isEmpty);
  });
}
