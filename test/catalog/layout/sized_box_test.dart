import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sized_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SizedBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sizedBoxEntry);
    final built = demoWidget<SizedBox>(tester);

    expect(built.width, isNull);
    expect(built.height, isNull);
    expect(built.child, isNull);
  });
}
