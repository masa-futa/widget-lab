import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/center.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Center の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, centerEntry);
    final built = demoWidget<Center>(tester);

    expect(built.widthFactor, isNull);
    expect(built.heightFactor, isNull);
    expect(built.child, isNull);
  });
}
