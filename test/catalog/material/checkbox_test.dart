import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/checkbox.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Checkbox の既定値（押せない・誤りでない）で組み立てる', () {
    final built = checkboxEntry.build(
      DemoArgs(checkboxEntry, allOff(checkboxEntry)),
    );
    final checkbox = built as Checkbox;

    // value は必須なので OFF にしても渡る
    expect(checkbox.value, isTrue);
    expect(checkbox.onChanged, isNull);
    expect(checkbox.activeColor, isNull);
    expect(checkbox.checkColor, isNull);
    expect(checkbox.isError, isFalse);
  });
}
