import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/overflow_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら OverflowBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, overflowBoxEntry);
    final built = demoWidget<OverflowBox>(tester);

    expect(built.minWidth, isNull);
    expect(built.minHeight, isNull);
    expect(built.maxWidth, isNull);
    expect(built.maxHeight, isNull);
    expect(built.alignment, Alignment.center);
    expect(built.child, isNull);
  });
}
