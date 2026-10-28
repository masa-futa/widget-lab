import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_selection_toolbar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF でも必須のアンカーとボタンを渡して組み立てる', () {
    final box = cupertinoTextSelectionToolbarEntry.build(
      DemoArgs(
        cupertinoTextSelectionToolbarEntry,
        allOff(cupertinoTextSelectionToolbarEntry),
      ),
    ) as SizedBox;
    final toolbar = box.child! as CupertinoTextSelectionToolbar;

    expect(toolbar.anchorAbove, const Offset(150, 60));
    expect(toolbar.anchorBelow, const Offset(150, 80));
    expect(toolbar.children, hasLength(3));
  });
}
