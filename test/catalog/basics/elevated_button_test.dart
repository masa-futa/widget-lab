import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/elevated_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら ElevatedButton の既定値（押せない・style なし）で組み立てる', () {
    final button = elevatedButtonEntry.build(
      DemoArgs(elevatedButtonEntry, allOff(elevatedButtonEntry)),
    ) as ElevatedButton;

    expect(button.onPressed, isNull);
    expect(button.enabled, isFalse);
    expect(button.style, isNull);
    // child は必須なので OFF にしても渡る
    expect(button.child, isA<Text>());
  });
}
