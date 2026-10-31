import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/fitted_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら FittedBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, fittedBoxEntry);
    final built = demoWidget<FittedBox>(tester);

    expect(built.fit, BoxFit.contain);
    expect(built.alignment, Alignment.center);
    expect(built.clipBehavior, Clip.none);
    expect(built.child, isNull);
  });
}
