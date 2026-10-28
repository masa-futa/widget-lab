import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/stack.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Stack の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, stackEntry);
    final built = demoWidget<Stack>(tester);

    expect(built.alignment, AlignmentDirectional.topStart);
    expect(built.fit, StackFit.loose);
    expect(built.children, isEmpty);
  });
}
