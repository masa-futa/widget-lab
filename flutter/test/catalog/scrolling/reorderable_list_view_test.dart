import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/scrolling/reorderable_list_view.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら ReorderableListView の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, reorderableListViewEntry);
    final built = demoWidget<ReorderableListView>(tester);

    expect(built.buildDefaultDragHandles, isTrue);
    expect(built.scrollDirection, Axis.vertical);
  });

  testWidgets('ReorderableListView: 落とすと、並べ替えた順で組み直す', (tester) async {
    await pumpEntry(tester, reorderableListViewEntry);

    // 1 番目（1）を、抜いた後の 2 番目へ
    demoWidget<ReorderableListView>(tester).onReorderItem!(0, 2);
    await tester.pump();

    final order = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    expect(order, ['2', '3', '1', '4', '5']);
  });
}
