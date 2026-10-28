import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/chip.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Chip の既定値（avatar・消すボタンなし）で組み立てる', () {
    final built = chipEntry.build(DemoArgs(chipEntry, allOff(chipEntry)));
    final chip = built as Chip;

    expect(chip.label, isA<Text>());
    expect(chip.avatar, isNull);
    expect(chip.onDeleted, isNull);
    expect(chip.backgroundColor, isNull);
    expect(chip.elevation, isNull);
  });
}
