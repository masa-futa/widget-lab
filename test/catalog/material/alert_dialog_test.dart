import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/alert_dialog.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AlertDialog の既定値（中身なし）で組み立てる', () {
    final stage = alertDialogEntry.build(
      DemoArgs(alertDialogEntry, allOff(alertDialogEntry)),
    ) as DemoStage;
    final dialog = _find<AlertDialog>(stage);

    expect(dialog.icon, isNull);
    expect(dialog.title, isNull);
    expect(dialog.content, isNull);
    expect(dialog.actions, isNull);
    expect(dialog.actionsAlignment, isNull);
    expect(dialog.backgroundColor, isNull);
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
