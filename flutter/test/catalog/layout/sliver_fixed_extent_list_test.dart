import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_fixed_extent_list.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverFixedExtentList の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, sliverFixedExtentListEntry);
    final built = demoWidget<SliverFixedExtentList>(tester);

    // itemExtent・delegate は必須なので最初の値
    expect(built.itemExtent, 40);
    expect(built.delegate, isA<SliverChildBuilderDelegate>());
  });
}
