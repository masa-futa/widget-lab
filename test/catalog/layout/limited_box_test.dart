import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/limited_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら LimitedBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, limitedBoxEntry);
    final built = demoWidget<LimitedBox>(tester);

    expect(built.maxWidth, double.infinity);
    expect(built.maxHeight, double.infinity);
    expect(built.child, isNull);
  });
}
