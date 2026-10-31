import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_desktop_text_selection_toolbar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF でも必須のアンカーと項目を渡して組み立てる', () {
    final box = cupertinoDesktopTextSelectionToolbarEntry.build(
      DemoArgs(
        cupertinoDesktopTextSelectionToolbarEntry,
        allOff(cupertinoDesktopTextSelectionToolbarEntry),
      ),
    ) as FittedBox;
    final toolbar =
        (box.child! as SizedBox).child! as CupertinoDesktopTextSelectionToolbar;

    expect(toolbar.anchor, const Offset(60, 10));
    expect(toolbar.children, hasLength(3));
  });
}
