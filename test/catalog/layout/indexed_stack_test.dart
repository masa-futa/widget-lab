import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/indexed_stack.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら IndexedStack の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, indexedStackEntry);
    final built = demoWidget<IndexedStack>(tester);

    expect(built.index, 0);
    expect(built.alignment, AlignmentDirectional.topStart);
    expect(built.sizing, StackFit.loose);
    expect(built.children, isEmpty);
  });
}
