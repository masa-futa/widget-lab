import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/common_buttons.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら FilledButton の既定値（押せない・style なし）で組み立てる', () {
    final button = commonButtonsEntry.build(
      DemoArgs(commonButtonsEntry, allOff(commonButtonsEntry)),
    ) as FilledButton;

    expect(button.onPressed, isNull);
    expect(button.enabled, isFalse);
    expect(button.style, isNull);
    // child は必須なので OFF にしても渡る
    expect(button.child, isA<Text>());
  });
}
