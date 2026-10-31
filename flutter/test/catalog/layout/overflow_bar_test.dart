import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/overflow_bar.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら OverflowBar の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, overflowBarEntry);
    final built = demoWidget<OverflowBar>(tester);

    expect(built.spacing, 0);
    expect(built.alignment, isNull);
    expect(built.overflowSpacing, 0);
    expect(built.overflowAlignment, OverflowBarAlignment.start);
    expect(built.overflowDirection, VerticalDirection.down);
    expect(built.textDirection, isNull);
    expect(built.children, isEmpty);
  });
}
