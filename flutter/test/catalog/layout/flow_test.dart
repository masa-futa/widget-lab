import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/flow.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Flow の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, flowEntry);
    final built = demoWidget<Flow>(tester);

    expect(built.children, isEmpty);
  });
}
