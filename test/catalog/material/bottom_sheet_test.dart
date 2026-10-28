import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/bottom_sheet.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら BottomSheet の既定値（引ける印なし・引いて閉じられる）で組み立てる', () {
    final box = bottomSheetEntry.build(
      DemoArgs(bottomSheetEntry, allOff(bottomSheetEntry)),
    ) as SizedBox;
    final sheet = _find<BottomSheet>(box);

    expect(sheet.showDragHandle, isNull);
    expect(sheet.enableDrag, isTrue);
    expect(sheet.backgroundColor, isNull);
    expect(sheet.elevation, isNull);
  });
}

/// デモの包み（DemoStage・SizedBox・Material）の中から [T] を探す。
T _find<T extends Widget>(Widget widget) => switch (widget) {
  T() => widget,
  SingleChildRenderObjectWidget(:final child?) => _find<T>(child),
  Material(:final child?) => _find<T>(child),
  Column(:final children) => children.whereType<T>().single,
  _ => throw StateError('$T が見つからない: $widget'),
};
