import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/list_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら ListTile の既定値（中身なし・押せない・選んでいない）で組み立てる', () {
    final box = listTileEntry.build(
      DemoArgs(listTileEntry, allOff(listTileEntry)),
    ) as SizedBox;
    final tile = _find<ListTile>(box);

    expect(tile.leading, isNull);
    expect(tile.title, isNull);
    expect(tile.subtitle, isNull);
    expect(tile.trailing, isNull);
    expect(tile.onTap, isNull);
    expect(tile.selected, isFalse);
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
