import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/constrained_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら ConstrainedBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, constrainedBoxEntry);
    final built = demoWidget<ConstrainedBox>(tester);

    expect(built.constraints, const BoxConstraints());
    expect(built.child, isNull);
  });
}
