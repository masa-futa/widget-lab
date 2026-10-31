import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_theme_data.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら CupertinoThemeData() の既定値で組み立てる', () {
    final built = cupertinoThemeDataEntry.build(
      DemoArgs(cupertinoThemeDataEntry, allOff(cupertinoThemeDataEntry)),
    ) as FittedBox;

    expect((built.child! as CupertinoTheme).data, const CupertinoThemeData());
  });
}
