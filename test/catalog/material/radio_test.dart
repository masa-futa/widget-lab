import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/radio.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Radio の既定値で組み立て、RadioGroup の下に置く', () {
    final built = radioEntry.build(DemoArgs(radioEntry, allOff(radioEntry)));
    final group = built as RadioGroup<int>;
    final radio = group.child as Radio<int>;

    // value は必須なので OFF にしても渡る
    expect(radio.value, 1);
    expect(group.groupValue, 1);
    expect(radio.enabled, isNull);
    expect(radio.activeColor, isNull);
    expect(radio.toggleable, isFalse);
  });
}
