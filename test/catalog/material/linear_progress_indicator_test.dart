import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/linear_progress_indicator.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら LinearProgressIndicator の既定値（流れ続ける）で組み立てる', () {
    final box = linearProgressIndicatorEntry.build(
      DemoArgs(
        linearProgressIndicatorEntry,
        allOff(linearProgressIndicatorEntry),
      ),
    ) as SizedBox;
    final indicator = _find<LinearProgressIndicator>(box);

    expect(indicator.value, isNull);
    expect(indicator.minHeight, isNull);
    expect(indicator.color, isNull);
    expect(indicator.borderRadius, isNull);
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
