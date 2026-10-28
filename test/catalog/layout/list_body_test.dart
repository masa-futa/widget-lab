import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/list_body.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら ListBody の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, listBodyEntry);
    final built = demoWidget<ListBody>(tester);

    expect(built.mainAxis, Axis.vertical);
    expect(built.reverse, isFalse);
    expect(built.children, isEmpty);
  });
}
