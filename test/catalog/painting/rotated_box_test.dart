import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/rotated_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら RotatedBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, rotatedBoxEntry);
    final built = demoWidget<RotatedBox>(tester);

    expect(built.quarterTurns, 0);
    expect(built.child, isNull);
  });
}
