import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/text_field.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら TextField の既定値（下線だけ・隠さない・上限なし）で組み立てる', () {
    final built = textFieldEntry.build(
      DemoArgs(textFieldEntry, allOff(textFieldEntry)),
    );
    final field = built as TextField;

    expect(field.decoration, const InputDecoration());
    expect(field.enabled, isNull);
    expect(field.obscureText, isFalse);
    expect(field.maxLength, isNull);
    expect(field.textAlign, TextAlign.start);
  });
}
