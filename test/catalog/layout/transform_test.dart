import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/transform.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Transform の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, transformEntry);
    final built = demoWidget<Transform>(tester);

    expect(built.transform, Matrix4.identity());
    expect(built.alignment, isNull);
    expect(built.child, isNull);
  });
}
