import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/align.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Align の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, alignEntry);
    final built = demoWidget<Align>(tester);

    expect(built.alignment, Alignment.center);
    expect(built.widthFactor, isNull);
    expect(built.heightFactor, isNull);
    expect(built.child, isNull);
  });
}
