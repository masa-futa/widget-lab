import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/flutter_logo.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら FlutterLogo() の既定値で組み立てる', () {
    final built = flutterLogoEntry.build(
      DemoArgs(flutterLogoEntry, allOff(flutterLogoEntry)),
    ) as FlutterLogo;
    const defaults = FlutterLogo();

    expect(built.size, defaults.size);
    expect(built.style, defaults.style);
    expect(built.textColor, defaults.textColor);
  });
}
