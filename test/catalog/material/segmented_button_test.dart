import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/segmented_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test(
    'TC-18: 全部 OFF なら SegmentedButton の既定値（押せない・1 つだけ選ぶ・チェックの印あり）で組み立てる',
    () {
      final button = segmentedButtonEntry.build(
        DemoArgs(segmentedButtonEntry, allOff(segmentedButtonEntry)),
      ) as SegmentedButton<String>;

      expect(button.segments, hasLength(3));
      expect(button.selected, {'day'});
      expect(button.onSelectionChanged, isNull);
      expect(button.multiSelectionEnabled, isFalse);
      expect(button.showSelectedIcon, isTrue);
    },
  );
}
