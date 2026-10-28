import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/fractionally_sized_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら FractionallySizedBox の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, fractionallySizedBoxEntry);
    final built = demoWidget<FractionallySizedBox>(tester);

    expect(built.widthFactor, isNull);
    expect(built.heightFactor, isNull);
    expect(built.alignment, Alignment.center);
    expect(built.child, isNull);
  });
}
