import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/custom_scroll_view.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CustomScrollView の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, customScrollViewEntry);
    final built = demoWidget<CustomScrollView>(tester);

    expect(built.scrollDirection, Axis.vertical);
    expect(built.reverse, isFalse);
    expect(built.slivers, isEmpty);
  });
}
