import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/scrollable.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Scrollable の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, scrollableEntry);
    final built = demoWidget<Scrollable>(tester);

    expect(built.axisDirection, AxisDirection.down);
    expect(built.physics, isNull);
  });

  testWidgets('Scrollable: Viewport は上の Scrollable と同じ向きに並べる', (tester) async {
    await pumpEntry(tester, scrollableEntry, scrollableEntry.initialSettings());

    expect(demoWidget<Viewport>(tester).axisDirection, AxisDirection.right);
  });
}
