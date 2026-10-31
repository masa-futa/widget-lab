import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_field.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

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
    expect(built.placeholderStyle, defaults.placeholderStyle);
    expect(built.decoration, defaults.decoration);
    expect(built.prefixMode, defaults.prefixMode);
    expect(built.suffixMode, defaults.suffixMode);
    expect(built.crossAxisAlignment, defaults.crossAxisAlignment);
    expect(built.maxLines, defaults.maxLines);
    expect(built.minLines, defaults.minLines);
    expect(built.expands, defaults.expands);
    expect(built.obscuringCharacter, defaults.obscuringCharacter);
    expect(built.readOnly, defaults.readOnly);
    expect(
      built.enableInteractiveSelection,
      defaults.enableInteractiveSelection,
    );
    expect(built.cursorWidth, defaults.cursorWidth);
    expect(built.cursorRadius, defaults.cursorRadius);
  });

  test('obscureText は maxLines が 1 のときだけ渡す（SDK の assert）', () {
    final settings = {
      ...allOff(cupertinoTextFieldEntry),
      'obscureText': const PropertySetting(on: true, value: SwitchValue(true)),
      // maxLines の選択肢の 2 つ目（3 行）
      'maxLines': const PropertySetting(on: true, value: ChoiceValue(1)),
    };
    final box = cupertinoTextFieldEntry.build(
      DemoArgs(cupertinoTextFieldEntry, settings),
    ) as SizedBox;
    final built = box.child! as CupertinoTextField;

    expect(built.obscureText, isFalse);
    expect(built.maxLines, 3);
  });
}
