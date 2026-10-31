import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/custom_multi_child_layout.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CustomMultiChildLayout の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, customMultiChildLayoutEntry);
    final built = demoWidget<CustomMultiChildLayout>(tester);

    expect(built.children, isEmpty);
  });
}
