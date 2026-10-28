import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_activity_indicator.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら CupertinoActivityIndicator の既定値で組み立てる', () {
    final built = cupertinoActivityIndicatorEntry.build(
      DemoArgs(
        cupertinoActivityIndicatorEntry,
        allOff(cupertinoActivityIndicatorEntry),
      ),
    ) as CupertinoActivityIndicator;
    const defaults = CupertinoActivityIndicator();

    expect(built.color, defaults.color);
    expect(built.animating, defaults.animating);
    expect(built.radius, defaults.radius);
  });
}
