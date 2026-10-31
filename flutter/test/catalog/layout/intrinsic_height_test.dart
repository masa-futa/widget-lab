import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/intrinsic_height.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら IntrinsicHeight の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, intrinsicHeightEntry);
    final built = demoWidget<IntrinsicHeight>(tester);

    expect(built.child, isNull);
  });
}
