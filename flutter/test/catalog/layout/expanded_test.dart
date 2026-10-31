import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/expanded.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Expanded の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, expandedEntry);
    final built = demoWidget<Expanded>(tester);

    expect(built.flex, 1);
  });
}
