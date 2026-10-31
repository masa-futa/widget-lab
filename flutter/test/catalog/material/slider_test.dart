import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/slider.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Slider の既定値（動かせない・段なし）で組み立てる', () {
    final built = sliderEntry.build(DemoArgs(sliderEntry, allOff(sliderEntry)));
    final slider = built as Slider;

    // value は必須なので OFF にしても渡る
    expect(slider.value, 0.4);
    expect(slider.onChanged, isNull);
    expect(slider.divisions, isNull);
    expect(slider.activeColor, isNull);
    expect(slider.inactiveColor, isNull);
  });
}
