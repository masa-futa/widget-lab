import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/grid_view.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら GridView の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, gridViewEntry);
    final built = demoWidget<GridView>(tester);

    final grid =
        built.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(grid.mainAxisSpacing, 0);
    expect(grid.crossAxisSpacing, 0);
    expect(built.scrollDirection, Axis.vertical);
  });
}
