import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/custom_paint.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CustomPaint の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, customPaintEntry);
    final built = demoWidget<CustomPaint>(tester);

    expect(built.painter, isNull);
    expect(built.foregroundPainter, isNull);
    expect(built.size, Size.zero);
    expect(built.child, isNull);
  });
}
