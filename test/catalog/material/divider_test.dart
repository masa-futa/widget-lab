import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/divider.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Divider の既定値で組み立てる', () {
    final stage = dividerEntry.build(
      DemoArgs(dividerEntry, allOff(dividerEntry)),
    ) as DemoStage;
    final divider = _find<Divider>(stage);

    expect(divider.height, isNull);
    expect(divider.thickness, isNull);
    expect(divider.indent, isNull);
    expect(divider.endIndent, isNull);
    expect(divider.color, isNull);
  });
}

/// デモの包み（DemoStage・SizedBox・Material）の中から [T] を探す。
T _find<T extends Widget>(Widget widget) => switch (widget) {
  T() => widget,
  DemoStage(:final child) => _find<T>(child),
  SingleChildRenderObjectWidget(:final child?) => _find<T>(child),
  Material(:final child?) => _find<T>(child),
  Column(:final children) => children.whereType<T>().single,
  _ => throw StateError('$T が見つからない: $widget'),
};
