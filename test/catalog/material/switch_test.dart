import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/switch.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Switch の既定値（押せない・アイコンなし）で組み立てる', () {
    final built = switchEntry.build(DemoArgs(switchEntry, allOff(switchEntry)));
    final widget = built as Switch;

    // value は必須なので OFF にしても渡る
    expect(widget.value, isTrue);
    expect(widget.onChanged, isNull);
    expect(widget.activeThumbColor, isNull);
    expect(widget.activeTrackColor, isNull);
    expect(widget.thumbIcon, isNull);
  });
}
