import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/baseline.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Baseline の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, baselineEntry);
    final built = demoWidget<Baseline>(tester);

    // baseline・baselineType は必須なので最初の値
    expect(built.baseline, 40.0);
    expect(built.baselineType, TextBaseline.alphabetic);
    expect(built.child, isNull);
  });
}
