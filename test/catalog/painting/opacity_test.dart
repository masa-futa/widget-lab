import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/opacity.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Opacity の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, opacityEntry);
    final built = demoWidget<Opacity>(tester);

    expect(built.opacity, 1.0);
    expect(built.child, isNull);
  });
}
