import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_search_text_field.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら CupertinoSearchTextField の既定値で組み立てる', () {
    final box = cupertinoSearchTextFieldEntry.build(
      DemoArgs(
        cupertinoSearchTextFieldEntry,
        allOff(cupertinoSearchTextFieldEntry),
      ),
    ) as SizedBox;
    final built = box.child! as CupertinoSearchTextField;
    const defaults = CupertinoSearchTextField();

    expect(built.placeholder, defaults.placeholder);
    expect(built.backgroundColor, defaults.backgroundColor);
    expect(built.borderRadius, defaults.borderRadius);
    expect(built.itemColor, defaults.itemColor);
    expect(built.suffixMode, defaults.suffixMode);
    expect(built.enabled, defaults.enabled);
    expect(built.decoration, defaults.decoration);
    expect(built.padding, defaults.padding);
    expect(built.itemSize, defaults.itemSize);
    expect(built.prefixInsets, defaults.prefixInsets);
    expect(built.suffixInsets, defaults.suffixInsets);
    expect(built.style, defaults.style);
    expect(built.placeholderStyle, defaults.placeholderStyle);
    expect(built.cursorWidth, defaults.cursorWidth);
    expect(built.cursorRadius, defaults.cursorRadius);
  });
}
