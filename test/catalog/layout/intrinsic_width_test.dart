import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/intrinsic_width.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら IntrinsicWidth の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, intrinsicWidthEntry);
    final built = demoWidget<IntrinsicWidth>(tester);

    expect(built.stepWidth, isNull);
    expect(built.stepHeight, isNull);
    expect(built.child, isNull);
  });
}
