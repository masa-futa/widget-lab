import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_field.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら CupertinoTextField の既定値で組み立てる', () {
    final box = cupertinoTextFieldEntry.build(
      DemoArgs(cupertinoTextFieldEntry, allOff(cupertinoTextFieldEntry)),
    ) as SizedBox;
    final built = box.child! as CupertinoTextField;
    const defaults = CupertinoTextField();

    expect(built.placeholder, defaults.placeholder);
    expect(built.prefix, defaults.prefix);
    expect(built.clearButtonMode, defaults.clearButtonMode);
    expect(built.obscureText, defaults.obscureText);
    expect(built.textAlign, defaults.textAlign);
    expect(built.padding, defaults.padding);
    expect(built.enabled, defaults.enabled);
  });
}
