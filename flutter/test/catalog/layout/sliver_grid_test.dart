import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_grid.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverGrid の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sliverGridEntry);
    final built = demoWidget<SliverGrid>(tester);

    // gridDelegate・delegate は必須なので最初の値
    final grid =
        built.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(grid.crossAxisCount, 4);
  });
}
