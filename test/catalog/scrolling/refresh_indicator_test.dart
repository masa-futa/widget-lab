import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/scrolling/refresh_indicator.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら RefreshIndicator の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, refreshIndicatorEntry);
    final built = demoWidget<RefreshIndicator>(tester);

    expect(built.color, isNull);
    expect(built.displacement, 40);
  });
}
