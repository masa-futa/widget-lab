import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/scrolling/single_child_scroll_view.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SingleChildScrollView の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, singleChildScrollViewEntry);
    final built = demoWidget<SingleChildScrollView>(tester);

    expect(built.padding, isNull);
    expect(built.reverse, isFalse);
    expect(built.physics, isNull);
    expect(built.child, isNull);
  });
}
