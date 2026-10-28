import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/scrolling/nested_scroll_view.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら NestedScrollView の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, nestedScrollViewEntry);
    final built = demoWidget<NestedScrollView>(tester);

    expect(built.floatHeaderSlivers, isFalse);
  });
}
