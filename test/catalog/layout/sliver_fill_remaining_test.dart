import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_fill_remaining.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverFillRemaining の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, sliverFillRemainingEntry);
    final built = demoWidget<SliverFillRemaining>(tester);

    expect(built.hasScrollBody, isTrue);
    expect(built.fillOverscroll, isFalse);
    expect(built.child, isNull);
  });
}
