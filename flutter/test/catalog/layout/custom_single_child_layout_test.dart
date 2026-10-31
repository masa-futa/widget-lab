import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/custom_single_child_layout.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CustomSingleChildLayout の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, customSingleChildLayoutEntry);
    final built = demoWidget<CustomSingleChildLayout>(tester);

    expect(built.child, isNull);
  });
}
